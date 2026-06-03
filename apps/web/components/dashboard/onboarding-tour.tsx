'use client';

/**
 * OnboardingTour — first-login walkthrough.
 *
 * Shows a 5-step modal sequence the first time a user lands on /dashboard.
 * Completion is stored in localStorage keyed by user email so the tour
 * never replays. Backend onboarding flag would be ideal but the user
 * profile already has a lot of write traffic on first login — keeping
 * the flag client-side avoids one extra round-trip on every page load.
 *
 * Steps are bilingual via the existing i18n provider, so flipping locale
 * mid-tour swaps copy without losing place.
 */

import { useEffect, useState } from 'react';
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
import { Card } from '@/components/ui/card';
import { useTranslation } from '@/lib/i18n/i18n-provider';

const STORAGE_KEY = 'relax_onboarding_seen';

interface Step {
  icon: typeof Sparkles;
  /** Pre-translated text — feeds typed `t()` outside the array. */
  title: string;
  body: string;
}

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
  if (typeof window === 'undefined') return true; // SSR — don't flash the modal.
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
    // localStorage might be disabled — degrade gracefully, the tour just
    // shows again next time.
  }
}

export function OnboardingTour() {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const [step, setStep] = useState(0);

  useEffect(() => {
    if (!hasSeen()) {
      // Wait a tick so the dashboard paints first — feels less abrupt.
      const id = window.setTimeout(() => setOpen(true), 250);
      return () => window.clearTimeout(id);
    }
  }, []);

  // Translate up front so the array stays typed and the dot-jump logic
  // doesn't need a `t()` call with a dynamic key.
  const steps: Step[] = [
    { icon: PartyPopper, title: t('onboarding.step1.title'), body: t('onboarding.step1.body') },
    { icon: HeartPulse, title: t('onboarding.step2.title'), body: t('onboarding.step2.body') },
    { icon: Wind, title: t('onboarding.step3.title'), body: t('onboarding.step3.body') },
    { icon: BookOpenText, title: t('onboarding.step4.title'), body: t('onboarding.step4.body') },
    { icon: CheckCircle2, title: t('onboarding.step5.title'), body: t('onboarding.step5.body') },
    { icon: Settings, title: t('onboarding.step6.title'), body: t('onboarding.step6.body') },
  ];

  const close = (markComplete = true) => {
    if (markComplete) markSeen();
    setOpen(false);
    setStep(0);
  };

  if (!open) return null;

  const current = steps[step];
  const Icon = current.icon;
  const isLast = step === steps.length - 1;
  const isFirst = step === 0;

  return (
    <div
      aria-modal="true"
      className="fixed inset-0 z-[100] flex items-center justify-center bg-ink/80 p-4 backdrop-blur-md"
      role="dialog"
    >
      <Card className="w-full max-w-lg">
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-3">
            <div className="flex h-12 w-12 items-center justify-center rounded-full bg-violet/15 text-violet">
              <Icon className="h-6 w-6" />
            </div>
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-violet">
                {t('onboarding.eyebrow', { current: step + 1, total: steps.length })}
              </p>
              <h3 className="mt-1 text-xl font-extrabold text-[var(--app-text)]">
                {current.title}
              </h3>
            </div>
          </div>
          <button
            aria-label={t('common.close')}
            className="rounded-full p-1 text-slate transition hover:bg-white/10 hover:text-coral"
            onClick={() => close(true)}
            type="button"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <p className="mt-5 text-sm leading-relaxed text-[var(--app-text)] opacity-90">
          {current.body}
        </p>

        {/* Step dots — clickable so the user can jump around. */}
        <div className="mt-6 flex justify-center gap-2">
          {steps.map((_, i) => (
            <button
              aria-label={t('onboarding.goTo', { step: i + 1 })}
              className={`h-2 rounded-full transition-all ${
                i === step ? 'w-8 bg-violet' : 'w-2 bg-violet/30 hover:bg-violet/50'
              }`}
              key={i}
              onClick={() => setStep(i)}
              type="button"
            />
          ))}
        </div>

        <div className="mt-6 flex flex-wrap justify-between gap-2">
          <Button
            disabled={isFirst}
            onClick={() => setStep((s) => Math.max(0, s - 1))}
            variant="ghost"
          >
            {t('onboarding.action.back')}
          </Button>
          <div className="flex gap-2">
            <Button onClick={() => close(true)} variant="ghost">
              {t('onboarding.action.skip')}
            </Button>
            {isLast ? (
              <Button onClick={() => close(true)}>
                <Sparkles className="h-4 w-4" />
                {t('onboarding.action.done')}
              </Button>
            ) : (
              <Button onClick={() => setStep((s) => Math.min(steps.length - 1, s + 1))}>
                {t('onboarding.action.next')}
              </Button>
            )}
          </div>
        </div>
      </Card>
    </div>
  );
}
