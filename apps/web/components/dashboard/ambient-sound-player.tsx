'use client';

/**
 * Ambient sound player widget. Fetches active AmbientSounds from the
 * backend, displays them as a clickable grid, and streams the selected
 * one via a single shared <audio> element so only one track plays at a
 * time. Loops by default (the seeded clips are 30s).
 *
 * Used in the dashboard /breaks page so the user can preview/play music
 * for their relax session without leaving the page.
 */

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { CloudRain, Music2, Pause, Play, Volume2, Waves } from 'lucide-react';
import { apiFetch } from '@/lib/api';
import { Card } from '@/components/ui/card';
import { SectionTitle } from './dashboard-ui';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { cn } from '@/lib/utils';

interface AmbientSound {
  id: string;
  title: string;
  description?: string | null;
  category: string;
  soundUrl: string;
  imageUrl?: string | null;
  duration?: number | null;
}

/** Visual fallback when DB row has no imageUrl. Soft gradient by category. */
const CATEGORY_GRADIENTS: Record<string, string> = {
  RAIN: 'from-sky-300/30 via-blue-400/20 to-indigo-500/10',
  NATURE: 'from-emerald-300/30 via-green-400/20 to-teal-500/10',
  LOFI: 'from-amber-300/30 via-orange-400/20 to-rose-500/10',
  AMBIENT: 'from-slate-300/30 via-zinc-400/20 to-stone-500/10',
  PIANO: 'from-violet-300/30 via-purple-400/20 to-fuchsia-500/10',
  MEDITATION: 'from-cyan-300/30 via-sky-400/20 to-blue-500/10',
};

export function AmbientSoundPlayer() {
  const { t } = useTranslation();
  const [sounds, setSounds] = useState<AmbientSound[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [playingId, setPlayingId] = useState<string | null>(null);
  const [volume, setVolume] = useState(0.7);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    let cancelled = false;
    apiFetch<{ items?: AmbientSound[] } | AmbientSound[]>('/ambient-sounds')
      .then((data) => {
        if (cancelled) return;
        const items = Array.isArray(data) ? data : (data.items ?? []);
        setSounds(items);
        setLoading(false);
      })
      .catch((cause) => {
        if (cancelled) return;
        setError(cause instanceof Error ? cause.message : 'load failed');
        setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  // Single shared audio element. Re-create on src change so events fire.
  useEffect(() => {
    return () => {
      // Pause + release on unmount so closing the page kills the sound.
      audioRef.current?.pause();
      audioRef.current = null;
    };
  }, []);

  // Volume slider syncs immediately even mid-playback.
  useEffect(() => {
    if (audioRef.current) audioRef.current.volume = volume;
  }, [volume]);

  const playing = useMemo(
    () => sounds.find((s) => s.id === playingId) ?? null,
    [sounds, playingId],
  );

  const handlePlay = useCallback(
    (sound: AmbientSound) => {
      // Toggle off if user clicks the currently-playing card.
      if (playingId === sound.id) {
        audioRef.current?.pause();
        setPlayingId(null);
        return;
      }

      // Tear down previous audio so the next track starts cleanly.
      audioRef.current?.pause();
      const next = new Audio(sound.soundUrl);
      next.loop = true;
      next.volume = volume;
      next.addEventListener('ended', () => setPlayingId(null));
      next.addEventListener('error', () => {
        setError(t('sound.error.playFailed', { title: sound.title }));
        setPlayingId(null);
      });
      audioRef.current = next;
      void next.play().catch(() => {
        setError(t('sound.error.browserBlocked', { title: sound.title }));
        setPlayingId(null);
      });
      setPlayingId(sound.id);
    },
    [playingId, volume, t],
  );

  const iconFor = (category: string) => {
    if (category === 'RAIN') return CloudRain;
    if (category === 'NATURE') return Waves;
    return Music2;
  };

  return (
    <Card>
      <SectionTitle
        title={t('breaks.start.heading')}
        copy={t('breaks.subtitle')}
        action={
          playing ? (
            <div className="flex items-center gap-2 text-xs font-semibold text-violet">
              <Volume2 className="h-3.5 w-3.5" />
              <input
                aria-label="Volume"
                className="h-1 w-20 cursor-pointer accent-violet"
                max={1}
                min={0}
                onChange={(event) => setVolume(Number(event.target.value))}
                step={0.05}
                type="range"
                value={volume}
              />
            </div>
          ) : null
        }
      />

      {loading ? (
        <p className="mt-5 text-sm font-semibold text-slate">
          {t('common.loading')}
        </p>
      ) : error ? (
        <p className="mt-5 rounded-lg border border-coral/40 bg-coral/10 p-3 text-sm font-semibold text-coral">
          {error}
        </p>
      ) : sounds.length === 0 ? (
        <p className="mt-5 text-sm font-semibold text-slate">
          {t('ui.empty')}
        </p>
      ) : (
        <div className="mt-5 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {sounds.map((sound) => {
            const Icon = iconFor(sound.category);
            const isPlaying = playingId === sound.id;
            const gradient =
              CATEGORY_GRADIENTS[sound.category] ?? CATEGORY_GRADIENTS.AMBIENT;
            return (
              <button
                aria-pressed={isPlaying}
                className={cn(
                  'group relative flex h-32 flex-col justify-between overflow-hidden rounded-lg border p-3 text-left transition',
                  isPlaying
                    ? 'border-violet ring-2 ring-violet shadow-panel'
                    : 'border-lilac/60 hover:border-violet hover:shadow-panel',
                )}
                key={sound.id}
                onClick={() => handlePlay(sound)}
                type="button"
              >
                {/* Backdrop: cover image if present, else gradient by category */}
                {sound.imageUrl ? (
                  <div
                    aria-hidden="true"
                    className="absolute inset-0 bg-cover bg-center opacity-50 transition group-hover:opacity-70"
                    style={{ backgroundImage: `url(${sound.imageUrl})` }}
                  />
                ) : (
                  <div
                    aria-hidden="true"
                    className={cn(
                      'absolute inset-0 bg-gradient-to-br opacity-80',
                      gradient,
                    )}
                  />
                )}
                <div
                  aria-hidden="true"
                  className="absolute inset-0 bg-gradient-to-t from-night/85 via-night/30 to-transparent"
                />

                {/* Header row: category icon + play/pause */}
                <div className="relative flex items-start justify-between">
                  <span className="inline-flex items-center gap-1 rounded-full bg-white/90 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide text-ink">
                    <Icon className="h-3 w-3" />
                    {sound.category}
                  </span>
                  <span
                    className={cn(
                      'flex h-8 w-8 items-center justify-center rounded-full text-white shadow-panel transition',
                      isPlaying ? 'bg-violet' : 'bg-night/70 group-hover:bg-violet',
                    )}
                  >
                    {isPlaying ? (
                      <Pause className="h-3.5 w-3.5" />
                    ) : (
                      <Play className="ml-0.5 h-3.5 w-3.5" />
                    )}
                  </span>
                </div>

                {/* Title row */}
                <div className="relative">
                  <p className="line-clamp-1 text-sm font-extrabold text-white drop-shadow">
                    {sound.title}
                  </p>
                  {sound.description ? (
                    <p className="mt-0.5 line-clamp-1 text-[11px] font-semibold text-white/80 drop-shadow">
                      {sound.description}
                    </p>
                  ) : null}
                </div>
              </button>
            );
          })}
        </div>
      )}
    </Card>
  );
}
