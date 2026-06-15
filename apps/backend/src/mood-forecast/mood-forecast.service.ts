import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { scoreFromMood } from '../mood-checkins/helpers/mood-scoring';

interface DayPattern {
  dayOfWeek: number;
  avgScore: number;
  dominantMood: string;
  count: number;
}

interface ForecastDay {
  date: string;
  dayOfWeek: number;
  predictedScore: number;
  predictedMood: string;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH';
  confidence: number;
  suggestion: string;
}

@Injectable()
export class MoodForecastService {
  constructor(private readonly prisma: PrismaService) {}

  async getForecast(userId: string, days = 7) {
    const patterns = await this.analyzeDayPatterns(userId);
    const recentTrend = await this.getRecentTrend(userId);
    const triggerAnalysis = await this.analyzeTriggers(userId);

    const forecast: ForecastDay[] = [];
    const today = new Date();

    for (let i = 1; i <= days; i++) {
      const date = new Date(today);
      date.setDate(date.getDate() + i);
      const dayOfWeek = date.getDay();
      const dateStr = date.toISOString().slice(0, 10);

      const dayPattern = patterns.find((p) => p.dayOfWeek === dayOfWeek);
      let predictedScore = dayPattern?.avgScore ?? 60;

      if (recentTrend.direction === 'declining') {
        predictedScore -= recentTrend.magnitude * 0.3;
      } else if (recentTrend.direction === 'improving') {
        predictedScore += recentTrend.magnitude * 0.2;
      }

      predictedScore = Math.max(10, Math.min(100, predictedScore));

      const riskLevel: 'LOW' | 'MEDIUM' | 'HIGH' =
        predictedScore < 40 ? 'HIGH' : predictedScore < 60 ? 'MEDIUM' : 'LOW';

      const confidence = Math.min(
        95,
        Math.max(20, (dayPattern?.count ?? 0) * 8 + 20),
      );

      const predictedMood = this.scoreToMood(predictedScore);
      const suggestion = this.getSuggestion(riskLevel, dayOfWeek, triggerAnalysis);

      forecast.push({
        date: dateStr,
        dayOfWeek,
        predictedScore: Math.round(predictedScore),
        predictedMood,
        riskLevel,
        confidence,
        suggestion,
      });
    }

    return {
      forecast,
      patterns,
      recentTrend,
      topTriggers: triggerAnalysis.slice(0, 3),
    };
  }

  private async analyzeDayPatterns(userId: string): Promise<DayPattern[]> {
    const since = new Date();
    since.setDate(since.getDate() - 60);

    const checkins = await this.prisma.moodCheckin.findMany({
      where: { userId, createdAt: { gte: since } },
      select: { mood: true, createdAt: true, finalScore: true },
    });

    const byDay = new Map<number, { scores: number[]; moods: string[] }>();
    for (const c of checkins) {
      const dow = c.createdAt.getDay();
      const entry = byDay.get(dow) ?? { scores: [], moods: [] };
      entry.scores.push(c.finalScore ?? scoreFromMood(c.mood));
      entry.moods.push(c.mood);
      byDay.set(dow, entry);
    }

    return Array.from(byDay.entries()).map(([dayOfWeek, data]) => {
      const avgScore =
        data.scores.reduce((a, b) => a + b, 0) / data.scores.length;
      const moodCounts = new Map<string, number>();
      for (const m of data.moods) {
        moodCounts.set(m, (moodCounts.get(m) ?? 0) + 1);
      }
      const dominantMood = [...moodCounts.entries()].sort(
        (a, b) => b[1] - a[1],
      )[0][0];

      return {
        dayOfWeek,
        avgScore: Math.round(avgScore),
        dominantMood,
        count: data.scores.length,
      };
    });
  }

  private async getRecentTrend(userId: string) {
    const recent = await this.prisma.moodCheckin.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 14,
      select: { finalScore: true, mood: true, createdAt: true },
    });

    if (recent.length < 4) {
      return { direction: 'stable' as const, magnitude: 0 };
    }

    const half = Math.floor(recent.length / 2);
    const recentHalf = recent.slice(0, half);
    const olderHalf = recent.slice(half);

    const avgRecent =
      recentHalf.reduce(
        (s, c) => s + (c.finalScore ?? scoreFromMood(c.mood)),
        0,
      ) / recentHalf.length;
    const avgOlder =
      olderHalf.reduce(
        (s, c) => s + (c.finalScore ?? scoreFromMood(c.mood)),
        0,
      ) / olderHalf.length;

    const diff = avgRecent - avgOlder;

    if (diff > 5) return { direction: 'improving' as const, magnitude: diff };
    if (diff < -5) return { direction: 'declining' as const, magnitude: Math.abs(diff) };
    return { direction: 'stable' as const, magnitude: Math.abs(diff) };
  }

  private async analyzeTriggers(userId: string) {
    const since = new Date();
    since.setDate(since.getDate() - 30);

    const checkins = await this.prisma.moodCheckin.findMany({
      where: {
        userId,
        trigger: { not: null },
        createdAt: { gte: since },
      },
      select: { trigger: true, mood: true, finalScore: true },
    });

    const byTrigger = new Map<
      string,
      { count: number; negativeCount: number }
    >();
    for (const c of checkins) {
      if (!c.trigger) continue;
      const entry = byTrigger.get(c.trigger) ?? {
        count: 0,
        negativeCount: 0,
      };
      entry.count++;
      const score = c.finalScore ?? scoreFromMood(c.mood);
      if (score < 50) entry.negativeCount++;
      byTrigger.set(c.trigger, entry);
    }

    return Array.from(byTrigger.entries())
      .map(([trigger, data]) => ({
        trigger,
        count: data.count,
        negativeRate: Math.round((data.negativeCount / data.count) * 100),
      }))
      .sort((a, b) => b.negativeRate - a.negativeRate);
  }

  private scoreToMood(score: number): string {
    if (score >= 80) return 'HAPPY';
    if (score >= 65) return 'CALM';
    if (score >= 50) return 'NEUTRAL';
    if (score >= 35) return 'TIRED';
    if (score >= 20) return 'ANXIOUS';
    return 'STRESSED';
  }

  private getSuggestion(
    risk: string,
    dayOfWeek: number,
    triggers: { trigger: string; negativeRate: number }[],
  ): string {
    const dayNames = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];

    if (risk === 'HIGH') {
      const topTrigger = triggers[0];
      if (topTrigger) {
        return `${dayNames[dayOfWeek]} có nguy cơ stress cao. Yếu tố "${topTrigger.trigger}" thường ảnh hưởng xấu. Hãy chuẩn bị phiên thở trước.`;
      }
      return `${dayNames[dayOfWeek]} có nguy cơ stress cao. Lên kế hoạch nghỉ ngắn giữa ngày nhé.`;
    }
    if (risk === 'MEDIUM') {
      return `${dayNames[dayOfWeek]} có thể hơi căng. Nhớ ghi nhận cảm xúc và nghỉ giải lao nhé.`;
    }
    return `${dayNames[dayOfWeek]} dự kiến ổn. Duy trì thói quen check-in để giữ đà tích cực!`;
  }
}
