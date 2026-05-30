/**
 * Streak calculation — chuỗi ngày liên tiếp user check-in.
 * Pure: lấy danh sách check-in + TimezoneContext → trả về { current, longest }.
 */
import { MoodCheckin } from '@prisma/client';
import type { TimezoneContext } from '../../common/timezone';
import { getCheckinDate } from './mood-time';
import { toLocalDateKey } from '../../common/timezone';

export interface StreakResult {
  current: number;
  longest: number;
}

/**
 * Tính streak từ list check-in:
 * - longest: chuỗi dài nhất từng đạt
 * - current: chuỗi hiện tại (chỉ tính khi ngày cuối là hôm nay hoặc hôm qua)
 */
export function calculateStreaks(
  checkins: Array<Pick<MoodCheckin, 'createdAt' | 'scoredAt'>>,
  timezoneContext: TimezoneContext,
): StreakResult {
  const days = Array.from(
    new Set(
      checkins.map((checkin) =>
        toLocalDateKey(getCheckinDate(checkin), timezoneContext),
      ),
    ),
  ).sort();

  let longest = 0;
  let run = 0;
  let previous: Date | undefined;

  for (const day of days) {
    const current = new Date(`${day}T00:00:00.000Z`);
    const diffDays = previous
      ? Math.round(
          (current.getTime() - previous.getTime()) / (1000 * 60 * 60 * 24),
        )
      : 1;

    run = diffDays === 1 ? run + 1 : 1;
    longest = Math.max(longest, run);
    previous = current;
  }

  const today = toLocalDateKey(new Date(), timezoneContext);
  const yesterday = toLocalDateKey(
    new Date(Date.now() - 1000 * 60 * 60 * 24),
    timezoneContext,
  );
  const latest = days.at(-1);
  const current =
    latest === today || latest === yesterday ? currentRun(days) : 0;

  return { current, longest };
}

/**
 * Walk back from the last day, counting consecutive days. Used by
 * calculateStreaks to compute the current streak.
 */
function currentRun(days: string[]): number {
  let run = 0;
  let expected = new Date(`${days.at(-1)}T00:00:00.000Z`);

  for (let index = days.length - 1; index >= 0; index -= 1) {
    const current = new Date(`${days[index]}T00:00:00.000Z`);

    if (current.getTime() !== expected.getTime()) break;

    run += 1;
    expected = new Date(expected.getTime() - 1000 * 60 * 60 * 24);
  }

  return run;
}
