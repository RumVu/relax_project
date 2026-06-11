/**
 * Streak calculation — chuỗi ngày liên tiếp user check-in.
 * Pure: lấy danh sách check-in + TimezoneContext → trả về { current, longest }.
 */
import { MoodCheckin } from '@prisma/client';
import type { TimezoneContext } from '../../common/timezone';
import { getCheckinDate } from './mood-time';
import { toLocalDateKey } from '../../common/timezone';
import { calculateStreakDays } from '@digital-cigarette-break/shared-utils';

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

  const today = toLocalDateKey(new Date(), timezoneContext);
  const yesterday = toLocalDateKey(
    new Date(Date.now() - 1000 * 60 * 60 * 24),
    timezoneContext,
  );

  return calculateStreakDays(days, today, yesterday);
}
