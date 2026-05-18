const DEFAULT_TIMEZONE = 'Asia/Ho_Chi_Minh';

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

  return Math.round((localAsUtc - date.getTime()) / 60_000);
}
