/**
 * Aggregations over a list of check-ins. All pure.
 */
import { MoodCheckin, MoodType } from '@prisma/client';
import { MOOD_OPTIONS } from '../mood-options';

/**
 * Per-mood `{ option, count, percentage }` rows in MOOD_OPTIONS order.
 * Always returns every mood (count 0 for absent moods) so the UI can
 * render a stable chart.
 */
export function buildDistribution(checkins: MoodCheckin[]) {
  const total = checkins.length;

  return MOOD_OPTIONS.map((option) => {
    const count = checkins.filter(
      (checkin) => checkin.mood === option.mood,
    ).length;
    const percentage = total > 0 ? Math.round((count / total) * 100) : 0;

    return { ...option, count, percentage };
  });
}

/** Mood that appears most often. Null if no check-ins. */
export function getTopMood(
  checkins: Pick<MoodCheckin, 'mood'>[],
): MoodType | null {
  if (checkins.length === 0) return null;

  const counts = checkins.reduce<Record<string, number>>(
    (accumulator, checkin) => {
      accumulator[checkin.mood] = (accumulator[checkin.mood] ?? 0) + 1;
      return accumulator;
    },
    {},
  );

  return Object.entries(counts).sort(
    (left, right) => right[1] - left[1],
  )[0][0] as MoodType;
}

/**
 * Flat `[ { mood, count } ]` for every mood — used in timeline buckets
 * where we want predictable shape.
 */
export function buildMoodCounts(checkins: Pick<MoodCheckin, 'mood'>[]) {
  return MOOD_OPTIONS.map((option) => ({
    mood: option.mood,
    count: checkins.filter((checkin) => checkin.mood === option.mood).length,
  }));
}
