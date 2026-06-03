'use client';

/**
 * PremiumGate — paywall overlay for FREE users.
 *
 * Wraps a chunk of UI and, when the active subscription isn't a paid one,
 * dims/blurs the content underneath and shows a "membership only" card
 * with a CTA that jumps to the billing section in Settings. Admin users
 * always bypass the gate.
 *
 * Hook usage:
 *   <PremiumGate planName={data.settings.billing.planName} role={profile.role}>
 *     <AnalyticsCharts ... />
 *   </PremiumGate>
 */

import { useRouter } from 'next/navigation';
import { Lock, Sparkles } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useTranslation } from '@/lib/i18n/i18n-provider';

// Anything that includes "CHILL_PLUS" or "PREMIUM" counts as paid. We match
// loosely so future tiers (CHILL_PLUS_QUARTERLY, PREMIUM_FAMILY, …) inherit
// access without a code change. Plan strings can carry status suffixes like
// "CHILL_PLUS · ACTIVE" — the prefix is what matters.
const PAID_PREFIXES = ['CHILL_PLUS', 'PREMIUM', 'PRO'];

export function isPaidPlan(planName: string | null | undefined): boolean {
  if (!planName) return false;
  const code = planName.split('·')[0].trim().toUpperCase();
  return PAID_PREFIXES.some((p) => code.startsWith(p));
}

export function PremiumGate({
  children,
  planName,
  role,
  title,
  body,
}: {
  children: React.ReactNode;
  planName: string | null | undefined;
  /** ADMIN role bypasses every gate. */
  role?: string | null;
  /** Override copy when the section needs a more specific message. */
  title?: string;
  body?: string;
}) {
  const router = useRouter();
  const { t } = useTranslation();
  const unlocked = role === 'ADMIN' || isPaidPlan(planName);

  if (unlocked) return <>{children}</>;

  return (
    <div className="relative isolate overflow-hidden rounded-lg">
      {/* Real content stays in the DOM so layout doesn't jump and the user
          can see what they're about to unlock. aria-hidden + pointer-events
          off so screen readers + tab order don't reach it. */}
      <div
        aria-hidden
        className="pointer-events-none select-none opacity-40 blur-[3px]"
      >
        {children}
      </div>

      <div className="absolute inset-0 flex items-center justify-center bg-gradient-to-br from-ink/70 via-ink/65 to-violet/40 p-6 backdrop-blur-sm">
        <div className="w-full max-w-md rounded-xl border border-violet/50 bg-[var(--panel-bg)] p-6 text-center shadow-[0_24px_60px_rgba(20,18,46,0.55)]">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-violet/15 text-violet">
            <Lock className="h-6 w-6" />
          </div>
          <p className="mt-4 text-xs font-bold uppercase tracking-[0.18em] text-violet">
            {t('premium.eyebrow')}
          </p>
          <h3 className="mt-1 text-lg font-extrabold text-[var(--app-text)]">
            {title ?? t('premium.title')}
          </h3>
          <p className="mt-2 text-sm leading-relaxed text-[var(--app-text)] opacity-85">
            {body ?? t('premium.body')}
          </p>
          <Button
            className="mt-5"
            onClick={() => router.push('/dashboard/settings#billing')}
          >
            <Sparkles className="h-4 w-4" />
            {t('premium.cta')}
          </Button>
        </div>
      </div>
    </div>
  );
}
