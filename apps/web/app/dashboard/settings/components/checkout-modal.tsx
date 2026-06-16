'use client';

import { CreditCard, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { VI_SETTINGS_COPY, EN_SETTINGS_COPY } from '../settings-copy';
import { formatPlanPrice } from '../settings-utils';
import type { BillingPlan, CheckoutResult } from '../settings-types';

export function CheckoutModal({
  billingState,
  currentPlanName,
  onClose,
  onConfirm,
  plan,
  result,
}: {
  billingState: string | null;
  currentPlanName: string;
  onClose: () => void;
  onConfirm: () => Promise<void>;
  plan: BillingPlan;
  result: CheckoutResult | null;
}) {
  const { locale, t } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;
  const creating = billingState === plan.name;
  const currentPlan = currentPlanName === plan.name;
  const hasSepayCheckout =
    result?.provider === 'SEPAY' &&
    result?.checkout?.checkoutUrl &&
    result?.checkout?.checkoutFormfields;

  const hasQrCode = !hasSepayCheckout && !!result?.checkout?.qrUrl;

  const isDowngradeToFree = currentPlanName !== 'FREE' && plan.name === 'FREE';

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-ink/55 p-4 backdrop-blur-sm sm:items-center">
      <div className="w-full max-w-xl rounded-2xl border border-[var(--panel-border)] bg-[var(--panel-strong)] p-5 text-[var(--app-text)] shadow-2xl">
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.18em] text-violet">
              {hasSepayCheckout ? '💳 SePay Payment' : hasQrCode ? '💳 Chuyển khoản' : 'Checkout intent'}
            </p>
            <h2 className="mt-2 text-2xl font-extrabold">{copy.checkoutTitle}</h2>
            <p className="mt-1 text-sm font-medium text-[var(--app-muted)]">
              {copy.checkoutCopy}
            </p>
          </div>
          <button
            aria-label={copy.closeCheckout}
            className="rounded-full border border-[var(--field-border)] p-2 text-[var(--app-text)] transition hover:bg-violet/10"
            onClick={onClose}
            type="button"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Plan summary card */}
        <div className="mt-5 rounded-xl border border-[var(--field-border)] bg-[var(--panel-bg)] p-4">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <p className="text-xl font-extrabold">{plan.title}</p>
              <p className="mt-1 text-sm font-semibold text-violet">
                {formatPlanPrice(plan.price, plan.currency, locale)}
              </p>
            </div>
            <span className="rounded-full bg-cloud px-3 py-1 text-xs font-bold text-ink">
              {currentPlan ? copy.currentPlan : copy.upgradable}
            </span>
          </div>
          {plan.features.length > 0 ? (
            <div className="mt-4 flex flex-wrap gap-2">
              {plan.features.map((feature) => (
                <span
                  className="rounded-md border border-[var(--field-border)] px-2 py-1 text-xs font-bold"
                  key={feature}
                >
                  {feature}
                </span>
              ))}
            </div>
          ) : null}
        </div>

        {/* Downgrade warning */}
        {isDowngradeToFree && !result ? (
          <div className="mt-4 rounded-xl border border-coral/40 bg-coral/10 p-4">
            <div className="flex items-center gap-2">
              <div className="flex h-7 w-7 items-center justify-center rounded-full bg-coral/20">
                <span className="text-sm font-bold text-coral">⚠</span>
              </div>
              <p className="font-extrabold text-coral">
                {locale === 'en' ? 'Downgrade Plan Warning' : 'Cảnh báo hạ cấp gói cước'}
              </p>
            </div>
            <p className="mt-2 text-xs font-semibold leading-relaxed">
              {locale === 'en'
                ? 'Your account will be downgraded from your current paid plan to the Free plan. Advanced features (such as advanced analytics, custom companion, smart reminders) will be locked after downgrading.'
                : 'Tài khoản của anh sẽ bị hạ từ gói cước có trả phí hiện tại xuống gói Miễn phí. Các tính năng nâng cao (thống kê nâng cao, tùy chỉnh linh thú, reminder thông minh...) sẽ bị khóa sau khi hạ cấp.'}
            </p>
          </div>
        ) : null}

        {/* Result panel — with enhanced SePay checkout */}
        {result ? (
          <div className="mt-4 space-y-4">
            {/* Payment info summary */}
            <div className="rounded-xl border border-mint/40 bg-mint/10 p-4">
              <div className="flex items-center gap-2">
                <div className="flex h-7 w-7 items-center justify-center rounded-full bg-mint/20">
                  <span className="text-sm">✓</span>
                </div>
                <p className="font-extrabold text-mint">{copy.intentReady}</p>
              </div>
              <div className="mt-3 grid gap-2 text-sm font-semibold sm:grid-cols-2">
                <span className="flex items-center gap-1.5">
                  <span className="inline-block h-1.5 w-1.5 rounded-full bg-mint/60" />
                  Payment: <code className="text-xs">{result.payment?.id ? `${result.payment.id.slice(0, 12)}…` : '-'}</code>
                </span>
                <span className="flex items-center gap-1.5">
                  <span className={`inline-block h-1.5 w-1.5 rounded-full ${result.payment?.status === 'COMPLETED' ? 'bg-emerald-500' : result.payment?.status === 'PENDING' ? 'bg-amber-400 animate-pulse' : 'bg-slate'}`} />
                  Status: {result.payment?.status ?? '-'}
                </span>
                <span className="flex items-center gap-1.5">
                  <span className="inline-block h-1.5 w-1.5 rounded-full bg-violet/60" />
                  Provider: {result.provider ?? 'MANUAL'}
                </span>
                <span className="flex items-center gap-1.5">
                  <span className="inline-block h-1.5 w-1.5 rounded-full bg-violet/60" />
                  Amount:{' '}
                  {formatPlanPrice(
                    result.payment?.amount ?? plan.price,
                    result.payment?.currency ?? plan.currency,
                    locale,
                  )}
                </span>
              </div>
            </div>

            {/* SePay checkout form — prominent payment button */}
            {hasSepayCheckout ? (
              <div className="rounded-xl border-2 border-violet/30 bg-gradient-to-br from-violet/5 via-transparent to-violet/10 p-5">
                <div className="mb-4 text-center">
                  <p className="text-sm font-bold text-violet uppercase tracking-wider">Thanh toán an toàn qua SePay</p>
                  <p className="mt-2 text-3xl font-extrabold text-[var(--app-text)]">
                    {formatPlanPrice(
                      result.payment?.amount ?? plan.price,
                      result.payment?.currency ?? plan.currency,
                      locale,
                    )}
                  </p>
                  <p className="mt-1 text-xs font-medium text-[var(--app-muted)]">
                    Gói {plan.title} • Chuyển khoản ngân hàng
                  </p>
                </div>

                <form action={result.checkout!.checkoutUrl!} method="POST">
                  {Object.entries(result.checkout!.checkoutFormfields!).map(([key, value]) => (
                    <input key={key} type="hidden" name={key} value={value} />
                  ))}
                  <button
                    type="submit"
                    className="group relative w-full overflow-hidden rounded-xl bg-gradient-to-r from-violet to-plum px-6 py-4 text-white font-bold text-base shadow-lg transition-all duration-300 hover:shadow-xl hover:shadow-violet/25 hover:scale-[1.01] active:scale-[0.99]"
                  >
                    <span className="absolute inset-0 bg-white/10 opacity-0 transition-opacity group-hover:opacity-100" />
                    <span className="relative flex items-center justify-center gap-3">
                      <CreditCard className="h-5 w-5" />
                      <span>Thanh toán ngay qua SePay</span>
                      <span className="text-xs opacity-75">→</span>
                    </span>
                  </button>
                </form>

                <div className="mt-3 flex items-center justify-center gap-1.5 text-xs font-medium text-[var(--app-muted)]">
                  <svg className="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
                  </svg>
                  <span>Bảo mật bởi SePay Payment Gateway</span>
                </div>
              </div>
            ) : hasQrCode ? (
              <div className="rounded-xl border-2 border-violet/30 bg-gradient-to-br from-violet/5 via-transparent to-violet/10 p-5">
                <div className="mb-4 text-center">
                  <p className="text-sm font-bold text-violet uppercase tracking-wider">
                    {locale === 'en' ? 'Bank Transfer Payment' : 'Thanh toán chuyển khoản'}
                  </p>
                  <p className="mt-2 text-3xl font-extrabold text-[var(--app-text)]">
                    {formatPlanPrice(
                      result.checkout?.amount ?? result.payment?.amount ?? plan.price,
                      result.payment?.currency ?? plan.currency,
                      locale,
                    )}
                  </p>
                  <p className="mt-1 text-xs font-medium text-[var(--app-muted)]">
                    {locale === 'en' ? `Plan ${plan.title} • Bank transfer` : `Gói ${plan.title} • Chuyển khoản ngân hàng`}
                  </p>
                </div>

                {/* QR Code */}
                <div className="flex justify-center">
                  <div className="rounded-xl border border-[var(--field-border)] bg-white p-3">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      alt="QR chuyển khoản"
                      className="h-56 w-56 object-contain"
                      src={result.checkout!.qrUrl!}
                    />
                  </div>
                </div>

                {/* Bank details */}
                <div className="mt-4 space-y-2 rounded-lg border border-[var(--field-border)] bg-[var(--panel-bg)] p-4 text-sm">
                  <div className="flex items-center justify-between">
                    <span className="font-medium text-[var(--app-muted)]">
                      {locale === 'en' ? 'Bank' : 'Ngân hàng'}
                    </span>
                    <span className="font-bold">{result.checkout?.bankName ?? 'MB Bank'}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="font-medium text-[var(--app-muted)]">
                      {locale === 'en' ? 'Account number' : 'Số tài khoản'}
                    </span>
                    <span className="font-bold font-mono tracking-wide">{result.checkout?.accountNo ?? result.checkout?.bankAccount}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="font-medium text-[var(--app-muted)]">
                      {locale === 'en' ? 'Account holder' : 'Chủ tài khoản'}
                    </span>
                    <span className="font-bold">{result.checkout?.accountName}</span>
                  </div>
                  <div className="flex items-center justify-between border-t border-[var(--field-border)] pt-2">
                    <span className="font-medium text-[var(--app-muted)]">
                      {locale === 'en' ? 'Transfer content' : 'Nội dung CK'}
                    </span>
                    <span className="font-bold font-mono text-violet">{result.checkout?.transferContent}</span>
                  </div>
                </div>

                <div className="mt-3 rounded-lg border border-amber-400/40 bg-amber-400/10 p-3 text-center">
                  <p className="text-xs font-semibold text-amber-600">
                    {locale === 'en'
                      ? '⚡ After transferring, your plan will be activated automatically within a few minutes.'
                      : '⚡ Sau khi chuyển khoản, gói cước sẽ được kích hoạt tự động trong vài phút.'}
                  </p>
                </div>

                <div className="mt-3 flex items-center justify-center gap-1.5 text-xs font-medium text-[var(--app-muted)]">
                  <svg className="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
                  </svg>
                  <span>{locale === 'en' ? 'Secured by VietQR & SePay' : 'Bảo mật bởi VietQR & SePay'}</span>
                </div>
              </div>
            ) : (
              <p className="text-sm font-medium text-[var(--app-muted)]">
                {result.checkout?.note ?? copy.paymentPendingNote}
              </p>
            )}
          </div>
        ) : null}

        <div className="mt-5 flex flex-wrap justify-end gap-3">
          <Button onClick={onClose} type="button" variant="secondary">
            {t('common.close')}
          </Button>
          {!hasSepayCheckout && !hasQrCode && (
            <Button
              disabled={creating || currentPlan}
              onClick={async () => {
                if (isDowngradeToFree) {
                  const msg = locale === 'en'
                    ? 'Are you sure you want to downgrade to the Free plan?'
                    : 'Anh có chắc chắn đồng ý hạ xuống gói cước Miễn phí không?';
                  const confirmed = window.confirm(msg);
                  if (!confirmed) {
                    return;
                  }
                }
                await onConfirm();
              }}
              type="button"
            >
              <CreditCard className="h-4 w-4" />
              {creating
                ? copy.creatingIntent
                : currentPlan
                  ? copy.inUse
                  : isDowngradeToFree
                    ? (locale === 'en' ? 'Confirm Downgrade' : 'Xác nhận hạ cấp')
                    : copy.createCheckout}
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}

