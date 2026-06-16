'use client';

/**
 * Admin pricing page — manage SubscriptionTier rows (price, sale, activation).
 *
 * Doesn't reuse AdminCatalogPage because the schema is structurally
 * different (sale window, billing cycle, currency) and warrants its own
 * focused editor.
 */

import { useCallback, useEffect, useMemo, useState } from 'react';
import { Pencil, Plus, Tag, TrashIcon } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { useUiStore } from '@/stores/use-ui-store';
import type { BillingCycle, Tier, EditDraft } from './pricing-types';
import { EMPTY_DRAFT, toDraft } from './pricing-utils';

export default function AdminPricingPage() {
  const { t, locale } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const [tiers, setTiers] = useState<Tier[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<EditDraft | null>(null);
  const [saving, setSaving] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const list = await apiFetch<Tier[]>('/admin/billing/tiers');
      setTiers(list);
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      pushToast({
        tone: 'error',
        title: t('adminPricing.toast.loadFailed'),
        message,
      });
    } finally {
      setLoading(false);
    }
  }, [pushToast, t]);

  useEffect(() => {
    const timer = setTimeout(() => {
      void load();
    }, 0);
    return () => clearTimeout(timer);
  }, [load]);

  const formatter = useMemo(
    () =>
      new Intl.NumberFormat(locale === 'vi' ? 'vi-VN' : 'en-US', {
        maximumFractionDigits: 0,
      }),
    [locale],
  );

  const isSaleActive = useCallback((tier: Tier) => {
    if (tier.salePrice == null) return false;
    if (!tier.saleStartsAt || !tier.saleEndsAt) return false;
    const now = Date.now();
    return (
      now >= new Date(tier.saleStartsAt).getTime() &&
      now <= new Date(tier.saleEndsAt).getTime()
    );
  }, []);

  const submit = useCallback(async () => {
    if (!draft) return;
    setSaving(true);
    try {
      const payload: Record<string, unknown> = {
        name: draft.name.trim(),
        title: draft.title.trim() || undefined,
        description: draft.description.trim() || undefined,
        price: Number(draft.price),
        currency: draft.currency.trim().toUpperCase(),
        billingCycle: draft.billingCycle,
        displayOrder: Number(draft.displayOrder),
        isActive: draft.isActive,
      };
      const hasSale = draft.salePrice.trim().length > 0;
      payload.salePrice = hasSale ? Number(draft.salePrice) : null;
      payload.saleLabel = draft.saleLabel.trim() || null;
      payload.saleStartsAt = draft.saleStartsAt
        ? new Date(draft.saleStartsAt).toISOString()
        : null;
      payload.saleEndsAt = draft.saleEndsAt
        ? new Date(draft.saleEndsAt).toISOString()
        : null;

      if (draft.id) {
        await apiFetch(`/admin/billing/tiers/${draft.id}`, {
          method: 'PATCH',
          body: JSON.stringify(payload),
        });
        pushToast({
          tone: 'success',
          title: t('adminPricing.toast.updatedTitle'),
          message: payload.name as string,
        });
      } else {
        await apiFetch('/admin/billing/tiers', {
          method: 'POST',
          body: JSON.stringify(payload),
        });
        pushToast({
          tone: 'success',
          title: t('adminPricing.toast.createdTitle'),
          message: payload.name as string,
        });
      }
      setDraft(null);
      await load();
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      pushToast({
        tone: 'error',
        title: t('adminPricing.toast.saveFailed'),
        message,
      });
    } finally {
      setSaving(false);
    }
  }, [draft, load, pushToast, t]);

  const clearSale = useCallback(
    async (tier: Tier) => {
      try {
        await apiFetch(`/admin/billing/tiers/${tier.id}/clear-sale`, {
          method: 'PATCH',
        });
        pushToast({
          tone: 'success',
          title: t('adminPricing.toast.saleClearedTitle'),
          message: tier.name,
        });
        await load();
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        pushToast({
          tone: 'error',
          title: t('adminPricing.toast.saveFailed'),
          message,
        });
      }
    },
    [load, pushToast, t],
  );

  const deactivate = useCallback(
    async (tier: Tier) => {
      if (!confirm(t('adminPricing.confirm.deactivate'))) return;
      try {
        await apiFetch(`/admin/billing/tiers/${tier.id}`, { method: 'DELETE' });
        pushToast({
          tone: 'success',
          title: t('adminPricing.toast.deactivatedTitle'),
          message: tier.name,
        });
        await load();
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        pushToast({
          tone: 'error',
          title: t('adminPricing.toast.saveFailed'),
          message,
        });
      }
    },
    [load, pushToast, t],
  );

  return (
    <DashboardShell
      admin
      eyebrow={t('adminPricing.eyebrow')}
      title={t('adminPricing.title')}
    >
      <Card>
        <SectionTitle
          title={t('adminPricing.section.title')}
          copy={t('adminPricing.section.copy')}
          action={
            <Button onClick={() => setDraft({ ...EMPTY_DRAFT })} variant="primary">
              <Plus className="h-4 w-4" />
              {t('adminPricing.action.create')}
            </Button>
          }
        />

        {loading ? (
          <p className="mt-5 text-sm text-slate">{t('common.loading')}</p>
        ) : (
          <div className="mt-5 grid gap-3">
            {tiers.map((tier) => {
              const onSale = isSaleActive(tier);
              const effective = onSale && tier.salePrice != null ? tier.salePrice : tier.price;
              return (
                <div
                  className={`rounded-lg border p-4 ${
                    tier.isActive
                      ? 'border-[var(--panel-border)] bg-[var(--panel-bg)]'
                      : 'border-slate/30 bg-slate/5 opacity-70'
                  }`}
                  key={tier.id}
                >
                  <div className="flex flex-wrap items-start justify-between gap-3">
                    <div className="min-w-0">
                      <div className="flex flex-wrap items-center gap-2">
                        <h4 className="text-base font-extrabold text-[var(--app-text)]">
                          {tier.title || tier.name}
                        </h4>
                        <code className="rounded bg-[var(--field-bg)] px-2 py-0.5 text-xs">
                          {tier.name}
                        </code>
                        <Badge className="bg-violet/15 text-violet">
                          {tier.billingCycle}
                        </Badge>
                        {!tier.isActive ? (
                          <Badge className="bg-slate/20 text-slate">
                            {t('adminPricing.badge.inactive')}
                          </Badge>
                        ) : null}
                        {onSale ? (
                          <Badge className="bg-coral/15 text-coral">
                            <Tag className="mr-1 h-3 w-3" />
                            {tier.saleLabel ?? t('adminPricing.badge.onSale')}
                          </Badge>
                        ) : null}
                      </div>
                      {tier.description ? (
                        <p className="mt-2 max-w-2xl text-sm text-slate">
                          {tier.description}
                        </p>
                      ) : null}
                      <div className="mt-3 flex flex-wrap items-baseline gap-3">
                        {onSale ? (
                          <>
                            <span className="text-2xl font-extrabold text-coral">
                              {formatter.format(effective)} {tier.currency}
                            </span>
                            <span className="text-sm font-semibold text-slate line-through">
                              {formatter.format(tier.price)} {tier.currency}
                            </span>
                          </>
                        ) : (
                          <span className="text-2xl font-extrabold text-[var(--app-text)]">
                            {formatter.format(tier.price)} {tier.currency}
                          </span>
                        )}
                        <span className="text-xs text-slate">
                          {t('adminPricing.field.order')} #{tier.displayOrder}
                        </span>
                      </div>
                      {onSale ? (
                        <p className="mt-1 text-xs text-slate">
                          {t('adminPricing.field.saleWindow', {
                            start: new Date(tier.saleStartsAt as string).toLocaleString(locale === 'vi' ? 'vi-VN' : 'en-US'),
                            end: new Date(tier.saleEndsAt as string).toLocaleString(locale === 'vi' ? 'vi-VN' : 'en-US'),
                          })}
                        </p>
                      ) : null}
                    </div>
                    <div className="flex flex-wrap gap-2">
                      <Button
                        onClick={() => setDraft(toDraft(tier))}
                        variant="secondary"
                      >
                        <Pencil className="h-4 w-4" />
                        {t('adminPricing.action.edit')}
                      </Button>
                      {onSale ? (
                        <Button
                          onClick={() => clearSale(tier)}
                          variant="ghost"
                        >
                          {t('adminPricing.action.clearSale')}
                        </Button>
                      ) : null}
                      {tier.isActive ? (
                        <Button
                          onClick={() => deactivate(tier)}
                          variant="ghost"
                        >
                          <TrashIcon className="h-4 w-4" />
                          {t('adminPricing.action.deactivate')}
                        </Button>
                      ) : null}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </Card>

      {draft ? (
        <TierEditor
          draft={draft}
          onCancel={() => setDraft(null)}
          onChange={setDraft}
          onSubmit={submit}
          saving={saving}
        />
      ) : null}
    </DashboardShell>
  );
}

function TierEditor({
  draft,
  onCancel,
  onChange,
  onSubmit,
  saving,
}: {
  draft: EditDraft;
  onCancel: () => void;
  onChange: (d: EditDraft) => void;
  onSubmit: () => void;
  saving: boolean;
}) {
  const { t } = useTranslation();
  const isEditing = Boolean(draft.id);

  const set = (patch: Partial<EditDraft>) => onChange({ ...draft, ...patch });

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-ink/60 p-4 backdrop-blur"
      onClick={onCancel}
    >
      <Card
        className="max-h-[90vh] w-full max-w-2xl overflow-y-auto"
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      >
        <div onClick={(e) => e.stopPropagation()}>
        <SectionTitle
          title={isEditing ? t('adminPricing.editor.editTitle') : t('adminPricing.editor.createTitle')}
          copy={t('adminPricing.editor.copy')}
        />

        <div className="mt-5 grid gap-4 md:grid-cols-2">
          <label className="text-sm font-semibold">
            {t('adminPricing.field.name')}
            <input
              className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 font-mono text-sm uppercase"
              disabled={isEditing}
              onChange={(e) => set({ name: e.target.value.toUpperCase() })}
              placeholder="CHILL_PLUS_QUARTERLY"
              value={draft.name}
            />
          </label>

          <label className="text-sm font-semibold">
            {t('adminPricing.field.title')}
            <input
              className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-sm"
              onChange={(e) => set({ title: e.target.value })}
              placeholder="Chill Plus 3 tháng"
              value={draft.title}
            />
          </label>

          <label className="text-sm font-semibold md:col-span-2">
            {t('adminPricing.field.description')}
            <textarea
              className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-sm"
              onChange={(e) => set({ description: e.target.value })}
              rows={2}
              value={draft.description}
            />
          </label>

          <label className="text-sm font-semibold">
            {t('adminPricing.field.price')}
            <input
              className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-sm"
              inputMode="numeric"
              onChange={(e) => set({ price: e.target.value })}
              value={draft.price}
            />
          </label>

          <label className="text-sm font-semibold">
            {t('adminPricing.field.currency')}
            <input
              className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-sm uppercase"
              maxLength={3}
              onChange={(e) => set({ currency: e.target.value.toUpperCase() })}
              value={draft.currency}
            />
          </label>

          <label className="text-sm font-semibold">
            {t('adminPricing.field.billingCycle')}
            <select
              className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-sm"
              onChange={(e) => set({ billingCycle: e.target.value as BillingCycle })}
              value={draft.billingCycle}
            >
              <option value="MONTHLY">MONTHLY</option>
              <option value="QUARTERLY">QUARTERLY</option>
              <option value="YEARLY">YEARLY</option>
              <option value="LIFETIME">LIFETIME</option>
            </select>
          </label>

          <label className="text-sm font-semibold">
            {t('adminPricing.field.order')}
            <input
              className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-sm"
              inputMode="numeric"
              onChange={(e) => set({ displayOrder: e.target.value })}
              value={draft.displayOrder}
            />
          </label>

          <fieldset className="rounded-lg border border-coral/30 bg-coral/5 p-3 md:col-span-2">
            <legend className="px-1 text-xs font-bold uppercase tracking-wider text-coral">
              {t('adminPricing.section.sale')}
            </legend>
            <div className="grid gap-3 md:grid-cols-2">
              <label className="text-sm font-semibold">
                {t('adminPricing.field.salePrice')}
                <input
                  className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-sm"
                  inputMode="numeric"
                  onChange={(e) => set({ salePrice: e.target.value })}
                  placeholder={t('adminPricing.placeholder.salePrice')}
                  value={draft.salePrice}
                />
              </label>
              <label className="text-sm font-semibold">
                {t('adminPricing.field.saleLabel')}
                <input
                  className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-sm"
                  onChange={(e) => set({ saleLabel: e.target.value })}
                  placeholder="BLACK FRIDAY -20%"
                  value={draft.saleLabel}
                />
              </label>
              <label className="text-sm font-semibold">
                {t('adminPricing.field.saleStartsAt')}
                <input
                  className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-sm"
                  onChange={(e) => set({ saleStartsAt: e.target.value })}
                  type="datetime-local"
                  value={draft.saleStartsAt}
                />
              </label>
              <label className="text-sm font-semibold">
                {t('adminPricing.field.saleEndsAt')}
                <input
                  className="mt-1 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-sm"
                  onChange={(e) => set({ saleEndsAt: e.target.value })}
                  type="datetime-local"
                  value={draft.saleEndsAt}
                />
              </label>
            </div>
            <p className="mt-2 text-xs text-slate">
              {t('adminPricing.hint.sale')}
            </p>
          </fieldset>

          <label className="flex items-center gap-2 text-sm font-semibold md:col-span-2">
            <input
              checked={draft.isActive}
              onChange={(e) => set({ isActive: e.target.checked })}
              type="checkbox"
            />
            {t('adminPricing.field.active')}
          </label>
        </div>

        <div className="mt-5 flex flex-wrap justify-end gap-2">
          <Button disabled={saving} onClick={onCancel} variant="ghost">
            {t('common.cancel')}
          </Button>
          <Button disabled={saving || !draft.name || !draft.price} onClick={onSubmit}>
            {saving ? t('common.loading') : t('common.save')}
          </Button>
        </div>
        </div>
      </Card>
    </div>
  );
}
