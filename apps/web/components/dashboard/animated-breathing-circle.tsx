'use client';

/**
 * AnimatedBreathingCircle — inline breathing guide for the Breaks page.
 *
 * Renders a circle that scales between two sizes following an
 * inhale → hold → exhale → hold-after cycle. Phase length is driven by
 * the chosen pattern so the same component handles Box Breathing 4-4-4-4,
 * the 4-7-8 wind-down, and 4-0-4-0 natural breathing without special-casing.
 *
 * State machine (single setInterval at TICK_MS):
 *   each tick subtracts TICK_MS/1000 from `phaseRemaining`. when it hits
 *   zero we hop to the next non-zero phase. when the order wraps back to
 *   inhale, that counts as one finished cycle; we stop when `cyclesDone`
 *   reaches the pattern's `cycles`.
 *
 * Visual scaling uses a CSS transition whose duration matches the active
 * phase length — the browser's compositor handles the easing so we never
 * touch transform per frame.
 */

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Pause, Play, RotateCcw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export interface BreathingPattern {
  code: string;
  label: { vi: string; en: string };
  inhale: number;
  hold: number;
  exhale: number;
  holdAfter: number;
  cycles: number;
}

type Phase = 'inhale' | 'hold' | 'exhale' | 'holdAfter' | 'finished' | 'idle';

const TICK_MS = 100;

const DEFAULT_PATTERNS: BreathingPattern[] = [
  {
    code: 'BOX_4_4_4_4',
    label: { vi: 'Box 4-4-4-4 · cân bằng', en: 'Box 4-4-4-4 · balanced' },
    inhale: 4,
    hold: 4,
    exhale: 4,
    holdAfter: 4,
    cycles: 6,
  },
  {
    code: 'RELAX_4_7_8',
    label: { vi: '4-7-8 · ngủ ngon', en: '4-7-8 · wind down' },
    inhale: 4,
    hold: 7,
    exhale: 8,
    holdAfter: 0,
    cycles: 5,
  },
  {
    code: 'NATURAL_4_0_4_0',
    label: { vi: '4-0-4-0 · tự nhiên', en: '4-0-4-0 · natural' },
    inhale: 4,
    hold: 0,
    exhale: 4,
    holdAfter: 0,
    cycles: 8,
  },
];

const PHASE_ORDER: Phase[] = ['inhale', 'hold', 'exhale', 'holdAfter'];

export function AnimatedBreathingCircle({
  patterns = DEFAULT_PATTERNS,
}: {
  patterns?: BreathingPattern[];
}) {
  const { t, locale } = useTranslation();
  const [patternIdx, setPatternIdx] = useState(0);
  const pattern = patterns[patternIdx] ?? patterns[0] ?? DEFAULT_PATTERNS[0];

  const [phase, setPhase] = useState<Phase>('idle');
  const [phaseRemaining, setPhaseRemaining] = useState(0);
  const [cyclesDone, setCyclesDone] = useState(0);
  const [running, setRunning] = useState(false);
  // Track current phase in a ref so the tick interval can read it without
  // re-subscribing on every render.
  const phaseRef = useRef<Phase>('idle');
  phaseRef.current = phase;

  const phaseLength = useCallback(
    (p: Phase): number => {
      switch (p) {
        case 'inhale':
          return Math.max(0, pattern.inhale);
        case 'hold':
          return Math.max(0, pattern.hold);
        case 'exhale':
          return Math.max(0, pattern.exhale);
        case 'holdAfter':
          return Math.max(0, pattern.holdAfter);
        default:
          return 0;
      }
    },
    [pattern],
  );

  /** Next non-zero phase, wrapping the 4-slot order. */
  const nextPhaseAfter = useCallback(
    (current: Phase): Phase => {
      const idx = PHASE_ORDER.indexOf(current);
      if (idx === -1) return 'inhale';
      for (let step = 1; step <= PHASE_ORDER.length; step++) {
        const candidate = PHASE_ORDER[(idx + step) % PHASE_ORDER.length];
        if (phaseLength(candidate) > 0) return candidate;
      }
      return 'inhale';
    },
    [phaseLength],
  );

  const reset = useCallback(() => {
    setRunning(false);
    setPhase('idle');
    setPhaseRemaining(0);
    setCyclesDone(0);
  }, []);

  // Reset whenever pattern changes so we don't carry stale phase counts.
  useEffect(() => {
    reset();
  }, [patternIdx, reset]);

  const start = useCallback(() => {
    const first = PHASE_ORDER.find((p) => phaseLength(p) > 0) ?? 'inhale';
    setPhase(first);
    setPhaseRemaining(phaseLength(first));
    setCyclesDone(0);
    setRunning(true);
  }, [phaseLength]);

  // Single ticker — no per-phase setTimeout so pausing never leaks timers.
  useEffect(() => {
    if (!running) return;
    const id = window.setInterval(() => {
      setPhaseRemaining((rem) => {
        const next = +(rem - TICK_MS / 1000).toFixed(2);
        if (next > 0) return next;

        const current = phaseRef.current;
        const nextPhase = nextPhaseAfter(current);

        // Wrapping back to inhale = one cycle finished.
        if (nextPhase === 'inhale' && current !== 'idle' && current !== 'finished') {
          setCyclesDone((c) => {
            const newCount = c + 1;
            if (newCount >= pattern.cycles) {
              setRunning(false);
              setPhase('finished');
            }
            return newCount;
          });
        }
        if (phaseRef.current === 'finished') return 0;
        setPhase(nextPhase);
        return phaseLength(nextPhase);
      });
    }, TICK_MS);
    return () => window.clearInterval(id);
  }, [running, nextPhaseAfter, phaseLength, pattern.cycles]);

  // inhale → grow, exhale → shrink, holds keep current size.
  const targetScale = useMemo(() => {
    switch (phase) {
      case 'inhale':
      case 'hold':
        return 1;
      case 'exhale':
      case 'holdAfter':
      case 'idle':
      case 'finished':
        return 0.55;
      default:
        return 0.55;
    }
  }, [phase]);

  const transitionDuration =
    phase === 'inhale' || phase === 'exhale'
      ? `${phaseLength(phase)}s`
      : '0.4s';

  const phaseLabelKey =
    phase === 'inhale'
      ? 'breathingCircle.phase.inhale'
      : phase === 'hold'
        ? 'breathingCircle.phase.hold'
        : phase === 'exhale'
          ? 'breathingCircle.phase.exhale'
          : phase === 'holdAfter'
            ? 'breathingCircle.phase.holdAfter'
            : phase === 'finished'
              ? 'breathingCircle.phase.finished'
              : 'breathingCircle.phase.ready';

  return (
    <div className="rounded-lg border border-white/10 bg-night/40 p-5">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <p className="text-xs font-bold uppercase tracking-[0.18em] text-mist/60">
          {t('breathingCircle.eyebrow')}
        </p>
        <div className="flex flex-wrap gap-1.5">
          {patterns.map((p, i) => (
            <button
              className={`rounded-full px-2.5 py-1 text-xs font-semibold transition ${
                i === patternIdx
                  ? 'bg-violet text-white'
                  : 'bg-white/10 text-mist/70 hover:bg-white/20'
              }`}
              key={p.code}
              onClick={() => setPatternIdx(i)}
              type="button"
            >
              {p.label[locale === 'en' ? 'en' : 'vi']}
            </button>
          ))}
        </div>
      </div>

      <div className="mt-5 flex flex-col items-center">
        <div
          aria-hidden
          className="relative flex h-56 w-56 items-center justify-center"
        >
          {/* Three concentric guide rings — subtle motion cue even when paused. */}
          <div className="absolute inset-0 rounded-full border border-violet/25" />
          <div className="absolute inset-3 rounded-full border border-violet/15" />
          <div className="absolute inset-6 rounded-full border border-violet/10" />

          <div
            className="relative flex h-48 w-48 items-center justify-center rounded-full bg-gradient-to-br from-violet via-violet/70 to-plum text-white shadow-[0_0_56px_rgba(115,87,246,0.45)] transition-transform ease-in-out"
            style={{
              transform: `scale(${targetScale})`,
              transitionDuration,
            }}
          >
            <div className="text-center">
              <p className="text-[10px] font-bold uppercase tracking-[0.22em] text-white/85">
                {t(phaseLabelKey)}
              </p>
              <p className="mt-1 text-4xl font-extrabold tabular-nums">
                {phase === 'idle'
                  ? '·'
                  : phase === 'finished'
                    ? '✓'
                    : Math.ceil(phaseRemaining)}
              </p>
            </div>
          </div>
        </div>

        <p className="mt-4 text-xs font-semibold text-mist/75">
          {t('breathingCircle.cycleCounter', {
            done: cyclesDone,
            total: pattern.cycles,
          })}
        </p>
        <p className="mt-1 text-[10px] text-mist/45">
          {t('breathingCircle.patternSummary', {
            inhale: pattern.inhale,
            hold: pattern.hold,
            exhale: pattern.exhale,
            holdAfter: pattern.holdAfter,
            cycles: pattern.cycles,
          })}
        </p>
      </div>

      <div className="mt-5 flex flex-wrap justify-center gap-2">
        {phase === 'idle' || phase === 'finished' ? (
          <Button onClick={start}>
            <Play className="h-4 w-4" />
            {phase === 'finished'
              ? t('breathingCircle.action.restart')
              : t('breathingCircle.action.start')}
          </Button>
        ) : running ? (
          <Button onClick={() => setRunning(false)} variant="secondary">
            <Pause className="h-4 w-4" />
            {t('breathingCircle.action.pause')}
          </Button>
        ) : (
          <Button onClick={() => setRunning(true)}>
            <Play className="h-4 w-4" />
            {t('breathingCircle.action.resume')}
          </Button>
        )}
        <Button onClick={reset} variant="ghost">
          <RotateCcw className="h-4 w-4" />
          {t('breathingCircle.action.reset')}
        </Button>
      </div>
    </div>
  );
}
