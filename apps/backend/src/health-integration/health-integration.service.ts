import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SyncHealthDto } from './dto/sync-health.dto';

@Injectable()
export class HealthIntegrationService {
  constructor(private readonly prisma: PrismaService) {}

  // ── Sync health data from mobile ────────────────────────────────────
  async syncHealthData(userId: string, dto: SyncHealthDto) {
    return this.prisma.appEvent.create({
      data: {
        userId,
        type: 'HEALTH_SYNC',
        data: {
          sleepMinutes: dto.sleepMinutes ?? null,
          heartRate: dto.heartRate ?? null,
          steps: dto.steps ?? null,
          breathingMinutes: dto.breathingMinutes ?? null,
          date: dto.date,
        },
      },
    });
  }

  // ── Health ↔ Mood correlation insights ──────────────────────────────
  async getHealthCorrelation(userId: string) {
    const since = new Date();
    since.setDate(since.getDate() - 30);

    const [healthEvents, moodCheckins] = await Promise.all([
      this.prisma.appEvent.findMany({
        where: { userId, type: 'HEALTH_SYNC', createdAt: { gte: since } },
        orderBy: { createdAt: 'asc' },
      }),
      this.prisma.moodCheckin.findMany({
        where: { userId, createdAt: { gte: since } },
        orderBy: { createdAt: 'asc' },
      }),
    ]);

    // Build a date-indexed map of health data
    const healthByDate = new Map<
      string,
      { sleepMinutes: number; steps: number }
    >();
    for (const event of healthEvents) {
      const d = event.data as Record<string, unknown> | null;
      if (!d) continue;
      const dateKey =
        typeof d.date === 'string' ? d.date.slice(0, 10) : undefined;
      if (!dateKey) continue;
      healthByDate.set(dateKey, {
        sleepMinutes: (d.sleepMinutes as number) ?? 0,
        steps: (d.steps as number) ?? 0,
      });
    }

    // Build a date-indexed map of mood scores
    const moodByDate = new Map<string, { moods: string[]; scores: number[] }>();
    for (const checkin of moodCheckins) {
      const dateKey = checkin.createdAt.toISOString().slice(0, 10);
      const entry = moodByDate.get(dateKey) ?? { moods: [], scores: [] };
      entry.moods.push(checkin.mood);
      if (checkin.finalScore != null) entry.scores.push(checkin.finalScore);
      moodByDate.set(dateKey, entry);
    }

    // Correlate sleep and mood
    const lowSleepMoods: string[] = [];
    const highSleepMoods: string[] = [];
    const lowSleepScores: number[] = [];
    const highSleepScores: number[] = [];
    const highStepScores: number[] = [];
    const lowStepScores: number[] = [];

    const allSteps = [...healthByDate.values()]
      .map((h) => h.steps)
      .filter((s) => s > 0);
    const medianSteps =
      allSteps.length > 0
        ? allSteps.sort((a, b) => a - b)[Math.floor(allSteps.length / 2)]
        : 5000;

    for (const [dateKey, health] of healthByDate) {
      const mood = moodByDate.get(dateKey);
      if (!mood) continue;

      if (health.sleepMinutes > 0 && health.sleepMinutes < 360) {
        lowSleepMoods.push(...mood.moods);
        lowSleepScores.push(...mood.scores);
      } else if (health.sleepMinutes >= 420) {
        highSleepMoods.push(...mood.moods);
        highSleepScores.push(...mood.scores);
      }

      if (health.steps >= medianSteps) {
        highStepScores.push(...mood.scores);
      } else if (health.steps > 0) {
        lowStepScores.push(...mood.scores);
      }
    }

    const avg = (arr: number[]) =>
      arr.length > 0 ? arr.reduce((a, b) => a + b, 0) / arr.length : null;

    const avgLowSleep = avg(lowSleepScores);
    const avgHighSleep = avg(highSleepScores);
    const avgHighSteps = avg(highStepScores);
    const avgLowSteps = avg(lowStepScores);

    const insights: string[] = [];

    // Count stress on low-sleep days
    const stressCountLow = lowSleepMoods.filter((m) => m === 'STRESSED').length;
    const totalLow = lowSleepMoods.length;
    if (totalLow > 0) {
      const pct = Math.round((stressCountLow / totalLow) * 100);
      if (pct > 0) {
        insights.push(
          `Những ngày ngủ dưới 6 tiếng, mood STRESSED chiếm ${pct}%`,
        );
      }
    }

    if (avgLowSleep !== null && avgHighSleep !== null) {
      const diff = Math.round(avgHighSleep - avgLowSleep);
      if (diff > 0) {
        insights.push(
          `Ngủ đủ 7+ tiếng giúp mood score cao hơn trung bình ${diff} điểm`,
        );
      }
    }

    if (avgHighSteps !== null && avgLowSteps !== null) {
      const diff = Math.round(avgHighSteps - avgLowSteps);
      if (diff > 0) {
        insights.push(
          `Ngày vận động nhiều, mood score cao hơn ${diff} điểm so với ngày ít vận động`,
        );
      }
    }

    if (insights.length === 0) {
      insights.push(
        'Chưa đủ dữ liệu để phân tích tương quan. Hãy đồng bộ thêm dữ liệu sức khỏe!',
      );
    }

    return {
      insights,
      summary: {
        totalHealthEvents: healthEvents.length,
        totalMoodCheckins: moodCheckins.length,
        avgScoreLowSleep: avgLowSleep,
        avgScoreHighSleep: avgHighSleep,
        avgScoreHighSteps: avgHighSteps,
        avgScoreLowSteps: avgLowSteps,
        medianSteps,
      },
    };
  }

  // ── Integration status ──────────────────────────────────────────────
  async getIntegrationStatus(userId: string) {
    const links = await this.prisma.integrationLink.findMany({
      where: { userId },
      select: { type: true, isActive: true, createdAt: true, updatedAt: true },
    });

    const statusMap: Record<
      string,
      { isActive: boolean; linkedAt: Date | null }
    > = {
      APPLE_HEALTH: { isActive: false, linkedAt: null },
      GOOGLE_FIT: { isActive: false, linkedAt: null },
    };

    for (const link of links) {
      statusMap[link.type] = {
        isActive: link.isActive,
        linkedAt: link.createdAt,
      };
    }

    return statusMap;
  }

  // ── Link integration ────────────────────────────────────────────────
  async linkIntegration(userId: string, type: string) {
    return this.prisma.integrationLink.upsert({
      where: { userId_type: { userId, type } },
      create: { userId, type, isActive: true },
      update: { isActive: true },
    });
  }

  // ── Unlink integration ──────────────────────────────────────────────
  async unlinkIntegration(userId: string, type: string) {
    const existing = await this.prisma.integrationLink.findUnique({
      where: { userId_type: { userId, type } },
    });
    if (!existing) return { success: true };

    await this.prisma.integrationLink.update({
      where: { id: existing.id },
      data: { isActive: false },
    });

    return { success: true };
  }
}
