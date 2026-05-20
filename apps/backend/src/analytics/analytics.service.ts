import { Injectable } from '@nestjs/common';
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
import { UserCompanionsService } from '../user-companions/user-companions.service';
import { AnalyticsPeriod, AnalyticsQueryDto } from './analytics-query.dto';

@Injectable()
export class AnalyticsService {
  constructor(
    private readonly moodCheckinsService: MoodCheckinsService,
    private readonly journalsService: JournalsService,
    private readonly relaxActivitiesService: RelaxActivitiesService,
    private readonly userCompanionsService: UserCompanionsService,
    private readonly prisma: PrismaService,
  ) {}

  async getOverview(userId: string, query: AnalyticsQueryDto) {
    const period = query.period ?? AnalyticsPeriod.WEEK;
    const timezone = await this.resolveTimezone(userId, query.timezone);
    const timezoneOffsetMinutes =
      query.timezoneOffsetMinutes ?? getTimezoneOffsetMinutes(timezone);
    const [mood, journals, relax, companion] = await Promise.all([
      this.moodCheckinsService.getAnalytics(userId, {
        period: period as unknown as MoodAnalyticsPeriod,
        timezone,
        timezoneOffsetMinutes: query.timezoneOffsetMinutes,
      }),
      this.journalsService.getStats(userId, {}),
      this.relaxActivitiesService.getStats(userId, {
        period: period as unknown as RelaxStatsPeriod,
        timezone,
        timezoneOffsetMinutes: query.timezoneOffsetMinutes,
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
}
