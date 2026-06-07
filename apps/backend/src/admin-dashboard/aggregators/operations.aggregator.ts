/**
 * Operations + timeline + retention + DAU/WAU/MAU aggregators.
 * The "everything that isn't billing/engagement/content" bucket.
 */
import { Injectable } from '@nestjs/common';
import { PaymentStatus } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { AdminDashboardPeriod } from '../dto/admin-dashboard-query.dto';
import { DateRange } from '../helpers/date-range.helper';
import { round2 } from '../helpers/admin-math.helper';
import {
  buildBuckets,
  bucketKey,
  shouldGroupMonthly,
} from '../helpers/timeline-buckets.helper';

@Injectable()
export class OperationsAggregator {
  constructor(private readonly prisma: PrismaService) {}

  /** Distinct users who had at least one session in `range`. */
  countDistinctSessionUsers(range: DateRange) {
    return this.prisma.session
      .findMany({
        where: { createdAt: { gte: range.from, lte: range.to } },
        distinct: ['userId'],
        select: { userId: true },
      })
      .then((rows) => rows.length);
  }

  async getOperations(range: DateRange) {
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

  async getTimeline(period: AdminDashboardPeriod, range: DateRange) {
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
    const groupMonthly = shouldGroupMonthly(period, range);
    const buckets = buildBuckets(period, range, groupMonthly);

    for (const user of users) {
      buckets.get(bucketKey(user.createdAt, groupMonthly))!.users += 1;
    }
    for (const session of sessions) {
      buckets
        .get(bucketKey(session.createdAt, groupMonthly))!
        .active.add(session.userId);
    }
    for (const payment of payments) {
      buckets.get(bucketKey(payment.createdAt, groupMonthly))!.revenue +=
        payment.amount;
    }

    return Array.from(buckets.values()).map((bucket) => ({
      label: bucket.label,
      users: bucket.users,
      active: bucket.active.size,
      revenue: round2(bucket.revenue),
    }));
  }

  /**
   * Cohort = users created BEFORE `range.from` and not deleted.
   * Retained = cohort users who logged in inside `range`.
   * Churn risk = cohort users with no login at all OR last login before range.
   */
  async getRetention(range: DateRange) {
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
          ? round2((retained / cohortUsers.length) * 100)
          : 0,
    };
  }
}
