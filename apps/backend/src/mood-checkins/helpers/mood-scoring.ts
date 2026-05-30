/**
 * Pure mood ↔ score lookups and small score utilities.
 * No Prisma, no DI — safe to import anywhere.
 */
import { MoodCheckin, MoodType } from '@prisma/client';

/**
 * 1-5 emotional valence score used in stat aggregations.
 */
export function getMoodScore(mood: MoodType): number {
  const scores: Record<MoodType, number> = {
    [MoodType.HAPPY]: 5,
    [MoodType.CALM]: 5,
    [MoodType.EXCITED]: 5,
    [MoodType.GRATEFUL]: 5,
    [MoodType.NEUTRAL]: 3,
    [MoodType.TIRED]: 2,
    [MoodType.LONELY]: 2,
    [MoodType.SAD]: 1,
    [MoodType.ANXIOUS]: 1,
    [MoodType.STRESSED]: 1,
  };

  return scores[mood];
}

/**
 * 0-100 stress score — higher = more stressed. Used as default raw/final
 * score when the user doesn't provide one.
 */
export function scoreFromMood(mood: MoodType): number {
  const stressScores: Record<MoodType, number> = {
    [MoodType.STRESSED]: 90,
    [MoodType.ANXIOUS]: 80,
    [MoodType.SAD]: 65,
    [MoodType.TIRED]: 60,
    [MoodType.LONELY]: 55,
    [MoodType.NEUTRAL]: 40,
    [MoodType.EXCITED]: 30,
    [MoodType.GRATEFUL]: 20,
    [MoodType.HAPPY]: 15,
    [MoodType.CALM]: 10,
  };

  return stressScores[mood];
}

export function clampScore(score: number): number {
  return Math.max(0, Math.min(100, Math.round(score)));
}

/**
 * finalScore ?? rawScore ?? scoreFromMood(mood) — the score the user
 * "feels", falling back through layers of precision.
 */
export function getEffectiveScore(
  checkin: Pick<MoodCheckin, 'mood' | 'rawScore' | 'finalScore'>,
): number {
  return checkin.finalScore ?? checkin.rawScore ?? scoreFromMood(checkin.mood);
}

export function isStressMood(mood: MoodType): boolean {
  return mood === MoodType.STRESSED || mood === MoodType.ANXIOUS;
}

export function isPositiveMood(mood: MoodType): boolean {
  const positiveMoods: MoodType[] = [
    MoodType.HAPPY,
    MoodType.CALM,
    MoodType.EXCITED,
    MoodType.GRATEFUL,
  ];

  return positiveMoods.includes(mood);
}

/** Round to 2 decimal places. */
export function round2(value: number): number {
  return Math.round(value * 100) / 100;
}
