import { Injectable } from '@nestjs/common';
import {
  MoodType,
  RelaxActivityType,
  RelaxSession,
  RelaxSessionStatus,
} from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import {
  addLocalDays,
  createTimezoneContext,
  endOfLocalDay as getEndOfLocalDay,
  getLocalDayLabel,
  getTimezoneContextOffsetMinutes,
  normalizeTimezone,
  startOfLocalDay as getStartOfLocalDay,
  toLocalDateKey as getLocalDateKey,
} from '../common/timezone';
import type { TimezoneContext } from '../common/timezone';
import { MoodCheckinsService } from '../mood-checkins/mood-checkins.service';
import { PrismaService } from '../prisma/prisma.service';
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

interface RelaxRange {
  from: Date;
  to: Date;
}

const MAX_RELAX_SESSION_DURATION_SECONDS = 60 * 60 * 12;

@Injectable()
export class RelaxActivitiesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
    private readonly moodCheckinsService: MoodCheckinsService,
  ) {}

  async getActivities() {
    const [sounds, breathingExercises] = await Promise.all([
      this.prisma.ambientSound.findMany({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
        take: 5,
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

    return {
      ...this.toSessionPayload(session),
      activity: option,
    };
  }

  async finishSession(
    userId: string,
    sessionId: string,
    dto: FinishRelaxSessionDto,
  ) {
    await this.usersService.findOne(userId);
    const started = await this.findStartedSession(userId, sessionId);
    const endedAt = new Date();
    const durationSeconds = this.resolveDurationSeconds(
      started.startedAt,
      endedAt,
    );
    const activityType = started.activityType;
    const option = getRelaxActivityOption(activityType);
    const stressReliefPercent = this.getStressReliefPercent(
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

    if (dto.moodAfter) {
      await this.moodCheckinsService.create(userId, {
        mood: dto.moodAfter,
        intensity: dto.reliefLevel,
        rawScore: this.getStressScore(started.moodBefore ?? dto.moodAfter),
        finalScore: this.getStressScore(dto.moodAfter),
        scoredAt: endedAt,
        note: dto.note,
        tags: ['relax-finish', activityType.toLowerCase(), session.id],
        checkedAt: endedAt,
        allowSystemScoring: true,
      });
    }

    return {
      ...this.toSessionPayload(session),
      activity: option,
      postCheckin: {
        title: stressReliefPercent > 0 ? 'Mức độ giảm tải' : 'Có lên nhé!',
        stressReliefPercent,
        message:
          stressReliefPercent > 0
            ? `Mình thấy bạn đã giảm stress khoảng ${stressReliefPercent}% rồi nè!`
            : 'Chúc bạn hoàn thành được việc tiếp theo nha.',
      },
      nextSuggestion: this.getNextSuggestion(activityType),
    };
  }

  async listSessions(userId: string, query: RelaxActivityQueryDto) {
    await this.usersService.findOne(userId);
    const sessions = await this.findFinishedSessions(userId, query);

    return sessions.map((session) => this.toSessionPayload(session));
  }

  async getStats(userId: string, query: RelaxActivityQueryDto) {
    await this.usersService.findOne(userId);
    const timezone = await this.resolveTimezone(userId, query.timezone);
    const timezoneContext = createTimezoneContext(
      timezone,
      query.timezoneOffsetMinutes,
    );
    const range = this.resolveRange(query, timezoneContext);
    const sessions = await this.findFinishedSessions(userId, {
      ...query,
      from: range.from,
      to: range.to,
      limit: 100,
    });
    const payloads = sessions.map((session) => this.toSessionPayload(session));
    const totalDurationSeconds = payloads.reduce(
      (sum, session) => sum + session.durationSeconds,
      0,
    );

    return {
      period: query.period ?? RelaxStatsPeriod.WEEK,
      range,
      timezone,
      timezoneOffsetMinutes: getTimezoneContextOffsetMinutes(timezoneContext),
      streak: this.calculateActivityStreak(payloads, timezoneContext),
      totalDurationSeconds,
      totalDurationLabel: this.formatDuration(totalDurationSeconds),
      totalSessions: payloads.length,
      favoriteActivities: this.buildFavoriteActivities(payloads),
      recentMoments: payloads.slice(0, query.limit ?? 5),
      timeline: this.buildTimeline(payloads, range, timezoneContext),
      relief: this.buildReliefSummary(payloads),
    };
  }

  private async resolveTimezone(userId: string, timezone?: string) {
    if (timezone) {
      return normalizeTimezone(timezone);
    }

    const preferences = await this.prisma.userPreference.findUnique({
      where: { userId },
      select: { timezone: true },
    });

    return normalizeTimezone(preferences?.timezone);
  }

  private async findStartedSession(userId: string, sessionId: string) {
    const session = await this.prisma.relaxSession.findFirst({
      where: {
        id: sessionId,
        userId,
        status: RelaxSessionStatus.STARTED,
      },
    });

    if (!session) {
      throw AppException.notFound(
        ErrorCode.RELAX_SESSION_NOT_FOUND,
        'Relax session not found',
      );
    }

    return session;
  }

  private findFinishedSessions(userId: string, query: RelaxActivityQueryDto) {
    return this.prisma.relaxSession.findMany({
      where: {
        userId,
        status: RelaxSessionStatus.FINISHED,
        activityType: query.activityType,
        endedAt: {
          gte: query.from,
          lte: query.to,
        },
      },
      orderBy: { endedAt: 'desc' },
      take: query.limit ?? 50,
    });
  }

  private toSessionPayload(session: RelaxSession) {
    const option = getRelaxActivityOption(session.activityType);

    return {
      id: session.id,
      userId: session.userId,
      activityType: session.activityType,
      status: session.status,
      resourceId: session.resourceId,
      title: session.title,
      startedAt: session.startedAt.toISOString(),
      endedAt: session.endedAt?.toISOString(),
      durationSeconds: session.duration ?? 0,
      moodBefore: session.moodBefore,
      moodAfter: session.moodAfter,
      reliefLevel: session.reliefLevel,
      stressReliefPercent: session.stressReliefPercent,
      note: session.note,
      nextActionAccepted: session.nextActionAccepted,
      createdAt: session.createdAt,
      activity: option,
    };
  }

  private getStressReliefPercent(
    reliefLevel?: number,
    moodBefore?: MoodType,
    moodAfter?: MoodType,
  ) {
    if (reliefLevel) {
      return Math.max(0, Math.min(100, reliefLevel * 20));
    }

    if (!moodBefore || !moodAfter) {
      return 0;
    }

    return Math.max(
      0,
      Math.round(
        ((this.getMoodScore(moodAfter) - this.getMoodScore(moodBefore)) / 4) *
          100,
      ),
    );
  }

  private getMoodScore(mood: MoodType) {
    const scores: Record<MoodType, number> = {
      [MoodType.HAPPY]: 5,
      [MoodType.CALM]: 5,
      [MoodType.EXCITED]: 5,
      [MoodType.GRATEFUL]: 5,
      [MoodType.NEUTRAL]: 3,
      [MoodType.TIRED]: 2,
      [MoodType.LONELY]: 2,
      [MoodType.SAD]: 1,
      [MoodType.ANXIOUS]: 1,
      [MoodType.STRESSED]: 1,
    };

    return scores[mood];
  }

  private getStressScore(mood: MoodType) {
    const stressScores: Record<MoodType, number> = {
      [MoodType.STRESSED]: 90,
      [MoodType.ANXIOUS]: 80,
      [MoodType.SAD]: 65,
      [MoodType.TIRED]: 60,
      [MoodType.LONELY]: 55,
      [MoodType.NEUTRAL]: 40,
      [MoodType.EXCITED]: 30,
      [MoodType.GRATEFUL]: 20,
      [MoodType.HAPPY]: 15,
      [MoodType.CALM]: 10,
    };

    return stressScores[mood];
  }

  private resolveDurationSeconds(startedAt: Date, endedAt: Date) {
    const elapsedSeconds = Math.max(
      0,
      Math.round((endedAt.getTime() - startedAt.getTime()) / 1000),
    );

    return Math.min(elapsedSeconds, MAX_RELAX_SESSION_DURATION_SECONDS);
  }

  private getNextSuggestion(completedType: RelaxActivityType) {
    const fallback = RELAX_ACTIVITY_OPTIONS.find(
      (option) => option.type !== completedType,
    );

    return fallback ?? RELAX_ACTIVITY_OPTIONS[0];
  }

  private resolveRange(
    query: RelaxActivityQueryDto,
    timezoneContext: TimezoneContext,
  ) {
    if (query.period === RelaxStatsPeriod.CUSTOM && query.from && query.to) {
      return {
        from: this.startOfLocalDay(query.from, timezoneContext),
        to: this.endOfLocalDay(query.to, timezoneContext),
      };
    }

    const period = query.period ?? RelaxStatsPeriod.WEEK;
    const daysByPeriod: Record<Exclude<RelaxStatsPeriod, 'custom'>, number> = {
      [RelaxStatsPeriod.WEEK]: 7,
      [RelaxStatsPeriod.MONTH]: 30,
      [RelaxStatsPeriod.QUARTER]: 90,
      [RelaxStatsPeriod.YEAR]: 365,
    };
    const days = period === RelaxStatsPeriod.CUSTOM ? 7 : daysByPeriod[period];
    const to = this.endOfLocalDay(query.to ?? new Date(), timezoneContext);
    const from = new Date(to);
    from.setUTCDate(from.getUTCDate() - days + 1);

    return {
      from: this.startOfLocalDay(from, timezoneContext),
      to,
    };
  }

  private buildFavoriteActivities(
    sessions: Array<ReturnType<typeof this.toSessionPayload>>,
  ) {
    return RELAX_ACTIVITY_OPTIONS.map((option) => {
      const activitySessions = sessions.filter(
        (session) => session.activityType === option.type,
      );
      const durationSeconds = activitySessions.reduce(
        (sum, session) => sum + (session.durationSeconds ?? 0),
        0,
      );

      return {
        type: option.type,
        title: option.title,
        iconKey: option.iconKey,
        count: activitySessions.length,
        durationSeconds,
        durationLabel: this.formatDuration(durationSeconds),
      };
    }).sort((left, right) => right.durationSeconds - left.durationSeconds);
  }

  private buildTimeline(
    sessions: Array<ReturnType<typeof this.toSessionPayload>>,
    range: RelaxRange,
    timezoneContext: TimezoneContext,
  ) {
    const days = this.listLocalDays(range, timezoneContext);

    return days.map((day) => {
      const daySessions = sessions.filter(
        (session) =>
          this.toLocalDateKey(
            new Date(session.endedAt ?? session.createdAt),
            timezoneContext,
          ) === day.date,
      );
      const durationSeconds = daySessions.reduce(
        (sum, session) => sum + (session.durationSeconds ?? 0),
        0,
      );

      return {
        ...day,
        totalSessions: daySessions.length,
        durationSeconds,
        durationLabel: this.formatDuration(durationSeconds),
      };
    });
  }

  private buildReliefSummary(
    sessions: Array<ReturnType<typeof this.toSessionPayload>>,
  ) {
    const finishedWithRelief = sessions.filter(
      (session) => typeof session.stressReliefPercent === 'number',
    );
    const averageStressRelief =
      finishedWithRelief.length > 0
        ? Math.round(
            finishedWithRelief.reduce(
              (sum, session) => sum + (session.stressReliefPercent ?? 0),
              0,
            ) / finishedWithRelief.length,
          )
        : 0;

    return {
      averageStressRelief,
      finishedWithRelief: finishedWithRelief.length,
    };
  }

  private calculateActivityStreak(
    sessions: Array<ReturnType<typeof this.toSessionPayload>>,
    timezoneContext: TimezoneContext,
  ) {
    const days = Array.from(
      new Set(
        sessions.map((session) =>
          this.toLocalDateKey(
            new Date(session.endedAt ?? session.createdAt),
            timezoneContext,
          ),
        ),
      ),
    ).sort();
    let longest = 0;
    let run = 0;
    let previous: Date | undefined;

    for (const day of days) {
      const current = new Date(`${day}T00:00:00.000Z`);
      const diffDays = previous
        ? Math.round(
            (current.getTime() - previous.getTime()) / (1000 * 60 * 60 * 24),
          )
        : 1;
      run = diffDays === 1 ? run + 1 : 1;
      longest = Math.max(longest, run);
      previous = current;
    }

    return {
      current: days.length > 0 ? run : 0,
      longest,
    };
  }

  private listLocalDays(range: RelaxRange, timezoneContext: TimezoneContext) {
    const days: Array<{ date: string; label: string }> = [];
    let cursor = this.startOfLocalDay(range.from, timezoneContext);
    const end = this.startOfLocalDay(range.to, timezoneContext);

    while (cursor.getTime() <= end.getTime()) {
      days.push({
        date: this.toLocalDateKey(cursor, timezoneContext),
        label: this.getDayLabel(cursor, timezoneContext),
      });
      cursor = addLocalDays(cursor, 1, timezoneContext);
    }

    return days;
  }

  private startOfLocalDay(date: Date, timezoneContext: TimezoneContext) {
    return getStartOfLocalDay(date, timezoneContext);
  }

  private endOfLocalDay(date: Date, timezoneContext: TimezoneContext) {
    return getEndOfLocalDay(date, timezoneContext);
  }

  private toLocalDateKey(date: Date, timezoneContext: TimezoneContext) {
    return getLocalDateKey(date, timezoneContext);
  }

  private getDayLabel(date: Date, timezoneContext: TimezoneContext) {
    return getLocalDayLabel(date, timezoneContext);
  }

  private formatDuration(totalSeconds: number) {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.round((totalSeconds % 3600) / 60);

    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    }

    return `${minutes} phút`;
  }
}
