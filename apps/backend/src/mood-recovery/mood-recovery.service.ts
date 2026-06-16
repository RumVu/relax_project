import { Injectable } from '@nestjs/common';
import { MoodType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { scoreFromMood } from '../mood-checkins/helpers/mood-scoring';

export interface RecoverySession {
  id: string;
  activityType: string;
  title: string;
  moodBefore: MoodType;
  moodAfter: MoodType;
  scoreBefore: number;
  scoreAfter: number;
  delta: number;
  stressReliefPercent: number | null;
  duration: number | null;
  createdAt: Date;
}

@Injectable()
export class MoodRecoveryService {
  constructor(private readonly prisma: PrismaService) {}

  async getRecoveryHistory(
    userId: string,
    days = 30,
  ): Promise<RecoverySession[]> {
    const since = new Date();
    since.setDate(since.getDate() - days);

    const sessions = await this.prisma.relaxSession.findMany({
      where: {
        userId,
        moodBefore: { not: null },
        moodAfter: { not: null },
        startedAt: { gte: since },
      },
      orderBy: { startedAt: 'desc' },
      take: 100,
    });

    return sessions.map((s) => {
      const scoreBefore = scoreFromMood(s.moodBefore!);
      const scoreAfter = scoreFromMood(s.moodAfter!);
      return {
        id: s.id,
        activityType: s.activityType,
        title: s.title,
        moodBefore: s.moodBefore!,
        moodAfter: s.moodAfter!,
        scoreBefore,
        scoreAfter,
        delta: scoreAfter - scoreBefore,
        stressReliefPercent: s.stressReliefPercent,
        duration: s.duration,
        createdAt: s.startedAt,
      };
    });
  }

  async getRecoverySummary(userId: string, days = 30) {
    const history = await this.getRecoveryHistory(userId, days);

    if (history.length === 0) {
      return {
        totalSessions: 0,
        avgDelta: 0,
        avgStressRelief: 0,
        bestActivity: null,
        recoveryRate: 0,
        byActivity: [],
        trend: [],
      };
    }

    const totalDelta = history.reduce((sum, s) => sum + s.delta, 0);
    const avgDelta = Math.round((totalDelta / history.length) * 10) / 10;

    const withRelief = history.filter((s) => s.stressReliefPercent != null);
    const avgStressRelief =
      withRelief.length > 0
        ? Math.round(
            withRelief.reduce((sum, s) => sum + s.stressReliefPercent!, 0) /
              withRelief.length,
          )
        : 0;

    const improved = history.filter((s) => s.delta > 0);
    const recoveryRate = Math.round((improved.length / history.length) * 100);

    const byActivityMap = new Map<
      string,
      { total: number; count: number; relief: number; reliefCount: number }
    >();
    for (const s of history) {
      const entry = byActivityMap.get(s.activityType) ?? {
        total: 0,
        count: 0,
        relief: 0,
        reliefCount: 0,
      };
      entry.total += s.delta;
      entry.count++;
      if (s.stressReliefPercent != null) {
        entry.relief += s.stressReliefPercent;
        entry.reliefCount++;
      }
      byActivityMap.set(s.activityType, entry);
    }

    const byActivity = Array.from(byActivityMap.entries())
      .map(([type, data]) => ({
        activityType: type,
        sessions: data.count,
        avgDelta: Math.round((data.total / data.count) * 10) / 10,
        avgRelief:
          data.reliefCount > 0 ? Math.round(data.relief / data.reliefCount) : 0,
      }))
      .sort((a, b) => b.avgDelta - a.avgDelta);

    const bestActivity = byActivity[0] ?? null;

    const trendMap = new Map<string, { total: number; count: number }>();
    for (const s of history) {
      const day = s.createdAt.toISOString().slice(0, 10);
      const entry = trendMap.get(day) ?? { total: 0, count: 0 };
      entry.total += s.delta;
      entry.count++;
      trendMap.set(day, entry);
    }

    const trend = Array.from(trendMap.entries())
      .map(([date, data]) => ({
        date,
        avgDelta: Math.round((data.total / data.count) * 10) / 10,
        sessions: data.count,
      }))
      .sort((a, b) => a.date.localeCompare(b.date));

    return {
      totalSessions: history.length,
      avgDelta,
      avgStressRelief,
      bestActivity,
      recoveryRate,
      byActivity,
      trend,
    };
  }
}
