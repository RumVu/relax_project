/**
 * Scoring helpers cho relax session — pure, no DI.
 * Reuses mood-checkins/helpers/mood-scoring for mood→score lookups so we
 * keep a single source of truth.
 */
import { MoodType } from '@prisma/client';
import { getMoodScore } from '../../mood-checkins/helpers/mood-scoring';

/** Cap relax-session duration at 12h (sleep sessions etc. count toward this). */
export const MAX_RELAX_SESSION_DURATION_SECONDS = 60 * 60 * 12;

/**
 * Final "stress relief %" stored on a finished session:
 *  1) Prefer the user's explicit reliefLevel (1-5 → 20-100%).
 *  2) Fallback to delta of mood-score before/after if both present.
 *  3) Otherwise 0 (we don't fabricate a number).
 */
export function getStressReliefPercent(
  reliefLevel?: number,
  moodBefore?: MoodType,
  moodAfter?: MoodType,
): number {
  if (reliefLevel) {
    return Math.max(0, Math.min(100, reliefLevel * 20));
  }
  if (!moodBefore || !moodAfter) return 0;

  return Math.max(
    0,
    Math.round(
      ((getMoodScore(moodAfter) - getMoodScore(moodBefore)) / 4) * 100,
    ),
  );
}

/**
 * Elapsed seconds clamped to MAX_RELAX_SESSION_DURATION_SECONDS so a
 * forgotten "Sleep" session left running for days doesn't blow up the
 * weekly total.
 */
export function resolveDurationSeconds(startedAt: Date, endedAt: Date): number {
  const elapsedSeconds = Math.max(
    0,
    Math.round((endedAt.getTime() - startedAt.getTime()) / 1000),
  );
  return Math.min(elapsedSeconds, MAX_RELAX_SESSION_DURATION_SECONDS);
}
