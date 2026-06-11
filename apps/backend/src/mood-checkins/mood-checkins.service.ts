import { ForbiddenException, Injectable } from '@nestjs/common';
import { MoodCheckin, MoodType, Prisma, UserRole } from '@prisma/client';
import { ErrorCode } from '../common/errors/error-code';
import { AppException } from '../common/errors/app.exception';
import { buildPage } from '../common/pagination/page';
import { RealtimeService } from '../realtime/realtime.service';
import {
  createTimezoneContext,
  getTimezoneContextOffsetMinutes,
  normalizeTimezone,
  getLocalWeekStart,
} from '../common/timezone';
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
import { AchievementsService } from '../achievements/achievements.service';
import { FeedService } from '../feed/feed.service';

// Helpers (pure)
import {
  clampScore,
  getEffectiveScore,
  round2,
  scoreFromMood,
} from './helpers/mood-scoring';
import { buildDistribution, getTopMood } from './helpers/mood-distribution';
import {
  MoodDateRange,
  getCheckinDate,
  addLocalDays,
} from './helpers/mood-time';
import { calculateStreaks, StreakResult } from './helpers/mood-streaks';
import { buildGreeting } from './helpers/mood-greeting';
import {
  buildRecommendation,
  getSoundCategoriesForMood,
} from './helpers/mood-recommendation';
import {
  buildAnalyticsDelta,
  buildAnalyticsSummary,
  buildInsights,
  buildTimeline,
  getPreviousRange,
  resolveAnalyticsRange,
} from './analytics/mood-analytics.helper';
import {
  addAffectedWeekStarts,
  resolveRecalculateRange,
} from './weekly-stats/mood-weekly-stats.helper';

type SystemMoodCheckinFields = {
  allowSystemScoring?: boolean;
  rawScore?: number;
  finalScore?: number;
  scoredAt?: Date;
  checkedAt?: Date;
};

type CreateMoodCheckinInput = CreateMoodCheckinDto & SystemMoodCheckinFields;

/**
 * MoodCheckinsService — orchestrator mỏng.
 *
 * Toàn bộ pure logic (scoring, distribution, streaks, greeting,
 * recommendations, analytics, weekly-stat math) đã được tách sang
 * `./helpers/` + `./analytics/` + `./weekly-stats/`. Service này chỉ
 * còn:
 *   - CRUD trên Prisma
 *   - Orchestrate helpers + I/O (UsersService, RealtimeService)
 *   - Domain guards (assertOwnerOrAdmin)
 *   - Database-aware sync (syncProfileStats, upsertWeeklyStat)
 */
@Injectable()
export class MoodCheckinsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
    private readonly realtime: RealtimeService,
    private readonly achievementsService: AchievementsService,
    private readonly feedService: FeedService,
  ) {}

  // ============================================================
  // READ
  // ============================================================

  async findAll(query: MoodCheckinQueryDto) {
    const where = this.buildWhere(undefined, query);
    const [items, total] = await Promise.all([
      this.prisma.moodCheckin.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: query.skip,
        take: query.limit ?? 50,
        include: {
          user: { select: { id: true, email: true, name: true } },
        },
      }),
      this.prisma.moodCheckin.count({ where }),
    ]);

    return buildPage(items, total, query);
  }

  getOptions() {
    return MOOD_OPTIONS;
  }

  async findByUserId(userId: string, query: MoodCheckinQueryDto) {
    await this.usersService.findOne(userId);

    const where = this.buildWhere(userId, query);
    const [items, total] = await Promise.all([
      this.prisma.moodCheckin.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: query.skip,
        take: query.limit ?? 50,
      }),
      this.prisma.moodCheckin.count({ where }),
    ]);

    return buildPage(items, total, query);
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

  // ============================================================
  // WRITE
  // ============================================================

  async create(userId: string, dto: CreateMoodCheckinInput) {
    await this.usersService.findOne(userId);
    const now = new Date();
    const baseScore = scoreFromMood(dto.mood);
    const rawScore = dto.allowSystemScoring
      ? clampScore(dto.rawScore ?? baseScore)
      : baseScore;
    const finalScore = dto.allowSystemScoring
      ? clampScore(dto.finalScore ?? rawScore)
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

    const streak = await this.syncProfileStats(userId);
    await this.syncWeeklyStatsAroundDate(userId, getCheckinDate(checkin));
    this.realtime.emitToUser(userId, 'mood.updated', {
      id: checkin.id,
      mood: checkin.mood,
      createdAt: checkin.createdAt,
    });

    // Check achievement and create feed entry
    try {
      await this.achievementsService.checkAndUnlock(
        userId,
        'Bước đầu ghi nhận cảm xúc',
      );
      if (streak.current >= 3) {
        await this.achievementsService.checkAndUnlock(
          userId,
          'Chuỗi 3 ngày: Đồng hành chớm nở',
        );
      }
      if (streak.current >= 7) {
        await this.achievementsService.checkAndUnlock(
          userId,
          'Chuỗi 7 ngày: Thói quen vững vàng',
        );
      }
      if (streak.current >= 30) {
        await this.achievementsService.checkAndUnlock(
          userId,
          'Chuỗi 30 ngày: Bậc thầy tự cân bằng',
        );
      }

      await this.feedService.createEntry(
        userId,
        'MOOD_CHECKIN',
        'Ghi nhận cảm xúc mới',
        `đã ghi nhận cảm xúc: "${checkin.mood}" với cường độ ${checkin.intensity}/5.`,
        checkin.id,
      );
    } catch {
      // Don't block flow if achievements/feed fails
    }

    return checkin;
  }

  async update(id: string, dto: UpdateMoodCheckinDto, user: AuthUser) {
    const checkin = await this.findExisting(id);
    this.assertOwnerOrAdmin(checkin, user);
    const previousScoreDate = getCheckinDate(checkin);

    const updated = await this.prisma.moodCheckin.update({
      where: { id },
      data: {
        ...dto,
        ...(dto.mood
          ? {
              rawScore: scoreFromMood(dto.mood),
              finalScore: scoreFromMood(dto.mood),
            }
          : {}),
      },
    });
    const nextScoreDate = getCheckinDate(updated);

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
      getCheckinDate(removed),
    );
    return removed;
  }

  // ============================================================
  // STATS / DASHBOARD / ANALYTICS
  // ============================================================

  async getStats(userId: string, query: MoodCheckinQueryDto) {
    await this.usersService.findOne(userId);
    const where = this.buildWhere(userId, query);

    const [total, byMood, average, latest, userStreak] = await Promise.all([
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
      this.prisma.userStreak.findUnique({
        where: { userId },
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
      streak: {
        current: userStreak?.currentStreak ?? 0,
        longest: userStreak?.longestStreak ?? 0,
      },
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
    const range = resolveRecalculateRange(dto, timezoneContext);
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
              gte: getLocalWeekStart(range.from, timezoneContext),
              lte: getLocalWeekStart(range.to, timezoneContext),
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
      addAffectedWeekStarts(
        weekStarts,
        getCheckinDate(checkin),
        timezoneContext,
      );
    }

    for (const stat of existingStats) {
      addAffectedWeekStarts(weekStarts, stat.weekStart, timezoneContext);
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
      this.prisma.userProfile.findUnique({ where: { userId } }),
    ]);

    const topMood = getTopMood(checkins) ?? latest?.mood ?? MoodType.NEUTRAL;
    const option = getMoodOption(latest?.mood ?? topMood);

    return {
      greeting: buildGreeting(profile?.displayName),
      companion: {
        prompt: option.companionLine,
        mood: option.mood,
        iconKey: option.iconKey,
      },
      currentMood: latest
        ? { checkin: latest, option: getMoodOption(latest.mood) }
        : null,
      options: MOOD_OPTIONS,
      distribution: buildDistribution(checkins),
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
    const range = resolveAnalyticsRange(query, timezoneContext);
    const previousRange = getPreviousRange(range);

    const [currentCheckins, previousCheckins, userStreak] = await Promise.all([
      this.findCheckinsInRange(userId, range),
      query.compare === false
        ? Promise.resolve([])
        : this.findCheckinsInRange(userId, previousRange),
      this.prisma.userStreak.findUnique({
        where: { userId },
      }),
    ]);

    const summary = buildAnalyticsSummary(currentCheckins, timezoneContext);
    const previousSummary = buildAnalyticsSummary(
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
          : buildAnalyticsDelta(summary, previousSummary),
      timeline: buildTimeline(currentCheckins, range, timezoneContext),
      distribution: buildDistribution(currentCheckins),
      streak: {
        current: userStreak?.currentStreak ?? 0,
        longest: userStreak?.longestStreak ?? 0,
      },
      insights: buildInsights(summary, previousSummary),
    };
  }

  // ============================================================
  // PRIVATE — DB-aware helpers (cannot be pure)
  // ============================================================

  private async resolveTimezone(userId: string, timezone?: string) {
    if (timezone) return normalizeTimezone(timezone);

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
    if (user.role === UserRole.ADMIN || checkin.userId === user.id) return;

    throw new ForbiddenException({
      code: ErrorCode.AUTH_FORBIDDEN,
      message: 'You do not have permission to access this mood check-in',
    });
  }

  private buildWhere(userId: string | undefined, query: MoodCheckinQueryDto) {
    const where: Prisma.MoodCheckinWhereInput = {};
    const andFilters: Prisma.MoodCheckinWhereInput[] = [];

    if (userId) where.userId = userId;
    if (query.mood) where.mood = query.mood;
    if (query.from || query.to) {
      andFilters.push(this.buildScoredAtRangeWhere(query.from, query.to));
    }
    if (andFilters.length > 0) where.AND = andFilters;

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
    const dateFilter: Prisma.DateTimeFilter = { gte: from, lte: to };
    return {
      OR: [{ scoredAt: dateFilter }, { scoredAt: null, createdAt: dateFilter }],
    } satisfies Prisma.MoodCheckinWhereInput;
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
          category: { in: getSoundCategoriesForMood(mood) },
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
      buildRecommendation(
        action,
        mood,
        breathingExercise,
        ambientSound,
        cozyQuote,
      ),
    );
  }

  private async syncProfileStats(userId: string): Promise<StreakResult> {
    const timezone = await this.resolveTimezone(userId);
    const timezoneContext = createTimezoneContext(timezone);
    const checkins = await this.prisma.moodCheckin.findMany({
      where: { userId },
      select: { createdAt: true, scoredAt: true },
      orderBy: { createdAt: 'desc' },
    });
    const streak = calculateStreaks(checkins, timezoneContext);

    const latestCheckin = checkins[0];
    const lastActivityDate = latestCheckin
      ? (latestCheckin.scoredAt ?? latestCheckin.createdAt)
      : null;

    await this.prisma.userStreak.upsert({
      where: { userId },
      update: {
        currentStreak: streak.current,
        longestStreak: streak.longest,
        lastActivityDate,
      },
      create: {
        userId,
        currentStreak: streak.current,
        longestStreak: streak.longest,
        lastActivityDate,
        streakType: 'MOOD_TRACKING',
      },
    });

    await this.prisma.userProfile.updateMany({
      where: { userId },
      data: {
        totalMoodCheckins: checkins.length,
        currentStreak: streak.current,
        longestStreak: streak.longest,
      },
    });

    return streak;
  }

  private async syncWeeklyStatsAroundDate(userId: string, date: Date) {
    const timezone = await this.resolveTimezone(userId);
    const timezoneContext = createTimezoneContext(timezone);
    const weekStarts = new Map<string, Date>();
    addAffectedWeekStarts(weekStarts, date, timezoneContext);

    for (const weekStart of weekStarts.values()) {
      await this.upsertWeeklyStat(userId, weekStart, timezoneContext);
    }
  }

  private async upsertWeeklyStat(
    userId: string,
    weekStart: Date,
    timezoneContext: ReturnType<typeof createTimezoneContext>,
  ) {
    const weekEnd = new Date(
      addLocalDays(weekStart, 7, timezoneContext).getTime() - 1,
    );
    const previousWeekStart = addLocalDays(weekStart, -7, timezoneContext);
    const previousWeekEnd = new Date(
      addLocalDays(previousWeekStart, 7, timezoneContext).getTime() - 1,
    );

    const [checkins, previousCheckins, userStreak] = await Promise.all([
      this.findCheckinsInRange(userId, { from: weekStart, to: weekEnd }),
      this.findCheckinsInRange(userId, {
        from: previousWeekStart,
        to: previousWeekEnd,
      }),
      this.prisma.userStreak.findUnique({
        where: { userId },
      }),
    ]);
    const existingStat = await this.prisma.weeklyMoodStat.findUnique({
      where: { userId_weekStart: { userId, weekStart } },
    });

    if (checkins.length === 0 && !existingStat) return;

    const avgScore =
      checkins.length > 0
        ? round2(
            checkins.reduce(
              (sum, checkin) => sum + getEffectiveScore(checkin),
              0,
            ) / checkins.length,
          )
        : 0;
    const previousAvgScore =
      previousCheckins.length > 0
        ? round2(
            previousCheckins.reduce(
              (sum, checkin) => sum + getEffectiveScore(checkin),
              0,
            ) / previousCheckins.length,
          )
        : avgScore;

    const streakDays = userStreak?.currentStreak ?? 0;
    const dominantMood = getTopMood(checkins);
    const stressReducePct = round2(previousAvgScore - avgScore);

    await this.prisma.weeklyMoodStat.upsert({
      where: { userId_weekStart: { userId, weekStart } },
      create: {
        userId,
        weekStart,
        avgScore,
        stressReducePct,
        streakDays,
        dominantMood,
      },
      update: { avgScore, stressReducePct, streakDays, dominantMood },
    });
  }
}
