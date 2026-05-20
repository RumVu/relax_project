import {
  Injectable,
  Logger,
  OnApplicationBootstrap,
  OnApplicationShutdown,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Worker } from 'bullmq';
import { randomUUID } from 'node:crypto';
import { MoodCheckinsService } from '../mood-checkins/mood-checkins.service';
import { PrismaService } from '../prisma/prisma.service';
import { QueuesService } from '../queues/queues.service';
import { RedisService } from '../redis/redis.service';
import { RunWeeklyMoodStatsJobDto } from './dto/run-weekly-mood-stats-job.dto';

const WEEKLY_MOOD_STATS_QUEUE = 'weekly-mood-stats';
const WEEKLY_MOOD_STATS_JOB = 'recalculate-weekly-mood-stats';
const WEEKLY_MOOD_STATS_LOCK_KEY = 'jobs:weekly-mood-stats:lock';

@Injectable()
export class JobsService
  implements OnApplicationBootstrap, OnApplicationShutdown
{
  private readonly logger = new Logger(JobsService.name);
  private weeklyMoodStatsTimer?: NodeJS.Timeout;
  private weeklyMoodStatsWorker?: Worker<
    RunWeeklyMoodStatsJobDto,
    Awaited<ReturnType<JobsService['runWeeklyMoodStats']>>,
    string
  >;
  private lastWeeklyMoodStatsRun?: {
    startedAt: Date;
    finishedAt: Date;
    processedUsers: number;
    failedUsers: number;
  };

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
    private readonly moodCheckinsService: MoodCheckinsService,
    private readonly queuesService: QueuesService,
    private readonly redisService: RedisService,
  ) {}

  onApplicationBootstrap() {
    if (this.isWeeklyMoodStatsQueueWorkerEnabled()) {
      this.startWeeklyMoodStatsQueueWorker();
    }

    if (!this.isWeeklyMoodStatsJobEnabled()) {
      return;
    }

    const intervalMs = this.getWeeklyMoodStatsIntervalMs();
    this.weeklyMoodStatsTimer = setInterval(() => {
      void this.runWeeklyMoodStats({});
    }, intervalMs);
    this.weeklyMoodStatsTimer.unref();
    this.logger.log(`Weekly mood stats job enabled every ${intervalMs}ms`);
  }

  async onApplicationShutdown() {
    if (this.weeklyMoodStatsTimer) {
      clearInterval(this.weeklyMoodStatsTimer);
    }

    if (this.weeklyMoodStatsWorker) {
      await this.weeklyMoodStatsWorker.close();
      this.weeklyMoodStatsWorker = undefined;
    }
  }

  getStatus() {
    return {
      weeklyMoodStats: {
        enabled: this.isWeeklyMoodStatsJobEnabled(),
        intervalMs: this.getWeeklyMoodStatsIntervalMs(),
        batchSize: this.getWeeklyMoodStatsBatchSize(),
        queue: {
          name: WEEKLY_MOOD_STATS_QUEUE,
          jobName: WEEKLY_MOOD_STATS_JOB,
          workerEnabled: this.isWeeklyMoodStatsQueueWorkerEnabled(),
          workerConcurrency: this.getWeeklyMoodStatsQueueWorkerConcurrency(),
        },
        lastRun: this.lastWeeklyMoodStatsRun ?? null,
      },
    };
  }

  enqueueWeeklyMoodStats(dto: RunWeeklyMoodStatsJobDto) {
    return this.queuesService.add<RunWeeklyMoodStatsJobDto>(
      WEEKLY_MOOD_STATS_QUEUE,
      WEEKLY_MOOD_STATS_JOB,
      dto,
    );
  }

  async runWeeklyMoodStats(dto: RunWeeklyMoodStatsJobDto) {
    const startedAt = new Date();
    const lockValue = randomUUID();
    const lockAcquired = await this.redisService.acquireLock(
      this.getWeeklyMoodStatsLockKey(dto),
      lockValue,
      this.getWeeklyMoodStatsLockTtlSeconds(),
    );

    if (!lockAcquired) {
      const finishedAt = new Date();
      return {
        job: 'weekly-mood-stats',
        startedAt,
        finishedAt,
        skipped: true,
        skipReason: 'LOCK_NOT_ACQUIRED',
        processedUsers: 0,
        failedUsers: 0,
        results: [],
        errors: [],
      };
    }

    const results: unknown[] = [];
    const errors: Array<{ userId: string; message: string }> = [];
    let processedUsers = 0;
    let cursorId: string | undefined;
    let batches = 0;

    try {
      while (true) {
        const remainingLimit =
          typeof dto.limit === 'number' ? dto.limit - processedUsers : null;
        if (remainingLimit !== null && remainingLimit <= 0) {
          break;
        }

        const users = await this.findWeeklyMoodStatUsers(
          dto,
          cursorId,
          remainingLimit,
        );
        if (users.length === 0) {
          break;
        }

        batches += 1;
        cursorId = users.at(-1)?.id;

        for (const user of users) {
          try {
            results.push(
              await this.moodCheckinsService.recalculateWeeklyStats(user.id, {
                from: dto.from,
                to: dto.to,
                timezone:
                  dto.timezone ?? user.preferences?.timezone ?? undefined,
              }),
            );
          } catch (error) {
            errors.push({
              userId: user.id,
              message: this.errorMessage(error),
            });
          } finally {
            processedUsers += 1;
          }
        }

        if (dto.userId || users.length < this.getWeeklyMoodStatsBatchSize()) {
          break;
        }
      }
    } finally {
      await this.redisService.releaseLock(
        this.getWeeklyMoodStatsLockKey(dto),
        lockValue,
      );
    }

    const finishedAt = new Date();
    this.lastWeeklyMoodStatsRun = {
      startedAt,
      finishedAt,
      processedUsers,
      failedUsers: errors.length,
    };

    return {
      job: 'weekly-mood-stats',
      startedAt,
      finishedAt,
      skipped: false,
      processedUsers,
      failedUsers: errors.length,
      batches,
      results,
      errors,
    };
  }

  private findWeeklyMoodStatUsers(
    dto: RunWeeklyMoodStatsJobDto,
    cursorId?: string,
    remainingLimit?: number | null,
  ) {
    const take = Math.min(
      this.getWeeklyMoodStatsBatchSize(),
      remainingLimit ?? this.getWeeklyMoodStatsBatchSize(),
    );

    return this.prisma.user.findMany({
      where: dto.userId
        ? { id: dto.userId, isActive: true, deletedAt: null }
        : { isActive: true, deletedAt: null },
      select: { id: true, preferences: { select: { timezone: true } } },
      orderBy: { id: 'asc' },
      ...(cursorId && !dto.userId
        ? {
            cursor: { id: cursorId },
            skip: 1,
          }
        : {}),
      take: dto.userId ? 1 : take,
    });
  }

  private isWeeklyMoodStatsJobEnabled() {
    return (
      this.configService.get<string>('WEEKLY_STATS_JOB_ENABLED') === 'true'
    );
  }

  private getWeeklyMoodStatsIntervalMs() {
    return Number(
      this.configService.get<string>('WEEKLY_STATS_JOB_INTERVAL_MS') ??
        1000 * 60 * 60 * 6,
    );
  }

  private getWeeklyMoodStatsBatchSize() {
    return Number(
      this.configService.get<string>('WEEKLY_STATS_JOB_BATCH_SIZE') ?? 500,
    );
  }

  private getWeeklyMoodStatsLockTtlSeconds() {
    return Number(
      this.configService.get<string>('WEEKLY_STATS_JOB_LOCK_TTL_SECONDS') ??
        60 * 60,
    );
  }

  private getWeeklyMoodStatsLockKey(dto: RunWeeklyMoodStatsJobDto) {
    return dto.userId
      ? `${WEEKLY_MOOD_STATS_LOCK_KEY}:user:${dto.userId}`
      : `${WEEKLY_MOOD_STATS_LOCK_KEY}:all`;
  }

  private startWeeklyMoodStatsQueueWorker() {
    try {
      this.weeklyMoodStatsWorker = this.queuesService.createWorker<
        RunWeeklyMoodStatsJobDto,
        Awaited<ReturnType<JobsService['runWeeklyMoodStats']>>
      >(
        WEEKLY_MOOD_STATS_QUEUE,
        async (job) => this.runWeeklyMoodStats(job.data),
        {
          concurrency: this.getWeeklyMoodStatsQueueWorkerConcurrency(),
        },
      );

      this.logger.log(
        `Weekly mood stats queue worker enabled with concurrency ${this.getWeeklyMoodStatsQueueWorkerConcurrency()}`,
      );
    } catch (error) {
      this.logger.warn(
        `Weekly mood stats queue worker disabled: ${this.errorMessage(error)}`,
      );
    }
  }

  private isWeeklyMoodStatsQueueWorkerEnabled() {
    return (
      this.configService.get<string>('WEEKLY_STATS_QUEUE_WORKER_ENABLED') ===
      'true'
    );
  }

  private getWeeklyMoodStatsQueueWorkerConcurrency() {
    return Number(
      this.configService.get<string>('WEEKLY_STATS_QUEUE_WORKER_CONCURRENCY') ??
        2,
    );
  }

  private errorMessage(error: unknown) {
    if (error instanceof Error) {
      return error.message;
    }
    return String(error);
  }
}
