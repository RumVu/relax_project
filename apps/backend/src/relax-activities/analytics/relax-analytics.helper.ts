/**
 * Stats analytics for relax sessions: favorite activities, daily
 * timeline, relief summary, activity streak. All pure.
 */
import type { TimezoneContext } from '../../common/timezone';
import { toLocalDateKey } from '../../common/timezone';
import { RELAX_ACTIVITY_OPTIONS } from '../relax-activity-options';
import {
  RelaxRange,
  formatDuration,
  listLocalDays,
} from '../helpers/relax-time';
import { RelaxSessionPayload } from '../helpers/relax-mapper';

/** Per-activity-type breakdown sorted by total time spent. */
export function buildFavoriteActivities(sessions: RelaxSessionPayload[]) {
  return RELAX_ACTIVITY_OPTIONS.map((option) => {
    const activitySessions = sessions.filter(
      (session) => session.activityType === option.type,
    );
    const durationSeconds = activitySessions.reduce(
      (sum, session) => sum + (session.durationSeconds ?? 0),
      0,
    );
    const sessionsWithRelief = activitySessions.filter(
      (session) => typeof session.stressReliefPercent === 'number',
    );
    const stressReliefPercent =
      sessionsWithRelief.length > 0
        ? Math.round(
            sessionsWithRelief.reduce(
              (sum, session) => sum + (session.stressReliefPercent ?? 0),
              0,
            ) / sessionsWithRelief.length,
          )
        : 0;

    return {
      type: option.type,
      title: option.title,
      iconKey: option.iconKey,
      count: activitySessions.length,
      durationSeconds,
      durationLabel: formatDuration(durationSeconds),
      stressReliefPercent,
    };
  }).sort((left, right) => right.durationSeconds - left.durationSeconds);
}

/** Per-day buckets covering `range`, with session count + total duration. */
export function buildTimeline(
  sessions: RelaxSessionPayload[],
  range: RelaxRange,
  timezoneContext: TimezoneContext,
) {
  const days = listLocalDays(range, timezoneContext);

  return days.map((day) => {
    const daySessions = sessions.filter(
      (session) =>
        toLocalDateKey(
          new Date(session.endedAt ?? session.createdAt),
          timezoneContext,
        ) === day.date,
    );
    const durationSeconds = daySessions.reduce(
      (sum, session) => sum + (session.durationSeconds ?? 0),
      0,
    );

    return {
      ...day,
      totalSessions: daySessions.length,
      durationSeconds,
      durationLabel: formatDuration(durationSeconds),
    };
  });
}

/**
 * Average stress-relief % across finished sessions that recorded a
 * number. Sessions without relief data don't drag the average down.
 */
export function buildReliefSummary(sessions: RelaxSessionPayload[]) {
  const finishedWithRelief = sessions.filter(
    (session) => typeof session.stressReliefPercent === 'number',
  );
  const averageStressRelief =
    finishedWithRelief.length > 0
      ? Math.round(
          finishedWithRelief.reduce(
            (sum, session) => sum + (session.stressReliefPercent ?? 0),
            0,
          ) / finishedWithRelief.length,
        )
      : 0;

  return {
    averageStressRelief,
    finishedWithRelief: finishedWithRelief.length,
  };
}

/**
 * Activity streak = consecutive local-days with at least one finished
 * session. Returns `{ current, longest }` matching mood-streaks shape.
 */
export function calculateActivityStreak(
  sessions: RelaxSessionPayload[],
  timezoneContext: TimezoneContext,
) {
  const days = Array.from(
    new Set(
      sessions.map((session) =>
        toLocalDateKey(
          new Date(session.endedAt ?? session.createdAt),
          timezoneContext,
        ),
      ),
    ),
  ).sort();
  let longest = 0;
  let run = 0;
  let previous: Date | undefined;

  for (const day of days) {
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

  return {
    current: days.length > 0 ? run : 0,
    longest,
  };
}
