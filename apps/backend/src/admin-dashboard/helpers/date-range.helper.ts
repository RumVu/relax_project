/**
 * Date-range math for admin dashboard. Pure — no DI.
 *
 * Periods are UTC-aligned: WEEK = last 7 days, MONTH = 30, QUARTER = 90,
 * YEAR = 365. CUSTOM uses query.from/to verbatim (start-of-day → end-of-day).
 */
import {
  AdminDashboardPeriod,
  AdminDashboardQueryDto,
} from '../dto/admin-dashboard-query.dto';

export type DateRange = {
  from: Date;
  to: Date;
};

export function resolveRange(query: AdminDashboardQueryDto): DateRange {
  if (
    query.period === AdminDashboardPeriod.CUSTOM &&
    query.from &&
    query.to
  ) {
    return { from: startOfDay(query.from), to: endOfDay(query.to) };
  }

  const period = query.period ?? AdminDashboardPeriod.WEEK;
  const daysByPeriod: Record<
    Exclude<AdminDashboardPeriod, AdminDashboardPeriod.CUSTOM>,
    number
  > = {
    [AdminDashboardPeriod.WEEK]: 7,
    [AdminDashboardPeriod.MONTH]: 30,
    [AdminDashboardPeriod.QUARTER]: 90,
    [AdminDashboardPeriod.YEAR]: 365,
  };
  const to = endOfDay(query.to ?? new Date());
  const from = new Date(to);
  from.setUTCDate(
    from.getUTCDate() -
      (period === AdminDashboardPeriod.CUSTOM ? 7 : daysByPeriod[period]) +
      1,
  );
  return { from: startOfDay(from), to };
}

/** Adjacent earlier range of the same length, for delta calculations. */
export function getPreviousRange(range: DateRange): DateRange {
  const duration = range.to.getTime() - range.from.getTime();
  const to = new Date(range.from.getTime() - 1);
  const from = new Date(to.getTime() - duration);
  return { from, to };
}

export function startOfDay(date: Date): Date {
  return new Date(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()),
  );
}

export function endOfDay(date: Date): Date {
  return new Date(
    Date.UTC(
      date.getUTCFullYear(),
      date.getUTCMonth(),
      date.getUTCDate(),
      23, 59, 59, 999,
    ),
  );
}

export function daysAgo(days: number): Date {
  const date = new Date();
  date.setUTCDate(date.getUTCDate() - days + 1);
  return startOfDay(date);
}

export function dateKey(date: Date): string {
  return date.toISOString().slice(0, 10);
}

export function daysBetween(from: Date, to: Date): number {
  return Math.ceil((to.getTime() - from.getTime()) / (1000 * 60 * 60 * 24));
}
