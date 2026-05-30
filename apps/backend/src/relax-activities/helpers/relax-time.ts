/**
 * Time + range helpers cho relax stats. Pure.
 */
import {
  addLocalDays,
  endOfLocalDay,
  getLocalDayLabel,
  startOfLocalDay,
  toLocalDateKey,
} from '../../common/timezone';
import type { TimezoneContext } from '../../common/timezone';
import {
  RelaxActivityQueryDto,
  RelaxStatsPeriod,
} from '../dto/relax-activity-query.dto';

export interface RelaxRange {
  from: Date;
  to: Date;
}

/**
 * Resolve query.period → RelaxRange. CUSTOM uses exact dates; preset
 * periods roll back N days from `to` (or now).
 */
export function resolveRelaxRange(
  query: RelaxActivityQueryDto,
  timezoneContext: TimezoneContext,
): RelaxRange {
  if (query.period === RelaxStatsPeriod.CUSTOM && query.from && query.to) {
    return {
      from: startOfLocalDay(query.from, timezoneContext),
      to: endOfLocalDay(query.to, timezoneContext),
    };
  }

  const period = query.period ?? RelaxStatsPeriod.WEEK;
  const daysByPeriod: Record<Exclude<RelaxStatsPeriod, 'custom'>, number> = {
    [RelaxStatsPeriod.WEEK]: 7,
    [RelaxStatsPeriod.MONTH]: 30,
    [RelaxStatsPeriod.QUARTER]: 90,
    [RelaxStatsPeriod.YEAR]: 365,
  };
  const days = period === RelaxStatsPeriod.CUSTOM ? 7 : daysByPeriod[period];
  const to = endOfLocalDay(query.to ?? new Date(), timezoneContext);
  const from = new Date(to);
  from.setUTCDate(from.getUTCDate() - days + 1);

  return { from: startOfLocalDay(from, timezoneContext), to };
}

/** Enumerate every local day inside `range` with `{ date, label }`. */
export function listLocalDays(
  range: RelaxRange,
  timezoneContext: TimezoneContext,
): Array<{ date: string; label: string }> {
  const days: Array<{ date: string; label: string }> = [];
  let cursor = startOfLocalDay(range.from, timezoneContext);
  const end = startOfLocalDay(range.to, timezoneContext);

  while (cursor.getTime() <= end.getTime()) {
    days.push({
      date: toLocalDateKey(cursor, timezoneContext),
      label: getLocalDayLabel(cursor, timezoneContext),
    });
    cursor = addLocalDays(cursor, 1, timezoneContext);
  }

  return days;
}

/**
 * Format seconds into a friendly label.
 *  3661 → "1h 1m"
 *  120  → "2 phút"
 */
export function formatDuration(totalSeconds: number): string {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.round((totalSeconds % 3600) / 60);

  if (hours > 0) return `${hours}h ${minutes}m`;
  return `${minutes} phút`;
}
