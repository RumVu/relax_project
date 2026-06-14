import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import {
  AdminDashboardPeriod,
  AdminDashboardQueryDto,
} from './dto/admin-dashboard-query.dto';
import { AdminSearchQueryDto } from './dto/admin-search-query.dto';

import {
  daysAgo,
  getPreviousRange,
  resolveRange,
} from './helpers/date-range.helper';
import { percentDelta } from './helpers/admin-math.helper';
import { BillingAggregator } from './aggregators/billing.aggregator';
import { ContentAggregator } from './aggregators/content.aggregator';
import { EngagementAggregator } from './aggregators/engagement.aggregator';
import { OperationsAggregator } from './aggregators/operations.aggregator';

const ADMIN_DASHBOARD_CACHE_TTL_SECONDS = 60;

type PromptsConfig = Record<string, string>;

const DEFAULT_PROMPTS: PromptsConfig = {
  companion: 'Bạn là Mon Leo, linh thú hệ mèo siêu dễ thương...',
  weeklyReflection: 'Bạn là chuyên gia phân tích cảm xúc...',
  journalSuggestion: 'Đọc nhật ký sau và đưa ra một lời khuyên...',
  safetyResponse: 'Phát hiện từ khóa tự hại...',
  recommendationExplanation: 'Giải thích lý do tại sao hoạt động...',
};

function isPromptsConfig(value: unknown): value is PromptsConfig {
  return (
    typeof value === 'object' &&
    value !== null &&
    Object.values(value).every((item) => typeof item === 'string')
  );
}

/**
 * AdminDashboardService — orchestrator. The heavy reads have moved into
 * 4 aggregator services (billing / engagement / content / operations).
 * Pure helpers (date range, math, timeline buckets) sit in `./helpers/`.
 *
 * `getOverview` runs every aggregator in parallel and packages the
 * results. The whole thing is cached in Redis for 60s so a busy admin
 * page doesn't hammer Postgres.
 */
@Injectable()
export class AdminDashboardService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redisService: RedisService,
    private readonly billing: BillingAggregator,
    private readonly engagement: EngagementAggregator,
    private readonly content: ContentAggregator,
    private readonly operations: OperationsAggregator,
  ) {}

  async getOverview(query: AdminDashboardQueryDto) {
    const period = query.period ?? AdminDashboardPeriod.WEEK;
    const range = resolveRange(query);
    const previousRange = getPreviousRange(range);

    return this.redisService.remember(
      [
        'admin-dashboard',
        'overview',
        period,
        range.from.toISOString(),
        range.to.toISOString(),
        query.timezone ?? 'UTC',
        query.timezoneOffsetMinutes ?? 0,
      ].join(':'),
      ADMIN_DASHBOARD_CACHE_TTL_SECONDS,
      () => this.buildOverview(period, range, previousRange, query),
    );
  }

  async search(query: AdminSearchQueryDto) {
    const normalized = query.q?.trim() ?? '';
    const limit = Math.min(query.limit ?? 20, 100);
    const where: Prisma.SearchIndexWhereInput = {
      ...(query.entityType ? { entityType: query.entityType } : {}),
      ...(normalized.length >= 2
        ? {
            OR: [
              { title: { contains: normalized, mode: 'insensitive' } },
              { content: { contains: normalized, mode: 'insensitive' } },
              { tags: { has: normalized.toLowerCase() } },
            ],
          }
        : {}),
    };

    if (normalized.length === 1) {
      return {
        total: 0,
        skip: query.skip ?? 0,
        limit,
        items: [],
        note: 'Search query must contain at least 2 characters, or leave it blank to browse latest indexes.',
      };
    }

    const [total, items] = await Promise.all([
      this.prisma.searchIndex.count({ where }),
      this.prisma.searchIndex.findMany({
        where,
        orderBy: { updatedAt: 'desc' },
        skip: query.skip ?? 0,
        take: limit,
      }),
    ]);

    return { total, skip: query.skip ?? 0, limit, items };
  }

  // ============================================================
  // PRIVATE — aggregate + assemble response
  // ============================================================

  private async buildOverview(
    period: AdminDashboardPeriod,
    range: ReturnType<typeof resolveRange>,
    previousRange: ReturnType<typeof getPreviousRange>,
    query: AdminDashboardQueryDto,
  ) {
    const [
      totalUsers,
      activeUsers,
      inactiveUsers,
      deletedUsers,
      newUsers,
      dau,
      wau,
      mau,
      revenue,
      previousRevenue,
      paymentStatus,
      subscriptionStatus,
      subscriptionPlans,
      relaxByActivity,
      moodDistribution,
      contentRatings,
      companionCtr,
      pushDeliverability,
      contentInventory,
      operations,
      timeline,
      retention,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.user.count({ where: { isActive: true } }),
      this.prisma.user.count({ where: { isActive: false } }),
      this.prisma.user.count({ where: { deletedAt: { not: null } } }),
      this.prisma.user.count({
        where: { createdAt: { gte: range.from, lte: range.to } },
      }),
      this.operations.countDistinctSessionUsers({
        from: daysAgo(1),
        to: range.to,
      }),
      this.operations.countDistinctSessionUsers({
        from: daysAgo(7),
        to: range.to,
      }),
      this.operations.countDistinctSessionUsers({
        from: daysAgo(30),
        to: range.to,
      }),
      this.billing.getRevenue(range),
      this.billing.getRevenue(previousRange),
      this.billing.getPaymentStatus(range),
      this.billing.getSubscriptionStatus(),
      this.billing.getSubscriptionPlans(),
      this.engagement.getRelaxByActivity(range),
      this.engagement.getMoodDistribution(range),
      this.engagement.getContentRatings(range),
      this.engagement.getCompanionCtr(range),
      this.engagement.getPushDeliverability(range),
      this.content.getContentInventory(),
      this.operations.getOperations(range),
      this.operations.getTimeline(period, range),
      this.operations.getRetention(range),
    ]);

    return {
      period,
      range,
      previousRange,
      timezone: query.timezone ?? 'UTC',
      timezoneOffsetMinutes: query.timezoneOffsetMinutes ?? 0,
      summaryCards: {
        dau,
        wau,
        mau,
        totalUsers,
        activeUsers,
        inactiveUsers,
        deletedUsers,
        newUsers,
        mrr: revenue.amount,
        revenue: revenue.amount,
        revenueDeltaPct: percentDelta(revenue.amount, previousRevenue.amount),
        retentionRate: retention.rate,
        churnRiskUsers: retention.churnRiskUsers,
        pushDeliveredRate: pushDeliverability.deliveredRate,
      },
      billing: {
        revenue,
        paymentStatus,
        subscriptionStatus,
        subscriptionPlans,
      },
      engagement: {
        relaxByActivity,
        moodDistribution,
        contentRatings,
        companionCtr,
        notifications: pushDeliverability,
      },
      content: contentInventory,
      operations,
      timeline,
      contracts: {
        generatedFor:
          'Admin dashboard aggregate: DAU/WAU/MAU, revenue, retention, engagement, push, search.',
        userGrowth: 'timeline[].users',
        activeUsers: 'timeline[].active',
        revenue: 'timeline[].revenue',
        moodDistribution: 'engagement.moodDistribution[]',
        relaxEngagement: 'engagement.relaxByActivity[]',
      },
    };
  }

  private getPromptsPath(): string {
    const paths = [
      path.join(process.cwd(), 'apps/backend/src/config/prompts.json'),
      path.join(process.cwd(), 'src/config/prompts.json'),
      path.join(__dirname, '../../config/prompts.json'),
      path.join(__dirname, '../config/prompts.json'),
    ];
    for (const p of paths) {
      if (fs.existsSync(p)) {
        return p;
      }
    }
    return paths[0];
  }

  getPrompts(): PromptsConfig {
    try {
      const filePath = this.getPromptsPath();
      if (fs.existsSync(filePath)) {
        const parsed: unknown = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        if (isPromptsConfig(parsed)) {
          return parsed;
        }
      }
    } catch {
      // ignore
    }
    return DEFAULT_PROMPTS;
  }

  updatePrompts(prompts: Record<string, string>) {
    try {
      const filePath = this.getPromptsPath();
      fs.writeFileSync(filePath, JSON.stringify(prompts, null, 2), 'utf8');
      return { success: true, prompts };
    } catch (err) {
      return { success: false, error: (err as Error).message };
    }
  }

  async getContentQuality() {
    const ratings = await this.prisma.contentRating.groupBy({
      by: ['contentType', 'contentId'],
      _avg: { rating: true },
      _count: { rating: true },
    });

    const soundSessions = await this.prisma.soundSession.groupBy({
      by: ['soundId'],
      _count: { soundId: true },
    });

    const sounds = await this.prisma.ambientSound.findMany({
      select: { id: true, title: true, category: true },
    });

    const soundMap = new Map(sounds.map((s) => [s.id, s]));

    const popularSounds = soundSessions
      .map((session) => {
        const sound = soundMap.get(session.soundId ?? '');
        return {
          id: session.soundId,
          title: sound?.title ?? 'Unknown Sound',
          category: sound?.category ?? 'AMBIENT',
          listens: session._count.soundId,
        };
      })
      .sort((a, b) => b.listens - a.listens)
      .slice(0, 10);

    const ratedItems = ratings
      .map((r) => {
        const isSound = r.contentType === 'AmbientSound';
        const sound = isSound ? soundMap.get(r.contentId) : null;
        return {
          contentType: r.contentType,
          contentId: r.contentId,
          title: sound?.title ?? `Content ${r.contentId}`,
          avgRating: r._avg.rating ?? 0,
          totalReviews: r._count.rating,
        };
      })
      .sort((a, b) => b.avgRating - a.avgRating)
      .slice(0, 10);

    return {
      popularSounds,
      ratedItems,
    };
  }
}
