/**
 * Mood analytics — summary / delta / timeline / insights.
 * All pure; receive check-in arrays + TimezoneContext, return shaped data.
 */
import { MoodCheckin, MoodType } from '@prisma/client';
import type { TimezoneContext } from '../../common/timezone';
import {
  getEffectiveScore,
  isPositiveMood,
  isStressMood,
  round2,
  scoreFromMood,
} from '../helpers/mood-scoring';
import { buildMoodCounts, getTopMood } from '../helpers/mood-distribution';
import {
  MoodDateRange,
  getCheckinDate,
  listLocalDays,
  getEndOfLocalDay,
  getStartOfLocalDay,
  getLocalDateKey,
} from '../helpers/mood-time';
import {
  MoodAnalyticsPeriod,
  MoodAnalyticsQueryDto,
} from '../dto/mood-analytics-query.dto';

export type MoodCheckinAnalyticsInput = Pick<
  MoodCheckin,
  'mood' | 'intensity' | 'rawScore' | 'finalScore' | 'scoredAt' | 'createdAt'
>;

/**
 * Pick the date range from the analytics query:
 *  - CUSTOM: use exact from/to
 *  - everything else: roll back N days from `to` (or now)
 */
export function resolveAnalyticsRange(
  query: MoodAnalyticsQueryDto,
  timezoneContext: TimezoneContext,
): MoodDateRange {
  if (query.period === MoodAnalyticsPeriod.CUSTOM && query.from && query.to) {
    return {
      from: getStartOfLocalDay(query.from, timezoneContext),
      to: getEndOfLocalDay(query.to, timezoneContext),
    };
  }

  const period = query.period ?? MoodAnalyticsPeriod.WEEK;
  const daysByPeriod: Record<Exclude<MoodAnalyticsPeriod, 'custom'>, number> = {
    [MoodAnalyticsPeriod.WEEK]: 7,
    [MoodAnalyticsPeriod.MONTH]: 30,
    [MoodAnalyticsPeriod.QUARTER]: 90,
    [MoodAnalyticsPeriod.YEAR]: 365,
  };
  const days = period === MoodAnalyticsPeriod.CUSTOM ? 7 : daysByPeriod[period];
  const to = getEndOfLocalDay(query.to ?? new Date(), timezoneContext);
  const from = new Date(to);
  from.setUTCDate(from.getUTCDate() - days + 1);

  return {
    from: getStartOfLocalDay(from, timezoneContext),
    to,
  };
}

/** The range immediately before `range`, used for delta comparisons. */
export function getPreviousRange(range: MoodDateRange): MoodDateRange {
  const duration = range.to.getTime() - range.from.getTime();
  const to = new Date(range.from.getTime() - 1);
  const from = new Date(to.getTime() - duration);
  return { from, to };
}

export interface MoodAnalyticsSummary {
  total: number;
  activeDays: number;
  averageIntensity: number | null;
  averageRawScore: number | null;
  averageFinalScore: number | null;
  moodScore: number | null;
  topMood: MoodType | null;
  stressCount: number;
  stressRate: number;
  positiveCount: number;
  positiveRate: number;
}

export function buildAnalyticsSummary(
  checkins: MoodCheckinAnalyticsInput[],
  timezoneContext: TimezoneContext,
): MoodAnalyticsSummary {
  const total = checkins.length;
  const activeDays = new Set(
    checkins.map((checkin) =>
      getLocalDateKey(getCheckinDate(checkin), timezoneContext),
    ),
  ).size;

  const averageIntensity =
    total > 0
      ? round2(
          checkins.reduce((sum, checkin) => sum + (checkin.intensity ?? 0), 0) /
            total,
        )
      : null;

  const averageRawScore =
    total > 0
      ? round2(
          checkins.reduce(
            (sum, checkin) =>
              sum + (checkin.rawScore ?? scoreFromMood(checkin.mood)),
            0,
          ) / total,
        )
      : null;

  const averageFinalScore =
    total > 0
      ? round2(
          checkins.reduce(
            (sum, checkin) => sum + getEffectiveScore(checkin),
            0,
          ) / total,
        )
      : null;

  // moodScore == averageFinalScore for now; kept as separate key to leave
  // room for a different weighting later without breaking the API shape.
  const moodScore = averageFinalScore;

  const stressCount = checkins.filter((checkin) =>
    isStressMood(checkin.mood),
  ).length;
  const positiveCount = checkins.filter((checkin) =>
    isPositiveMood(checkin.mood),
  ).length;
  const topMood = getTopMood(checkins);

  return {
    total,
    activeDays,
    averageIntensity,
    averageRawScore,
    averageFinalScore,
    moodScore,
    topMood,
    stressCount,
    stressRate: total > 0 ? Math.round((stressCount / total) * 100) : 0,
    positiveCount,
    positiveRate: total > 0 ? Math.round((positiveCount / total) * 100) : 0,
  };
}

export function buildAnalyticsDelta(
  current: MoodAnalyticsSummary,
  previous: MoodAnalyticsSummary,
) {
  return {
    total: current.total - previous.total,
    activeDays: current.activeDays - previous.activeDays,
    moodScore:
      current.moodScore !== null && previous.moodScore !== null
        ? round2(current.moodScore - previous.moodScore)
        : null,
    stressRate: current.stressRate - previous.stressRate,
    stressReduction: previous.stressRate - current.stressRate,
    positiveRate: current.positiveRate - previous.positiveRate,
  };
}

/** Per-day buckets across the range, with per-bucket summary + mood counts. */
export function buildTimeline(
  checkins: MoodCheckinAnalyticsInput[],
  range: MoodDateRange,
  timezoneContext: TimezoneContext,
) {
  const buckets = listLocalDays(range, timezoneContext);

  return buckets.map((bucket) => {
    const dayCheckins = checkins.filter(
      (checkin) =>
        getLocalDateKey(getCheckinDate(checkin), timezoneContext) ===
        bucket.date,
    );
    const summary = buildAnalyticsSummary(dayCheckins, timezoneContext);

    return {
      date: bucket.date,
      label: bucket.label,
      total: summary.total,
      moodScore: summary.moodScore,
      averageIntensity: summary.averageIntensity,
      stressRate: summary.stressRate,
      positiveRate: summary.positiveRate,
      dominantMood: summary.topMood,
      counts: buildMoodCounts(dayCheckins),
    };
  });
}

/** Vietnamese narrative insights derived from delta + summary. */
export function buildInsights(
  summary: MoodAnalyticsSummary,
  previous: MoodAnalyticsSummary,
): string[] {
  const delta = buildAnalyticsDelta(summary, previous);
  const insights: string[] = [];

  if (delta.stressReduction > 0) {
    insights.push(`Stress giảm ${delta.stressReduction}% so với kỳ trước.`);
  } else if (delta.stressReduction < 0) {
    insights.push(
      `Stress tăng ${Math.abs(delta.stressReduction)}% so với kỳ trước.`,
    );
  }

  if (delta.positiveRate > 0) {
    insights.push(`Mood tích cực tăng ${delta.positiveRate}% so với kỳ trước.`);
  }

  if (summary.activeDays > 0) {
    insights.push(
      `Bạn đã check-in cảm xúc trong ${summary.activeDays} ngày của kỳ này.`,
    );
  }

  return insights;
}
