import { describe, it, expect } from 'vitest';
import { calculateStreakDays, formatMinutes, formatPercentage } from './index';

describe('Shared Utils', () => {
  it('formats minutes and percentages', () => {
    expect(formatMinutes(15)).toBe('15 min');
    expect(formatPercentage(85)).toBe('85%');
  });

  it('calculates streaks correctly', () => {
    const today = '2026-06-11';
    const yesterday = '2026-06-10';

    // Empty array
    expect(calculateStreakDays([], today, yesterday)).toEqual({ current: 0, longest: 0 });

    // Single check-in today
    expect(calculateStreakDays([today], today, yesterday)).toEqual({ current: 1, longest: 1 });

    // Single check-in yesterday
    expect(calculateStreakDays([yesterday], today, yesterday)).toEqual({ current: 1, longest: 1 });

    // Consecutive check-ins ending today
    expect(calculateStreakDays(['2026-06-08', '2026-06-09', '2026-06-10', today], today, yesterday)).toEqual({
      current: 4,
      longest: 4,
    });

    // Consecutive check-ins ending yesterday
    expect(calculateStreakDays(['2026-06-08', '2026-06-09', yesterday], today, yesterday)).toEqual({
      current: 3,
      longest: 3,
    });

    // Broken streak (ended 2 days ago)
    expect(calculateStreakDays(['2026-06-07', '2026-06-08', '2026-06-09'], today, yesterday)).toEqual({
      current: 0,
      longest: 3,
    });

    // Multiple streaks, longest is in the past
    expect(
      calculateStreakDays(['2026-06-01', '2026-06-02', '2026-06-03', '2026-06-04', '2026-06-08', yesterday, today], today, yesterday)
    ).toEqual({
      current: 2,
      longest: 4,
    });
  });
});
