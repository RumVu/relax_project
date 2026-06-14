import { Injectable } from '@nestjs/common';
import { MoodType, RelaxActivityType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

interface TimingBucket {
  hour: number;
  count: number;
  stressCount: number;
  stressRatio: number;
}

interface ActivityEffectiveness {
  activityType: RelaxActivityType;
  avgRelief: number;
  sessionCount: number;
}

interface NotificationPattern {
  hour: number;
  total: number;
  read: number;
  readRate: number;
}

export interface AdaptivePlan {
  timingSuggestions: Array<{
    period: string;
    suggestion: string;
    reason: string;
    stressRatio: number;
  }>;
  activityPriorities: Array<{
    activityType: string;
    label: string;
    avgRelief: number;
    sessionCount: number;
    reason: string;
  }>;
  notificationAdjustments: Array<{
    period: string;
    suggestion: string;
    reason: string;
    readRate: number;
  }>;
  breathingVsMusic: {
    breathingAvgRelief: number | null;
    musicAvgRelief: number | null;
    recommendation: string;
    reason: string;
  };
  generatedAt: string;
}

@Injectable()
export class AdaptivePlanService {
  constructor(private readonly prisma: PrismaService) {}

  async generateAdaptivePlan(userId: string): Promise<AdaptivePlan> {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    // 1. Time-of-day mood patterns
    const moodCheckins = await this.prisma.moodCheckin.findMany({
      where: { userId, createdAt: { gte: thirtyDaysAgo } },
      select: { mood: true, createdAt: true, trigger: true },
      orderBy: { createdAt: 'desc' },
    });

    const timingBuckets = this.buildTimingBuckets(moodCheckins);
    const timingSuggestions = this.buildTimingSuggestions(timingBuckets);

    // 2. Activity effectiveness
    const relaxSessions = await this.prisma.relaxSession.findMany({
      where: {
        userId,
        status: 'FINISHED',
        stressReliefPercent: { not: null },
        createdAt: { gte: thirtyDaysAgo },
      },
      select: { activityType: true, stressReliefPercent: true },
    });

    const activityEffectiveness =
      this.buildActivityEffectiveness(relaxSessions);
    const activityPriorities = this.buildActivityPriorities(
      activityEffectiveness,
    );

    // 3. Breathing vs music comparison
    const breathingSessions = await this.prisma.breathingSession.findMany({
      where: {
        userId,
        moodBefore: { not: null },
        moodAfter: { not: null },
        startedAt: { gte: thirtyDaysAgo },
      },
      select: { moodBefore: true, moodAfter: true },
    });

    const breathingVsMusic = this.buildBreathingVsMusic(
      breathingSessions,
      activityEffectiveness,
    );

    // 4. Notification engagement patterns
    const notifications = await this.prisma.notification.findMany({
      where: { userId, createdAt: { gte: thirtyDaysAgo } },
      select: { createdAt: true, isRead: true },
    });

    const notifPatterns = this.buildNotificationPatterns(notifications);
    const notificationAdjustments =
      this.buildNotificationAdjustments(notifPatterns);

    return {
      timingSuggestions,
      activityPriorities,
      notificationAdjustments,
      breathingVsMusic,
      generatedAt: new Date().toISOString(),
    };
  }

  async getInsights(userId: string): Promise<string[]> {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const insights: string[] = [];

    // Insight 1: Sleep vs stress correlation
    const sleepSessions = await this.prisma.sleepSession.findMany({
      where: { userId, createdAt: { gte: thirtyDaysAgo } },
      select: { startedAt: true, endedAt: true },
    });

    const moodCheckins = await this.prisma.moodCheckin.findMany({
      where: { userId, createdAt: { gte: thirtyDaysAgo } },
      select: { mood: true, createdAt: true },
    });

    if (sleepSessions.length >= 5 && moodCheckins.length >= 5) {
      const shortSleepDays = new Set<string>();
      const normalSleepDays = new Set<string>();

      for (const s of sleepSessions) {
        if (!s.endedAt) continue;
        const hours =
          (s.endedAt.getTime() - s.startedAt.getTime()) / (1000 * 60 * 60);
        const dateKey = s.startedAt.toISOString().slice(0, 10);
        if (hours < 6) shortSleepDays.add(dateKey);
        else normalSleepDays.add(dateKey);
      }

      let shortSleepStress = 0;
      let shortSleepTotal = 0;
      let normalSleepStress = 0;
      let normalSleepTotal = 0;

      for (const m of moodCheckins) {
        const dateKey = m.createdAt.toISOString().slice(0, 10);
        if (shortSleepDays.has(dateKey)) {
          shortSleepTotal++;
          if (m.mood === MoodType.STRESSED || m.mood === MoodType.ANXIOUS)
            shortSleepStress++;
        } else if (normalSleepDays.has(dateKey)) {
          normalSleepTotal++;
          if (m.mood === MoodType.STRESSED || m.mood === MoodType.ANXIOUS)
            normalSleepStress++;
        }
      }

      if (shortSleepTotal >= 3 && normalSleepTotal >= 3) {
        const shortRatio = Math.round(
          (shortSleepStress / shortSleepTotal) * 100,
        );
        const normalRatio = Math.round(
          (normalSleepStress / normalSleepTotal) * 100,
        );
        const diff = shortRatio - normalRatio;
        if (diff > 10) {
          insights.push(
            `Những ngày ngủ dưới 6 tiếng, mood STRESSED tăng ${diff}%`,
          );
        }
      }
    }

    // Insight 2: Most effective time for activities
    const relaxSessions = await this.prisma.relaxSession.findMany({
      where: {
        userId,
        status: 'FINISHED',
        stressReliefPercent: { not: null, gte: 50 },
        createdAt: { gte: thirtyDaysAgo },
      },
      select: { startedAt: true, stressReliefPercent: true },
    });

    if (relaxSessions.length >= 5) {
      const hourCounts: Record<string, { total: number; count: number }> = {};
      for (const s of relaxSessions) {
        const h = s.startedAt.getHours();
        const period = this.hourToPeriod(h);
        if (!hourCounts[period]) hourCounts[period] = { total: 0, count: 0 };
        hourCounts[period].total += s.stressReliefPercent ?? 0;
        hourCounts[period].count++;
      }

      let bestPeriod = '';
      let bestAvg = 0;
      for (const [period, data] of Object.entries(hourCounts)) {
        const avg = data.total / data.count;
        if (avg > bestAvg) {
          bestAvg = avg;
          bestPeriod = period;
        }
      }

      if (bestPeriod && bestAvg > 40) {
        insights.push(
          `Hoạt động thư giãn hiệu quả nhất vào ${bestPeriod} (giảm stress trung bình ${Math.round(bestAvg)}%)`,
        );
      }
    }

    // Insight 3: Trigger frequency
    const triggerCheckins = await this.prisma.moodCheckin.findMany({
      where: {
        userId,
        trigger: { not: null },
        createdAt: { gte: thirtyDaysAgo },
      },
      select: { trigger: true },
    });

    if (triggerCheckins.length >= 3) {
      const counts: Record<string, number> = {};
      for (const c of triggerCheckins) {
        if (c.trigger) counts[c.trigger] = (counts[c.trigger] ?? 0) + 1;
      }
      const sorted = Object.entries(counts).sort((a, b) => b[1] - a[1]);
      if (sorted.length > 0) {
        const [trigger, count] = sorted[0];
        insights.push(
          `Trigger xuất hiện nhiều nhất: ${trigger.toLowerCase().replace('_', ' ')} (${count} lần trong 30 ngày)`,
        );
      }
    }

    // Insight 4: Journal mood correlation
    const journals = await this.prisma.journal.findMany({
      where: {
        userId,
        mood: { not: null },
        createdAt: { gte: thirtyDaysAgo },
      },
      select: { mood: true, createdAt: true },
    });

    if (journals.length >= 3) {
      const journalDays = new Set(
        journals.map((j) => j.createdAt.toISOString().slice(0, 10)),
      );
      const allDays = new Set(
        moodCheckins.map((m) => m.createdAt.toISOString().slice(0, 10)),
      );

      let journalDayPositive = 0;
      let journalDayTotal = 0;
      let nonJournalDayPositive = 0;
      let nonJournalDayTotal = 0;

      for (const m of moodCheckins) {
        const dateKey = m.createdAt.toISOString().slice(0, 10);
        const positive =
          m.mood === MoodType.HAPPY ||
          m.mood === MoodType.CALM ||
          m.mood === MoodType.GRATEFUL ||
          m.mood === MoodType.EXCITED;
        if (journalDays.has(dateKey)) {
          journalDayTotal++;
          if (positive) journalDayPositive++;
        } else if (allDays.has(dateKey)) {
          nonJournalDayTotal++;
          if (positive) nonJournalDayPositive++;
        }
      }

      if (journalDayTotal >= 3 && nonJournalDayTotal >= 3) {
        const journalRate = Math.round(
          (journalDayPositive / journalDayTotal) * 100,
        );
        const nonRate = Math.round(
          (nonJournalDayPositive / nonJournalDayTotal) * 100,
        );
        if (journalRate > nonRate + 10) {
          insights.push(
            `Những ngày viết nhật ký, mood tích cực cao hơn ${journalRate - nonRate}%`,
          );
        }
      }
    }

    // Insight 5: Consistency insight
    const checkinDays = new Set(
      moodCheckins.map((m) => m.createdAt.toISOString().slice(0, 10)),
    );
    if (checkinDays.size >= 20) {
      insights.push(
        `Bạn đã check-in ${checkinDays.size}/30 ngày gần đây — tuyệt vời!`,
      );
    } else if (checkinDays.size >= 10) {
      insights.push(
        `Bạn check-in ${checkinDays.size}/30 ngày. Thử check-in mỗi ngày để nhận gợi ý chính xác hơn!`,
      );
    }

    if (insights.length === 0) {
      insights.push(
        'Chưa đủ dữ liệu để phân tích. Hãy tiếp tục sử dụng app mỗi ngày nhé!',
      );
    }

    return insights;
  }

  // ── Helpers ──────────────────────────────────────────────

  private buildTimingBuckets(
    checkins: Array<{ mood: MoodType; createdAt: Date }>,
  ): TimingBucket[] {
    const buckets: Record<number, { count: number; stressCount: number }> = {};
    for (let h = 0; h < 24; h++) buckets[h] = { count: 0, stressCount: 0 };

    for (const c of checkins) {
      const h = c.createdAt.getHours();
      buckets[h].count++;
      if (c.mood === MoodType.STRESSED || c.mood === MoodType.ANXIOUS) {
        buckets[h].stressCount++;
      }
    }

    return Object.entries(buckets)
      .filter(([, v]) => v.count > 0)
      .map(([h, v]) => ({
        hour: parseInt(h, 10),
        count: v.count,
        stressCount: v.stressCount,
        stressRatio: v.count > 0 ? v.stressCount / v.count : 0,
      }))
      .sort((a, b) => b.stressRatio - a.stressRatio);
  }

  private buildTimingSuggestions(
    buckets: TimingBucket[],
  ): AdaptivePlan['timingSuggestions'] {
    const suggestions: AdaptivePlan['timingSuggestions'] = [];

    // Find stress peak periods
    const stressPeaks = buckets.filter(
      (b) => b.stressRatio >= 0.4 && b.count >= 2,
    );

    for (const peak of stressPeaks.slice(0, 3)) {
      const period = this.hourToPeriod(peak.hour);
      suggestions.push({
        period,
        suggestion: `Đặt nhắc nhở hít thở lúc ${peak.hour}h`,
        reason: `${Math.round(peak.stressRatio * 100)}% check-in lúc ${peak.hour}h là stressed/anxious`,
        stressRatio: Math.round(peak.stressRatio * 100),
      });
    }

    // Find calm periods — suggest maintaining
    const calmBuckets = buckets.filter(
      (b) => b.stressRatio < 0.2 && b.count >= 2,
    );
    if (calmBuckets.length > 0) {
      const bestCalm = calmBuckets[calmBuckets.length - 1];
      suggestions.push({
        period: this.hourToPeriod(bestCalm.hour),
        suggestion: `Giữ thói quen tốt lúc ${bestCalm.hour}h — đây là lúc bạn bình yên nhất`,
        reason: `Chỉ ${Math.round(bestCalm.stressRatio * 100)}% stress vào khung giờ này`,
        stressRatio: Math.round(bestCalm.stressRatio * 100),
      });
    }

    return suggestions;
  }

  private buildActivityEffectiveness(
    sessions: Array<{
      activityType: RelaxActivityType;
      stressReliefPercent: number | null;
    }>,
  ): ActivityEffectiveness[] {
    const map: Record<string, { total: number; count: number }> = {};
    for (const s of sessions) {
      if (!map[s.activityType]) map[s.activityType] = { total: 0, count: 0 };
      map[s.activityType].total += s.stressReliefPercent ?? 0;
      map[s.activityType].count++;
    }

    return Object.entries(map)
      .map(([type, data]) => ({
        activityType: type as RelaxActivityType,
        avgRelief: Math.round(data.total / data.count),
        sessionCount: data.count,
      }))
      .sort((a, b) => b.avgRelief - a.avgRelief);
  }

  private buildActivityPriorities(
    effectiveness: ActivityEffectiveness[],
  ): AdaptivePlan['activityPriorities'] {
    const labels: Record<string, string> = {
      BREATHING: 'Hít thở',
      MEDITATION: 'Thiền',
      MUSIC: 'Nghe nhạc',
      JOURNAL: 'Nhật ký',
      PODCAST: 'Podcast',
      MYSTERY: 'Khám phá',
    };

    return effectiveness.map((e, i) => ({
      activityType: e.activityType,
      label: labels[e.activityType] ?? e.activityType,
      avgRelief: e.avgRelief,
      sessionCount: e.sessionCount,
      reason:
        i === 0
          ? `Hiệu quả nhất của bạn (giảm ${e.avgRelief}% stress, ${e.sessionCount} lần)`
          : `Giảm ${e.avgRelief}% stress trung bình qua ${e.sessionCount} lần`,
    }));
  }

  private buildBreathingVsMusic(
    breathingSessions: Array<{
      moodBefore: MoodType | null;
      moodAfter: MoodType | null;
    }>,
    activityEffectiveness: ActivityEffectiveness[],
  ): AdaptivePlan['breathingVsMusic'] {
    const musicData = activityEffectiveness.find(
      (e) => e.activityType === 'MUSIC',
    );
    const breathingRelaxData = activityEffectiveness.find(
      (e) => e.activityType === 'BREATHING',
    );

    const breathingAvgRelief = breathingRelaxData?.avgRelief ?? null;
    const musicAvgRelief = musicData?.avgRelief ?? null;

    let recommendation: string;
    let reason: string;

    if (breathingAvgRelief !== null && musicAvgRelief !== null) {
      if (breathingAvgRelief > musicAvgRelief) {
        recommendation = 'Hít thở hiệu quả hơn nghe nhạc với bạn';
        reason = `Breathing giảm ${breathingAvgRelief}% vs Music giảm ${musicAvgRelief}%`;
      } else if (musicAvgRelief > breathingAvgRelief) {
        recommendation = 'Nghe nhạc hiệu quả hơn hít thở với bạn';
        reason = `Music giảm ${musicAvgRelief}% vs Breathing giảm ${breathingAvgRelief}%`;
      } else {
        recommendation = 'Hít thở và nghe nhạc hiệu quả tương đương';
        reason = `Cả hai giảm ${breathingAvgRelief}% stress`;
      }
    } else if (breathingAvgRelief !== null) {
      recommendation = 'Hãy thử nghe nhạc để so sánh';
      reason = `Breathing giảm ${breathingAvgRelief}% — chưa có dữ liệu music`;
    } else if (musicAvgRelief !== null) {
      recommendation = 'Hãy thử hít thở để so sánh';
      reason = `Music giảm ${musicAvgRelief}% — chưa có dữ liệu breathing`;
    } else {
      recommendation = 'Hãy thử cả hai để tìm ra cái phù hợp';
      reason = 'Chưa có đủ dữ liệu để so sánh';
    }

    return { breathingAvgRelief, musicAvgRelief, recommendation, reason };
  }

  private buildNotificationPatterns(
    notifications: Array<{ createdAt: Date; isRead: boolean }>,
  ): NotificationPattern[] {
    const buckets: Record<number, { total: number; read: number }> = {};
    for (const n of notifications) {
      const h = n.createdAt.getHours();
      if (!buckets[h]) buckets[h] = { total: 0, read: 0 };
      buckets[h].total++;
      if (n.isRead) buckets[h].read++;
    }

    return Object.entries(buckets)
      .map(([h, data]) => ({
        hour: parseInt(h, 10),
        total: data.total,
        read: data.read,
        readRate: data.total > 0 ? data.read / data.total : 0,
      }))
      .sort((a, b) => a.readRate - b.readRate);
  }

  private buildNotificationAdjustments(
    patterns: NotificationPattern[],
  ): AdaptivePlan['notificationAdjustments'] {
    const adjustments: AdaptivePlan['notificationAdjustments'] = [];

    // Low engagement periods
    const lowEngagement = patterns.filter(
      (p) => p.readRate < 0.3 && p.total >= 3,
    );
    for (const le of lowEngagement.slice(0, 2)) {
      adjustments.push({
        period: this.hourToPeriod(le.hour),
        suggestion: `Giảm thông báo lúc ${le.hour}h — bạn ít đọc`,
        reason: `Chỉ ${Math.round(le.readRate * 100)}% thông báo được đọc vào ${le.hour}h`,
        readRate: Math.round(le.readRate * 100),
      });
    }

    // High engagement periods
    const highEngagement = patterns.filter(
      (p) => p.readRate >= 0.7 && p.total >= 3,
    );
    for (const he of highEngagement.slice(0, 2)) {
      adjustments.push({
        period: this.hourToPeriod(he.hour),
        suggestion: `Tầng thông báo lúc ${he.hour}h — bạn hay đọc`,
        reason: `${Math.round(he.readRate * 100)}% thông báo được đọc vào ${he.hour}h`,
        readRate: Math.round(he.readRate * 100),
      });
    }

    return adjustments;
  }

  private hourToPeriod(hour: number): string {
    if (hour >= 5 && hour < 9) return 'Sáng sớm';
    if (hour >= 9 && hour < 12) return 'Buổi sáng';
    if (hour >= 12 && hour < 14) return 'Giữa trưa';
    if (hour >= 14 && hour < 18) return 'Chiều';
    if (hour >= 18 && hour < 21) return 'Tối';
    return 'Đêm khuya';
  }
}
