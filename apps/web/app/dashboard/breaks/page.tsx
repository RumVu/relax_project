'use client';

import { useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { CheckCircle2, Headphones, Pause, PenLine, Play, Shuffle, Volume2, Wind } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  DataTable,
  MetricCard,
  RelaxActivityChart,
  SectionTitle,
} from '@/components/dashboard/dashboard-ui';
import { DashboardFilterBar, useDashboardFilters } from '@/components/dashboard/dashboard-filters';
import { ActionModal } from '@/components/ui/action-modal';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUserDashboardData } from '@/lib/live-dashboard';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { AmbientSoundPlayer } from '@/components/dashboard/ambient-sound-player';
import { AnimatedBreathingCircle } from '@/components/dashboard/animated-breathing-circle';

const activityIcons = {
  MUSIC: Headphones,
  PODCAST: Headphones,
  JOURNAL: PenLine,
  BREATHING: Wind,
  MYSTERY: Shuffle,
  MEDITATION: CheckCircle2,
};

function formatTrackDuration(seconds?: number | null) {
  if (!seconds) return '';
  const minutes = Math.floor(seconds / 60);
  const rest = seconds % 60;
  return `${minutes}:${String(rest).padStart(2, '0')}`;
}

export default function BreaksPage() {
  const router = useRouter();
  const { t } = useTranslation();
  const relaxFilters = useDashboardFilters('/relax-activities/me/stats', 'relax');
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const triggerRefresh = useDashboardStore((state) => state.triggerRefresh);
  const pushToast = useUiStore((state) => state.pushToast);
  const data = useUserDashboardData({
    refreshKey: refreshNonce,
    relaxQuery: relaxFilters.query,
  });
  const [activeActivity, setActiveActivity] = useState(data.relaxActivities[0]?.id ?? '');
  const [activeSessionId, setActiveSessionId] = useState<string | null>(null);
  const [actionState, setActionState] = useState<
    'idle' | 'starting' | 'started' | 'finishing' | 'finished' | 'error'
  >('idle');
  const [errorReason, setErrorReason] = useState<string | null>(null);
  const [sessionModal, setSessionModal] = useState<{
    open: boolean;
    phase: 'started' | 'finished';
  }>({
    open: false,
    phase: 'started',
  });
  const selectedActivityId = activeActivity || data.relaxActivities[0]?.id || '';
  const active =
    data.relaxActivities.find((activity) => activity.id === selectedActivityId) ??
    data.relaxActivities[0];
  const hasActivities = Boolean(active);
  const ActiveIcon = activityIcons[active?.type as keyof typeof activityIcons] ?? Play;
  const sessionRunning = actionState === 'started' && Boolean(activeSessionId);
  const queue = active?.resources ?? [];
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [playingResourceId, setPlayingResourceId] = useState<string | null>(null);
  const [playerProgress, setPlayerProgress] = useState(0);
  const [playerBusy, setPlayerBusy] = useState(false);
  const [playerPaused, setPlayerPaused] = useState(true);
  const [playerError, setPlayerError] = useState<string | null>(null);
  const playingResource =
    queue.find((resource) => resource.id === playingResourceId) ?? null;
  const isPlaying = Boolean(playingResourceId && !playerPaused);

  useEffect(() => {
    return () => {
      audioRef.current?.pause();
      audioRef.current = null;
    };
  }, []);

  async function handleResourcePlay(resource: (typeof queue)[number]) {
    if (!resource.soundUrl) {
      setPlayerError(t('breaks.session.noAudio'));
      return;
    }

    if (playingResourceId === resource.id && audioRef.current) {
      if (audioRef.current.paused) {
        setPlayerBusy(true);
        try {
          await audioRef.current.play();
          setPlayerPaused(false);
          setPlayerError(null);
        } catch {
          setPlayerError(t('breaks.session.playFailed'));
        } finally {
          setPlayerBusy(false);
        }
      } else {
        audioRef.current.pause();
        setPlayerPaused(true);
      }
      return;
    }

    audioRef.current?.pause();
    const audio = new Audio(resource.soundUrl);
    audioRef.current = audio;
    setPlayingResourceId(resource.id);
    setPlayerProgress(0);
    setPlayerPaused(true);
    setPlayerBusy(true);
    setPlayerError(null);

    audio.addEventListener('timeupdate', () => {
      if (!audio.duration || Number.isNaN(audio.duration)) return;
      setPlayerProgress(Math.min(100, (audio.currentTime / audio.duration) * 100));
    });
    audio.addEventListener('play', () => setPlayerPaused(false));
    audio.addEventListener('pause', () => setPlayerPaused(true));
    audio.addEventListener('ended', () => {
      setPlayerProgress(100);
      setPlayingResourceId(null);
      setPlayerPaused(true);
    });
    audio.addEventListener('error', () => {
      setPlayerError(t('breaks.session.playFailed'));
      setPlayingResourceId(null);
      setPlayerPaused(true);
    });

    try {
      await audio.play();
    } catch {
      setPlayerError(t('breaks.session.playFailed'));
      setPlayingResourceId(null);
    } finally {
      setPlayerBusy(false);
    }
  }

  function stopCurrentAudio() {
    audioRef.current?.pause();
    audioRef.current = null;
    setPlayingResourceId(null);
    setPlayerProgress(0);
    setPlayerPaused(true);
    setPlayerError(null);
  }

  return (
    <DashboardShell eyebrow={t('breaks.eyebrow')} title={t('breaks.title')}>
      <ActionModal
        description={
          sessionModal.phase === 'started'
            ? t('breaks.modal.started', { activity: active?.title ?? '' })
            : t('breaks.modal.finished', { activity: active?.title ?? '' })
        }
        onClose={() => setSessionModal((current) => ({ ...current, open: false }))}
        onPrimary={() => {
          setSessionModal((current) => ({ ...current, open: false }));
          router.push(
            sessionModal.phase === 'started'
              ? '/dashboard/breaks'
              : '/dashboard/mood',
          );
        }}
        onSecondary={() => setSessionModal((current) => ({ ...current, open: false }))}
        open={sessionModal.open}
        primaryLabel={
          sessionModal.phase === 'started' ? t('breaks.modal.continue') : t('breaks.modal.toMood')
        }
        secondaryLabel={t('common.close')}
        title={
          sessionModal.phase === 'started'
            ? t('breaks.modal.sessionStarted')
            : t('breaks.modal.sessionFinished')
        }
      />
      <DashboardFilterBar {...relaxFilters} title={t('breaks.filterTitle')} />

      {/* Sound player — fetch /v1/ambient-sounds, play through shared
       *  <audio> element. Lives at the top so user can pick a soundscape
       *  before / during their relax session. */}
      <AmbientSoundPlayer />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard icon={Play} label={t('breaks.metric.totalSessions')} value={data.overview.relax.totalSessions} />
        <MetricCard icon={Pause} label={t('breaks.metric.totalTime')} tone="lilac" value={data.overview.relax.totalDurationLabel} />
        <MetricCard icon={CheckCircle2} label={t('breaks.metric.relaxStreak')} note={t('breaks.metric.relaxStreak.note')} tone="sun" value={data.overview.relax.streak} />
        <MetricCard icon={Wind} label={t('breaks.metric.avgRelief')} note={t('breaks.metric.avgRelief.note')} tone="mint" value={`${data.overview.relax.relief}%`} />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1fr)_380px]">
        <Card>
          <SectionTitle title={t('breaks.catalog.title')} copy={t('breaks.catalog.copy')} />
          <div className="mt-5 grid gap-3 md:grid-cols-2">
            {data.relaxActivities.map((activity, index) => {
              const Icon = activityIcons[activity.type as keyof typeof activityIcons] ?? Play;
              const activeRow = selectedActivityId === activity.id;

              return (
                <button
                  className={`rounded-lg border p-4 text-left transition ${
                    activeRow
                      ? 'border-violet bg-violet text-white shadow-panel'
                      : 'border-lilac/70 bg-white/75 hover:border-violet'
                  }`}
                  key={activity.id}
                  onClick={() => {
                    if (selectedActivityId !== activity.id) {
                      stopCurrentAudio();
                    }
                    setActiveActivity(activity.id);
                  }}
                  type="button"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className={`flex h-11 w-11 items-center justify-center rounded-lg ${activeRow ? 'bg-white/15' : 'bg-lilac text-plum'}`}>
                      <Icon className="h-5 w-5" />
                    </div>
                    <span className="font-mono text-xs font-bold">0{index + 1}</span>
                  </div>
                  <h3 className="mt-4 text-lg font-extrabold">{activity.title}</h3>
                  <p className={`mt-1 text-sm ${activeRow ? 'text-white/70' : 'text-slate'}`}>{activity.subtitle}</p>
                  <div className="mt-3 flex flex-wrap items-center gap-2 text-sm font-bold">
                    <span>{activity.duration}</span>
                    <span>relief {activity.relief}%</span>
                    <span
                      className={`rounded-full px-2 py-0.5 text-[11px] ${
                        activeRow ? 'bg-white/15 text-white' : 'bg-lilac text-plum'
                      }`}
                    >
                      {t('breaks.catalog.resources', {
                        count: activity.resources.length,
                      })}
                    </span>
                  </div>
                </button>
              );
            })}
            {data.relaxActivities.length === 0 ? (
              <div className="rounded-lg border border-dashed border-lilac bg-white/70 p-6 text-sm font-medium text-slate">
                {t('ui.empty')}
              </div>
            ) : null}
          </div>
        </Card>

        <Card className="bg-night text-white">
          <SectionTitle
            title={t('breaks.session.heading')}
            copy={t('breaks.session.start')}
            action={<ActiveIcon className="h-5 w-5 text-mint" />}
          />
          <div className="mt-8 rounded-lg border border-white/10 bg-white/10 p-5">
            <div className="flex h-16 w-16 items-center justify-center rounded-lg bg-violet">
              <ActiveIcon className="h-8 w-8" />
            </div>
            <h3 className="mt-5 text-2xl font-extrabold">
              {active?.title ?? t('breaks.session.empty')}
            </h3>
            <p className="mt-2 text-sm text-mist/70">
              {active?.subtitle ?? t('common.loading')}
            </p>
            {active?.type === 'BREATHING' && sessionRunning ? (
              <div className="mt-5">
                <AnimatedBreathingCircle />
              </div>
            ) : (
            <div className="mt-5 rounded-lg border border-white/10 bg-night/30 p-3">
              <p className="text-xs font-bold uppercase tracking-[0.18em] text-mist/60">
                {sessionRunning
                  ? t('breaks.session.runningQueue')
                  : t('breaks.session.resources')}
              </p>
              {queue.length ? (
                <div className="mt-3 max-h-72 space-y-2 overflow-y-auto pr-1">
                  {queue.map((resource, index) => {
                    const rowPlaying = playingResourceId === resource.id;

                    return (
                    <div
                      className={`flex items-center justify-between gap-3 rounded-lg px-3 py-2 text-sm ${
                        rowPlaying
                          ? 'bg-mint/20 ring-1 ring-mint/40'
                          : 'bg-white/10'
                      }`}
                      key={resource.id}
                    >
                      <button
                        aria-label={
                          rowPlaying && isPlaying
                            ? t('breaks.session.pauseTrack')
                            : t('breaks.session.playTrack')
                        }
                        className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-white/10 text-white transition hover:bg-white/20 disabled:cursor-not-allowed disabled:opacity-45"
                        disabled={!resource.soundUrl || playerBusy}
                        onClick={() => void handleResourcePlay(resource)}
                        type="button"
                      >
                        {rowPlaying && isPlaying ? (
                          <Pause className="h-3.5 w-3.5" />
                        ) : (
                          <Play className="h-3.5 w-3.5" />
                        )}
                      </button>
                      <div className="min-w-0 flex-1">
                        <span className="block truncate font-semibold">
                          {resource.title}
                        </span>
                        {rowPlaying || (sessionRunning && index === 0) ? (
                          <span className="mt-0.5 block text-[11px] font-bold text-mint">
                            {rowPlaying
                              ? t('breaks.session.nowListening')
                              : t('breaks.session.upNext')}
                          </span>
                        ) : null}
                      </div>
                      <span className="shrink-0 text-xs font-bold text-mist/70">
                        {resource.category}
                        {resource.duration ? ` · ${formatTrackDuration(resource.duration)}` : ''}
                      </span>
                    </div>
                    );
                  })}
                </div>
              ) : (
                <p className="mt-3 text-sm font-semibold text-mist/60">
                  {t('breaks.session.noResources')}
                </p>
              )}
              <div className="mt-4 rounded-lg border border-white/10 bg-white/10 p-3">
                <div className="flex items-center gap-3">
                  <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-violet/80">
                    <Volume2 className="h-4 w-4" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-mist/60">
                      {t('breaks.session.player')}
                    </p>
                    <p className="truncate text-sm font-extrabold">
                      {playingResource?.title ?? t('breaks.session.pickToListen')}
                    </p>
                  </div>
                </div>
                <div className="mt-3 h-2 overflow-hidden rounded-full bg-white/15">
                  <div
                    className="h-full rounded-full bg-mint transition-all"
                    style={{ width: `${playingResource ? playerProgress : 0}%` }}
                  />
                </div>
                {playerError ? (
                  <p className="mt-2 text-xs font-semibold text-coral">{playerError}</p>
                ) : null}
              </div>
            </div>
            )}
            <div className="mt-6 h-3 overflow-hidden rounded-full bg-white/15">
              <div
                className={`h-full rounded-full bg-mint transition-all ${
                  actionState === 'started' ? 'w-full' : 'w-1/4'
                }`}
              />
            </div>
            <p className="mt-2 text-xs font-semibold text-mist/60">
              {sessionRunning
                ? t('breaks.session.runningHint', { count: queue.length })
                : hasActivities
                  ? t('breaks.session.ready')
                  : t('common.loading')}
            </p>
          </div>
          <div className="mt-5 grid gap-2 sm:grid-cols-2">
            <Button
              disabled={actionState === 'starting' || !hasActivities || Boolean(activeSessionId)}
              onClick={async () => {
                if (!active) {
                  // Guard ngay tại UI để báo lỗi cụ thể thay vì throw chung chung.
                  pushToast({
                    tone: 'error',
                    title: t('breaks.toast.startFailed'),
                    message: t('breaks.toast.noActivity'),
                  });
                  setActionState('error');
                  setErrorReason(t('breaks.toast.noActivity'));
                  return;
                }
                setActionState('starting');
                setErrorReason(null);
                try {
                  const session = await apiFetch<{ id?: string }>(
                    '/relax-activities/sessions/start',
                    {
                      method: 'POST',
                      body: JSON.stringify({
                        activityType: active.type,
                        title: active.title,
                        moodBefore: 'STRESSED',
                      }),
                    },
                  );
                  setActiveSessionId(session.id ?? null);
                  setActionState('started');
                  triggerRefresh();
                  setSessionModal({ open: true, phase: 'started' });
                  pushToast({
                    tone: 'success',
                    title: t('breaks.session.start'),
                    message: active.title,
                  });
                } catch (err) {
                  const message = err instanceof Error ? err.message : String(err);
                  setActionState('error');
                  setErrorReason(message);
                  pushToast({
                    tone: 'error',
                    title: t('breaks.toast.startFailed'),
                    message,
                  });
                }
              }}
            >
              <Play className="h-4 w-4" />
              {actionState === 'starting' ? t('breaks.session.starting') : t('breaks.session.start')}
            </Button>
            <Button
              disabled={actionState === 'finishing' || !activeSessionId}
              onClick={async () => {
                if (!activeSessionId) {
                  // Người dùng bấm "Kết thúc phiên" khi chưa có phiên nào — báo rõ ràng.
                  pushToast({
                    tone: 'error',
                    title: t('breaks.toast.finishFailed'),
                    message: t('breaks.toast.noActiveSession'),
                  });
                  setActionState('error');
                  setErrorReason(t('breaks.toast.noActiveSession'));
                  return;
                }
                setActionState('finishing');
                setErrorReason(null);
                try {
                  await apiFetch(`/relax-activities/sessions/${activeSessionId}/finish`, {
                    method: 'POST',
                    body: JSON.stringify({
                      moodAfter: 'CALM',
                      reliefLevel: 4,
                      note: 'Finished from web dashboard',
                    }),
                  });
                  setActionState('finished');
                  setActiveSessionId(null);
                  triggerRefresh();
                  setSessionModal({ open: true, phase: 'finished' });
                  pushToast({
                    tone: 'success',
                    title: t('breaks.session.finish'),
                    message: t('breaks.modal.sessionFinished'),
                  });
                } catch (err) {
                  const message = err instanceof Error ? err.message : String(err);
                  setActionState('error');
                  setErrorReason(message);
                  pushToast({
                    tone: 'error',
                    title: t('breaks.toast.finishFailed'),
                    message,
                  });
                }
              }}
              variant="secondary"
            >
              <CheckCircle2 className="h-4 w-4" />
              {actionState === 'finishing' ? t('breaks.session.finishing') : t('breaks.session.finish')}
            </Button>
          </div>
          {actionState === 'started' || actionState === 'finished' || actionState === 'error' ? (
            <p
              className={`mt-3 text-sm font-semibold ${
                actionState === 'error' ? 'text-coral' : 'text-mint'
              }`}
            >
              {actionState === 'error'
                ? (errorReason ?? t('breaks.toast.actionFailed'))
                : actionState === 'started'
                  ? t('breaks.modal.sessionStarted')
                  : t('breaks.modal.sessionFinished')}
            </p>
          ) : null}
        </Card>
      </div>

      <RelaxActivityChart data={data.relaxActivities} />

      <Card>
        <SectionTitle title={t('breaks.history.title')} copy={t('breaks.history.copy')} />
        <div className="mt-5">
          <DataTable
            columns={[t('breaks.col.activity'), t('breaks.col.time'), t('breaks.col.duration'), t('breaks.col.relief')]}
            rows={data.overview.relax.recentMoments.map((moment) => [
              moment.title,
              moment.time,
              moment.duration,
              `${moment.relief}%`,
            ])}
          />
        </div>
      </Card>
    </DashboardShell>
  );
}
