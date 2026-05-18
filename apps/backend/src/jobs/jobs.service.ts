import {
  Injectable,
  Logger,
  OnApplicationBootstrap,
  OnApplicationShutdown,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { MoodCheckinsService } from '../mood-checkins/mood-checkins.service';
import { PrismaService } from '../prisma/prisma.service';
import { RunWeeklyMoodStatsJobDto } from './dto/run-weekly-mood-stats-job.dto';

@Injectable()
export class JobsService
  implements OnApplicationBootstrap, OnApplicationShutdown
{
  private readonly logger = new Logger(JobsService.name);
  private weeklyMoodStatsTimer?: NodeJS.Timeout;
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
  ) {}

  onApplicationBootstrap() {
    if (!this.isWeeklyMoodStatsJobEnabled()) {
      return;
    }

    const intervalMs = this.getWeeklyMoodStatsIntervalMs();
    this.weeklyMoodStatsTimer = setInterval(() => {
      void this.runWeeklyMoodStats({
        limit: this.getWeeklyMoodStatsBatchSize(),
      });
    }, intervalMs);
    this.weeklyMoodStatsTimer.unref();
    this.logger.log(`Weekly mood stats job enabled every ${intervalMs}ms`);
  }

  onApplicationShutdown() {
    if (this.weeklyMoodStatsTimer) {
      clearInterval(this.weeklyMoodStatsTimer);
    }
  }

  getStatus() {
    return {
      weeklyMoodStats: {
        enabled: this.isWeeklyMoodStatsJobEnabled(),
        intervalMs: this.getWeeklyMoodStatsIntervalMs(),
        batchSize: this.getWeeklyMoodStatsBatchSize(),
        lastRun: this.lastWeeklyMoodStatsRun ?? null,
      },
    };
  }

  async runWeeklyMoodStats(dto: RunWeeklyMoodStatsJobDto) {
    const startedAt = new Date();
    const users = dto.userId
      ? await this.prisma.user.findMany({
          where: { id: dto.userId, isActive: true, deletedAt: null },
          select: { id: true, preferences: { select: { timezone: true } } },
          take: 1,
        })
      : await this.prisma.user.findMany({
          where: { isActive: true, deletedAt: null },
          select: { id: true, preferences: { select: { timezone: true } } },
          orderBy: { updatedAt: 'desc' },
          take: dto.limit ?? this.getWeeklyMoodStatsBatchSize(),
        });
    const results: unknown[] = [];
    const errors: Array<{ userId: string; message: string }> = [];

    for (const user of users) {
      try {
        results.push(
          await this.moodCheckinsService.recalculateWeeklyStats(user.id, {
            from: dto.from,
            to: dto.to,
            timezone: dto.timezone ?? user.preferences?.timezone ?? undefined,
          }),
        );
      } catch (error) {
        errors.push({
          userId: user.id,
          message: error instanceof Error ? error.message : 'Unknown error',
        });
      }
    }

    const finishedAt = new Date();
    this.lastWeeklyMoodStatsRun = {
      startedAt,
      finishedAt,
      processedUsers: users.length,
      failedUsers: errors.length,
    };

    return {
      job: 'weekly-mood-stats',
      startedAt,
      finishedAt,
      processedUsers: users.length,
      failedUsers: errors.length,
      results,
      errors,
    };
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
}
