const DEFAULT_TIMEZONE = 'Asia/Ho_Chi_Minh';
const MINUTE_MS = 60_000;
const DAY_MS = 24 * 60 * 60 * 1000;

export interface TimezoneContext {
  timezone: string;
  fixedOffsetMinutes?: number;
}

interface LocalDateTimeParts {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
  millisecond: number;
}

export function normalizeTimezone(timezone?: string | null) {
  if (!timezone) {
    return DEFAULT_TIMEZONE;
  }

  try {
    Intl.DateTimeFormat(undefined, { timeZone: timezone });
    return timezone;
  } catch {
    return DEFAULT_TIMEZONE;
  }
}

export function getTimezoneOffsetMinutes(
  timezone?: string | null,
  date = new Date(),
) {
  const normalizedTimezone = normalizeTimezone(timezone);
  const localParts = new Intl.DateTimeFormat('en-US', {
    timeZone: normalizedTimezone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hourCycle: 'h23',
  }).formatToParts(date);

  const getPart = (type: Intl.DateTimeFormatPartTypes) =>
    Number(localParts.find((part) => part.type === type)?.value ?? 0);

  const localAsUtc = Date.UTC(
    getPart('year'),
    getPart('month') - 1,
    getPart('day'),
    getPart('hour'),
    getPart('minute'),
    getPart('second'),
  );

  return Math.round((localAsUtc - date.getTime()) / MINUTE_MS);
}

export function createTimezoneContext(
  timezone?: string | null,
  fixedOffsetMinutes?: number | null,
): TimezoneContext {
  return {
    timezone: normalizeTimezone(timezone),
    fixedOffsetMinutes:
      typeof fixedOffsetMinutes === 'number' ? fixedOffsetMinutes : undefined,
  };
}

export function getTimezoneContextOffsetMinutes(
  context: TimezoneContext,
  date = new Date(),
) {
  return (
    context.fixedOffsetMinutes ??
    getTimezoneOffsetMinutes(context.timezone, date)
  );
}

export function startOfLocalDay(date: Date, context: TimezoneContext) {
  if (typeof context.fixedOffsetMinutes === 'number') {
    const shifted = new Date(
      date.getTime() + context.fixedOffsetMinutes * MINUTE_MS,
    );
    shifted.setUTCHours(0, 0, 0, 0);
    return new Date(shifted.getTime() - context.fixedOffsetMinutes * MINUTE_MS);
  }

  const parts = getLocalDateTimeParts(date, context.timezone);
  return localDateTimeToUtc(
    {
      ...parts,
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    },
    context.timezone,
  );
}

export function endOfLocalDay(date: Date, context: TimezoneContext) {
  return new Date(
    addLocalDays(startOfLocalDay(date, context), 1, context).getTime() - 1,
  );
}

export function addLocalDays(
  date: Date,
  days: number,
  context: TimezoneContext,
) {
  if (typeof context.fixedOffsetMinutes === 'number') {
    return new Date(date.getTime() + days * DAY_MS);
  }

  const parts = getLocalDateTimeParts(date, context.timezone);
  const shiftedDate = new Date(
    Date.UTC(
      parts.year,
      parts.month - 1,
      parts.day + days,
      parts.hour,
      parts.minute,
      parts.second,
      parts.millisecond,
    ),
  );

  return localDateTimeToUtc(
    {
      year: shiftedDate.getUTCFullYear(),
      month: shiftedDate.getUTCMonth() + 1,
      day: shiftedDate.getUTCDate(),
      hour: shiftedDate.getUTCHours(),
      minute: shiftedDate.getUTCMinutes(),
      second: shiftedDate.getUTCSeconds(),
      millisecond: shiftedDate.getUTCMilliseconds(),
    },
    context.timezone,
  );
}

export function toLocalDateKey(date: Date, context: TimezoneContext) {
  if (typeof context.fixedOffsetMinutes === 'number') {
    return new Date(date.getTime() + context.fixedOffsetMinutes * MINUTE_MS)
      .toISOString()
      .slice(0, 10);
  }

  const parts = getLocalDateTimeParts(date, context.timezone);
  return `${parts.year}-${pad2(parts.month)}-${pad2(parts.day)}`;
}

export function getLocalDayLabel(date: Date, context: TimezoneContext) {
  const localDate =
    typeof context.fixedOffsetMinutes === 'number'
      ? new Date(date.getTime() + context.fixedOffsetMinutes * MINUTE_MS)
      : localDatePartsAsUtcDate(getLocalDateTimeParts(date, context.timezone));
  const labels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  return labels[localDate.getUTCDay()];
}

export function getLocalWeekStart(date: Date, context: TimezoneContext) {
  const start = startOfLocalDay(date, context);
  const localDate =
    typeof context.fixedOffsetMinutes === 'number'
      ? new Date(start.getTime() + context.fixedOffsetMinutes * MINUTE_MS)
      : localDatePartsAsUtcDate(getLocalDateTimeParts(start, context.timezone));
  const day = localDate.getUTCDay();
  const daysFromMonday = day === 0 ? 6 : day - 1;
  return addLocalDays(start, -daysFromMonday, context);
}

function getLocalDateTimeParts(
  date: Date,
  timezone: string,
): LocalDateTimeParts {
  const localParts = new Intl.DateTimeFormat('en-US', {
    timeZone: normalizeTimezone(timezone),
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hourCycle: 'h23',
  }).formatToParts(date);

  const getPart = (type: Intl.DateTimeFormatPartTypes) =>
    Number(localParts.find((part) => part.type === type)?.value ?? 0);

  return {
    year: getPart('year'),
    month: getPart('month'),
    day: getPart('day'),
    hour: getPart('hour'),
    minute: getPart('minute'),
    second: getPart('second'),
    millisecond: date.getUTCMilliseconds(),
  };
}

function localDateTimeToUtc(parts: LocalDateTimeParts, timezone: string) {
  const localAsUtc = Date.UTC(
    parts.year,
    parts.month - 1,
    parts.day,
    parts.hour,
    parts.minute,
    parts.second,
    parts.millisecond,
  );
  const initialOffset = getTimezoneOffsetMinutes(
    timezone,
    new Date(localAsUtc),
  );
  const firstCandidate = new Date(localAsUtc - initialOffset * MINUTE_MS);
  const settledOffset = getTimezoneOffsetMinutes(timezone, firstCandidate);
  return new Date(localAsUtc - settledOffset * MINUTE_MS);
}

function localDatePartsAsUtcDate(parts: LocalDateTimeParts) {
  return new Date(Date.UTC(parts.year, parts.month - 1, parts.day));
}

function pad2(value: number) {
  return String(value).padStart(2, '0');
}
