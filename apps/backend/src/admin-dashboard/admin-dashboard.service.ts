import { Injectable } from '@nestjs/common';
import {
  PaymentStatus,
  Prisma,
  RelaxSessionStatus,
  SubscriptionStatus,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import {
  AdminDashboardPeriod,
  AdminDashboardQueryDto,
} from './dto/admin-dashboard-query.dto';
import { AdminSearchQueryDto } from './dto/admin-search-query.dto';

const ADMIN_DASHBOARD_CACHE_TTL_SECONDS = 60;

type DateRange = {
  from: Date;
  to: Date;
};

type Bucket = {
  key: string;
  label: string;
  users: number;
  active: Set<string>;
  revenue: number;
};

@Injectable()
export class AdminDashboardService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redisService: RedisService,
  ) {}

  async getOverview(query: AdminDashboardQueryDto) {
    const period = query.period ?? AdminDashboardPeriod.WEEK;
    const range = this.resolveRange(query);
    const previousRange = this.getPreviousRange(range);

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
      async () => {
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
          this.countDistinctSessionUsers({
            from: this.daysAgo(1),
            to: range.to,
          }),
          this.countDistinctSessionUsers({
            from: this.daysAgo(7),
            to: range.to,
          }),
          this.countDistinctSessionUsers({
            from: this.daysAgo(30),
            to: range.to,
          }),
          this.getRevenue(range),
          this.getRevenue(previousRange),
          this.getPaymentStatus(range),
          this.getSubscriptionStatus(),
          this.getSubscriptionPlans(),
          this.getRelaxByActivity(range),
          this.getMoodDistribution(range),
          this.getContentRatings(range),
          this.getCompanionCtr(range),
          this.getPushDeliverability(range),
          this.getContentInventory(),
          this.getOperations(range),
          this.getTimeline(period, range),
          this.getRetention(range),
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
            revenueDeltaPct: this.percentDelta(
              revenue.amount,
              previousRevenue.amount,
            ),
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
      },
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

    return {
      total,
      skip: query.skip ?? 0,
      limit,
      items,
    };
  }

  private resolveRange(query: AdminDashboardQueryDto): DateRange {
    if (
      query.period === AdminDashboardPeriod.CUSTOM &&
      query.from &&
      query.to
    ) {
      return {
        from: this.startOfDay(query.from),
        to: this.endOfDay(query.to),
      };
    }

    const period = query.period ?? AdminDashboardPeriod.WEEK;
    const daysByPeriod: Record<
      Exclude<AdminDashboardPeriod, AdminDashboardPeriod.CUSTOM>,
      number
    > = {
      [AdminDashboardPeriod.WEEK]: 7,
      [AdminDashboardPeriod.MONTH]: 30,
      [AdminDashboardPeriod.QUARTER]: 90,
      [AdminDashboardPeriod.YEAR]: 365,
    };
    const to = this.endOfDay(query.to ?? new Date());
    const from = new Date(to);
    from.setUTCDate(
      from.getUTCDate() -
        (period === AdminDashboardPeriod.CUSTOM ? 7 : daysByPeriod[period]) +
        1,
    );

    return {
      from: this.startOfDay(from),
      to,
    };
  }

  private getPreviousRange(range: DateRange): DateRange {
    const duration = range.to.getTime() - range.from.getTime();
    const to = new Date(range.from.getTime() - 1);
    const from = new Date(to.getTime() - duration);
    return { from, to };
  }

  private countDistinctSessionUsers(range: DateRange) {
    return this.prisma.session
      .findMany({
        where: { createdAt: { gte: range.from, lte: range.to } },
        distinct: ['userId'],
        select: { userId: true },
      })
      .then((rows) => rows.length);
  }

  private async getRevenue(range: DateRange) {
    const result = await this.prisma.payment.aggregate({
      where: {
        status: PaymentStatus.COMPLETED,
        createdAt: { gte: range.from, lte: range.to },
      },
      _sum: { amount: true },
      _count: { _all: true },
    });

    return {
      amount: this.round(result._sum.amount ?? 0),
      currency: 'VND',
      completedPayments: result._count._all,
    };
  }

  private async getPaymentStatus(range: DateRange) {
    const rows = await this.prisma.payment.groupBy({
      by: ['status'],
      where: { createdAt: { gte: range.from, lte: range.to } },
      _count: { _all: true },
      _sum: { amount: true },
      orderBy: { status: 'asc' },
    });

    return rows.map((row) => ({
      status: row.status,
      count: row._count._all,
      amount: this.round(row._sum.amount ?? 0),
    }));
  }

  private async getSubscriptionStatus() {
    const rows = await this.prisma.subscription.groupBy({
      by: ['status'],
      _count: { _all: true },
      orderBy: { status: 'asc' },
    });

    return this.fillEnumCounts(
      rows,
      Object.values(SubscriptionStatus),
      'status',
    );
  }

  private async getSubscriptionPlans() {
    const rows = await this.prisma.subscription.groupBy({
      by: ['planName'],
      _count: { _all: true },
      _sum: { price: true },
      orderBy: { planName: 'asc' },
    });

    return rows.map((row) => ({
      planName: row.planName,
      count: row._count._all,
      value: this.round(row._sum.price ?? 0),
    }));
  }

  private async getRelaxByActivity(range: DateRange) {
    const rows = await this.prisma.relaxSession.groupBy({
      by: ['activityType'],
      where: {
        status: RelaxSessionStatus.FINISHED,
        endedAt: { gte: range.from, lte: range.to },
      },
      _count: { _all: true },
      _sum: { duration: true },
      _avg: { stressReliefPercent: true, reliefLevel: true },
      orderBy: { activityType: 'asc' },
    });

    return rows.map((row) => ({
      activityType: row.activityType,
      sessions: row._count._all,
      totalDurationSeconds: row._sum.duration ?? 0,
      avgReliefLevel: this.round(row._avg.reliefLevel ?? 0),
      avgStressReliefPercent: this.round(row._avg.stressReliefPercent ?? 0),
    }));
  }

  private async getMoodDistribution(range: DateRange) {
    const rows = await this.prisma.moodCheckin.groupBy({
      by: ['mood'],
      where: {
        OR: [
          { scoredAt: { gte: range.from, lte: range.to } },
          {
            scoredAt: null,
            createdAt: { gte: range.from, lte: range.to },
          },
        ],
      },
      _count: { _all: true },
      _avg: { rawScore: true, finalScore: true },
      orderBy: { mood: 'asc' },
    });
    const total = rows.reduce((sum, row) => sum + row._count._all, 0);

    return rows.map((row) => ({
      mood: row.mood,
      count: row._count._all,
      percent: total > 0 ? this.round((row._count._all / total) * 100) : 0,
      avgRawScore: this.round(row._avg.rawScore ?? 0),
      avgFinalScore: this.round(row._avg.finalScore ?? 0),
    }));
  }

  private async getContentRatings(range: DateRange) {
    const rows = await this.prisma.contentRating.groupBy({
      by: ['contentType'],
      where: { createdAt: { gte: range.from, lte: range.to } },
      _count: { _all: true },
      _avg: { rating: true },
      orderBy: { contentType: 'asc' },
    });

    return rows.map((row) => ({
      contentType: row.contentType,
      count: row._count._all,
      avgRating: this.round(row._avg.rating ?? 0),
    }));
  }

  private async getCompanionCtr(range: DateRange) {
    const [shown, clicked, dismissed] = await Promise.all([
      this.prisma.companionMessageLog.count({
        where: { shownAt: { gte: range.from, lte: range.to } },
      }),
      this.prisma.companionMessageLog.count({
        where: { clickedAt: { gte: range.from, lte: range.to } },
      }),
      this.prisma.companionMessageLog.count({
        where: { dismissedAt: { gte: range.from, lte: range.to } },
      }),
    ]);

    return {
      shown,
      clicked,
      dismissed,
      clickThroughRate: shown > 0 ? this.round((clicked / shown) * 100) : 0,
      dismissRate: shown > 0 ? this.round((dismissed / shown) * 100) : 0,
    };
  }

  private async getContentInventory() {
    const [
      quotes,
      sounds,
      exercises,
      themes,
      onboarding,
      companionAssets,
      companionMessages,
    ] = await Promise.all([
      this.countPublishState('cozyQuote'),
      this.countPublishState('ambientSound'),
      this.countPublishState('breathingExercise'),
      this.countPublishState('appTheme'),
      this.countPublishState('onboardingSlide'),
      this.countPublishState('companionAsset'),
      this.countPublishState('companionMessage'),
    ]);

    return [
      { area: 'Quotes', endpoint: '/cozy-quotes', ...quotes },
      { area: 'Sounds', endpoint: '/ambient-sounds', ...sounds },
      { area: 'Exercises', endpoint: '/breathing-exercises', ...exercises },
      { area: 'Themes', endpoint: '/app-themes', ...themes },
      { area: 'Onboarding', endpoint: '/onboarding-slides', ...onboarding },
      {
        area: 'Companion Assets',
        endpoint: '/companion-assets',
        ...companionAssets,
      },
      {
        area: 'Companion Messages',
        endpoint: '/companion-messages',
        ...companionMessages,
      },
    ];
  }

  private async countPublishState(
    model:
      | 'cozyQuote'
      | 'ambientSound'
      | 'breathingExercise'
      | 'appTheme'
      | 'onboardingSlide'
      | 'companionAsset'
      | 'companionMessage',
  ) {
    const delegate = this.prisma[model] as {
      count: (args?: { where?: { isActive?: boolean } }) => Promise<number>;
    };
    const [live, total] = await Promise.all([
      delegate.count({ where: { isActive: true } }),
      delegate.count(),
    ]);

    return {
      live,
      drafts: Math.max(0, total - live),
      total,
    };
  }

  private async getPushDeliverability(range: DateRange) {
    const [total, read, unread, devices] = await Promise.all([
      this.prisma.notification.count({
        where: { createdAt: { gte: range.from, lte: range.to } },
      }),
      this.prisma.notification.count({
        where: {
          isRead: true,
          createdAt: { gte: range.from, lte: range.to },
        },
      }),
      this.prisma.notification.count({
        where: {
          isRead: false,
          createdAt: { gte: range.from, lte: range.to },
        },
      }),
      this.prisma.pushDevice.groupBy({
        by: ['enabled', 'platform'],
        _count: { _all: true },
        orderBy: [{ enabled: 'desc' }, { platform: 'asc' }],
      }),
    ]);

    return {
      total,
      read,
      unread,
      deliveredRate: total > 0 ? this.round((read / total) * 100) : 0,
      devices: devices.map((device) => ({
        enabled: device.enabled,
        platform: device.platform,
        count: device._count._all,
      })),
    };
  }

  private async getOperations(range: DateRange) {
    const [
      sessions,
      activeSessions,
      storageFiles,
      platformEvents,
      appEvents,
      feedbackOpen,
    ] = await Promise.all([
      this.prisma.session.count({
        where: { createdAt: { gte: range.from, lte: range.to } },
      }),
      this.prisma.session.count({ where: { expiresAt: { gt: new Date() } } }),
      this.prisma.storageFile.count(),
      this.prisma.platformEvent.count({
        where: { createdAt: { gte: range.from, lte: range.to } },
      }),
      this.prisma.appEvent.count({
        where: { createdAt: { gte: range.from, lte: range.to } },
      }),
      this.prisma.feedback.count({ where: { status: 'OPEN' } }),
    ]);

    return {
      sessions,
      activeSessions,
      storageFiles,
      platformEvents,
      appEvents,
      feedbackOpen,
    };
  }

  private async getTimeline(period: AdminDashboardPeriod, range: DateRange) {
    const [users, sessions, payments] = await Promise.all([
      this.prisma.user.findMany({
        where: { createdAt: { gte: range.from, lte: range.to } },
        select: { createdAt: true },
      }),
      this.prisma.session.findMany({
        where: { createdAt: { gte: range.from, lte: range.to } },
        select: { createdAt: true, userId: true },
      }),
      this.prisma.payment.findMany({
        where: {
          status: PaymentStatus.COMPLETED,
          createdAt: { gte: range.from, lte: range.to },
        },
        select: { createdAt: true, amount: true },
      }),
    ]);
    const groupMonthly = this.shouldGroupMonthly(period, range);
    const buckets = this.buildBuckets(period, range, groupMonthly);

    for (const user of users) {
      buckets.get(this.bucketKey(user.createdAt, groupMonthly))!.users += 1;
    }

    for (const session of sessions) {
      buckets
        .get(this.bucketKey(session.createdAt, groupMonthly))!
        .active.add(session.userId);
    }

    for (const payment of payments) {
      buckets.get(this.bucketKey(payment.createdAt, groupMonthly))!.revenue +=
        payment.amount;
    }

    return Array.from(buckets.values()).map((bucket) => ({
      label: bucket.label,
      users: bucket.users,
      active: bucket.active.size,
      revenue: this.round(bucket.revenue),
    }));
  }

  private async getRetention(range: DateRange) {
    const cohortUsers = await this.prisma.user.findMany({
      where: { createdAt: { lt: range.from }, deletedAt: null },
      select: { id: true, lastLoginAt: true },
    });
    const retained = cohortUsers.filter(
      (user) =>
        user.lastLoginAt &&
        user.lastLoginAt >= range.from &&
        user.lastLoginAt <= range.to,
    ).length;
    const churnRiskUsers = cohortUsers.filter(
      (user) => !user.lastLoginAt || user.lastLoginAt < range.from,
    ).length;

    return {
      cohortUsers: cohortUsers.length,
      retained,
      churnRiskUsers,
      rate:
        cohortUsers.length > 0
          ? this.round((retained / cohortUsers.length) * 100)
          : 0,
    };
  }

  private buildBuckets(
    period: AdminDashboardPeriod,
    range: DateRange,
    groupMonthly = this.shouldGroupMonthly(period, range),
  ) {
    const buckets = new Map<string, Bucket>();
    const cursor = new Date(range.from);

    while (cursor <= range.to) {
      const key = groupMonthly
        ? `${cursor.getUTCFullYear()}-${String(cursor.getUTCMonth() + 1).padStart(2, '0')}`
        : this.dateKey(cursor);

      if (!buckets.has(key)) {
        buckets.set(key, {
          key,
          label: key,
          users: 0,
          active: new Set<string>(),
          revenue: 0,
        });
      }

      if (groupMonthly) {
        cursor.setUTCMonth(cursor.getUTCMonth() + 1, 1);
      } else {
        cursor.setUTCDate(cursor.getUTCDate() + 1);
      }
    }

    return buckets;
  }

  private bucketKey(date: Date, groupMonthly: boolean) {
    return groupMonthly
      ? `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, '0')}`
      : this.dateKey(date);
  }

  private shouldGroupMonthly(period: AdminDashboardPeriod, range: DateRange) {
    return (
      period === AdminDashboardPeriod.QUARTER ||
      period === AdminDashboardPeriod.YEAR ||
      this.daysBetween(range.from, range.to) > 60
    );
  }

  private fillEnumCounts(
    rows: Array<Record<string, unknown> & { _count: { _all: number } }>,
    values: string[],
    key: string,
  ) {
    return values.map((value) => {
      const row = rows.find((entry) => entry[key] === value);
      return { [key]: value, count: row?._count._all ?? 0 };
    });
  }

  private percentDelta(current: number, previous: number) {
    if (previous === 0) {
      return current > 0 ? 100 : 0;
    }

    return this.round(((current - previous) / previous) * 100);
  }

  private daysAgo(days: number) {
    const date = new Date();
    date.setUTCDate(date.getUTCDate() - days + 1);
    return this.startOfDay(date);
  }

  private startOfDay(date: Date) {
    return new Date(
      Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()),
    );
  }

  private endOfDay(date: Date) {
    return new Date(
      Date.UTC(
        date.getUTCFullYear(),
        date.getUTCMonth(),
        date.getUTCDate(),
        23,
        59,
        59,
        999,
      ),
    );
  }

  private dateKey(date: Date) {
    return date.toISOString().slice(0, 10);
  }

  private daysBetween(from: Date, to: Date) {
    return Math.ceil((to.getTime() - from.getTime()) / (1000 * 60 * 60 * 24));
  }

  private round(value: number) {
    return Math.round(value * 100) / 100;
  }
}
