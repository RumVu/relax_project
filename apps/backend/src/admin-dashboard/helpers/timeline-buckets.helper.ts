/**
 * Build day/month buckets covering `range`. Pure.
 *
 * Decision: when the range spans > 60 days OR the period is QUARTER/YEAR
 * we group monthly (otherwise the chart has too many bars). Daily otherwise.
 */
import {
  AdminDashboardPeriod,
} from '../dto/admin-dashboard-query.dto';
import { DateRange, dateKey, daysBetween } from './date-range.helper';

export type Bucket = {
  key: string;
  label: string;
  users: number;
  active: Set<string>;
  revenue: number;
};

export function shouldGroupMonthly(
  period: AdminDashboardPeriod,
  range: DateRange,
): boolean {
  return (
    period === AdminDashboardPeriod.QUARTER ||
    period === AdminDashboardPeriod.YEAR ||
    daysBetween(range.from, range.to) > 60
  );
}

export function bucketKey(date: Date, groupMonthly: boolean): string {
  return groupMonthly
    ? `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, '0')}`
    : dateKey(date);
}

export function buildBuckets(
  period: AdminDashboardPeriod,
  range: DateRange,
  groupMonthly = shouldGroupMonthly(period, range),
): Map<string, Bucket> {
  const buckets = new Map<string, Bucket>();
  const cursor = new Date(range.from);

  while (cursor <= range.to) {
    const key = bucketKey(cursor, groupMonthly);

    if (!buckets.has(key)) {
      buckets.set(key, {
        key,
        label: key,
        users: 0,
        active: new Set<string>(),
        revenue: 0,
      });
    }

    if (groupMonthly) {
      cursor.setUTCMonth(cursor.getUTCMonth() + 1, 1);
    } else {
      cursor.setUTCDate(cursor.getUTCDate() + 1);
    }
  }

  return buckets;
}
