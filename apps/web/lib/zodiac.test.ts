import { describe, expect, it } from 'vitest';
import {
  chineseZodiacLabel,
  computeZodiac,
  zodiacLabel,
} from './zodiac';

describe('computeZodiac', () => {
  it('matches the backend signs at every boundary', () => {
    // Spot-check each boundary day, both sides.
    const cases: Array<[string, string]> = [
      ['2003-10-02', 'Libra'],
      ['2000-02-19', 'Pisces'],
      ['2000-02-18', 'Aquarius'],
      ['2000-03-20', 'Pisces'],
      ['2000-03-21', 'Aries'],
      ['2000-12-21', 'Sagittarius'],
      ['2000-12-22', 'Capricorn'],
      ['2000-01-19', 'Capricorn'],
      ['2000-01-20', 'Aquarius'],
      ['2000-07-22', 'Cancer'],
      ['2000-07-23', 'Leo'],
    ];
    for (const [date, sign] of cases) {
      expect(computeZodiac(date).zodiacSign).toBe(sign);
    }
  });

  it('computes the correct chinese zodiac from year', () => {
    // 1900 = Rat, so any year cycles back to 1900 % 12.
    expect(computeZodiac('1900-06-01').chineseZodiac).toBe('Rat');
    expect(computeZodiac('2003-10-02').chineseZodiac).toBe('Goat'); // 2003 → Goat
    expect(computeZodiac('2024-02-10').chineseZodiac).toBe('Dragon');
    expect(computeZodiac('1988-09-01').chineseZodiac).toBe('Dragon');
  });

  it('returns nulls for empty / invalid input', () => {
    expect(computeZodiac(null)).toEqual({ zodiacSign: null, chineseZodiac: null });
    expect(computeZodiac(undefined)).toEqual({ zodiacSign: null, chineseZodiac: null });
    expect(computeZodiac('')).toEqual({ zodiacSign: null, chineseZodiac: null });
    expect(computeZodiac('not-a-date')).toEqual({
      zodiacSign: null,
      chineseZodiac: null,
    });
  });

  it('accepts a Date object', () => {
    const date = new Date(Date.UTC(2003, 9, 2)); // 2003-10-02
    expect(computeZodiac(date).zodiacSign).toBe('Libra');
  });
});

describe('zodiac labels', () => {
  it('maps known signs to vietnamese', () => {
    expect(zodiacLabel('Pisces')).toBe('Song Ngư');
    expect(zodiacLabel('Aries')).toBe('Bạch Dương');
    expect(chineseZodiacLabel('Goat')).toBe('Mùi (Dê)');
    expect(chineseZodiacLabel('Dragon')).toBe('Thìn (Rồng)');
  });

  it('falls back to em-dash for null/empty', () => {
    expect(zodiacLabel(null)).toBe('—');
    expect(zodiacLabel(undefined)).toBe('—');
    expect(chineseZodiacLabel('')).toBe('—');
  });

  it('returns the raw value for unknown signs', () => {
    expect(zodiacLabel('Foo')).toBe('Foo');
    expect(chineseZodiacLabel('Bar')).toBe('Bar');
  });
});
