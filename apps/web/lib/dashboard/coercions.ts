import type { PageResponse } from './constants';

export function getSettledValue<T>(result: PromiseSettledResult<unknown>) {
  return result.status === 'fulfilled' ? (result.value as T) : undefined;
}

export function pickQuery(
  query: Record<string, string | number | boolean | undefined> | undefined,
  keys: string[],
): Record<string, string | number | boolean | undefined> | undefined {
  if (!query) {
    return undefined;
  }

  const picked = Object.fromEntries(
    keys
      .filter((key) => {
        const value = query[key];
        return value !== undefined && value !== '';
      })
      .map((key) => [key, query[key]]),
  ) as Record<string, string | number | boolean | undefined>;

  return Object.keys(picked).length > 0 ? picked : undefined;
}

export function asRecord(value: unknown) {
  return value && typeof value === 'object' && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : undefined;
}

export function asArray<T>(value: unknown) {
  return Array.isArray(value) ? (value as T[]) : undefined;
}

export function asString(value: unknown) {
  return typeof value === 'string' && value.trim().length > 0 ? value : undefined;
}

export function asNumber(value: unknown) {
  return typeof value === 'number' && Number.isFinite(value) ? value : undefined;
}

export function asBoolean(value: unknown) {
  return typeof value === 'boolean' ? value : undefined;
}

export function asStringArray(value: unknown) {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === 'string')
    : [];
}

export function readReliefPercent(record: Record<string, unknown> | undefined) {
  if (!record) {
    return undefined;
  }

  const nestedRelief = asRecord(record.relief);
  const value =
    asNumber(record.stressReliefPercent) ??
    asNumber(record.reliefPercent) ??
    asNumber(record.reliefPct) ??
    asNumber(record.relief) ??
    asNumber(record.averageStressRelief) ??
    asNumber(record.avgStressRelief) ??
    asNumber(record.averageRelief) ??
    asNumber(record.avgRelief) ??
    asNumber(nestedRelief?.averageStressRelief) ??
    asNumber(nestedRelief?.stressReliefPercent) ??
    asNumber(nestedRelief?.percent);

  if (value === undefined) {
    return undefined;
  }

  return Math.max(0, Math.min(100, Math.round(value)));
}

export function normalizeCollection(
  value:
    | Array<Record<string, unknown>>
    | PageResponse<Record<string, unknown>>
    | undefined,
) {
  if (Array.isArray(value)) {
    return value;
  }

  return value?.items;
}

export function truncate(value: string | undefined, maxLength: number) {
  if (!value) {
    return undefined;
  }

  return value.length > maxLength ? `${value.slice(0, maxLength - 1)}…` : value;
}
