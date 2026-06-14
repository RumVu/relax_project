import { Injectable } from '@nestjs/common';
import { MoodType, RelaxActivityType, TriggerType } from '@prisma/client';
import {
  getTimezoneOffsetMinutes,
  normalizeTimezone,
} from '../common/timezone';
import { MoodAnalyticsPeriod } from '../mood-checkins/dto/mood-analytics-query.dto';
import { MoodCheckinsService } from '../mood-checkins/mood-checkins.service';
import { JournalsService } from '../journals/journals.service';
import { PrismaService } from '../prisma/prisma.service';
import { RelaxStatsPeriod } from '../relax-activities/dto/relax-activity-query.dto';
import { RelaxActivitiesService } from '../relax-activities/relax-activities.service';
import { RedisService } from '../redis/redis.service';
import { UserCompanionsService } from '../user-companions/user-companions.service';
import { AnalyticsPeriod, AnalyticsQueryDto } from './analytics-query.dto';

const ANALYTICS_OVERVIEW_CACHE_TTL_SECONDS = 60;

@Injectable()
export class AnalyticsService {
  constructor(
    private readonly moodCheckinsService: MoodCheckinsService,
    private readonly journalsService: JournalsService,
    private readonly relaxActivitiesService: RelaxActivitiesService,
    private readonly userCompanionsService: UserCompanionsService,
    private readonly prisma: PrismaService,
    private readonly redisService: RedisService,
  ) {}

  async getOverview(userId: string, query: AnalyticsQueryDto) {
    const period = query.period ?? AnalyticsPeriod.WEEK;
    const timezone = await this.resolveTimezone(userId, query.timezone);
    const timezoneOffsetMinutes =
      query.timezoneOffsetMinutes ?? getTimezoneOffsetMinutes(timezone);

    return this.redisService.remember(
      [
        'analytics',
        'overview',
        userId,
        period,
        timezone,
        timezoneOffsetMinutes,
      ].join(':'),
      ANALYTICS_OVERVIEW_CACHE_TTL_SECONDS,
      async () => {
        const [mood, journals, relax, companion] = await Promise.all([
          this.moodCheckinsService.getAnalytics(userId, {
            period: period as unknown as MoodAnalyticsPeriod,
            timezone,
            timezoneOffsetMinutes,
          }),
          this.journalsService.getStats(userId, {}),
          this.relaxActivitiesService.getStats(userId, {
            period: period as unknown as RelaxStatsPeriod,
            timezone,
            timezoneOffsetMinutes,
          }),
          this.userCompanionsService.getStats(userId),
        ]);

        return {
          period,
          timezone,
          timezoneOffsetMinutes,
          mood,
          journals,
          relax,
          companion,
          summaryCards: {
            currentStreak: mood.streak.current,
            totalRelaxTime: relax.totalDurationLabel,
            totalJournals: journals.total,
            companionAffection: companion.companion.affection,
            stressReduction: mood.delta?.stressReduction ?? 0,
          },
        };
      },
    );
  }

  getContracts() {
    return {
      moodScore: {
        scale: '0-100',
        meaning: 'Điểm càng cao càng căng thẳng; điểm càng thấp càng thư giãn.',
        rawScore: 'Điểm thô khi người dùng chọn mood/mức độ trước activity.',
        finalScore: 'Điểm sau khi hoàn thành activity/check-in relief.',
        effectiveScore: 'finalScore ?? rawScore ?? scoreFromMood(mood)',
      },
      weeklyMoodStat: {
        weekStartsOn: 'MONDAY',
        timezoneSource:
          'query.timezone > userPreference.timezone > Asia/Ho_Chi_Minh',
        avgScore: 'Trung bình effectiveScore trong tuần theo timezone user.',
        stressReducePct:
          'previousWeekAvgScore - currentWeekAvgScore. Số dương nghĩa là stress giảm.',
        materialization:
          'Tự cập nhật khi mood check-in thay đổi và có job/admin endpoint recalculate.',
      },
      dashboardCards: [
        {
          key: 'currentStreak',
          source: 'mood.streak.current',
          unit: 'days',
        },
        {
          key: 'totalRelaxTime',
          source: 'relax.totalDurationLabel',
          unit: 'duration',
        },
        {
          key: 'totalJournals',
          source: 'journals.total',
          unit: 'count',
        },
        {
          key: 'companionAffection',
          source: 'companion.companion.affection',
          unit: '0-100',
        },
        {
          key: 'stressReduction',
          source: 'mood.delta.stressReduction',
          unit: 'percent',
        },
      ],
      charts: {
        moodTimeline: {
          endpoint: 'GET /mood-checkins/me/analytics',
          x: 'timeline[].label/date',
          y: 'timeline[].moodScore',
          grouping: 'day',
        },
        weeklyStats: {
          endpoint: 'GET /mood-checkins/me/weekly-stats',
          x: 'weekStart',
          y: 'avgScore',
          compare: 'stressReducePct',
        },
        relaxBreakdown: {
          endpoint: 'GET /relax-activities/me/stats',
          x: 'activityBreakdown[].activityType',
          y: 'activityBreakdown[].totalDurationSeconds',
        },
      },
    };
  }

  private async resolveTimezone(userId: string, timezone?: string) {
    if (timezone) {
      return normalizeTimezone(timezone);
    }

    const preferences = await this.prisma.userPreference.findUnique({
      where: { userId },
      select: { timezone: true },
    });

    return normalizeTimezone(preferences?.timezone);
  }

  async getMoodRecovery(userId: string) {
    const sessions = await this.prisma.relaxSession.findMany({
      where: {
        userId,
        status: 'FINISHED',
      },
      orderBy: { endedAt: 'desc' },
    });

    if (sessions.length === 0) {
      return {
        overallRecoveryScore: 0,
        activityStats: [],
        bestActivity: null,
      };
    }

    const activityStatsMap = new Map<
      string,
      { totalScore: number; totalRelief: number; count: number }
    >();

    let totalScoreSum = 0;
    let totalScoreCount = 0;

    for (const session of sessions) {
      let score = session.stressReliefPercent;
      if (score == null && session.reliefLevel != null) {
        score = session.reliefLevel * 10;
      }
      if (score == null) {
        if (session.moodBefore && session.moodAfter) {
          const isBeforeNegative = ['STRESSED', 'ANXIOUS', 'SAD', 'TIRED'].includes(session.moodBefore);
          const isAfterPositive = ['HAPPY', 'CALM'].includes(session.moodAfter);
          score = (isBeforeNegative && isAfterPositive) ? 80 : 40;
        } else {
          score = 50;
        }
      }

      totalScoreSum += score;
      totalScoreCount++;

      const type = session.activityType;
      const relief = session.reliefLevel ?? 5;

      const existing = activityStatsMap.get(type) ?? {
        totalScore: 0,
        totalRelief: 0,
        count: 0,
      };

      existing.totalScore += score;
      existing.totalRelief += relief;
      existing.count += 1;

      activityStatsMap.set(type, existing);
    }

    const activityStats = Array.from(activityStatsMap.entries()).map(
      ([activityType, data]) => ({
        activityType,
        count: data.count,
        avgRecoveryScore: Math.round((data.totalScore / data.count) * 10) / 10,
        avgReliefLevel: Math.round((data.totalRelief / data.count) * 10) / 10,
      }),
    );

    activityStats.sort((a, b) => b.avgRecoveryScore - a.avgRecoveryScore);

    const overallRecoveryScore =
      totalScoreCount > 0 ? Math.round((totalScoreSum / totalScoreCount) * 10) / 10 : 0;

    const bestActivity = activityStats.length > 0 ? activityStats[0].activityType : null;

    return {
      overallRecoveryScore,
      activityStats,
      bestActivity,
    };
  }

  async getMoodPatterns(userId: string) {
    const checkins = await this.prisma.moodCheckin.findMany({
      where: { userId },
      orderBy: { createdAt: 'asc' },
    });

    const sessions = await this.prisma.relaxSession.findMany({
      where: { userId, status: 'FINISHED' },
      orderBy: { endedAt: 'asc' },
    });

    // 1. Mood by Hour
    const hourlyMoods = { morning: [] as number[], afternoon: [] as number[], evening: [] as number[], night: [] as number[] };
    for (const c of checkins) {
      const hr = c.createdAt.getHours();
      const score = c.intensity ?? 5;
      if (hr >= 5 && hr < 11) hourlyMoods.morning.push(score);
      else if (hr >= 11 && hr < 17) hourlyMoods.afternoon.push(score);
      else if (hr >= 17 && hr < 22) hourlyMoods.evening.push(score);
      else hourlyMoods.night.push(score);
    }

    const avgScore = (arr: number[]) => arr.length > 0 ? Math.round((arr.reduce((a, b) => a + b, 0) / arr.length) * 10) / 10 : 5;
    const moodByHour = {
      morning: avgScore(hourlyMoods.morning),
      afternoon: avgScore(hourlyMoods.afternoon),
      evening: avgScore(hourlyMoods.evening),
      night: avgScore(hourlyMoods.night),
    };

    // 2. Mood by Weekday
    const weekdayMoods = Array.from({ length: 7 }, () => [] as number[]);
    for (const c of checkins) {
      const day = c.createdAt.getDay(); // 0 is Sunday, 1 is Monday...
      weekdayMoods[day].push(c.intensity ?? 5);
    }
    const weekdayNames = ['Chủ nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
    const moodByWeekday = weekdayNames.map((name, index) => ({
      name,
      avgScore: avgScore(weekdayMoods[index]),
      count: weekdayMoods[index].length,
    }));

    // 3. Mood by Trigger
    const triggerMap = new Map<TriggerType, number[]>();
    for (const c of checkins) {
      if (c.trigger) {
        const list = triggerMap.get(c.trigger) ?? [];
        list.push(c.intensity ?? 5);
        triggerMap.set(c.trigger, list);
      }
    }
    const moodByTrigger = Array.from(triggerMap.entries()).map(([trigger, list]) => ({
      trigger,
      avgScore: avgScore(list),
      count: list.length,
    })).sort((a, b) => b.count - a.count);

    // 4. Mood improvement by Activity
    const activityMap = new Map<RelaxActivityType, number[]>();
    for (const s of sessions) {
      if (s.stressReliefPercent != null) {
        const list = activityMap.get(s.activityType) ?? [];
        list.push(s.stressReliefPercent);
        activityMap.set(s.activityType, list);
      }
    }
    const moodByActivity = Array.from(activityMap.entries()).map(([activity, list]) => ({
      activity,
      avgReliefPercent: Math.round((list.reduce((a, b) => a + b, 0) / list.length) * 10) / 10,
      count: list.length,
    }));

    // 5. AI dynamic summary generator
    let aiSummary = 'Bắt đầu check-in cảm xúc thường xuyên để linh thú Mon Leo tìm ra quy luật sức khoẻ tinh thần của bạn nhé!';
    if (checkins.length >= 3) {
      // Find highest stress hour
      const sortedHours = Object.entries(moodByHour).sort((a, b) => b[1] - a[1]);
      const peakHour = sortedHours[0];
      const peakHourLabel = peakHour[0] === 'night' ? 'sau 22h đêm' : peakHour[0] === 'evening' ? 'buổi tối (17h-22h)' : peakHour[0] === 'afternoon' ? 'buổi chiều (11h-17h)' : 'buổi sáng';

      // Find best activity
      const bestAct = moodByActivity.sort((a, b) => b.avgReliefPercent - a.avgReliefPercent)[0];
      const bestActLabel = bestAct ? (bestAct.activity === 'BREATHING' ? 'Hít thở' : bestAct.activity === 'MEDITATION' ? 'Thiền định' : bestAct.activity === 'MUSIC' ? 'Âm thanh' : 'Nhật ký') : 'Hít thở';

      aiSummary = `Bạn thường cảm thấy căng thẳng hơn vào ${peakHourLabel}. Lịch sử ghi nhận bạn hồi phục tốt hơn và giải toả áp lực hiệu quả nhất với hoạt động ${bestActLabel}.`;
    }

    return {
      moodByHour,
      moodByWeekday,
      moodByTrigger,
      moodByActivity,
      aiSummary,
    };
  }

  async getMoodCalendar(userId: string) {
    const today = new Date();
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(today.getDate() - 30);

    const [checkins, journals, sessions, sleep] = await Promise.all([
      this.prisma.moodCheckin.findMany({
        where: { userId, createdAt: { gte: thirtyDaysAgo } },
        orderBy: { createdAt: 'asc' },
      }),
      this.prisma.journal.findMany({
        where: { userId, createdAt: { gte: thirtyDaysAgo } },
        orderBy: { createdAt: 'asc' },
      }),
      this.prisma.relaxSession.findMany({
        where: { userId, status: 'FINISHED', endedAt: { gte: thirtyDaysAgo } },
        orderBy: { endedAt: 'asc' },
      }),
      this.prisma.sleepSession.findMany({
        where: { userId, startedAt: { gte: thirtyDaysAgo } },
        orderBy: { startedAt: 'asc' },
      }),
    ]);

    const calendarMap = new Map<string, { moods: string[]; hasJournal: boolean; hasRelaxSession: boolean; avgSleepQuality: number | null; stressLevel: number | null }>();

    // Init 30 days
    for (let i = 0; i < 30; i++) {
      const date = new Date(thirtyDaysAgo);
      date.setDate(date.getDate() + i);
      const key = date.toISOString().split('T')[0];
      calendarMap.set(key, { moods: [], hasJournal: false, hasRelaxSession: false, avgSleepQuality: null, stressLevel: null });
    }

    // Populate Moods
    for (const c of checkins) {
      const key = c.createdAt.toISOString().split('T')[0];
      const dayData = calendarMap.get(key);
      if (dayData) {
        dayData.moods.push(c.mood);
        if (c.intensity != null) {
          dayData.stressLevel = dayData.stressLevel != null ? Math.round((dayData.stressLevel + c.intensity) / 2) : c.intensity;
        }
      }
    }

    // Populate Journals
    for (const j of journals) {
      const key = j.createdAt.toISOString().split('T')[0];
      const dayData = calendarMap.get(key);
      if (dayData) {
        dayData.hasJournal = true;
      }
    }

    // Populate Relax Sessions
    for (const s of sessions) {
      if (s.endedAt) {
        const key = s.endedAt.toISOString().split('T')[0];
        const dayData = calendarMap.get(key);
        if (dayData) {
          dayData.hasRelaxSession = true;
        }
      }
    }

    // Populate Sleep Quality
    const sleepMap = new Map<string, number[]>();
    for (const sl of sleep) {
      const key = sl.startedAt.toISOString().split('T')[0];
      if (sl.quality != null) {
        const list = sleepMap.get(key) ?? [];
        list.push(sl.quality);
        sleepMap.set(key, list);
      }
    }
    for (const [key, list] of sleepMap.entries()) {
      const dayData = calendarMap.get(key);
      if (dayData && list.length > 0) {
        dayData.avgSleepQuality = Math.round(list.reduce((a, b) => a + b, 0) / list.length);
      }
    }

    return Array.from(calendarMap.entries()).map(([date, data]) => ({
      date,
      ...data,
    }));
  }

  async getBurnoutSignal(userId: string) {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const [checkins, sleep] = await Promise.all([
      this.prisma.moodCheckin.findMany({
        where: { userId, createdAt: { gte: sevenDaysAgo } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.sleepSession.findMany({
        where: { userId, startedAt: { gte: sevenDaysAgo } },
        orderBy: { startedAt: 'desc' },
      }),
    ]);

    let hasSignal = false;
    let level = 'NONE';
    let message = 'Tình trạng sức khỏe tinh thần của bạn hiện tại rất ổn định. Tiếp tục duy trì lối sống lành mạnh này nhé!';
    const details: string[] = [];

    // Rule 1: High stress for consecutive check-ins
    const highStressCheckins = checkins.filter(c => c.intensity != null && c.intensity >= 7);
    if (highStressCheckins.length >= 3) {
      details.push('Phát hiện 3 phiên check-in có mức độ căng thẳng cao liên tục.');
    }

    // Rule 2: Consecutive negative moods
    const negativeMoodsCount = checkins.filter(c => ['STRESSED', 'ANXIOUS', 'SAD', 'TIRED'].includes(c.mood)).length;
    if (checkins.length >= 4 && negativeMoodsCount / checkins.length >= 0.75) {
      details.push('Hơn 75% số lần check-in ghi nhận tâm trạng tiêu cực.');
    }

    // Rule 3: Poor sleep quality
    const poorSleepCount = sleep.filter(s => s.quality != null && s.quality <= 2).length;
    if (poorSleepCount >= 2) {
      details.push('Giấc ngủ của bạn có chất lượng kém trong nhiều đêm gần đây.');
    }

    // Calculate level & message
    if (details.length >= 3) {
      hasSignal = true;
      level = 'SEVERE';
      message = 'Báo động: Cơ thể bạn đang phát đi những tín hiệu quá tải (Burnout) nghiêm trọng. Vui lòng tạm dừng công việc và dành ít nhất 5-10 phút hít thở sâu hoặc thiền ngay lập tức!';
    } else if (details.length === 2) {
      hasSignal = true;
      level = 'MODERATE';
      message = 'Cảnh báo: Bạn đang có dấu hiệu quá tải và căng thẳng kéo dài. Hãy tự thưởng cho mình một buổi tối offline hoàn toàn và nghe nhạc nhẹ trước khi ngủ nhé.';
    } else if (details.length === 1) {
      hasSignal = true;
      level = 'LIGHT';
      message = 'Nhắc nhở nhẹ: Tuần này bạn đang làm việc hơi căng sức. Đừng quên mở một nhịp thở ngắn 3 phút giữa giờ làm việc để tái tạo năng lượng nhé.';
    }

    return {
      hasSignal,
      level,
      message,
      details,
    };
  }

  async getMoodForecast(userId: string) {
    const checkins = await this.prisma.moodCheckin.findMany({
      where: { userId },
      orderBy: { createdAt: 'asc' },
    });

    let forecastMessage = 'Tâm trạng của bạn dự báo sẽ rất ổn định trong những ngày tới. Hãy duy trì thói quen check-in nhé!';
    let suggestedTime = '20:30';
    let suggestedRoutine = 'Routine thư giãn tối';
    let peakStressDay = 'Chủ nhật';
    let hasPattern = false;

    if (checkins.length >= 5) {
      const stressCheckins = checkins.filter(c => 
        ['STRESSED', 'ANXIOUS', 'SAD'].includes(c.mood) || 
        (c.intensity && c.intensity >= 6)
      );

      if (stressCheckins.length > 0) {
        const days = ['Chủ nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
        const dayCounts: Record<number, number> = {};
        stressCheckins.forEach(c => {
          const d = c.createdAt.getDay();
          dayCounts[d] = (dayCounts[d] ?? 0) + 1;
        });

        let topDayNum = 0;
        let maxCount = 0;
        for (const [d, count] of Object.entries(dayCounts)) {
          if (count > maxCount) {
            maxCount = count;
            topDayNum = parseInt(d, 10);
          }
        }

        peakStressDay = days[topDayNum];
        hasPattern = true;
        
        if (topDayNum === 0 || topDayNum === 6) {
          forecastMessage = `Dựa trên lịch sử, tối ${peakStressDay} bạn thường dễ stress hơn. Muốn đặt routine nhẹ lúc 20:30 để thư giãn trước tuần mới không?`;
          suggestedTime = '20:30';
        } else {
          forecastMessage = `Dựa trên lịch sử, các ngày trong tuần (${peakStressDay}) bạn dễ căng thẳng hơn. Bạn có muốn đặt Focus Break lúc 14:00 không?`;
          suggestedTime = '14:00';
          suggestedRoutine = 'Giờ nghỉ ngơi Focus';
        }
      }
    } else {
      forecastMessage = 'Tối Chủ nhật bạn thường dễ stress và lo lắng hơn do chuẩn bị cho tuần mới. Muốn đặt routine nhẹ lúc 20:30 không?';
    }

    return {
      hasPattern,
      peakStressDay,
      suggestedTime,
      suggestedRoutine,
      message: forecastMessage,
      createdAt: new Date(),
    };
  }
}
