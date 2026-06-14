import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LogCravingDto } from './dto/log-craving.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';

@Injectable()
export class CravingService {
  constructor(private readonly prisma: PrismaService) {}

  async logCraving(userId: string, dto: LogCravingDto) {
    return this.prisma.cravingLog.create({
      data: {
        userId,
        reason: dto.reason,
        intensityBefore: dto.intensityBefore,
        intensityAfter: dto.intensityAfter,
        duration: dto.duration,
        activityUsed: dto.activityUsed,
        resisted: dto.resisted ?? true,
        note: dto.note,
      },
    });
  }

  async getCravingHistory(userId: string, days = 30) {
    const since = new Date();
    since.setDate(since.getDate() - days);

    return this.prisma.cravingLog.findMany({
      where: {
        userId,
        createdAt: { gte: since },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getCravingStats(userId: string) {
    const logs = await this.prisma.cravingLog.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    // Hourly distribution
    const hourlyDistribution = Array.from({ length: 24 }, () => 0);
    for (const log of logs) {
      const hour = log.createdAt.getHours();
      hourlyDistribution[hour]++;
    }

    // Top triggers
    const triggerCounts: Record<string, number> = {};
    for (const log of logs) {
      triggerCounts[log.reason] = (triggerCounts[log.reason] ?? 0) + 1;
    }
    const topTriggers = Object.entries(triggerCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([reason, count]) => ({ reason, count }));

    // Best activities (activities used when intensity dropped most)
    const activityEffectiveness: Record<
      string,
      { totalDrop: number; count: number }
    > = {};
    for (const log of logs) {
      if (log.activityUsed && log.intensityAfter != null) {
        const drop = log.intensityBefore - log.intensityAfter;
        const existing = activityEffectiveness[log.activityUsed] ?? {
          totalDrop: 0,
          count: 0,
        };
        existing.totalDrop += drop;
        existing.count += 1;
        activityEffectiveness[log.activityUsed] = existing;
      }
    }
    const bestActivities = Object.entries(activityEffectiveness)
      .map(([activity, { totalDrop, count }]) => ({
        activity,
        avgDrop: Math.round((totalDrop / count) * 10) / 10,
        count,
      }))
      .sort((a, b) => b.avgDrop - a.avgDrop)
      .slice(0, 5);

    // Resistance rate
    const total = logs.length;
    const resisted = logs.filter((l) => l.resisted).length;
    const resistanceRate = total > 0 ? Math.round((resisted / total) * 100) : 0;

    return {
      total,
      resisted,
      resistanceRate,
      hourlyDistribution,
      topTriggers,
      bestActivities,
    };
  }

  async getOrCreateGoal(userId: string) {
    const existing = await this.prisma.smokingGoal.findUnique({
      where: { userId },
    });

    if (existing) return existing;

    return this.prisma.smokingGoal.create({
      data: {
        userId,
        dailyTarget: 0,
        currentDaily: 0,
        replacementGoal: 1,
      },
    });
  }

  async updateGoal(userId: string, dto: UpdateGoalDto) {
    return this.prisma.smokingGoal.upsert({
      where: { userId },
      update: {
        ...(dto.dailyTarget !== undefined && { dailyTarget: dto.dailyTarget }),
        ...(dto.currentDaily !== undefined && {
          currentDaily: dto.currentDaily,
        }),
        ...(dto.replacementGoal !== undefined && {
          replacementGoal: dto.replacementGoal,
        }),
      },
      create: {
        userId,
        dailyTarget: dto.dailyTarget ?? 0,
        currentDaily: dto.currentDaily ?? 0,
        replacementGoal: dto.replacementGoal ?? 1,
      },
    });
  }
}
