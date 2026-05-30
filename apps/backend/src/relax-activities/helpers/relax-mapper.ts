/**
 * RelaxSession → API payload mapper. Pure.
 */
import { RelaxActivityType, RelaxSession } from '@prisma/client';
import {
  RELAX_ACTIVITY_OPTIONS,
  getRelaxActivityOption,
} from '../relax-activity-options';

export type RelaxSessionPayload = ReturnType<typeof toSessionPayload>;

export function toSessionPayload(session: RelaxSession) {
  const option = getRelaxActivityOption(session.activityType);

  return {
    id: session.id,
    userId: session.userId,
    activityType: session.activityType,
    status: session.status,
    resourceId: session.resourceId,
    title: session.title,
    startedAt: session.startedAt.toISOString(),
    endedAt: session.endedAt?.toISOString(),
    durationSeconds: session.duration ?? 0,
    moodBefore: session.moodBefore,
    moodAfter: session.moodAfter,
    reliefLevel: session.reliefLevel,
    stressReliefPercent: session.stressReliefPercent,
    note: session.note,
    nextActionAccepted: session.nextActionAccepted,
    createdAt: session.createdAt,
    activity: option,
  };
}

/**
 * Pick next-suggested activity = any other type than the one just done.
 * Falls back to the first option if every option matches (impossible
 * today but defensive).
 */
export function getNextSuggestion(completedType: RelaxActivityType) {
  return (
    RELAX_ACTIVITY_OPTIONS.find((option) => option.type !== completedType) ??
    RELAX_ACTIVITY_OPTIONS[0]
  );
}
