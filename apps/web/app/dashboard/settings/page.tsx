'use client';

import { useEffect, useState } from 'react';
import {
  CreditCard,
  Globe2,
  MapPin,
  UserRound,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { MetricCard } from '@/components/dashboard/dashboard-ui';
import { PermissionsPanel } from '@/components/dashboard/permissions-panel';
import { apiFetch, extractList } from '@/lib/api';
import { useUserDashboardData } from '@/lib/live-dashboard';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import type { ThemeMode, BillingPlan, CheckoutResult, CompanionMode, CompanionOptionGroup, CompanionAsset, CompanionState, ThemeCard } from './settings-types';
import { VI_SETTINGS_COPY, EN_SETTINGS_COPY } from './settings-copy';

import { ProfileSection } from './sections/profile-section';
import { PreferencesSection } from './sections/preferences-section';
import { SecuritySection } from './sections/security-section';
import { DangerZoneSection } from './sections/danger-zone-section';
import { CompanionSection } from './sections/companion-section';
import { ThemeGallerySection } from './sections/theme-gallery-section';
import { SessionsSection } from './sections/sessions-section';
import { PushDevicesSection } from './sections/push-devices-section';
import { RemindersSection } from './sections/reminders-section';
import { BillingSection } from './sections/billing-section';
import { HistorySection } from './sections/history-section';

export default function SettingsPage() {
  const { locale, t } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;
  const accountProfile = useDashboardStore((state) => state.accountProfile);
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const setAccountProfile = useDashboardStore((state) => state.setAccountProfile);
  const triggerRefresh = useDashboardStore((state) => state.triggerRefresh);
  const [refreshKey, setRefreshKey] = useState(0);
  const settings = useUserDashboardData({ refreshKey: refreshNonce + refreshKey }).settings;
  const pushToast = useUiStore((state) => state.pushToast);

  const [isLoading, setIsLoading] = useState(true);
  const [billingPlans, setBillingPlans] = useState<BillingPlan[]>([]);
  const [companion, setCompanion] = useState<CompanionState | null>(null);
  const [companionOptions, setCompanionOptions] = useState<CompanionOptionGroup[]>([]);
  const [customAssets, setCustomAssets] = useState<CompanionAsset[]>([]);
  const [themeCatalog, setThemeCatalog] = useState<ThemeCard[]>([]);
  const [activeThemeId, setActiveThemeId] = useState<string | null>(null);
  const accountRole = useDashboardStore((state) => state.accountProfile?.role);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const params = new URLSearchParams(window.location.search);
      const paymentStatus = params.get('payment');
      if (paymentStatus === 'success') {
        pushToast({
          tone: 'success',
          title: 'Thanh toán thành công',
          message: 'Cảm ơn anh! Gói cước của anh đang được hệ thống kích hoạt tự động.',
        });
        window.history.replaceState({}, '', window.location.pathname);
      } else if (paymentStatus === 'error' || paymentStatus === 'cancel') {
        pushToast({
          tone: 'error',
          title: 'Thanh toán không thành công',
          message: 'Giao dịch thanh toán đã bị huỷ hoặc có lỗi xảy ra. Vui lòng thử lại.',
        });
        window.history.replaceState({}, '', window.location.pathname);
      }
    }
  }, [pushToast]);

  useEffect(() => {
    if (typeof window !== 'undefined' && window.location.hash === '#billing') {
      const handleScroll = () => {
        const el = document.getElementById('billing');
        if (el) {
          el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      };
      handleScroll();
      const timers = [100, 300, 600, 1000, 1500, 2000].map((t) => setTimeout(handleScroll, t));
      return () => {
        timers.forEach(clearTimeout);
      };
    }
  }, [isLoading, settings]);

  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);

    void Promise.allSettled([
      apiFetch('/billing/plans'),
      apiFetch('/user-companions/me'),
      apiFetch('/user-companions/me/personalization-options'),
      apiFetch('/companion-assets'),
      apiFetch('/app-themes'),
      apiFetch('/user-preferences/me/preferences'),
    ]).then((results) => {
      if (cancelled) {
        return;
      }

      const [plansResult, companionResult, optionsResult, assetsResult, themesResult, preferencesResult] =
        results;

      if (plansResult.status === 'fulfilled' && Array.isArray(plansResult.value)) {
        setBillingPlans(
          plansResult.value.map((plan) => ({
            name: String((plan as { name?: string }).name ?? 'FREE'),
            title: String(
              (plan as { title?: string }).title ??
                (plan as { name?: string }).name ??
                'FREE',
            ),
            price: Number((plan as { price?: number }).price ?? 0),
            currency: String((plan as { currency?: string }).currency ?? 'VND'),
            features: Array.isArray((plan as { features?: string[] }).features)
              ? (plan as { features?: string[] }).features ?? []
              : [],
          })),
        );
      }

      if (companionResult.status === 'fulfilled' && companionResult.value) {
        const payload = companionResult.value as Record<string, unknown>;
        const asset = (payload.asset ?? null) as Record<string, unknown> | null;
        setCompanion({
          name: String(payload.name ?? 'Mon Leo'),
          personalizationMode: String(
            payload.personalizationMode ?? 'DEFAULT',
          ) as CompanionMode,
          level: Number(payload.level ?? 1),
          affection: Number(payload.affection ?? 0),
          energy: Number(payload.energy ?? 100),
          mood: String(payload.mood ?? 'CHILL'),
          action: String(payload.action ?? 'IDLE'),
          assetId: String(payload.assetId ?? asset?.id ?? ''),
          asset: asset
            ? {
                id: String(asset.id ?? ''),
                name: String(asset.name ?? 'Companion'),
                description: String(asset.description ?? ''),
                previewImageUrl: String(asset.previewImageUrl ?? ''),
                primaryColor: String(asset.primaryColor ?? ''),
                secondaryColor: String(asset.secondaryColor ?? ''),
                accentColor: String(asset.accentColor ?? ''),
                zodiacSign: (asset.zodiacSign as string | null | undefined) ?? null,
                chineseZodiac:
                  (asset.chineseZodiac as string | null | undefined) ?? null,
                isDefault: Boolean(asset.isDefault),
              }
            : null,
        });
      }

      if (optionsResult.status === 'fulfilled' && optionsResult.value) {
        const modes = Array.isArray(
          (optionsResult.value as { modes?: unknown[] }).modes,
        )
          ? ((optionsResult.value as { modes?: unknown[] }).modes as Array<Record<string, unknown>>)
          : [];

        setCompanionOptions(
          modes.map((option) => ({
            mode: String(option.mode ?? 'DEFAULT') as CompanionMode,
            label: String(option.label ?? copy.companionDefaultLabel),
            key: (option.key as string | null | undefined) ?? null,
            available: Boolean(option.available),
            assets: Array.isArray(option.assets)
              ? option.assets.map((asset) => ({
                  id: String((asset as { id?: string }).id ?? ''),
                  name: String((asset as { name?: string }).name ?? 'Companion'),
                  description: String(
                    (asset as { description?: string }).description ?? '',
                  ),
                  previewImageUrl: String(
                    (asset as { previewImageUrl?: string }).previewImageUrl ?? '',
                  ),
                  primaryColor: String(
                    (asset as { primaryColor?: string }).primaryColor ?? '',
                  ),
                  secondaryColor: String(
                    (asset as { secondaryColor?: string }).secondaryColor ?? '',
                  ),
                  accentColor: String(
                    (asset as { accentColor?: string }).accentColor ?? '',
                  ),
                  zodiacSign:
                    ((asset as { zodiacSign?: string | null }).zodiacSign ?? null),
                  chineseZodiac:
                    ((asset as { chineseZodiac?: string | null }).chineseZodiac ??
                      null),
                  isDefault: Boolean((asset as { isDefault?: boolean }).isDefault),
                }))
              : [],
          })),
        );
      }

      if (assetsResult.status === 'fulfilled') {
        setCustomAssets(
          extractList<Record<string, unknown>>(assetsResult.value)
            .filter(
              (asset) =>
                !asset.zodiacSign &&
                !asset.chineseZodiac &&
                !Boolean(asset.isDefault) &&
                Boolean(asset.isActive ?? true),
            )
            .map((asset) => ({
              id: String(asset.id ?? ''),
              name: String(asset.name ?? 'Companion'),
              description: String(asset.description ?? ''),
              previewImageUrl: String(asset.previewImageUrl ?? ''),
              primaryColor: String(asset.primaryColor ?? ''),
              secondaryColor: String(asset.secondaryColor ?? ''),
              accentColor: String(asset.accentColor ?? ''),
            })),
        );
      }

      if (themesResult.status === 'fulfilled') {
        setThemeCatalog(
          extractList<Record<string, unknown>>(themesResult.value)
            .filter((theme) => Boolean(theme.isActive ?? true))
            .map((theme) => ({
              id: String(theme.id ?? ''),
              name: String(theme.name ?? 'Theme'),
              mode: String(theme.mode ?? 'LIGHT') as ThemeMode,
              backgroundColor: String(theme.backgroundColor ?? '#ffffff'),
              surfaceColor: String(theme.surfaceColor ?? '#f8f8ff'),
              primaryColor: String(theme.primaryColor ?? '#6D5DFB'),
              secondaryColor: String(theme.secondaryColor ?? ''),
              textColor: String(theme.textColor ?? '#261D55'),
              mutedTextColor: String(theme.mutedTextColor ?? ''),
              accentColor: String(theme.accentColor ?? ''),
              isDefault: Boolean(theme.isDefault),
              isActive: Boolean(theme.isActive ?? true),
            })),
        );
      }

      if (preferencesResult.status === 'fulfilled' && preferencesResult.value) {
        const preferences = preferencesResult.value as Record<string, unknown>;
        setActiveThemeId(
          preferences.themeId ? String(preferences.themeId) : null,
        );
      }
      setIsLoading(false);
    });

    return () => {
      cancelled = true;
    };
  }, [copy.companionDefaultLabel, refreshKey]);

  return (
    <>
      <DashboardShell eyebrow={t('settings.eyebrow')} title={t('settings.title')}>
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <MetricCard
            icon={UserRound}
            label={t('settings.metric.profile')}
            note={settings.profile.email}
            value={settings.profile.displayName}
          />
          <MetricCard
            icon={Globe2}
            label="Timezone"
            tone="lilac"
            value={settings.preferences.timezone}
          />
          <MetricCard
            icon={MapPin}
            label={t('settings.metric.location')}
            tone="mint"
            value={settings.preferences.locationName}
          />
          <MetricCard
            icon={CreditCard}
            label={t('settings.metric.plan')}
            note={t('settings.metric.planRenewal', { date: settings.billing.renewal })}
            tone="sun"
            value={settings.billing.planName}
          />
        </div>

        <div className="grid gap-4 xl:grid-cols-[minmax(0,0.9fr)_minmax(0,1.1fr)]">
          <ProfileSection
            t={t}
            locale={locale}
            avatar={settings.profile.avatar}
            displayName={settings.profile.displayName}
            birthday={settings.profile.birthday}
            email={settings.profile.email}
            zodiacSign={settings.profile.zodiacSign}
            chineseZodiac={settings.profile.chineseZodiac}
            accountProfile={accountProfile}
            setAccountProfile={setAccountProfile}
            triggerRefresh={triggerRefresh}
            setRefreshKey={setRefreshKey}
            pushToast={pushToast}
          />

          <PreferencesSection
            t={t}
            settings={settings}
            themeCatalog={themeCatalog}
            activeThemeId={activeThemeId}
            triggerRefresh={triggerRefresh}
            setRefreshKey={setRefreshKey}
            pushToast={pushToast}
          />
        </div>

        <SecuritySection
          t={t}
          pushToast={pushToast}
        />

        <DangerZoneSection
          t={t}
          locale={locale}
          authProvider={accountProfile?.authProvider ?? 'LOCAL'}
        />

        <div className="grid gap-4 xl:grid-cols-[minmax(0,1.05fr)_minmax(0,0.95fr)]">
          <CompanionSection
            copy={copy}
            locale={locale}
            companion={companion}
            companionOptions={companionOptions}
            customAssets={customAssets}
            accountRole={accountRole}
            planName={settings.billing.planName}
            triggerRefresh={triggerRefresh}
            setRefreshKey={setRefreshKey}
            pushToast={pushToast}
          />

          <ThemeGallerySection
            copy={copy}
            locale={locale}
            themeCatalog={themeCatalog}
            activeThemeId={activeThemeId}
            setActiveThemeId={setActiveThemeId}
            settings={settings}
            triggerRefresh={triggerRefresh}
            setRefreshKey={setRefreshKey}
            pushToast={pushToast}
          />
        </div>

        <PermissionsPanel />

        <div className="grid gap-4 xl:grid-cols-2">
          <SessionsSection
            t={t}
            locale={locale}
            copy={copy}
            settings={settings}
            triggerRefresh={triggerRefresh}
            pushToast={pushToast}
          />

          <PushDevicesSection
            t={t}
            locale={locale}
            copy={copy}
            settings={settings}
            triggerRefresh={triggerRefresh}
            setRefreshKey={setRefreshKey}
            pushToast={pushToast}
          />
        </div>

        <div className="grid gap-4 xl:grid-cols-[minmax(0,1.1fr)_minmax(0,0.9fr)_minmax(0,1.1fr)] mt-4">
          <RemindersSection
            t={t}
            locale={locale}
            copy={copy}
            settings={settings}
            triggerRefresh={triggerRefresh}
            setRefreshKey={setRefreshKey}
            pushToast={pushToast}
          />

          <BillingSection
            locale={locale}
            copy={copy}
            settings={settings}
            billingPlans={billingPlans}
            triggerRefresh={triggerRefresh}
            setRefreshKey={setRefreshKey}
            pushToast={pushToast}
          />

          <HistorySection
            locale={locale}
            copy={copy}
            settings={settings}
          />
        </div>
      </DashboardShell>
    </>
  );
}
