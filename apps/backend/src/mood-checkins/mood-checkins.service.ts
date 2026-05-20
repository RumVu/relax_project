import { ForbiddenException, Injectable } from '@nestjs/common';
import {
  AmbientSound,
  BreathingExercise,
  CozyQuote,
  MoodCheckin,
  MoodType,
  Prisma,
  UserRole,
} from '@prisma/client';
import { ErrorCode } from '../common/errors/error-code';
import { AppException } from '../common/errors/app.exception';
import {
  addLocalDays,
  createTimezoneContext,
  endOfLocalDay as getEndOfLocalDay,
  getLocalDayLabel,
  getLocalWeekStart as getTimezoneLocalWeekStart,
  getTimezoneContextOffsetMinutes,
  normalizeTimezone,
  startOfLocalDay as getStartOfLocalDay,
  toLocalDateKey as getLocalDateKey,
} from '../common/timezone';
import type { TimezoneContext } from '../common/timezone';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import type { AuthUser } from '../auth/auth.types';
import {
  MoodAnalyticsPeriod,
  MoodAnalyticsQueryDto,
} from './dto/mood-analytics-query.dto';
import { CreateMoodCheckinDto } from './dto/create-mood-checkin.dto';
import { MoodCheckinQueryDto } from './dto/mood-checkin-query.dto';
import { RecalculateWeeklyMoodStatsDto } from './dto/recalculate-weekly-mood-stats.dto';
import { UpdateMoodCheckinDto } from './dto/update-mood-checkin.dto';
import { getMoodOption, MOOD_OPTIONS, MoodActionType } from './mood-options';

type MoodCheckinAnalyticsInput = Pick<
  MoodCheckin,
  'mood' | 'intensity' | 'rawScore' | 'finalScore' | 'scoredAt' | 'createdAt'
>;

type SystemMoodCheckinFields = {
  allowSystemScoring?: boolean;
  rawScore?: number;
  finalScore?: number;
  scoredAt?: Date;
  checkedAt?: Date;
};

type CreateMoodCheckinInput = CreateMoodCheckinDto & SystemMoodCheckinFields;

interface MoodDateRange {
  from: Date;
  to: Date;
}

@Injectable()
export class MoodCheckinsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  findAll(query: MoodCheckinQueryDto) {
    return this.prisma.moodCheckin.findMany({
      where: this.buildWhere(undefined, query),
      orderBy: { createdAt: 'desc' },
      skip: query.skip,
      take: query.limit ?? 50,
      include: {
        user: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
    });
  }

  getOptions() {
    return MOOD_OPTIONS;
  }

  async findByUserId(userId: string, query: MoodCheckinQueryDto) {
    await this.usersService.findOne(userId);

    return this.prisma.moodCheckin.findMany({
      where: this.buildWhere(userId, query),
      orderBy: { createdAt: 'desc' },
      skip: query.skip,
      take: query.limit ?? 50,
    });
  }

  async findLatest(userId: string) {
    await this.usersService.findOne(userId);

    const checkin = await this.prisma.moodCheckin.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    if (!checkin) {
      throw AppException.notFound(
        ErrorCode.MOOD_CHECKIN_NOT_FOUND,
        'Mood check-in not found',
      );
    }

    return checkin;
  }

  async findOne(id: string, user: AuthUser) {
    const checkin = await this.findExisting(id);
    this.assertOwnerOrAdmin(checkin, user);
    return checkin;
  }

  async create(userId: string, dto: CreateMoodCheckinInput) {
    await this.usersService.findOne(userId);
    const now = new Date();
    const baseScore = this.scoreFromMood(dto.mood);
    const rawScore = dto.allowSystemScoring
      ? this.clampScore(dto.rawScore ?? baseScore)
      : baseScore;
    const finalScore = dto.allowSystemScoring
      ? this.clampScore(dto.finalScore ?? rawScore)
      : rawScore;
    const scoredAt = dto.allowSystemScoring
      ? (dto.scoredAt ?? dto.checkedAt ?? now)
      : now;

    const checkin = await this.prisma.moodCheckin.create({
      data: {
        userId,
        mood: dto.mood,
        intensity: dto.intensity,
        rawScore,
        finalScore,
        scoredAt,
        note: dto.note,
        tags: dto.tags ?? [],
        createdAt: dto.allowSystemScoring ? dto.checkedAt : undefined,
      },
    });

    await this.syncProfileStats(userId);
    await this.syncWeeklyStatsAroundDate(userId, this.getCheckinDate(checkin));
    return checkin;
  }

  async update(id: string, dto: UpdateMoodCheckinDto, user: AuthUser) {
    const checkin = await this.findExisting(id);
    this.assertOwnerOrAdmin(checkin, user);
    const previousScoreDate = this.getCheckinDate(checkin);

    const updated = await this.prisma.moodCheckin.update({
      where: { id },
      data: {
        ...dto,
        ...(dto.mood
          ? {
              rawScore: this.scoreFromMood(dto.mood),
              finalScore: this.scoreFromMood(dto.mood),
            }
          : {}),
      },
    });
    const nextScoreDate = this.getCheckinDate(updated);

    await this.syncProfileStats(updated.userId);
    await this.syncWeeklyStatsAroundDate(updated.userId, previousScoreDate);
    if (nextScoreDate.getTime() !== previousScoreDate.getTime()) {
      await this.syncWeeklyStatsAroundDate(updated.userId, nextScoreDate);
    }

    return updated;
  }

  async remove(id: string, user: AuthUser) {
    const checkin = await this.findExisting(id);
    this.assertOwnerOrAdmin(checkin, user);

    const removed = await this.prisma.moodCheckin.delete({
      where: { id },
    });

    await this.syncProfileStats(removed.userId);
    await this.syncWeeklyStatsAroundDate(
      removed.userId,
      this.getCheckinDate(removed),
    );
    return removed;
  }

  async getStats(userId: string, query: MoodCheckinQueryDto) {
    await this.usersService.findOne(userId);
    const timezone = await this.resolveTimezone(userId);
    const timezoneContext = createTimezoneContext(timezone);
    const where = this.buildWhere(userId, query);

    const [total, byMood, average, latest, checkinsForStreak] =
      await Promise.all([
        this.prisma.moodCheckin.count({ where }),
        this.prisma.moodCheckin.groupBy({
          by: ['mood'],
          where,
          _count: { mood: true },
          orderBy: { mood: 'asc' },
        }),
        this.prisma.moodCheckin.aggregate({
          where,
          _avg: { intensity: true },
        }),
        this.prisma.moodCheckin.findFirst({
          where,
          orderBy: { createdAt: 'desc' },
        }),
        this.prisma.moodCheckin.findMany({
          where: { userId },
          select: { createdAt: true, scoredAt: true },
          orderBy: { createdAt: 'desc' },
        }),
      ]);

    return {
      total,
      averageIntensity: average._avg.intensity,
      byMood: byMood.map((entry) => ({
        mood: entry.mood,
        count: entry._count.mood,
      })),
      latest,
      streak: this.calculateStreaks(checkinsForStreak, timezoneContext),
    };
  }

  async getWeeklyStats(userId: string, query: MoodCheckinQueryDto) {
    await this.usersService.findOne(userId);
    return this.prisma.weeklyMoodStat.findMany({
      where: { userId },
      orderBy: { weekStart: 'desc' },
      take: query.limit ?? 12,
    });
  }

  async recalculateWeeklyStats(
    userId: string,
    dto: RecalculateWeeklyMoodStatsDto,
  ) {
    await this.usersService.findOne(userId);
    const timezone = await this.resolveTimezone(userId, dto.timezone);
    const timezoneContext = createTimezoneContext(timezone);
    const range = this.resolveRecalculateRange(dto, timezoneContext);
    const dateWhere = range
      ? this.buildScoredAtRangeWhere(range.from, range.to)
      : undefined;
    const checkins = await this.prisma.moodCheckin.findMany({
      where: {
        userId,
        ...(dateWhere ? { AND: [dateWhere] } : {}),
      },
      select: { createdAt: true, scoredAt: true },
      orderBy: [{ scoredAt: 'asc' }, { createdAt: 'asc' }],
    });
    const existingStats = range
      ? await this.prisma.weeklyMoodStat.findMany({
          where: {
            userId,
            weekStart: {
              gte: this.getLocalWeekStart(range.from, timezoneContext),
              lte: this.getLocalWeekStart(range.to, timezoneContext),
            },
          },
          select: { weekStart: true },
        })
      : await this.prisma.weeklyMoodStat.findMany({
          where: { userId },
          select: { weekStart: true },
        });
    const weekStarts = new Map<string, Date>();

    for (const checkin of checkins) {
      this.addAffectedWeekStarts(
        weekStarts,
        this.getCheckinDate(checkin),
        timezoneContext,
      );
    }

    for (const stat of existingStats) {
      this.addAffectedWeekStarts(weekStarts, stat.weekStart, timezoneContext);
    }

    await this.syncProfileStats(userId);
    if (weekStarts.size === 0) {
      return {
        userId,
        timezone,
        timezoneOffsetMinutes: getTimezoneContextOffsetMinutes(timezoneContext),
        recalculatedCount: 0,
        recalculatedWeeks: [],
      };
    }

    for (const weekStart of weekStarts.values()) {
      await this.upsertWeeklyStat(userId, weekStart, timezoneContext);
    }

    const recalculatedWeeks = await this.prisma.weeklyMoodStat.findMany({
      where: {
        userId,
        weekStart: { in: Array.from(weekStarts.values()) },
      },
      orderBy: { weekStart: 'desc' },
    });

    return {
      userId,
      timezone,
      timezoneOffsetMinutes: getTimezoneContextOffsetMinutes(timezoneContext),
      recalculatedCount: recalculatedWeeks.length,
      recalculatedWeeks,
    };
  }

  async getDashboard(userId: string, query: MoodCheckinQueryDto) {
    await this.usersService.findOne(userId);
    const where = this.buildWhere(userId, query);

    const [checkins, latest, profile] = await Promise.all([
      this.prisma.moodCheckin.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        take: query.limit ?? 50,
      }),
      this.prisma.moodCheckin.findFirst({
        where: { userId },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.userProfile.findUnique({
        where: { userId },
      }),
    ]);

    const topMood =
      this.getTopMood(checkins) ?? latest?.mood ?? MoodType.NEUTRAL;
    const option = getMoodOption(latest?.mood ?? topMood);

    return {
      greeting: this.buildGreeting(profile?.displayName),
      companion: {
        prompt: option.companionLine,
        mood: option.mood,
        iconKey: option.iconKey,
      },
      currentMood: latest
        ? {
            checkin: latest,
            option: getMoodOption(latest.mood),
          }
        : null,
      options: MOOD_OPTIONS,
      distribution: this.buildDistribution(checkins),
      recommendations: await this.getRecommendationsForMood(topMood),
      summary: {
        total: checkins.length,
        topMood,
        currentStreak: profile?.currentStreak ?? 0,
        longestStreak: profile?.longestStreak ?? 0,
      },
    };
  }

  async getRecommendations(mood?: MoodType) {
    const normalizedMood: MoodType =
      mood && MOOD_OPTIONS.some((option) => option.mood === mood)
        ? mood
        : MoodType.NEUTRAL;

    return this.getRecommendationsForMood(normalizedMood);
  }

  async getAnalytics(userId: string, query: MoodAnalyticsQueryDto) {
    await this.usersService.findOne(userId);
    const timezone = await this.resolveTimezone(userId, query.timezone);
    const timezoneContext = createTimezoneContext(
      timezone,
      query.timezoneOffsetMinutes,
    );
    const range = this.resolveAnalyticsRange(query, timezoneContext);
    const previousRange = this.getPreviousRange(range);

    const [currentCheckins, previousCheckins, allCheckins] = await Promise.all([
      this.findCheckinsInRange(userId, range),
      query.compare === false
        ? Promise.resolve([])
        : this.findCheckinsInRange(userId, previousRange),
      this.prisma.moodCheckin.findMany({
        where: { userId },
        select: { createdAt: true, scoredAt: true },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    const summary = this.buildAnalyticsSummary(
      currentCheckins,
      timezoneContext,
    );
    const previousSummary = this.buildAnalyticsSummary(
      previousCheckins,
      timezoneContext,
    );

    return {
      period: query.period ?? MoodAnalyticsPeriod.WEEK,
      range,
      previousRange: query.compare === false ? null : previousRange,
      timezone,
      timezoneOffsetMinutes: getTimezoneContextOffsetMinutes(timezoneContext),
      summary,
      previousSummary: query.compare === false ? null : previousSummary,
      delta:
        query.compare === false
          ? null
          : this.buildAnalyticsDelta(summary, previousSummary),
      timeline: this.buildTimeline(currentCheckins, range, timezoneContext),
      distribution: this.buildDistribution(currentCheckins),
      streak: this.calculateStreaks(allCheckins, timezoneContext),
      insights: this.buildInsights(summary, previousSummary),
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

  private async findExisting(id: string) {
    const checkin = await this.prisma.moodCheckin.findUnique({
      where: { id },
    });

    if (!checkin) {
      throw AppException.notFound(
        ErrorCode.MOOD_CHECKIN_NOT_FOUND,
        'Mood check-in not found',
      );
    }

    return checkin;
  }

  private assertOwnerOrAdmin(checkin: MoodCheckin, user: AuthUser) {
    if (user.role === UserRole.ADMIN || checkin.userId === user.id) {
      return;
    }

    throw new ForbiddenException({
      code: ErrorCode.AUTH_FORBIDDEN,
      message: 'You do not have permission to access this mood check-in',
    });
  }

  private buildWhere(userId: string | undefined, query: MoodCheckinQueryDto) {
    const where: Prisma.MoodCheckinWhereInput = {};
    const andFilters: Prisma.MoodCheckinWhereInput[] = [];

    if (userId) {
      where.userId = userId;
    }

    if (query.mood) {
      where.mood = query.mood;
    }

    if (query.from || query.to) {
      andFilters.push(this.buildScoredAtRangeWhere(query.from, query.to));
    }

    if (andFilters.length > 0) {
      where.AND = andFilters;
    }

    return where;
  }

  private findCheckinsInRange(userId: string, range: MoodDateRange) {
    return this.prisma.moodCheckin.findMany({
      where: {
        userId,
        ...this.buildScoredAtRangeWhere(range.from, range.to),
      },
      orderBy: [{ scoredAt: 'asc' }, { createdAt: 'asc' }],
    });
  }

  private buildScoredAtRangeWhere(from?: Date, to?: Date) {
    const dateFilter: Prisma.DateTimeFilter = {
      gte: from,
      lte: to,
    };

    return {
      OR: [{ scoredAt: dateFilter }, { scoredAt: null, createdAt: dateFilter }],
    } satisfies Prisma.MoodCheckinWhereInput;
  }

  private resolveAnalyticsRange(
    query: MoodAnalyticsQueryDto,
    timezoneContext: TimezoneContext,
  ) {
    if (query.period === MoodAnalyticsPeriod.CUSTOM && query.from && query.to) {
      return {
        from: this.startOfLocalDay(query.from, timezoneContext),
        to: this.endOfLocalDay(query.to, timezoneContext),
      };
    }

    const period = query.period ?? MoodAnalyticsPeriod.WEEK;
    const daysByPeriod: Record<
      Exclude<MoodAnalyticsPeriod, 'custom'>,
      number
    > = {
      [MoodAnalyticsPeriod.WEEK]: 7,
      [MoodAnalyticsPeriod.MONTH]: 30,
      [MoodAnalyticsPeriod.QUARTER]: 90,
      [MoodAnalyticsPeriod.YEAR]: 365,
    };
    const days =
      period === MoodAnalyticsPeriod.CUSTOM ? 7 : daysByPeriod[period];
    const to = this.endOfLocalDay(query.to ?? new Date(), timezoneContext);
    const from = new Date(to);
    from.setUTCDate(from.getUTCDate() - days + 1);

    return {
      from: this.startOfLocalDay(from, timezoneContext),
      to,
    };
  }

  private getPreviousRange(range: MoodDateRange) {
    const duration = range.to.getTime() - range.from.getTime();
    const to = new Date(range.from.getTime() - 1);
    const from = new Date(to.getTime() - duration);

    return { from, to };
  }

  private buildAnalyticsSummary(
    checkins: MoodCheckinAnalyticsInput[],
    timezoneContext: TimezoneContext,
  ) {
    const total = checkins.length;
    const activeDays = new Set(
      checkins.map((checkin) =>
        this.toLocalDateKey(this.getCheckinDate(checkin), timezoneContext),
      ),
    ).size;
    const averageIntensity =
      total > 0
        ? this.round(
            checkins.reduce(
              (sum, checkin) => sum + (checkin.intensity ?? 0),
              0,
            ) / total,
          )
        : null;
    const averageRawScore =
      total > 0
        ? this.round(
            checkins.reduce(
              (sum, checkin) =>
                sum + (checkin.rawScore ?? this.scoreFromMood(checkin.mood)),
              0,
            ) / total,
          )
        : null;
    const averageFinalScore =
      total > 0
        ? this.round(
            checkins.reduce(
              (sum, checkin) => sum + this.getEffectiveScore(checkin),
              0,
            ) / total,
          )
        : null;
    const moodScore =
      total > 0
        ? this.round(
            checkins.reduce(
              (sum, checkin) => sum + this.getEffectiveScore(checkin),
              0,
            ) / total,
          )
        : null;
    const stressCount = checkins.filter((checkin) =>
      this.isStressMood(checkin.mood),
    ).length;
    const positiveCount = checkins.filter((checkin) =>
      this.isPositiveMood(checkin.mood),
    ).length;
    const topMood = this.getTopMood(checkins as MoodCheckin[]);

    return {
      total,
      activeDays,
      averageIntensity,
      averageRawScore,
      averageFinalScore,
      moodScore,
      topMood,
      stressCount,
      stressRate: total > 0 ? Math.round((stressCount / total) * 100) : 0,
      positiveCount,
      positiveRate: total > 0 ? Math.round((positiveCount / total) * 100) : 0,
    };
  }

  private buildAnalyticsDelta(
    current: ReturnType<typeof this.buildAnalyticsSummary>,
    previous: ReturnType<typeof this.buildAnalyticsSummary>,
  ) {
    return {
      total: current.total - previous.total,
      activeDays: current.activeDays - previous.activeDays,
      moodScore:
        current.moodScore !== null && previous.moodScore !== null
          ? this.round(current.moodScore - previous.moodScore)
          : null,
      stressRate: current.stressRate - previous.stressRate,
      stressReduction: previous.stressRate - current.stressRate,
      positiveRate: current.positiveRate - previous.positiveRate,
    };
  }

  private buildTimeline(
    checkins: MoodCheckinAnalyticsInput[],
    range: MoodDateRange,
    timezoneContext: TimezoneContext,
  ) {
    const buckets = this.listLocalDays(range, timezoneContext);

    return buckets.map((bucket) => {
      const dayCheckins = checkins.filter(
        (checkin) =>
          this.toLocalDateKey(this.getCheckinDate(checkin), timezoneContext) ===
          bucket.date,
      );
      const summary = this.buildAnalyticsSummary(dayCheckins, timezoneContext);

      return {
        date: bucket.date,
        label: bucket.label,
        total: summary.total,
        moodScore: summary.moodScore,
        averageIntensity: summary.averageIntensity,
        stressRate: summary.stressRate,
        positiveRate: summary.positiveRate,
        dominantMood: summary.topMood,
        counts: this.buildMoodCounts(dayCheckins),
      };
    });
  }

  private buildMoodCounts(checkins: MoodCheckinAnalyticsInput[]) {
    return MOOD_OPTIONS.map((option) => ({
      mood: option.mood,
      count: checkins.filter((checkin) => checkin.mood === option.mood).length,
    }));
  }

  private buildInsights(
    summary: ReturnType<typeof this.buildAnalyticsSummary>,
    previous: ReturnType<typeof this.buildAnalyticsSummary>,
  ) {
    const delta = this.buildAnalyticsDelta(summary, previous);
    const insights: string[] = [];

    if (delta.stressReduction > 0) {
      insights.push(`Stress giảm ${delta.stressReduction}% so với kỳ trước.`);
    } else if (delta.stressReduction < 0) {
      insights.push(
        `Stress tăng ${Math.abs(delta.stressReduction)}% so với kỳ trước.`,
      );
    }

    if (delta.positiveRate > 0) {
      insights.push(
        `Mood tích cực tăng ${delta.positiveRate}% so với kỳ trước.`,
      );
    }

    if (summary.activeDays > 0) {
      insights.push(
        `Bạn đã check-in cảm xúc trong ${summary.activeDays} ngày của kỳ này.`,
      );
    }

    return insights;
  }

  private listLocalDays(
    range: MoodDateRange,
    timezoneContext: TimezoneContext,
  ) {
    const days: Array<{ date: string; label: string }> = [];
    let cursor = this.startOfLocalDay(range.from, timezoneContext);
    const end = this.startOfLocalDay(range.to, timezoneContext);

    while (cursor.getTime() <= end.getTime()) {
      const date = this.toLocalDateKey(cursor, timezoneContext);
      days.push({
        date,
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

  private getCheckinDate(checkin: Pick<MoodCheckin, 'scoredAt' | 'createdAt'>) {
    return checkin.scoredAt ?? checkin.createdAt;
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

  private scoreFromMood(mood: MoodType) {
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

  private clampScore(score: number) {
    return Math.max(0, Math.min(100, Math.round(score)));
  }

  private getEffectiveScore(checkin: MoodCheckinAnalyticsInput) {
    return (
      checkin.finalScore ?? checkin.rawScore ?? this.scoreFromMood(checkin.mood)
    );
  }

  private isStressMood(mood: MoodType) {
    return mood === MoodType.STRESSED || mood === MoodType.ANXIOUS;
  }

  private isPositiveMood(mood: MoodType) {
    const positiveMoods: MoodType[] = [
      MoodType.HAPPY,
      MoodType.CALM,
      MoodType.EXCITED,
      MoodType.GRATEFUL,
    ];

    return positiveMoods.includes(mood);
  }

  private round(value: number) {
    return Math.round(value * 100) / 100;
  }

  private buildGreeting(displayName?: string | null) {
    const hour = new Date().getHours();
    const normalizedDisplayName = displayName?.trim() || null;
    const name = normalizedDisplayName ?? 'bạn';

    if (hour >= 22 || hour < 5) {
      return {
        title: `Khuya rồi nè, ${name} ơi`,
        titleTemplate: 'Khuya rồi nè, {{name}} ơi',
        displayName: normalizedDisplayName,
        subtitle: 'Đừng thức khuya quá đó nha ~',
        period: 'NIGHT',
        iconKey: 'weather-night',
      };
    }

    if (hour < 11) {
      return {
        title: `Đã trở lại rồi nè, ${name} ~`,
        titleTemplate: 'Đã trở lại rồi nè, {{name}} ~',
        displayName: normalizedDisplayName,
        subtitle: 'Trời nắng đẹp ghê!',
        period: 'MORNING',
        iconKey: 'weather-sunny',
      };
    }

    if (hour < 18) {
      return {
        title: 'Chiều rồi nè, nghỉ một chút nha ~',
        titleTemplate: 'Chiều rồi nè, nghỉ một chút nha ~',
        displayName: normalizedDisplayName,
        subtitle: 'Hít nhẹ một hơi rồi mình tiếp tục.',
        period: 'AFTERNOON',
        iconKey: 'weather-cloudy',
      };
    }

    return {
      title: 'Tối rồi nè, mình thả lỏng nha ~',
      titleTemplate: 'Tối rồi nè, mình thả lỏng nha ~',
      displayName: normalizedDisplayName,
      subtitle: 'Một ngày đã đi qua, nghe lòng mình chút nhé.',
      period: 'EVENING',
      iconKey: 'weather-evening',
    };
  }

  private buildDistribution(checkins: MoodCheckin[]) {
    const total = checkins.length;

    return MOOD_OPTIONS.map((option) => {
      const count = checkins.filter(
        (checkin) => checkin.mood === option.mood,
      ).length;
      const percentage = total > 0 ? Math.round((count / total) * 100) : 0;

      return {
        ...option,
        count,
        percentage,
      };
    });
  }

  private getTopMood(checkins: MoodCheckin[]) {
    if (checkins.length === 0) {
      return null;
    }

    const counts = checkins.reduce<Record<string, number>>(
      (accumulator, checkin) => {
        accumulator[checkin.mood] = (accumulator[checkin.mood] ?? 0) + 1;
        return accumulator;
      },
      {},
    );

    return Object.entries(counts).sort(
      (left, right) => right[1] - left[1],
    )[0][0] as MoodType;
  }

  private async getRecommendationsForMood(mood: MoodType) {
    const option = getMoodOption(mood);
    const [breathingExercise, ambientSound, cozyQuote] = await Promise.all([
      this.prisma.breathingExercise.findFirst({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.ambientSound.findFirst({
        where: {
          isActive: true,
          category: { in: this.getSoundCategoriesForMood(mood) },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.cozyQuote.findFirst({
        where: {
          isActive: true,
          OR: [{ mood }, { mood: null }],
        },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    const actions: MoodActionType[] = [...option.recommendedActions];

    return actions.map((action) =>
      this.buildRecommendation(
        action,
        mood,
        breathingExercise,
        ambientSound,
        cozyQuote,
      ),
    );
  }

  private buildRecommendation(
    action: MoodActionType,
    mood: MoodType,
    breathingExercise: BreathingExercise | null,
    ambientSound: AmbientSound | null,
    cozyQuote: CozyQuote | null,
  ) {
    const titles: Record<MoodActionType, string> = {
      MEDITATION: 'Thiền định',
      BREATHING: 'Hít thở',
      JOURNAL: 'Viết nhật ký',
      MUSIC: 'Nghe nhạc',
    };
    const iconKeys: Record<MoodActionType, string> = {
      MEDITATION: 'lotus',
      BREATHING: 'breath-cloud',
      JOURNAL: 'journal',
      MUSIC: 'headphones',
    };

    const linkedResource =
      action === 'BREATHING'
        ? breathingExercise
        : action === 'MUSIC'
          ? ambientSound
          : action === 'JOURNAL'
            ? cozyQuote
            : null;

    return {
      type: action,
      title: titles[action],
      iconKey: iconKeys[action],
      reason: this.getRecommendationReason(action, mood),
      deepLink: this.getRecommendationDeepLink(action, linkedResource?.id),
      linkedResource,
    };
  }

  private getRecommendationReason(action: MoodActionType, mood: MoodType) {
    if (action === 'BREATHING') {
      return mood === MoodType.STRESSED || mood === MoodType.ANXIOUS
        ? 'Giúp hạ nhịp căng thẳng nhanh hơn.'
        : 'Giữ nhịp cơ thể nhẹ và đều hơn.';
    }

    if (action === 'JOURNAL') {
      return 'Ghi vài dòng để nhìn rõ cảm xúc hiện tại.';
    }

    if (action === 'MUSIC') {
      return 'Một nền âm thanh mềm sẽ giúp mood dễ dịu lại.';
    }

    return 'Một khoảng lặng nhỏ để quay về với mình.';
  }

  private getRecommendationDeepLink(
    action: MoodActionType,
    resourceId?: string,
  ) {
    const baseLinks: Record<MoodActionType, string> = {
      MEDITATION: 'relax://meditation',
      BREATHING: 'relax://breathing-exercises',
      JOURNAL: 'relax://journals/new',
      MUSIC: 'relax://ambient-sounds',
    };

    return resourceId
      ? `${baseLinks[action]}/${resourceId}`
      : baseLinks[action];
  }

  private getSoundCategoriesForMood(mood: MoodType) {
    const tenseMoods: MoodType[] = [MoodType.STRESSED, MoodType.ANXIOUS];
    const lowEnergyMoods: MoodType[] = [
      MoodType.SAD,
      MoodType.LONELY,
      MoodType.TIRED,
    ];

    if (tenseMoods.includes(mood)) {
      return ['RAIN', 'NATURE', 'MEDITATION', 'CALM'];
    }

    if (lowEnergyMoods.includes(mood)) {
      return ['PIANO', 'LOFI', 'AMBIENT', 'CALM'];
    }

    return ['LOFI', 'NATURE', 'AMBIENT', 'RAIN'];
  }

  private async syncProfileStats(userId: string) {
    const timezone = await this.resolveTimezone(userId);
    const timezoneContext = createTimezoneContext(timezone);
    const checkins = await this.prisma.moodCheckin.findMany({
      where: { userId },
      select: { createdAt: true, scoredAt: true },
      orderBy: { createdAt: 'desc' },
    });
    const streak = this.calculateStreaks(checkins, timezoneContext);

    await this.prisma.userProfile.updateMany({
      where: { userId },
      data: {
        totalMoodCheckins: checkins.length,
        currentStreak: streak.current,
        longestStreak: streak.longest,
      },
    });
  }

  private async syncWeeklyStatsAroundDate(userId: string, date: Date) {
    const timezone = await this.resolveTimezone(userId);
    const timezoneContext = createTimezoneContext(timezone);
    const weekStarts = new Map<string, Date>();
    this.addAffectedWeekStarts(weekStarts, date, timezoneContext);

    for (const weekStart of weekStarts.values()) {
      await this.upsertWeeklyStat(userId, weekStart, timezoneContext);
    }
  }

  private addAffectedWeekStarts(
    weekStarts: Map<string, Date>,
    date: Date,
    timezoneContext: TimezoneContext,
  ) {
    const weekStart = this.getLocalWeekStart(date, timezoneContext);

    for (const offsetDays of [-7, 0, 7]) {
      const affected = addLocalDays(weekStart, offsetDays, timezoneContext);
      weekStarts.set(affected.toISOString(), affected);
    }
  }

  private async upsertWeeklyStat(
    userId: string,
    weekStart: Date,
    timezoneContext: TimezoneContext,
  ) {
    const weekEnd = new Date(
      addLocalDays(weekStart, 7, timezoneContext).getTime() - 1,
    );

    const previousWeekStart = addLocalDays(weekStart, -7, timezoneContext);
    const previousWeekEnd = new Date(
      addLocalDays(previousWeekStart, 7, timezoneContext).getTime() - 1,
    );

    const [checkins, previousCheckins, streakCheckins] = await Promise.all([
      this.findCheckinsInRange(userId, { from: weekStart, to: weekEnd }),
      this.findCheckinsInRange(userId, {
        from: previousWeekStart,
        to: previousWeekEnd,
      }),
      this.prisma.moodCheckin.findMany({
        where: { userId },
        select: { createdAt: true, scoredAt: true },
        orderBy: { createdAt: 'desc' },
      }),
    ]);
    const existingStat = await this.prisma.weeklyMoodStat.findUnique({
      where: {
        userId_weekStart: {
          userId,
          weekStart,
        },
      },
    });

    if (checkins.length === 0 && !existingStat) {
      return;
    }

    const avgScore =
      checkins.length > 0
        ? this.round(
            checkins.reduce(
              (sum, checkin) => sum + this.getEffectiveScore(checkin),
              0,
            ) / checkins.length,
          )
        : 0;
    const previousAvgScore =
      previousCheckins.length > 0
        ? this.round(
            previousCheckins.reduce(
              (sum, checkin) => sum + this.getEffectiveScore(checkin),
              0,
            ) / previousCheckins.length,
          )
        : avgScore;

    await this.prisma.weeklyMoodStat.upsert({
      where: {
        userId_weekStart: {
          userId,
          weekStart,
        },
      },
      create: {
        userId,
        weekStart,
        avgScore,
        stressReducePct: this.round(previousAvgScore - avgScore),
        streakDays: this.calculateStreaks(streakCheckins, timezoneContext)
          .current,
        dominantMood: this.getTopMood(checkins),
      },
      update: {
        avgScore,
        stressReducePct: this.round(previousAvgScore - avgScore),
        streakDays: this.calculateStreaks(streakCheckins, timezoneContext)
          .current,
        dominantMood: this.getTopMood(checkins),
      },
    });
  }

  private getLocalWeekStart(date: Date, timezoneContext: TimezoneContext) {
    return getTimezoneLocalWeekStart(date, timezoneContext);
  }

  private resolveRecalculateRange(
    dto: RecalculateWeeklyMoodStatsDto,
    timezoneContext: TimezoneContext,
  ): MoodDateRange | null {
    if (!dto.from && !dto.to) {
      return null;
    }

    return {
      from: this.startOfLocalDay(dto.from ?? dto.to!, timezoneContext),
      to: this.endOfLocalDay(dto.to ?? dto.from!, timezoneContext),
    };
  }

  private calculateStreaks(
    checkins: Array<Pick<MoodCheckin, 'createdAt' | 'scoredAt'>>,
    timezoneContext: TimezoneContext,
  ) {
    const days = Array.from(
      new Set(
        checkins.map((checkin) =>
          this.toLocalDateKey(this.getCheckinDate(checkin), timezoneContext),
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

    const today = this.toLocalDateKey(new Date(), timezoneContext);
    const yesterday = this.toLocalDateKey(
      new Date(Date.now() - 1000 * 60 * 60 * 24),
      timezoneContext,
    );
    const latest = days.at(-1);
    const current =
      latest === today || latest === yesterday ? this.currentRun(days) : 0;

    return { current, longest };
  }

  private currentRun(days: string[]) {
    let run = 0;
    let expected = new Date(`${days.at(-1)}T00:00:00.000Z`);

    for (let index = days.length - 1; index >= 0; index -= 1) {
      const current = new Date(`${days[index]}T00:00:00.000Z`);

      if (current.getTime() !== expected.getTime()) {
        break;
      }

      run += 1;
      expected = new Date(expected.getTime() - 1000 * 60 * 60 * 24);
    }

    return run;
  }
}
