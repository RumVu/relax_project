import { Injectable } from '@nestjs/common';
import { RelaxActivityType, RelaxSessionStatus } from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { buildPage } from '../common/pagination/page';
import {
  createTimezoneContext,
  getTimezoneContextOffsetMinutes,
  normalizeTimezone,
} from '../common/timezone';
import { MoodCheckinsService } from '../mood-checkins/mood-checkins.service';
import { scoreFromMood } from '../mood-checkins/helpers/mood-scoring';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeService } from '../realtime/realtime.service';
import { UsersService } from '../users/users.service';
import { FinishRelaxSessionDto } from './dto/finish-relax-session.dto';
import {
  RelaxActivityQueryDto,
  RelaxStatsPeriod,
} from './dto/relax-activity-query.dto';
import { StartRelaxSessionDto } from './dto/start-relax-session.dto';
import {
  getRelaxActivityOption,
  RELAX_ACTIVITY_OPTIONS,
} from './relax-activity-options';

import { getNextSuggestion, toSessionPayload } from './helpers/relax-mapper';
import {
  getStressReliefPercent,
  resolveDurationSeconds,
} from './helpers/relax-scoring';
import {
  RelaxRange,
  formatDuration,
  resolveRelaxRange,
} from './helpers/relax-time';
import {
  buildFavoriteActivities,
  buildReliefSummary,
  buildTimeline,
  calculateActivityStreak,
} from './analytics/relax-analytics.helper';

/**
 * RelaxActivitiesService — orchestrator mỏng.
 *
 * Pure logic đã tách:
 *   - helpers/relax-scoring.ts          stress-relief %, duration cap
 *   - helpers/relax-time.ts             range/day enum, duration label
 *   - helpers/relax-mapper.ts           RelaxSession → API payload
 *   - analytics/relax-analytics.helper  favorite activities, timeline,
 *                                       relief summary, streak
 *
 * Service giữ: CRUD trên Prisma + emit realtime + orchestrate post-finish
 * mood check-in qua MoodCheckinsService.
 */
@Injectable()
export class RelaxActivitiesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
    private readonly moodCheckinsService: MoodCheckinsService,
    private readonly realtime: RealtimeService,
  ) {}

  // ============================================================
  // READ
  // ============================================================

  async getActivities() {
    const [sounds, breathingExercises] = await Promise.all([
      this.prisma.ambientSound.findMany({
        where: { isActive: true },
        orderBy: [{ category: 'asc' }, { title: 'asc' }],
      }),
      this.prisma.breathingExercise.findMany({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
        take: 5,
      }),
    ]);

    return RELAX_ACTIVITY_OPTIONS.map((option) => ({
      ...option,
      resources:
        option.type === RelaxActivityType.MUSIC
          ? sounds
          : option.type === RelaxActivityType.BREATHING
            ? breathingExercises
            : [],
    }));
  }

  async listSessions(userId: string, query: RelaxActivityQueryDto) {
    await this.usersService.findOne(userId);
    const where = this.buildFinishedSessionWhere(userId, query);
    const [sessions, total] = await Promise.all([
      this.prisma.relaxSession.findMany({
        where,
        orderBy: { endedAt: 'desc' },
        skip: query.skip,
        take: query.limit ?? 50,
      }),
      this.prisma.relaxSession.count({ where }),
    ]);

    return buildPage(
      sessions.map((session) => toSessionPayload(session)),
      total,
      query,
    );
  }

  async getStats(userId: string, query: RelaxActivityQueryDto) {
    await this.usersService.findOne(userId);
    const timezone = await this.resolveTimezone(userId, query.timezone);
    const timezoneContext = createTimezoneContext(
      timezone,
      query.timezoneOffsetMinutes,
    );
    const range = resolveRelaxRange(query, timezoneContext);
    const sessions = await this.findFinishedSessions(userId, {
      ...query,
      from: range.from,
      to: range.to,
      limit: 100,
    });
    const payloads = sessions.map((session) => toSessionPayload(session));
    const totalDurationSeconds = payloads.reduce(
      (sum, session) => sum + session.durationSeconds,
      0,
    );

    return {
      period: query.period ?? RelaxStatsPeriod.WEEK,
      range,
      timezone,
      timezoneOffsetMinutes: getTimezoneContextOffsetMinutes(timezoneContext),
      streak: calculateActivityStreak(payloads, timezoneContext),
      totalDurationSeconds,
      totalDurationLabel: formatDuration(totalDurationSeconds),
      totalSessions: payloads.length,
      favoriteActivities: buildFavoriteActivities(payloads),
      recentMoments: payloads.slice(0, query.limit ?? 5),
      timeline: buildTimeline(payloads, range, timezoneContext),
      relief: buildReliefSummary(payloads),
    };
  }

  // ============================================================
  // WRITE
  // ============================================================

  async startSession(userId: string, dto: StartRelaxSessionDto) {
    await this.usersService.findOne(userId);
    const option = getRelaxActivityOption(dto.activityType);

    if (!option) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'Invalid relax activity type',
      );
    }

    const session = await this.prisma.relaxSession.create({
      data: {
        userId,
        activityType: dto.activityType,
        resourceId: dto.resourceId,
        title: dto.title ?? option.title,
        moodBefore: dto.moodBefore,
        startedAt: new Date(),
      },
    });

    return { ...toSessionPayload(session), activity: option };
  }

  async finishSession(
    userId: string,
    sessionId: string,
    dto: FinishRelaxSessionDto,
  ) {
    await this.usersService.findOne(userId);
    const started = await this.findStartedSession(userId, sessionId);
    const endedAt = new Date();
    const durationSeconds = resolveDurationSeconds(started.startedAt, endedAt);
    const activityType = started.activityType;
    const option = getRelaxActivityOption(activityType);
    const stressReliefPercent = getStressReliefPercent(
      dto.reliefLevel,
      started.moodBefore ?? undefined,
      dto.moodAfter,
    );

    const session = await this.prisma.relaxSession.update({
      where: { id: sessionId },
      data: {
        status: RelaxSessionStatus.FINISHED,
        endedAt,
        duration: durationSeconds,
        moodAfter: dto.moodAfter,
        reliefLevel: dto.reliefLevel,
        stressReliefPercent,
        note: dto.note,
        nextActionAccepted: dto.nextActionAccepted,
      },
    });

    this.realtime.emitToUser(userId, 'relax-session.updated', {
      id: session.id,
      activityType,
      status: session.status,
      durationSeconds,
    });

    // Side-effect: write a mood check-in derived from this session so
    // dashboards reflect "post-relax mood" automatically.
    if (dto.moodAfter) {
      await this.moodCheckinsService.create(userId, {
        mood: dto.moodAfter,
        intensity: dto.reliefLevel,
        rawScore: scoreFromMood(started.moodBefore ?? dto.moodAfter),
        finalScore: scoreFromMood(dto.moodAfter),
        scoredAt: endedAt,
        note: dto.note,
        tags: ['relax-finish', activityType.toLowerCase(), session.id],
        checkedAt: endedAt,
        allowSystemScoring: true,
      });
    }

    return {
      ...toSessionPayload(session),
      activity: option,
      postCheckin: {
        title: stressReliefPercent > 0 ? 'Mức độ giảm tải' : 'Có lên nhé!',
        stressReliefPercent,
        message:
          stressReliefPercent > 0
            ? `Mình thấy bạn đã giảm stress khoảng ${stressReliefPercent}% rồi nè!`
            : 'Chúc bạn hoàn thành được việc tiếp theo nha.',
      },
      nextSuggestion: getNextSuggestion(activityType),
    };
  }

  // ============================================================
  // PRIVATE — DB-aware helpers
  // ============================================================

  private async resolveTimezone(userId: string, timezone?: string) {
    if (timezone) return normalizeTimezone(timezone);

    const preferences = await this.prisma.userPreference.findUnique({
      where: { userId },
      select: { timezone: true },
    });

    return normalizeTimezone(preferences?.timezone);
  }

  private async findStartedSession(userId: string, sessionId: string) {
    const session = await this.prisma.relaxSession.findFirst({
      where: { id: sessionId, userId, status: RelaxSessionStatus.STARTED },
    });

    if (!session) {
      throw AppException.notFound(
        ErrorCode.RELAX_SESSION_NOT_FOUND,
        'Relax session not found',
      );
    }

    return session;
  }

  private findFinishedSessions(
    userId: string,
    query: RelaxActivityQueryDto & Partial<RelaxRange>,
  ) {
    return this.prisma.relaxSession.findMany({
      where: this.buildFinishedSessionWhere(userId, query),
      orderBy: { endedAt: 'desc' },
      skip: query.skip,
      take: query.limit ?? 50,
    });
  }

  private buildFinishedSessionWhere(
    userId: string,
    query: RelaxActivityQueryDto,
  ) {
    return {
      userId,
      status: RelaxSessionStatus.FINISHED,
      activityType: query.activityType,
      endedAt: { gte: query.from, lte: query.to },
    };
  }
}
