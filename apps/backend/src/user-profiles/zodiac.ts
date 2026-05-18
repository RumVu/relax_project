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

export function getZodiacPersonalization(birthday?: Date | null) {
  if (!birthday) {
    return {
      zodiacSign: null,
      chineseZodiac: null,
    };
  }

  const month = birthday.getUTCMonth() + 1;
  const day = birthday.getUTCDate();
  const year = birthday.getUTCFullYear();
  const zodiacSign =
    ZODIAC_SIGNS.find((range) =>
      isWithinDateRange(month, day, range.from, range.to),
    )?.sign ?? 'Capricorn';
  const chineseZodiac =
    CHINESE_ZODIACS[positiveModulo(year - 1900, CHINESE_ZODIACS.length)];

  return {
    zodiacSign,
    chineseZodiac,
  };
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
