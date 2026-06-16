'use client';

/**
 * OnboardingTour — first-login spotlight walkthrough.
 *
 * Instead of a generic centred modal, each step dims the rest of the
 * dashboard and cuts out a glowing rectangle around the actual UI element
 * being explained (`data-tour="<id>"`), then floats the explanation card
 * beside it. Welcome + closing steps have no target and render centred
 * the way the old version did.
 *
 * Cutout is built from four absolutely-positioned dark divs (top / bottom
 * / left / right of the target rect) plus a transparent inner box with a
 * violet glow — so the user can see the highlighted element through the
 * dim layer without us needing SVG mask hacks that misbehave on some
 * browsers.
 *
 * Completion is stored in localStorage keyed by the cached account email
 * so the tour never replays. Skipping or closing also counts as done.
 */

import { useCallback, useEffect, useState } from 'react';
import {
  BookOpenText,
  CheckCircle2,
  HeartPulse,
  PartyPopper,
  Settings,
  Sparkles,
  Wind,
  X,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useTranslation } from '@/lib/i18n/i18n-provider';

const STORAGE_KEY = 'relax_onboarding_seen';

interface Step {
  icon: typeof Sparkles;
  title: string;
  body: string;
  /** `data-tour` selector — null = centred welcome / done card with no target. */
  targetSelector: string | null;
}

interface Rect {
  top: number;
  left: number;
  width: number;
  height: number;
}

const PADDING = 12;
const CARD_GAP = 16;
const CARD_WIDTH = 380;
const CARD_HEIGHT_ESTIMATE = 240;

function readKey(): string {
  if (typeof window === 'undefined') return STORAGE_KEY;
  try {
    const cached = window.localStorage.getItem('relax_account_profile');
    const email = cached ? (JSON.parse(cached).email as string) : '';
    return email ? `${STORAGE_KEY}:${email}` : STORAGE_KEY;
  } catch {
    return STORAGE_KEY;
  }
}

function hasSeen(): boolean {
  if (typeof window === 'undefined') return true;
  try {
    return Boolean(window.localStorage.getItem(readKey()));
  } catch {
    return true;
  }
}

function markSeen() {
  try {
    window.localStorage.setItem(readKey(), new Date().toISOString());
  } catch {
    // localStorage disabled — degrade silently, tour just replays.
  }
}

/** Pick a spot for the popup so it doesn't overlap the highlighted target. */
function placeCard(rect: Rect | null, vw: number, vh: number) {
  if (!rect) {
    return {
      top: Math.max(16, (vh - CARD_HEIGHT_ESTIMATE) / 2),
      left: Math.max(16, (vw - CARD_WIDTH) / 2),
      arrow: 'none' as const,
    };
  }
  const spaceBelow = vh - (rect.top + rect.height) - CARD_GAP;
  const spaceAbove = rect.top - CARD_GAP;
  const spaceRight = vw - (rect.left + rect.width) - CARD_GAP;
  const spaceLeft = rect.left - CARD_GAP;

  // Prefer below, then above, then right, then left.
  if (spaceBelow >= CARD_HEIGHT_ESTIMATE) {
    const ideal = rect.left + rect.width / 2 - CARD_WIDTH / 2;
    const left = Math.min(Math.max(16, ideal), vw - CARD_WIDTH - 16);
    return {
      top: rect.top + rect.height + CARD_GAP,
      left,
      arrow: 'up' as const,
    };
  }
  if (spaceAbove >= CARD_HEIGHT_ESTIMATE) {
    const ideal = rect.left + rect.width / 2 - CARD_WIDTH / 2;
    const left = Math.min(Math.max(16, ideal), vw - CARD_WIDTH - 16);
    return {
      top: rect.top - CARD_HEIGHT_ESTIMATE - CARD_GAP,
      left,
      arrow: 'down' as const,
    };
  }
  if (spaceRight >= CARD_WIDTH) {
    const top = Math.max(
      16,
      Math.min(rect.top, vh - CARD_HEIGHT_ESTIMATE - 16),
    );
    return {
      top,
      left: rect.left + rect.width + CARD_GAP,
      arrow: 'left' as const,
    };
  }
  if (spaceLeft >= CARD_WIDTH) {
    const top = Math.max(
      16,
      Math.min(rect.top, vh - CARD_HEIGHT_ESTIMATE - 16),
    );
    return {
      top,
      left: rect.left - CARD_WIDTH - CARD_GAP,
      arrow: 'right' as const,
    };
  }
  // Fallback: dead-centre, like the welcome card.
  return {
    top: Math.max(16, (vh - CARD_HEIGHT_ESTIMATE) / 2),
    left: Math.max(16, (vw - CARD_WIDTH) / 2),
    arrow: 'none' as const,
  };
}

export function OnboardingTour() {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const [stepIdx, setStepIdx] = useState(0);
  const [rect, setRect] = useState<Rect | null>(null);
  const [viewport, setViewport] = useState({ w: 0, h: 0 });

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const params = new URLSearchParams(window.location.search);
      const forceTour = params.get('tour') === 'true';
      if (forceTour || !hasSeen()) {
        if (forceTour) {
          const url = new URL(window.location.href);
          url.searchParams.delete('tour');
          window.history.replaceState({}, '', url.pathname + url.search);
        }
        const id = window.setTimeout(() => {
          setStepIdx(0);
          setOpen(true);
        }, 250);
        return () => window.clearTimeout(id);
      }
    }
  }, []);

  const steps: Step[] = [
    {
      icon: PartyPopper,
      title: t('onboarding.step1.title'),
      body: t('onboarding.step1.body'),
      targetSelector: null,
    },
    {
      icon: HeartPulse,
      title: t('onboarding.step2.title'),
      body: t('onboarding.step2.body'),
      targetSelector: '[data-tour="mood-hero"]',
    },
    {
      icon: Wind,
      title: t('onboarding.step3.title'),
      body: t('onboarding.step3.body'),
      targetSelector: '[data-tour="tour-nav-breaks"]',
    },
    {
      icon: BookOpenText,
      title: t('onboarding.step4.title'),
      body: t('onboarding.step4.body'),
      targetSelector: '[data-tour="tour-nav-journal"]',
    },
    {
      icon: CheckCircle2,
      title: t('onboarding.step5.title'),
      body: t('onboarding.step5.body'),
      targetSelector: '[data-tour="quests"]',
    },
    {
      icon: Settings,
      title: t('onboarding.step6.title'),
      body: t('onboarding.step6.body'),
      targetSelector: '[data-tour="tour-nav-settings"]',
    },
  ];

  const close = useCallback(() => {
    markSeen();
    setOpen(false);
    setStepIdx(0);
  }, []);

  // Measure the target every time the step or viewport changes. Scroll the
  // target into view first so off-screen anchors get caught.
  useEffect(() => {
    if (!open) return;
    const step = steps[stepIdx];
    const measure = () => {
      setViewport({ w: window.innerWidth, h: window.innerHeight });
      if (!step.targetSelector) {
        setRect(null);
        return;
      }
      const el = document.querySelector<HTMLElement>(step.targetSelector);
      if (!el) {
        setRect(null);
        return;
      }
      const r = el.getBoundingClientRect();
      setRect({
        top: r.top - PADDING,
        left: r.left - PADDING,
        width: r.width + PADDING * 2,
        height: r.height + PADDING * 2,
      });
    };

    // Smooth-scroll into view, then measure (single rAF tick is enough).
    if (step.targetSelector) {
      const el = document.querySelector<HTMLElement>(step.targetSelector);
      el?.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
    const raf = window.requestAnimationFrame(measure);
    const observer = new ResizeObserver(measure);
    if (step.targetSelector) {
      const el = document.querySelector<HTMLElement>(step.targetSelector);
      if (el) observer.observe(el);
    }
    window.addEventListener('resize', measure);
    window.addEventListener('scroll', measure, true);
    return () => {
      window.cancelAnimationFrame(raf);
      window.removeEventListener('resize', measure);
      window.removeEventListener('scroll', measure, true);
      observer.disconnect();
    };
    // steps recompute each render from t(); only re-measure when index/open changes.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, stepIdx]);

  if (!open) return null;

  const step = steps[stepIdx];
  const Icon = step.icon;
  const isFirst = stepIdx === 0;
  const isLast = stepIdx === steps.length - 1;
  const place = placeCard(rect, viewport.w || 1, viewport.h || 1);

  // When there's no target, render the simpler centred card with a flat dim.
  if (!rect) {
    return (
      <div
        aria-modal="true"
        className="fixed inset-0 z-[100] flex items-center justify-center bg-ink/80 p-4 backdrop-blur-md"
        role="dialog"
      >
        <div className="w-full max-w-md">
          <TourCard
            currentStep={stepIdx + 1}
            icon={Icon}
            isFirst={isFirst}
            isLast={isLast}
            onClose={close}
            onJump={setStepIdx}
            onNext={() => setStepIdx((s) => Math.min(steps.length - 1, s + 1))}
            onPrev={() => setStepIdx((s) => Math.max(0, s - 1))}
            totalSteps={steps.length}
            text={step.body}
            title={step.title}
            t={t}
          />
        </div>
      </div>
    );
  }

  // Spotlight: 4 dim rectangles around the cutout + a glow border on the hole.
  const { top, left, width, height } = rect;
  const right = left + width;
  const bottom = top + height;

  return (
    <div
      aria-modal="true"
      className="fixed inset-0 z-[100]"
      role="dialog"
    >
      {/* 4 dim overlays forming a frame around the target */}
      <div
        className="absolute bg-ink/85 backdrop-blur-sm transition-all duration-200"
        style={{ top: 0, left: 0, right: 0, height: Math.max(0, top) }}
      />
      <div
        className="absolute bg-ink/85 backdrop-blur-sm transition-all duration-200"
        style={{
          top: bottom,
          left: 0,
          right: 0,
          bottom: 0,
        }}
      />
      <div
        className="absolute bg-ink/85 backdrop-blur-sm transition-all duration-200"
        style={{ top, left: 0, width: Math.max(0, left), height }}
      />
      <div
        className="absolute bg-ink/85 backdrop-blur-sm transition-all duration-200"
        style={{ top, left: right, right: 0, height }}
      />

      {/* Glow border around the cutout. pointer-events:none so the user can still
          interact with the highlighted region (e.g. read tooltips). */}
      <div
        className="pointer-events-none absolute rounded-xl ring-2 ring-violet ring-offset-2 ring-offset-ink/30 transition-all duration-200"
        style={{
          top,
          left,
          width,
          height,
          boxShadow: '0 0 0 9999px rgba(0,0,0,0), 0 0 32px 4px rgba(115,87,246,0.55)',
        }}
      />

      {/* Popup card positioned by placeCard() */}
      <div
        className="absolute"
        style={{
          top: place.top,
          left: place.left,
          width: CARD_WIDTH,
        }}
      >
        <TourCard
          arrow={place.arrow}
          currentStep={stepIdx + 1}
          icon={Icon}
          isFirst={isFirst}
          isLast={isLast}
          onClose={close}
          onJump={setStepIdx}
          onNext={() => setStepIdx((s) => Math.min(steps.length - 1, s + 1))}
          onPrev={() => setStepIdx((s) => Math.max(0, s - 1))}
          totalSteps={steps.length}
          text={step.body}
          title={step.title}
          t={t}
        />
      </div>
    </div>
  );
}

type TFunc = ReturnType<typeof useTranslation>['t'];

function TourCard({
  arrow,
  currentStep,
  icon: Icon,
  isFirst,
  isLast,
  onClose,
  onJump,
  onNext,
  onPrev,
  totalSteps,
  text,
  title,
  t,
}: {
  arrow?: 'up' | 'down' | 'left' | 'right' | 'none';
  currentStep: number;
  icon: typeof Sparkles;
  isFirst: boolean;
  isLast: boolean;
  onClose: () => void;
  onJump: (i: number) => void;
  onNext: () => void;
  onPrev: () => void;
  totalSteps: number;
  text: string;
  title: string;
  t: TFunc;
}) {
  return (
    <div className="relative rounded-2xl border border-[var(--panel-border)] bg-[var(--panel-bg)] p-5 shadow-[0_24px_60px_rgba(20,18,46,0.55)]">
      {/* Pointer arrow towards the highlighted region */}
      {arrow && arrow !== 'none' ? <Arrow direction={arrow} /> : null}

      <div className="flex items-start justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-11 w-11 items-center justify-center rounded-full bg-violet/15 text-violet">
            <Icon className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-violet">
              {t('onboarding.eyebrow', {
                current: currentStep,
                total: totalSteps,
              })}
            </p>
            <h3 className="mt-0.5 text-lg font-extrabold leading-tight text-[var(--app-text)]">
              {title}
            </h3>
          </div>
        </div>
        <button
          aria-label={t('common.close')}
          className="rounded-full p-1 text-slate transition hover:bg-white/10 hover:text-coral"
          onClick={onClose}
          type="button"
        >
          <X className="h-5 w-5" />
        </button>
      </div>

      <p className="mt-4 text-sm leading-relaxed text-[var(--app-text)] opacity-90">
        {text}
      </p>

      <div className="mt-5 flex justify-center gap-2">
        {Array.from({ length: totalSteps }).map((_, i) => (
          <button
            aria-label={t('onboarding.goTo', { step: i + 1 })}
            className={`h-2 rounded-full transition-all ${
              i === currentStep - 1
                ? 'w-8 bg-violet'
                : 'w-2 bg-violet/30 hover:bg-violet/50'
            }`}
            key={i}
            onClick={() => onJump(i)}
            type="button"
          />
        ))}
      </div>

      <div className="mt-5 flex flex-wrap justify-between gap-2">
        <Button disabled={isFirst} onClick={onPrev} variant="ghost">
          {t('onboarding.action.back')}
        </Button>
        <div className="flex gap-2">
          <Button onClick={onClose} variant="ghost">
            {t('onboarding.action.skip')}
          </Button>
          {isLast ? (
            <Button onClick={onClose}>
              <Sparkles className="h-4 w-4" />
              {t('onboarding.action.done')}
            </Button>
          ) : (
            <Button onClick={onNext}>{t('onboarding.action.next')}</Button>
          )}
        </div>
      </div>
    </div>
  );
}

function Arrow({ direction }: { direction: 'up' | 'down' | 'left' | 'right' }) {
  const base = 'absolute h-3 w-3 rotate-45 border-[var(--panel-border)] bg-[var(--panel-bg)]';
  const sides: Record<typeof direction, string> = {
    up: 'left-8 -top-1.5 border-t border-l',
    down: 'left-8 -bottom-1.5 border-b border-r',
    left: 'top-8 -left-1.5 border-l border-b',
    right: 'top-8 -right-1.5 border-r border-t',
  };
  return <div className={`${base} ${sides[direction]}`} aria-hidden />;
}
