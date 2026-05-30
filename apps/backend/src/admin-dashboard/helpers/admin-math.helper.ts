/**
 * Tiny number utilities used by the dashboard aggregators. Pure.
 */

/**
 * Percentage change `(current - previous) / previous * 100`, rounded
 * to 2 decimals. Special case: previous=0 → 100 if there's any current,
 * otherwise 0 (avoids Infinity for brand-new accounts).
 */
export function percentDelta(current: number, previous: number): number {
  if (previous === 0) return current > 0 ? 100 : 0;
  return round2(((current - previous) / previous) * 100);
}

export function round2(value: number): number {
  return Math.round(value * 100) / 100;
}

/**
 * Given groupBy rows + the full enum value list, return one row per
 * enum value (count 0 for absent values) so the UI shows the full
 * dropdown shape every time.
 */
export function fillEnumCounts(
  rows: Array<Record<string, unknown> & { _count: { _all: number } }>,
  values: string[],
  key: string,
) {
  return values.map((value) => {
    const row = rows.find((entry) => entry[key] === value);
    return { [key]: value, count: row?._count._all ?? 0 };
  });
}
