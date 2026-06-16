'use client';

import { useState } from 'react';
import { CreditCard } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { apiFetch } from '@/lib/api';
import { CheckoutModal } from '../components/checkout-modal';
import { formatPlanPrice } from '../settings-utils';
import type { BillingPlan, CheckoutResult, ConfirmResult } from '../settings-types';

interface BillingSectionProps {
  locale: 'vi' | 'en';
  copy: any;
  settings: any;
  billingPlans: BillingPlan[];
  triggerRefresh: () => void;
  setRefreshKey: (updater: (prev: number) => number) => void;
  pushToast: (toast: any) => void;
}

export function BillingSection({
  locale,
  copy,
  settings,
  billingPlans,
  triggerRefresh,
  setRefreshKey,
  pushToast,
}: BillingSectionProps) {
  const [billingState, setBillingState] = useState<string | null>(null);
  const [checkoutPlan, setCheckoutPlan] = useState<BillingPlan | null>(null);
  const [checkoutResult, setCheckoutResult] = useState<CheckoutResult | null>(null);

  return (
    <>
      <div id="billing" className="scroll-mt-6">
        <Card>
          <SectionTitle
            title={copy.billingTitle}
            copy={copy.billingCopy}
            action={<CreditCard className="h-5 w-5 text-violet" />}
          />
        <div className="mt-5 rounded-lg border border-lilac/70 bg-white/75 p-4">
          <p className="text-xs font-semibold uppercase tracking-[0.14em] text-slate">
            {copy.currentPlan}
          </p>
          <p className="mt-2 text-2xl font-extrabold text-ink">
            {settings.billing.planName}
          </p>
          <p className="mt-1 text-sm font-medium text-plum">
            {copy.billingStatus(settings.billing.status, settings.billing.renewal)}
          </p>
        </div>
        <div className="mt-5 grid gap-3">
          {billingPlans.length > 0 ? billingPlans.map((plan) => (
            <div
              className="rounded-lg border border-lilac/70 bg-white/75 p-4"
              key={plan.name}
            >
              <div className="flex flex-wrap items-start justify-between gap-3">
                <div>
                  <p className="text-lg font-extrabold text-ink">{plan.title}</p>
                  <p className="mt-1 text-sm font-semibold text-plum">
                    {formatPlanPrice(plan.price, plan.currency, locale)}
                  </p>
                </div>
                <Button
                  className="h-9 px-3 text-xs"
                  disabled={
                    billingState === plan.name ||
                    settings.billing.planName === plan.name
                  }
                  onClick={() => {
                    setCheckoutResult(null);
                    setCheckoutPlan(plan);
                  }}
                  variant={
                    settings.billing.planName === plan.name
                      ? 'secondary'
                      : 'primary'
                  }
                >
                  {settings.billing.planName === plan.name
                    ? copy.inUse
                    : billingState === plan.name
                      ? copy.creating
                      : copy.choosePlan}
                </Button>
              </div>
              {plan.features.length > 0 ? (
                <div className="mt-3 flex flex-wrap gap-2">
                  {plan.features.slice(0, 4).map((feature) => (
                    <span
                      className="rounded-md bg-cloud px-2 py-1 text-xs font-bold text-ink"
                      key={feature}
                    >
                      {feature}
                    </span>
                  ))}
                </div>
              ) : null}
            </div>
          )) : (
            <div className="rounded-lg border border-dashed border-lilac bg-white/70 p-5 text-sm font-medium text-slate">
              {copy.billingEmpty}
            </div>
          )}
        </div>
      </Card>
    </div>

      {checkoutPlan ? (
        <CheckoutModal
          billingState={billingState}
          currentPlanName={settings.billing.planName}
          onClose={() => {
            setCheckoutPlan(null);
            setCheckoutResult(null);
          }}
          onConfirm={async () => {
            setBillingState(checkoutPlan.name);
            setCheckoutResult(null);
            try {
              const isDowngradeToFree = checkoutPlan.price === 0 || checkoutPlan.name.toUpperCase() === 'FREE';

              if (isDowngradeToFree) {
                const downgradeResult = (await apiFetch('/billing/me/downgrade', {
                  method: 'POST',
                  body: JSON.stringify({ planName: checkoutPlan.name }),
                })) as { subscription?: { planName?: string; status?: string } };
                setCheckoutResult({
                  checkout: {
                    status: 'ACTIVATED',
                    note: copy.activatedNote(
                      downgradeResult.subscription?.planName ?? checkoutPlan.title,
                      downgradeResult.subscription?.status ?? 'ACTIVE',
                    ),
                  },
                });
                setRefreshKey((current) => current + 1);
                triggerRefresh();
                pushToast({
                  tone: 'success',
                  title: copy.activatedTitle(checkoutPlan.title),
                  message: locale === 'en' ? 'Plan has been downgraded.' : 'Đã hạ gói thành công!',
                });
                return;
              }

              const redirectOrigin = window.location.origin;
              const result = (await apiFetch('/billing/me/checkout-session', {
                method: 'POST',
                body: JSON.stringify({
                  planName: checkoutPlan.name,
                  provider: 'SEPAY',
                  description: `Upgrade intent from dashboard to ${checkoutPlan.title}`,
                  successUrl: `${redirectOrigin}/dashboard/settings?payment=success&plan=${encodeURIComponent(checkoutPlan.name)}`,
                  errorUrl: `${redirectOrigin}/dashboard/settings?payment=error`,
                  cancelUrl: `${redirectOrigin}/dashboard/settings?payment=cancel`,
                }),
              })) as CheckoutResult & {
                checkout?: {
                  checkoutUrl?: string;
                  checkoutFormfields?: Record<string, string | number>;
                  url?: string;
                };
              };
              setCheckoutResult(result);

              const paymentId = result.payment?.id;
              if (!paymentId) {
                triggerRefresh();
                pushToast({
                  tone: 'error',
                  title: copy.upgradeFailed,
                  message: copy.missingPaymentId,
                });
                return;
              }

              // Path A1: SePay PG SDK shape — `checkoutUrl` + `checkoutFormfields`.
              const sepayUrl = result.checkout?.checkoutUrl;
              const sepayFields = result.checkout?.checkoutFormfields;
              if (
                sepayUrl &&
                sepayFields &&
                Object.keys(sepayFields).length > 0
              ) {
                pushToast({
                  tone: 'info',
                  title: copy.intentCreated(checkoutPlan.title),
                  message: copy.redirectingToSepay,
                });
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = sepayUrl;
                form.style.display = 'none';
                for (const [key, value] of Object.entries(sepayFields)) {
                  const input = document.createElement('input');
                  input.type = 'hidden';
                  input.name = key;
                  input.value = String(value);
                  form.appendChild(input);
                }
                document.body.appendChild(form);
                form.submit();
                return;
              }

              // Path A2: Simple GET redirect URL (Stripe/mock).
              const externalUrl = result.checkout?.url;
              if (externalUrl) {
                pushToast({
                  tone: 'info',
                  title: copy.intentCreated(checkoutPlan.title),
                  message: result.checkout?.note ?? copy.intentRecorded,
                });
                window.location.href = externalUrl;
                return;
              }

              // Path B1: Backend returned QR code for bank transfer — show QR in modal, wait for webhook confirmation.
              if (result.checkout?.qrUrl) {
                pushToast({
                  tone: 'info',
                  title: copy.intentCreated(checkoutPlan.title),
                  message: locale === 'en' ? 'Scan QR to pay via bank transfer.' : 'Quét mã QR để chuyển khoản thanh toán.',
                });
                return;
              }

              // Path B2: No external URL and no QR — auto-confirm via /confirm endpoint.
              try {
                const activated = (await apiFetch(
                  `/billing/me/payments/${paymentId}/confirm`,
                  {
                    method: 'POST',
                    body: JSON.stringify({
                      planName: result.plan?.name ?? checkoutPlan.name,
                    }),
                  },
                )) as ConfirmResult;
                setCheckoutResult({
                  ...result,
                  payment: {
                    ...result.payment,
                    status: activated.payment?.status ?? result.payment?.status,
                  },
                  checkout: {
                    status: 'ACTIVATED',
                    note: copy.activatedNote(
                      activated.subscription?.planName ?? checkoutPlan.title,
                      activated.subscription?.status ?? 'ACTIVE',
                    ),
                  },
                });
                triggerRefresh();
                pushToast({
                  tone: 'success',
                  title: copy.activatedTitle(checkoutPlan.title),
                  message: copy.activatedMessage,
                });
              } catch (confirmErr) {
                const reason =
                  confirmErr instanceof Error
                    ? confirmErr.message
                    : String(confirmErr);
                console.error('[billing] confirm failed', confirmErr);
                triggerRefresh();
                pushToast({
                  tone: 'error',
                  title: copy.upgradeFailed,
                  message: copy.upgradeFailedReason(reason),
                });
              }
            } catch (checkoutErr) {
              const reason =
                checkoutErr instanceof Error
                  ? checkoutErr.message
                  : String(checkoutErr);
              console.error('[billing] checkout session failed', checkoutErr);
              pushToast({
                tone: 'error',
                title: copy.upgradeFailed,
                message: copy.upgradeFailedReason(reason),
              });
            } finally {
              setBillingState(null);
            }
          }}
          plan={checkoutPlan}
          result={checkoutResult}
        />
      ) : null}
    </>
  );
}
