/**
 * Time helpers specific to mood check-ins. Wraps the generic timezone
 * utils with a couple of mood-domain conveniences.
 */
import { MoodCheckin } from '@prisma/client';
import {
  addLocalDays,
  getLocalDayLabel,
  startOfLocalDay as getStartOfLocalDay,
  endOfLocalDay as getEndOfLocalDay,
  toLocalDateKey as getLocalDateKey,
} from '../../common/timezone';
import type { TimezoneContext } from '../../common/timezone';

/**
 * Effective timestamp of a mood check-in: prefer the user-supplied
 * `scoredAt` (so back-dated check-ins land in the right bucket),
 * fall back to `createdAt` (the row's insert time).
 */
export function getCheckinDate(
  checkin: Pick<MoodCheckin, 'scoredAt' | 'createdAt'>,
): Date {
  return checkin.scoredAt ?? checkin.createdAt;
}

export interface MoodDateRange {
  from: Date;
  to: Date;
}

/**
 * Enumerate every local day inside `range` with `{ date, label }`.
 * Used to scaffold per-day buckets even when no check-ins exist.
 */
export function listLocalDays(
  range: MoodDateRange,
  timezoneContext: TimezoneContext,
): Array<{ date: string; label: string }> {
  const days: Array<{ date: string; label: string }> = [];
  let cursor = getStartOfLocalDay(range.from, timezoneContext);
  const end = getStartOfLocalDay(range.to, timezoneContext);

  while (cursor.getTime() <= end.getTime()) {
    days.push({
      date: getLocalDateKey(cursor, timezoneContext),
      label: getLocalDayLabel(cursor, timezoneContext),
    });
    cursor = addLocalDays(cursor, 1, timezoneContext);
  }

  return days;
}

// Re-export the most common time helpers so service code only needs to
// import from this one file.
export {
  getStartOfLocalDay,
  getEndOfLocalDay,
  getLocalDateKey,
  addLocalDays,
};
