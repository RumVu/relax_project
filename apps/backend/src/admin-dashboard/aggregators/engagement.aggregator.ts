/**
 * Engagement aggregators — relax activities, mood distribution, content
 * ratings, companion CTR, push deliverability. Reads-only.
 */
import { Injectable } from '@nestjs/common';
import { RelaxSessionStatus } from '@prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { DateRange } from '../helpers/date-range.helper';
import { round2 } from '../helpers/admin-math.helper';

@Injectable()
export class EngagementAggregator {
  constructor(private readonly prisma: PrismaService) {}

  async getRelaxByActivity(range: DateRange) {
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
      avgReliefLevel: round2(row._avg.reliefLevel ?? 0),
      avgStressReliefPercent: round2(row._avg.stressReliefPercent ?? 0),
    }));
  }

  async getMoodDistribution(range: DateRange) {
    const rows = await this.prisma.moodCheckin.groupBy({
      by: ['mood'],
      where: {
        OR: [
          { scoredAt: { gte: range.from, lte: range.to } },
          { scoredAt: null, createdAt: { gte: range.from, lte: range.to } },
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
      percent: total > 0 ? round2((row._count._all / total) * 100) : 0,
      avgRawScore: round2(row._avg.rawScore ?? 0),
      avgFinalScore: round2(row._avg.finalScore ?? 0),
    }));
  }

  async getContentRatings(range: DateRange) {
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
      avgRating: round2(row._avg.rating ?? 0),
    }));
  }

  async getCompanionCtr(range: DateRange) {
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
      clickThroughRate: shown > 0 ? round2((clicked / shown) * 100) : 0,
      dismissRate: shown > 0 ? round2((dismissed / shown) * 100) : 0,
    };
  }

  async getPushDeliverability(range: DateRange) {
    const [total, read, unread, devices] = await Promise.all([
      this.prisma.notification.count({
        where: { createdAt: { gte: range.from, lte: range.to } },
      }),
      this.prisma.notification.count({
        where: { isRead: true, createdAt: { gte: range.from, lte: range.to } },
      }),
      this.prisma.notification.count({
        where: { isRead: false, createdAt: { gte: range.from, lte: range.to } },
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
      deliveredRate: total > 0 ? round2((read / total) * 100) : 0,
      devices: devices.map((device) => ({
        enabled: device.enabled,
        platform: device.platform,
        count: device._count._all,
      })),
    };
  }
}
