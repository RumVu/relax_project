/**
 * Client-side mirror of the backend's zodiac calculator
 * (apps/backend/src/user-profiles/zodiac.ts). Used by the Settings page
 * so the user sees their Zodiac / Chinese zodiac update instantly when
 * they pick a birthday instead of waiting for the PATCH round-trip.
 */

const ZODIAC_SIGNS = [
  { sign: 'Capricorn', from: [1, 1], to: [1, 19] },
  { sign: 'Aquarius', from: [1, 20], to: [2, 18] },
  { sign: 'Pisces', from: [2, 19], to: [3, 20] },
  { sign: 'Aries', from: [3, 21], to: [4, 19] },
  { sign: 'Taurus', from: [4, 20], to: [5, 20] },
  { sign: 'Gemini', from: [5, 21], to: [6, 20] },
  { sign: 'Cancer', from: [6, 21], to: [7, 22] },
  { sign: 'Leo', from: [7, 23], to: [8, 22] },
  { sign: 'Virgo', from: [8, 23], to: [9, 22] },
  { sign: 'Libra', from: [9, 23], to: [10, 22] },
  { sign: 'Scorpio', from: [10, 23], to: [11, 21] },
  { sign: 'Sagittarius', from: [11, 22], to: [12, 21] },
  { sign: 'Capricorn', from: [12, 22], to: [12, 31] },
] as const;

const CHINESE_ZODIACS = [
  'Rat',
  'Ox',
  'Tiger',
  'Rabbit',
  'Dragon',
  'Snake',
  'Horse',
  'Goat',
  'Monkey',
  'Rooster',
  'Dog',
  'Pig',
] as const;

export type ZodiacPersonalization = {
  zodiacSign: string | null;
  chineseZodiac: string | null;
};

/**
 * Compute zodiac + chinese zodiac from a birthday string ("YYYY-MM-DD")
 * or `Date`. Returns nulls when the input is empty / unparseable.
 */
export function computeZodiac(
  input: string | Date | null | undefined,
): ZodiacPersonalization {
  if (!input) {
    return { zodiacSign: null, chineseZodiac: null };
  }

  const date = typeof input === 'string' ? parseDateInput(input) : input;
  if (!date || Number.isNaN(date.getTime())) {
    return { zodiacSign: null, chineseZodiac: null };
  }

  // Use UTC to match the backend (apps/backend/src/user-profiles/zodiac.ts).
  const month = date.getUTCMonth() + 1;
  const day = date.getUTCDate();
  const year = date.getUTCFullYear();

  const zodiacSign =
    ZODIAC_SIGNS.find((range) =>
      isWithinDateRange(month, day, range.from, range.to),
    )?.sign ?? 'Capricorn';

  const chineseZodiac =
    CHINESE_ZODIACS[positiveModulo(year - 1900, CHINESE_ZODIACS.length)] ??
    null;

  return { zodiacSign, chineseZodiac };
}

function parseDateInput(value: string): Date | null {
  // The settings page stores the date input as YYYY-MM-DD; treat that as
  // a UTC midnight so January 1st never slips into the previous day in
  // negative-offset timezones.
  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return new Date(`${value}T00:00:00.000Z`);
  }
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

function isWithinDateRange(
  month: number,
  day: number,
  from: readonly [number, number],
  to: readonly [number, number],
) {
  const value = month * 100 + day;
  return value >= from[0] * 100 + from[1] && value <= to[0] * 100 + to[1];
}

function positiveModulo(value: number, divisor: number) {
  return ((value % divisor) + divisor) % divisor;
}

// ---------------------------------------------------------------------------
// Vietnamese display labels (matches the SettingsPage "Trang cá nhân" copy).
// ---------------------------------------------------------------------------

const ZODIAC_VI: Record<string, string> = {
  Aries: 'Bạch Dương',
  Taurus: 'Kim Ngưu',
  Gemini: 'Song Tử',
  Cancer: 'Cự Giải',
  Leo: 'Sư Tử',
  Virgo: 'Xử Nữ',
  Libra: 'Thiên Bình',
  Scorpio: 'Bọ Cạp',
  Sagittarius: 'Nhân Mã',
  Capricorn: 'Ma Kết',
  Aquarius: 'Bảo Bình',
  Pisces: 'Song Ngư',
};

const CHINESE_ZODIAC_VI: Record<string, string> = {
  Rat: 'Tý (Chuột)',
  Ox: 'Sửu (Trâu)',
  Tiger: 'Dần (Hổ)',
  Rabbit: 'Mão (Mèo)',
  Dragon: 'Thìn (Rồng)',
  Snake: 'Tỵ (Rắn)',
  Horse: 'Ngọ (Ngựa)',
  Goat: 'Mùi (Dê)',
  Monkey: 'Thân (Khỉ)',
  Rooster: 'Dậu (Gà)',
  Dog: 'Tuất (Chó)',
  Pig: 'Hợi (Heo)',
};

export function zodiacLabel(sign: string | null | undefined): string {
  if (!sign) return '—';
  return ZODIAC_VI[sign] ?? sign;
}

export function chineseZodiacLabel(sign: string | null | undefined): string {
  if (!sign) return '—';
  return CHINESE_ZODIAC_VI[sign] ?? sign;
}
