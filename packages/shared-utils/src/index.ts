export const formatMinutes = (minutes: number) => `${minutes} min`;

export const formatPercentage = (value: number) => `${value}%`;

/**
 * Calculate streak days from a list of date strings (formatted as YYYY-MM-DD).
 * Expects the dates list to be unique.
 */
export function calculateStreakDays(
  days: string[],
  todayKey: string,
  yesterdayKey: string,
): { current: number; longest: number } {
  if (days.length === 0) {
    return { current: 0, longest: 0 };
  }

  const sortedDays = Array.from(new Set(days)).sort();

  let longest = 0;
  let run = 0;
  let previous: Date | undefined;

  for (const day of sortedDays) {
    const current = new Date(`${day}T00:00:00.000Z`);
    const diffDays = previous
      ? Math.round(
          (current.getTime() - previous.getTime()) / (1000 * 60 * 60 * 24),
        )
      : 1;

    run = diffDays === 1 ? run + 1 : 1;
    longest = Math.max(longest, run);
    previous = current;
  }

  const latest = sortedDays.at(-1);
  let current = 0;

  if (latest === todayKey || latest === yesterdayKey) {
    let expected = new Date(`${latest}T00:00:00.000Z`);
    for (let index = sortedDays.length - 1; index >= 0; index -= 1) {
      const currentDay = new Date(`${sortedDays[index]}T00:00:00.000Z`);
      if (currentDay.getTime() !== expected.getTime()) break;
      current += 1;
      expected = new Date(expected.getTime() - 1000 * 60 * 60 * 24);
    }
  }

  return { current, longest };
}
