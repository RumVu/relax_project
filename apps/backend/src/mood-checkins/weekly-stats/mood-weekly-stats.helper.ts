/**
 * Helpers liên quan đến WeeklyMoodStat recalculation. Pure.
 */
import {
  addLocalDays,
  getLocalWeekStart,
  startOfLocalDay,
  endOfLocalDay,
} from '../../common/timezone';
import type { TimezoneContext } from '../../common/timezone';
import { RecalculateWeeklyMoodStatsDto } from '../dto/recalculate-weekly-mood-stats.dto';
import type { MoodDateRange } from '../helpers/mood-time';

/**
 * Khi 1 mood check-in ở `date` thay đổi, ít nhất 3 tuần có thể bị ảnh
 * hưởng (tuần trước, tuần đang chứa, tuần sau — ví dụ nếu user fix
 * `scoredAt` xuyên qua biên tuần). Thêm cả 3 mốc weekStart vào map.
 */
export function addAffectedWeekStarts(
  weekStarts: Map<string, Date>,
  date: Date,
  timezoneContext: TimezoneContext,
): void {
  const weekStart = getLocalWeekStart(date, timezoneContext);

  for (const offsetDays of [-7, 0, 7]) {
    const affected = addLocalDays(weekStart, offsetDays, timezoneContext);
    weekStarts.set(affected.toISOString(), affected);
  }
}

/**
 * Parse `RecalculateWeeklyMoodStatsDto` thành 1 range:
 *  - Nếu cả from + to đều rỗng → trả null (caller sẽ hiểu = recalc all)
 *  - Nếu chỉ có 1 trong 2 → dùng giá trị đó cho cả 2 đầu
 */
export function resolveRecalculateRange(
  dto: RecalculateWeeklyMoodStatsDto,
  timezoneContext: TimezoneContext,
): MoodDateRange | null {
  if (!dto.from && !dto.to) return null;

  return {
    from: startOfLocalDay(dto.from ?? dto.to!, timezoneContext),
    to: endOfLocalDay(dto.to ?? dto.from!, timezoneContext),
  };
}
