'use client';

import { useEffect, useState } from 'react';
import {
  Bell,
  CreditCard,
  Globe2,
  Laptop,
  type LucideIcon,
  MapPin,
  Moon,
  Navigation,
  Repeat,
  Save,
  Smartphone,
  UserRound,
  WandSparkles,
  X,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  DataTable,
  MetricCard,
  SectionTitle,
} from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import {
  DASHBOARD_THEME_APPLIED_EVENT,
  applyDashboardTheme,
  type DashboardThemeMode,
  type DashboardThemePalette,
} from '@/components/providers/theme-provider';
import { apiFetch, extractList } from '@/lib/api';
import { getReadableTextColor } from '@/lib/contrast';
import { useUserDashboardData } from '@/lib/live-dashboard';
import { describeBrowser, describeDevice } from '@/lib/user-agent';
import {
  chineseZodiacLabel,
  computeZodiac,
  zodiacLabel,
} from '@/lib/zodiac';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';

type ThemeMode = 'SYSTEM' | 'LIGHT' | 'DARK';

type ReminderDraft = {
  title: string;
  message: string;
  type: 'WATER' | 'REST' | 'BREATHING' | 'JOURNAL' | 'SLEEP' | 'CUSTOM';
  scheduledAt: string;
};

type BillingPlan = {
  name: string;
  title: string;
  price: number;
  currency: string;
  features: string[];
};

type CheckoutResult = {
  configured?: boolean;
  provider?: string;
  plan?: {
    name?: string;
    title?: string;
    price?: number;
    currency?: string;
  };
  payment?: {
    id?: string;
    status?: string;
    amount?: number;
    currency?: string;
  };
  checkout?: {
    status?: string;
    note?: string;
  };
};

type ConfirmResult = {
  payment?: {
    id?: string;
    status?: string;
  };
  subscription?: {
    status?: string;
    planName?: string;
  };
};

type CompanionMode = 'DEFAULT' | 'ZODIAC' | 'CHINESE_ZODIAC' | 'CUSTOM';

type CompanionAsset = {
  id: string;
  name: string;
  description?: string;
  previewImageUrl?: string;
  primaryColor?: string;
  secondaryColor?: string;
  accentColor?: string;
  zodiacSign?: string | null;
  chineseZodiac?: string | null;
  isDefault?: boolean;
};

type CompanionOptionGroup = {
  mode: CompanionMode;
  label: string;
  key?: string | null;
  available: boolean;
  assets: CompanionAsset[];
};

type CompanionState = {
  name: string;
  personalizationMode: CompanionMode;
  level: number;
  affection: number;
  energy: number;
  mood: string;
  action: string;
  assetId?: string | null;
  asset?: CompanionAsset | null;
};

type ThemeCard = {
  id: string;
  name: string;
  mode: ThemeMode;
  backgroundColor: string;
  surfaceColor: string;
  primaryColor: string;
  secondaryColor?: string | null;
  textColor: string;
  mutedTextColor?: string | null;
  accentColor?: string | null;
  isDefault: boolean;
  isActive: boolean;
};

export default function SettingsPage() {
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const triggerRefresh = useDashboardStore((state) => state.triggerRefresh);
  const [refreshKey, setRefreshKey] = useState(0);
  const settings = useUserDashboardData({ refreshKey: refreshNonce + refreshKey }).settings;
  const pushToast = useUiStore((state) => state.pushToast);
  const [draftPreferences, setDraftPreferences] = useState<{
    weatherEnabled: boolean;
    pushEnabled: boolean;
    soundEnabled: boolean;
    timezone: string;
    locationName: string;
    themeMode: ThemeMode;
  } | null>(null);
  const [profileDraft, setProfileDraft] = useState<{
    displayName: string;
    birthday: string;
  } | null>(null);
  const [reminderDraft, setReminderDraft] = useState<ReminderDraft>({
    title: 'Nhắc thở nhẹ',
    message: 'Đến lúc nghỉ một chút rồi hít thở nào.',
    type: 'BREATHING',
    scheduledAt: nextLocalReminderTime(),
  });
  const [saveState, setSaveState] = useState<'idle' | 'saving'>('idle');
  const [profileState, setProfileState] = useState<'idle' | 'saving'>('idle');
  const [reminderState, setReminderState] = useState<'idle' | 'saving'>('idle');
  const [deviceState, setDeviceState] = useState<'idle' | 'saving'>('idle');
  const [billingState, setBillingState] = useState<string | null>(null);
  const [billingPlans, setBillingPlans] = useState<BillingPlan[]>([]);
  const [checkoutPlan, setCheckoutPlan] = useState<BillingPlan | null>(null);
  const [checkoutResult, setCheckoutResult] = useState<CheckoutResult | null>(null);
  const [companion, setCompanion] = useState<CompanionState | null>(null);
  const [companionOptions, setCompanionOptions] = useState<CompanionOptionGroup[]>([]);
  const [customAssets, setCustomAssets] = useState<CompanionAsset[]>([]);
  const [companionNameDraft, setCompanionNameDraft] = useState('');
  const [companionState, setCompanionState] = useState<'idle' | 'saving'>('idle');
  const [themeCatalog, setThemeCatalog] = useState<ThemeCard[]>([]);
  const [themeState, setThemeState] = useState<string | null>(null);
  const [activeThemeId, setActiveThemeId] = useState<string | null>(null);
  const weatherEnabled =
    draftPreferences?.weatherEnabled ?? settings.preferences.weatherEnabled;
  const pushEnabled = draftPreferences?.pushEnabled ?? settings.preferences.pushEnabled;
  const soundEnabled =
    draftPreferences?.soundEnabled ?? settings.preferences.soundEnabled;
  const timezone = draftPreferences?.timezone ?? settings.preferences.timezone;
  const locationName = draftPreferences?.locationName ?? settings.preferences.locationName;
  const themeMode =
    draftPreferences?.themeMode ??
    (settings.preferences.theme.toUpperCase() as ThemeMode);
  const displayName = profileDraft?.displayName ?? settings.profile.displayName;
  const birthday =
    profileDraft?.birthday ?? normalizeBirthdayValue(settings.profile.birthday);

  useEffect(() => {
    let cancelled = false;

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
        setCompanionNameDraft(String(payload.name ?? 'Mon Leo'));
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
            label: String(option.label ?? 'Linh thú'),
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
    });

    return () => {
      cancelled = true;
    };
  }, [refreshKey]);

  return (
    <>
      <DashboardShell eyebrow="Personal controls" title="Setup">
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={UserRound}
          label="Hồ sơ"
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
          label="Vị trí thời tiết"
          tone="mint"
          value={settings.preferences.locationName}
        />
        <MetricCard
          icon={CreditCard}
          label="Gói cước"
          note={`Gia hạn: ${settings.billing.renewal}`}
          tone="sun"
          value={settings.billing.planName}
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,0.9fr)_minmax(0,1.1fr)]">
        <Card>
          <SectionTitle
            title="Trang cá nhân"
            copy="Cập nhật tên hiển thị và ngày sinh. Hai mục cung hoàng đạo bên dưới sẽ tự tính lại theo birthday."
          />
          <div className="mt-5 grid gap-4">
            <Field
              label="Display name"
              value={displayName}
              onChange={(value) =>
                setProfileDraft((current) => ({
                  displayName: value,
                  birthday:
                    current?.birthday ??
                    normalizeBirthdayValue(settings.profile.birthday),
                }))
              }
            />
            <Field
              label="Birthday"
              type="date"
              value={birthday}
              onChange={(value) =>
                setProfileDraft((current) => ({
                  displayName:
                    current?.displayName ?? settings.profile.displayName,
                  birthday: value,
                }))
              }
            />
            {(() => {
              // Compute zodiac client-side from the in-progress birthday
              // draft so the cards update the moment the user picks a new
              // date, without waiting for a PATCH round-trip. Falls back
              // to the server-rendered values when the draft is empty.
              const previewed = computeZodiac(birthday);
              const liveZodiac =
                zodiacLabel(previewed.zodiacSign) !== '—'
                  ? zodiacLabel(previewed.zodiacSign)
                  : settings.profile.zodiacSign;
              const liveChinese =
                chineseZodiacLabel(previewed.chineseZodiac) !== '—'
                  ? chineseZodiacLabel(previewed.chineseZodiac)
                  : settings.profile.chineseZodiac;
              return (
                <div className="grid gap-3 sm:grid-cols-2">
                  <DerivedCard
                    icon={WandSparkles}
                    label="Zodiac"
                    note="Tự đổi ngay khi chọn ngày sinh"
                    value={liveZodiac}
                  />
                  <DerivedCard
                    icon={WandSparkles}
                    label="Chinese zodiac"
                    note="Theo năm sinh — cập nhật tức thì"
                    value={liveChinese}
                  />
                </div>
              );
            })()}
          </div>
          <Button
            className="mt-5"
            disabled={profileState === 'saving'}
            onClick={async () => {
              setProfileState('saving');
              try {
                await apiFetch('/user-profiles/me/profile', {
                  method: 'PATCH',
                  body: JSON.stringify({
                    displayName,
                    // Always send UTC midnight for the picked date so we
                    // don't shift back a day in negative timezones.
                    // (`new Date('YYYY-MM-DDT00:00:00')` is interpreted
                    // as LOCAL time → +07 lost a day in UTC.)
                    birthday: birthday
                      ? new Date(`${birthday}T00:00:00.000Z`).toISOString()
                      : null,
                  }),
                });
                setRefreshKey((current) => current + 1);
                triggerRefresh();
                setProfileDraft(null);
                pushToast({
                  tone: 'success',
                  title: 'Đã cập nhật hồ sơ',
                  message: 'Tên hiển thị và ngày sinh đã được lưu.',
                });
              } catch {
                pushToast({
                  tone: 'error',
                  title: 'Lưu hồ sơ thất bại',
                  message: 'Kiểm tra đăng nhập hoặc backend rồi thử lại.',
                });
              } finally {
                setProfileState('idle');
              }
            }}
          >
            <Save className="h-4 w-4" />
            {profileState === 'saving' ? 'Đang lưu' : 'Lưu cấu hình'}
          </Button>
        </Card>

        <Card>
          <SectionTitle
            title="Thông báo & thời tiết"
            copy="Chọn theme, timezone, vị trí dự báo và các kiểu nhắc mà anh muốn app bật lên hằng ngày."
          />
          <div className="mt-5 grid gap-4">
            <div className="grid gap-4 sm:grid-cols-3">
              <Field
                label="Theme mode"
                select
                value={themeMode}
                options={['SYSTEM', 'LIGHT', 'DARK']}
                onChange={(value) => {
                  const nextMode = value as ThemeMode;
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      current?.weatherEnabled ??
                      settings.preferences.weatherEnabled,
                    pushEnabled:
                      current?.pushEnabled ?? settings.preferences.pushEnabled,
                    soundEnabled:
                      current?.soundEnabled ??
                      settings.preferences.soundEnabled,
                    timezone:
                      current?.timezone ?? settings.preferences.timezone,
                    locationName:
                      current?.locationName ??
                      settings.preferences.locationName,
                    themeMode: nextMode,
                  }));
                  // Hot-apply immediately so the user sees the new mode
                  // without having to press "Lưu preferences" first.
                  const activePalette =
                    themeCatalog.find((t) => t.id === activeThemeId) ?? null;
                  dispatchDashboardTheme(nextMode, activePalette);
                  // Best-effort persist in the background.
                  void apiFetch('/user-preferences/me/preferences', {
                    method: 'PATCH',
                    body: JSON.stringify({ themeMode: nextMode }),
                  }).catch(() => {
                    /* surfaced via the Save button if it fails */
                  });
                }}
              />
              <Field
                label="Timezone"
                value={timezone}
                onChange={(value) =>
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      current?.weatherEnabled ??
                      settings.preferences.weatherEnabled,
                    pushEnabled:
                      current?.pushEnabled ?? settings.preferences.pushEnabled,
                    soundEnabled:
                      current?.soundEnabled ??
                      settings.preferences.soundEnabled,
                    timezone: value,
                    locationName:
                      current?.locationName ??
                      settings.preferences.locationName,
                    themeMode:
                      current?.themeMode ??
                      (settings.preferences.theme.toUpperCase() as ThemeMode),
                  }))
                }
              />
              <Field
                label="Weather location"
                value={locationName}
                onChange={(value) =>
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      current?.weatherEnabled ??
                      settings.preferences.weatherEnabled,
                    pushEnabled:
                      current?.pushEnabled ?? settings.preferences.pushEnabled,
                    soundEnabled:
                      current?.soundEnabled ??
                      settings.preferences.soundEnabled,
                    timezone:
                      current?.timezone ?? settings.preferences.timezone,
                    locationName: value,
                    themeMode:
                      current?.themeMode ??
                      (settings.preferences.theme.toUpperCase() as ThemeMode),
                  }))
                }
              />
            </div>

            <div className="grid gap-3 sm:grid-cols-3">
              <ToggleCard
                checked={weatherEnabled}
                icon={MapPin}
                label="Weather"
                onClick={() =>
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      !(current?.weatherEnabled ??
                        settings.preferences.weatherEnabled),
                    pushEnabled:
                      current?.pushEnabled ?? settings.preferences.pushEnabled,
                    soundEnabled:
                      current?.soundEnabled ??
                      settings.preferences.soundEnabled,
                    timezone:
                      current?.timezone ?? settings.preferences.timezone,
                    locationName:
                      current?.locationName ??
                      settings.preferences.locationName,
                    themeMode:
                      current?.themeMode ??
                      (settings.preferences.theme.toUpperCase() as ThemeMode),
                  }))
                }
              />
              <ToggleCard
                checked={pushEnabled}
                icon={Bell}
                label="Push"
                onClick={() =>
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      current?.weatherEnabled ??
                      settings.preferences.weatherEnabled,
                    pushEnabled:
                      !(current?.pushEnabled ??
                        settings.preferences.pushEnabled),
                    soundEnabled:
                      current?.soundEnabled ??
                      settings.preferences.soundEnabled,
                    timezone:
                      current?.timezone ?? settings.preferences.timezone,
                    locationName:
                      current?.locationName ??
                      settings.preferences.locationName,
                    themeMode:
                      current?.themeMode ??
                      (settings.preferences.theme.toUpperCase() as ThemeMode),
                  }))
                }
              />
              <ToggleCard
                checked={soundEnabled}
                icon={Moon}
                label="Sound"
                onClick={() =>
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      current?.weatherEnabled ??
                      settings.preferences.weatherEnabled,
                    pushEnabled:
                      current?.pushEnabled ?? settings.preferences.pushEnabled,
                    soundEnabled:
                      !(current?.soundEnabled ??
                        settings.preferences.soundEnabled),
                    timezone:
                      current?.timezone ?? settings.preferences.timezone,
                    locationName:
                      current?.locationName ??
                      settings.preferences.locationName,
                    themeMode:
                      current?.themeMode ??
                      (settings.preferences.theme.toUpperCase() as ThemeMode),
                  }))
                }
              />
            </div>

            <div className="grid gap-3 sm:grid-cols-3">
              <StatusMiniCard
                note="Tự đổi theo hệ thống nếu chọn SYSTEM"
                title="Theme hiện tại"
                value={themeMode}
              />
              <StatusMiniCard
                note={weatherEnabled ? 'Dự báo đang bật' : 'Dự báo đang tắt'}
                title="Vị trí dự báo"
                value={locationName}
              />
              <StatusMiniCard
                note="Có thể thêm/xoá ở phần reminder phía dưới"
                title="Nhịp nhắc trong ngày"
                value={
                  settings.preferences.reminderTimes.length > 0
                    ? settings.preferences.reminderTimes.join(' • ')
                    : 'Chưa có'
                }
              />
            </div>
          </div>

          <div className="mt-5">
            <p className="mb-2 text-xs font-semibold uppercase tracking-[0.14em] text-[var(--app-muted,theme(colors.slate))]">
              Quick add nhắc trong ngày
            </p>
            <div className="flex flex-wrap items-center gap-2">
              {settings.preferences.reminderTimes.map((time) => (
                <span
                  className="inline-flex items-center gap-2 rounded-full border border-[var(--field-border)] bg-[var(--panel-bg)] px-3 py-1.5 text-sm font-bold"
                  key={time}
                >
                  <Repeat className="h-3.5 w-3.5 text-violet" />
                  {time}
                </span>
              ))}
              {settings.preferences.reminderTimes.length === 0 ? (
                <span className="text-xs font-semibold text-[var(--app-muted,theme(colors.slate))]">
                  Chưa có nhắc nào — pick thời điểm phía dưới để thêm nhanh.
                </span>
              ) : null}
            </div>
            <QuickAddReminder
              defaultTitle="Nhắc thở nhẹ"
              onCreated={() => {
                setRefreshKey((current) => current + 1);
                triggerRefresh();
              }}
            />
          </div>

          <div className="mt-5 flex flex-wrap gap-3">
            <Button
              disabled={saveState === 'saving'}
              onClick={async () => {
                setSaveState('saving');
                try {
                  await apiFetch('/user-preferences/me/preferences', {
                    method: 'PATCH',
                    body: JSON.stringify({
                      timezone,
                      locationName,
                      weatherEnabled,
                      enableSound: soundEnabled,
                      pushNotificationsEnabled: pushEnabled,
                      themeMode,
                    }),
                  });
                  setRefreshKey((current) => current + 1);
                  triggerRefresh();
                  setDraftPreferences(null);
                  pushToast({
                    tone: 'success',
                    title: 'Đã lưu preferences',
                    message:
                      'Theme, timezone và các toggle thông báo đã được cập nhật.',
                  });
                } catch {
                  pushToast({
                    tone: 'error',
                    title: 'Lưu preferences thất bại',
                    message: 'Backend chưa phản hồi hoặc token đã hết hạn.',
                  });
                } finally {
                  setSaveState('idle');
                }
              }}
            >
              <Save className="h-4 w-4" />
              {saveState === 'saving' ? 'Đang lưu' : 'Lưu preferences'}
            </Button>
            <Button
              onClick={() => {
                if (typeof navigator === 'undefined' || !navigator.geolocation) {
                  pushToast({
                    tone: 'error',
                    title: 'Trình duyệt không hỗ trợ định vị',
                  });
                  return;
                }
                navigator.geolocation.getCurrentPosition(
                  async (pos) => {
                    try {
                      await apiFetch('/weather/me/location', {
                        method: 'PATCH',
                        body: JSON.stringify({
                          latitude: pos.coords.latitude,
                          longitude: pos.coords.longitude,
                          weatherEnabled: true,
                        }),
                      });
                      setRefreshKey((current) => current + 1);
                      triggerRefresh();
                      pushToast({
                        tone: 'success',
                        title: 'Đã cập nhật vị trí',
                        message:
                          'Backend sẽ lấy thời tiết theo vị trí hiện tại của anh.',
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: 'Không lưu được vị trí',
                      });
                    }
                  },
                  (err) =>
                    pushToast({
                      tone: 'error',
                      title: 'Không lấy được vị trí',
                      message: err.message,
                    }),
                  { enableHighAccuracy: true, timeout: 10_000 },
                );
              }}
              variant="secondary"
            >
              <Navigation className="h-4 w-4" />
              Dùng vị trí hiện tại
            </Button>
            <Button
              onClick={async () => {
                try {
                  await apiFetch('/notifications/me/test', {
                    method: 'POST',
                    body: JSON.stringify({
                      title: 'Test popup từ dashboard',
                      message: 'Thông báo thử đã được tạo từ settings.',
                      type: 'IN_APP',
                    }),
                  });
                  setRefreshKey((current) => current + 1);
                  triggerRefresh();
                  pushToast({
                    tone: 'info',
                    title: 'Đã tạo test notification',
                    message:
                      'Notification mới đã được gửi vào tài khoản hiện tại.',
                  });
                } catch {
                  pushToast({
                    tone: 'error',
                    title: 'Không tạo được notification',
                    message: 'Kiểm tra backend hoặc token đăng nhập.',
                  });
                }
              }}
              variant="secondary"
            >
              <Bell className="h-4 w-4" />
              Gửi test notification
            </Button>
          </div>
        </Card>
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.05fr)_minmax(0,0.95fr)]">
        <Card>
          <SectionTitle
            title="Companion studio"
            copy="Đây là chỗ để anh nuôi, đặt tên và đổi linh thú theo ngày sinh, cung hoàng đạo, con giáp hoặc tự chọn."
            action={<WandSparkles className="h-5 w-5 text-violet" />}
          />
          {companion ? (
            <div className="mt-5 space-y-5">
              <div className="grid gap-4 sm:grid-cols-[180px_minmax(0,1fr)]">
                <div
                  className="overflow-hidden rounded-2xl border border-lilac/70 bg-white/75"
                  style={{
                    background:
                      companion.asset?.secondaryColor || 'rgba(255,255,255,0.72)',
                  }}
                >
                  {companion.asset?.previewImageUrl ? (
                    <SafeCompanionImage
                      alt={companion.asset.name}
                      className="h-44 w-full object-cover"
                      src={companion.asset.previewImageUrl}
                    />
                  ) : (
                    <div className="flex h-44 items-center justify-center text-sm font-semibold text-slate">
                      Chưa có preview
                    </div>
                  )}
                </div>
                <div className="space-y-3">
                  <Field
                    label="Tên linh thú"
                    value={companionNameDraft}
                    onChange={setCompanionNameDraft}
                  />
                  <div className="grid gap-3 sm:grid-cols-3">
                    <StatusMiniCard
                      note="cấp độ hiện tại"
                      title="Level"
                      value={String(companion.level)}
                    />
                    <StatusMiniCard
                      note="độ thân thiết"
                      title="Affection"
                      value={`${companion.affection}%`}
                    />
                    <StatusMiniCard
                      note="năng lượng"
                      title="Energy"
                      value={`${companion.energy}%`}
                    />
                  </div>
                  <div className="flex flex-wrap gap-2">
                    <Button
                      disabled={companionState === 'saving'}
                      onClick={async () => {
                        setCompanionState('saving');
                        try {
                          await apiFetch('/user-companions/me', {
                            method: 'PATCH',
                            body: JSON.stringify({ name: companionNameDraft }),
                          });
                          setRefreshKey((current) => current + 1);
                          triggerRefresh();
                          pushToast({
                            tone: 'success',
                            title: 'Đã đổi tên linh thú',
                          });
                        } catch {
                          pushToast({
                            tone: 'error',
                            title: 'Không đổi được tên linh thú',
                          });
                        } finally {
                          setCompanionState('idle');
                        }
                      }}
                    >
                      <Save className="h-4 w-4" />
                      Lưu tên
                    </Button>
                    {(['PET', 'FEED', 'PLAY'] as const).map((action) => (
                      <Button
                        key={action}
                        onClick={async () => {
                          try {
                            await apiFetch('/user-companions/me/interactions', {
                              method: 'POST',
                              body: JSON.stringify({ type: action }),
                            });
                            setRefreshKey((current) => current + 1);
                            triggerRefresh();
                            pushToast({
                              tone: 'success',
                              title:
                                action === 'PET'
                                  ? 'Đã vuốt ve linh thú'
                                  : action === 'FEED'
                                    ? 'Đã cho linh thú ăn'
                                    : 'Đã chơi với linh thú',
                            });
                          } catch {
                            pushToast({
                              tone: 'error',
                              title: 'Không tương tác được với linh thú',
                            });
                          }
                        }}
                        variant="secondary"
                      >
                        {action === 'PET'
                          ? 'Vuốt ve'
                          : action === 'FEED'
                            ? 'Cho ăn'
                            : 'Chơi'}
                      </Button>
                    ))}
                  </div>
                </div>
              </div>

              <div className="grid gap-3 sm:grid-cols-3">
                <StatusMiniCard
                  note="mode đang áp dụng"
                  title="Personalization"
                  value={modeLabel(companion.personalizationMode)}
                />
                <StatusMiniCard
                  note="cảm xúc hiện tại"
                  title="Mood"
                  value={companion.mood}
                />
                <StatusMiniCard
                  note="trạng thái chuyển động"
                  title="Action"
                  value={companion.action}
                />
              </div>

              <div className="space-y-3">
                {companionOptions.map((option) => (
                  <div
                    className="rounded-xl border border-lilac/70 bg-white/75 p-4"
                    key={option.mode}
                  >
                    <div className="flex flex-wrap items-start justify-between gap-3">
                      <div>
                        <p className="text-lg font-extrabold text-ink">{option.label}</p>
                        <p className="mt-1 text-sm text-slate">
                          {option.key
                            ? `Đang map theo ${option.key}`
                            : option.mode === 'CUSTOM'
                              ? 'Tự chọn linh thú theo ý anh'
                              : 'Dùng asset mặc định của hệ thống'}
                        </p>
                      </div>
                      <Button
                        disabled={!option.available || companionState === 'saving' || option.mode === 'CUSTOM'}
                        onClick={async () => {
                          setCompanionState('saving');
                          try {
                            await apiFetch('/user-companions/me/personalization-mode', {
                              method: 'PATCH',
                              body: JSON.stringify({
                                personalizationMode: option.mode,
                                preserveProgress: true,
                                resetVisualState: true,
                              }),
                            });
                            setRefreshKey((current) => current + 1);
                            triggerRefresh();
                            pushToast({
                              tone: 'success',
                              title: `Đã chuyển sang ${option.label.toLowerCase()}`,
                            });
                          } catch {
                            pushToast({
                              tone: 'error',
                              title: 'Không đổi được mode linh thú',
                            });
                          } finally {
                            setCompanionState('idle');
                          }
                        }}
                        variant={
                          companion.personalizationMode === option.mode &&
                          option.mode !== 'CUSTOM'
                            ? 'secondary'
                            : 'primary'
                        }
                      >
                        {option.mode === 'CUSTOM'
                          ? 'Chọn asset bên dưới'
                          : companion.personalizationMode === option.mode
                            ? 'Đang dùng'
                            : 'Áp dụng'}
                      </Button>
                    </div>

                    {option.assets.length > 0 ? (
                      <div className="mt-4 grid gap-3 sm:grid-cols-2">
                        {option.assets.slice(0, 2).map((asset) => (
                          <CompanionAssetCard
                            asset={asset}
                            key={asset.id}
                            onSelect={async () => {
                              setCompanionState('saving');
                              try {
                                await apiFetch('/user-companions/me/personalization-mode', {
                                  method: 'PATCH',
                                  body: JSON.stringify({
                                    personalizationMode: option.mode,
                                    preserveProgress: true,
                                    resetVisualState: true,
                                  }),
                                });
                                setRefreshKey((current) => current + 1);
                                triggerRefresh();
                                pushToast({
                                  tone: 'success',
                                  title: `Đã sync linh thú theo ${option.label.toLowerCase()}`,
                                });
                              } catch {
                                pushToast({
                                  tone: 'error',
                                  title: 'Không đổi được linh thú theo mode này',
                                });
                              } finally {
                                setCompanionState('idle');
                              }
                            }}
                            selected={companion.assetId === asset.id}
                          />
                        ))}
                      </div>
                    ) : null}
                  </div>
                ))}
              </div>

              <div className="rounded-xl border border-lilac/70 bg-white/75 p-4">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div>
                    <p className="text-lg font-extrabold text-ink">Kho linh thú tự chọn</p>
                    <p className="mt-1 text-sm text-slate">
                      Đây là chỗ anh tự nạp linh thú cho profile hiện tại thay vì bị ràng theo cung hay con giáp.
                    </p>
                  </div>
                </div>
                <div className="mt-4 grid gap-3 sm:grid-cols-2">
                  {customAssets.map((asset) => (
                    <CompanionAssetCard
                      asset={asset}
                      key={asset.id}
                      onSelect={async () => {
                        setCompanionState('saving');
                        try {
                          await apiFetch('/user-companions/me/personalization-mode', {
                            method: 'PATCH',
                            body: JSON.stringify({
                              personalizationMode: 'CUSTOM',
                              assetId: asset.id,
                              preserveProgress: true,
                              resetVisualState: true,
                            }),
                          });
                          setRefreshKey((current) => current + 1);
                          triggerRefresh();
                          pushToast({
                            tone: 'success',
                            title: `Đã nạp linh thú ${asset.name}`,
                          });
                        } catch {
                          pushToast({
                            tone: 'error',
                            title: 'Không nạp được linh thú custom',
                          });
                        } finally {
                          setCompanionState('idle');
                        }
                      }}
                      selected={
                        companion.personalizationMode === 'CUSTOM' &&
                        companion.assetId === asset.id
                      }
                    />
                  ))}
                </div>
              </div>
            </div>
          ) : (
            <div className="mt-5 rounded-xl border border-dashed border-lilac bg-white/70 p-6 text-sm font-medium text-slate">
              Đang tải studio linh thú...
            </div>
          )}
        </Card>

        <Card>
          <SectionTitle
            title="Theme gallery"
            copy="Chọn giao diện hợp mood của anh. Khi bấm áp dụng, app sẽ lưu mode và theme tương ứng vào preferences."
            action={<Moon className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5 space-y-3">
            {themeCatalog.map((theme) => {
              const isActiveTheme = activeThemeId === theme.id;
              const statusLabel = isActiveTheme
                ? 'Đang dùng'
                : themeState === theme.id
                  ? 'Đang áp dụng'
                  : 'Áp dụng';
              // Auto-fix unreadable palettes (e.g. dark ink on a dark
              // surface). If the admin's textColor has enough contrast we
              // keep it; otherwise we fall back to white/near-black.
              const readableText = getReadableTextColor(
                theme.surfaceColor,
                theme.textColor,
              );
              const readableMuted = getReadableTextColor(
                theme.surfaceColor,
                theme.mutedTextColor || theme.textColor,
              );

              return (
                <button
                  className="w-full rounded-xl border p-4 text-left transition hover:-translate-y-0.5"
                  key={theme.id}
                  onClick={async () => {
                    setThemeState(theme.id);
                    dispatchDashboardTheme(theme.mode, theme);
                    try {
                      await apiFetch('/user-preferences/me/preferences', {
                        method: 'PATCH',
                        body: JSON.stringify({
                          themeId: theme.id,
                          themeMode: theme.mode,
                        }),
                      });
                      setActiveThemeId(theme.id);
                      setDraftPreferences((current) => ({
                        weatherEnabled:
                          current?.weatherEnabled ?? settings.preferences.weatherEnabled,
                        pushEnabled:
                          current?.pushEnabled ?? settings.preferences.pushEnabled,
                        soundEnabled:
                          current?.soundEnabled ?? settings.preferences.soundEnabled,
                        timezone: current?.timezone ?? settings.preferences.timezone,
                        locationName:
                          current?.locationName ?? settings.preferences.locationName,
                        themeMode: theme.mode,
                      }));
                      setRefreshKey((current) => current + 1);
                      triggerRefresh();
                      pushToast({
                        tone: 'success',
                        title: `Đã áp dụng theme ${theme.name}`,
                      });
                    } catch {
                      const currentTheme = themeCatalog.find(
                        (item) => item.id === activeThemeId,
                      );
                      dispatchDashboardTheme(
                        draftPreferences?.themeMode ??
                          (settings.preferences.theme.toUpperCase() as ThemeMode),
                        currentTheme ?? null,
                      );
                      pushToast({
                        tone: 'error',
                        title: 'Không áp dụng được theme',
                      });
                    } finally {
                      setThemeState(null);
                    }
                  }}
                  style={{
                    backgroundColor: theme.surfaceColor,
                    borderColor: isActiveTheme
                      ? theme.primaryColor
                      : theme.secondaryColor || theme.primaryColor,
                    boxShadow: isActiveTheme
                      ? `0 0 0 1px ${theme.primaryColor}`
                      : 'none',
                    color: readableText,
                  }}
                  type="button"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p
                        className="text-lg font-extrabold"
                        style={{ color: readableText }}
                      >
                        {theme.name}
                      </p>
                      <p
                        className="mt-1 text-sm"
                        style={{ color: readableMuted }}
                      >
                        {theme.mode} {theme.isDefault ? '• mặc định hệ thống' : ''}
                      </p>
                    </div>
                    <div
                      className="text-xs font-bold"
                      style={{
                        color: getReadableTextColor(
                          theme.surfaceColor,
                          theme.primaryColor,
                        ),
                      }}
                    >
                      {statusLabel}
                    </div>
                  </div>
                  <div className="mt-4 grid grid-cols-4 gap-2">
                    {[
                      theme.backgroundColor,
                      theme.surfaceColor,
                      theme.primaryColor,
                      theme.accentColor || theme.secondaryColor || theme.textColor,
                    ].map((color) => (
                      <div
                        className="h-12 rounded-lg border"
                        key={color}
                        style={{
                          backgroundColor: color,
                          borderColor: theme.mutedTextColor || 'rgba(0,0,0,0.08)',
                        }}
                      />
                    ))}
                  </div>
                </button>
              );
            })}
          </div>
        </Card>
      </div>

      <div className="grid gap-4 xl:grid-cols-2">
        <Card>
          <SectionTitle
            title="Thiết bị đăng nhập"
            copy="Theo dõi các phiên đã đăng nhập gần đây để biết tài khoản đang mở ở đâu."
            action={<Laptop className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5">
            <DataTable
              columns={[
                'Thiết bị',
                'Trình duyệt',
                'IP',
                'Đăng nhập',
                'Hết hạn',
                'Trạng thái',
              ]}
              rows={settings.sessions.map((session) => [
                <div
                  className="max-w-[220px]"
                  key={`${session.id}-device`}
                  title={session.device}
                >
                  <p className="font-bold">{describeDevice(session.device)}</p>
                </div>,
                <span
                  className="text-sm font-semibold"
                  key={`${session.id}-browser`}
                >
                  {describeBrowser(session.device)}
                </span>,
                <code
                  className="rounded bg-[var(--field-bg)] px-2 py-1 text-xs"
                  key={`${session.id}-ip`}
                >
                  {session.ipAddress || '—'}
                </code>,
                session.createdAt,
                session.expiresAt,
                session.current ? 'Phiên hiện tại' : 'Đã lưu',
              ])}
            />
          </div>
          <p className="mt-4 text-sm text-slate">
            Quyền revoke session hiện được khoá ở phía backend cho admin, nên bảng này
            đang đóng vai trò lịch sử đăng nhập thay vì nút xoá phiên tại chỗ.
          </p>
        </Card>

        <Card>
          <SectionTitle
            title="Thiết bị push"
            copy="Đăng ký nhanh trình duyệt hiện tại để test thông báo, hoặc gỡ những thiết bị không còn dùng nữa."
            action={<Smartphone className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5 flex flex-wrap gap-3">
            <Button
              disabled={deviceState === 'saving'}
              onClick={async () => {
                setDeviceState('saving');
                try {
                  await apiFetch('/notifications/me/devices', {
                    method: 'POST',
                    body: JSON.stringify({
                      token: `web-debug-${crypto.randomUUID()}`,
                      platform: 'WEB',
                      deviceName: 'Current browser',
                      timezone,
                      enabled: true,
                    }),
                  });
                  setRefreshKey((current) => current + 1);
                  triggerRefresh();
                  pushToast({
                    tone: 'success',
                    title: 'Đã thêm thiết bị web',
                    message:
                      'Anh có thể dùng nó để test push/in-app notification ngay trong dashboard.',
                  });
                } catch {
                  pushToast({
                    tone: 'error',
                    title: 'Không thêm được thiết bị',
                    message: 'Kiểm tra backend hoặc quyền đăng nhập rồi thử lại.',
                  });
                } finally {
                  setDeviceState('idle');
                }
              }}
            >
              <Smartphone className="h-4 w-4" />
              {deviceState === 'saving' ? 'Đang thêm' : 'Đăng ký trình duyệt này'}
            </Button>
          </div>
          <div className="mt-5">
            <DataTable
              columns={['Label', 'Platform', 'Active', 'Action']}
              rows={settings.pushDevices.map((device) => [
                device.label,
                device.platform,
                device.active ? 'On' : 'Off',
                <Button
                  className="h-8 px-3 text-xs"
                  key={device.id}
                  onClick={async () => {
                    try {
                      await apiFetch(`/notifications/me/devices/${device.id}`, {
                        method: 'DELETE',
                      });
                      setRefreshKey((current) => current + 1);
                      triggerRefresh();
                      pushToast({
                        tone: 'success',
                        title: 'Đã gỡ thiết bị push',
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: 'Không gỡ được thiết bị push',
                      });
                    }
                  }}
                  variant="secondary"
                >
                  Gỡ
                </Button>,
              ])}
            />
          </div>
        </Card>

        <Card>
          <SectionTitle
            title="Nhắc nhở"
            copy="Tạo các mốc nhắc mới, bật tắt nhanh hoặc xoá hẳn khi lịch sống của anh thay đổi."
            action={<Repeat className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5 grid gap-4">
            {/* Stack on mobile, 2-col on tablet, full single row only on
             *  ≥xl where there's actually room for label + input + button.
             *  Old md:grid-cols-[1fr_180px_220px_auto] squeezed the title
             *  field to 0px on intermediate widths. */}
            <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-[minmax(0,1fr)_180px_220px_auto]">
              <Field
                label="Tiêu đề"
                value={reminderDraft.title}
                onChange={(value) =>
                  setReminderDraft((current) => ({ ...current, title: value }))
                }
              />
              <Field
                label="Loại"
                select
                value={reminderDraft.type}
                options={['WATER', 'REST', 'BREATHING', 'JOURNAL', 'SLEEP', 'CUSTOM']}
                onChange={(value) =>
                  setReminderDraft((current) => ({
                    ...current,
                    type: value as ReminderDraft['type'],
                  }))
                }
              />
              <Field
                label="Thời gian"
                type="datetime-local"
                value={reminderDraft.scheduledAt}
                onChange={(value) =>
                  setReminderDraft((current) => ({
                    ...current,
                    scheduledAt: value,
                  }))
                }
              />
              <div className="sm:col-span-2 xl:col-span-1 xl:self-end">
                <Button
                  className="w-full xl:w-auto"
                  disabled={reminderState === 'saving'}
                  onClick={async () => {
                    setReminderState('saving');
                    try {
                      await apiFetch('/reminders/me', {
                        method: 'POST',
                        body: JSON.stringify({
                          ...reminderDraft,
                          scheduledAt: new Date(
                            reminderDraft.scheduledAt,
                          ).toISOString(),
                          isActive: true,
                        }),
                      });
                      setRefreshKey((current) => current + 1);
                      triggerRefresh();
                      setReminderDraft({
                        title: 'Nhắc thở nhẹ',
                        message: 'Đến lúc nghỉ một chút rồi hít thở nào.',
                        type: 'BREATHING',
                        scheduledAt: nextLocalReminderTime(),
                      });
                      pushToast({
                        tone: 'success',
                        title: 'Đã tạo reminder',
                        message: 'Lịch nhắc mới đã lưu vào backend.',
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: 'Tạo reminder thất bại',
                        message: 'Kiểm tra dữ liệu nhập hoặc phiên đăng nhập.',
                      });
                    } finally {
                      setReminderState('idle');
                    }
                  }}
                >
                  <Save className="h-4 w-4" />
                  {reminderState === 'saving' ? 'Đang tạo' : 'Tạo reminder'}
                </Button>
              </div>
            </div>
            <DataTable
              columns={['Type', 'Title', 'Schedule', 'Active', 'Actions']}
              rows={settings.reminders.map((reminder) => [
                reminder.type,
                reminder.title,
                reminder.schedule,
                reminder.active ? 'On' : 'Off',
                <div className="flex gap-2" key={reminder.id}>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={async () => {
                      try {
                        await apiFetch(`/reminders/${reminder.id}`, {
                          method: 'PATCH',
                          body: JSON.stringify({
                            isActive: !reminder.active,
                          }),
                        });
                        setRefreshKey((current) => current + 1);
                        triggerRefresh();
                        pushToast({
                          tone: 'success',
                          title: reminder.active
                            ? 'Đã tắt reminder'
                            : 'Đã bật reminder',
                        });
                      } catch {
                        pushToast({
                          tone: 'error',
                          title: 'Không đổi được trạng thái reminder',
                        });
                      }
                    }}
                    variant="secondary"
                  >
                    {reminder.active ? 'Tắt' : 'Bật'}
                  </Button>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={async () => {
                      try {
                        await apiFetch(`/reminders/${reminder.id}`, {
                          method: 'DELETE',
                        });
                        setRefreshKey((current) => current + 1);
                        triggerRefresh();
                        pushToast({
                          tone: 'success',
                          title: 'Đã xoá reminder',
                        });
                      } catch {
                        pushToast({
                          tone: 'error',
                          title: 'Xoá reminder thất bại',
                        });
                      }
                    }}
                  >
                    Xoá
                  </Button>
                </div>,
              ])}
            />
          </div>
        </Card>

        <Card>
          <SectionTitle
            title="Gói cước & nâng cấp"
            copy="Xem plan đang dùng và tạo checkout intent để backend ghi nhận nhu cầu nâng cấp."
            action={<CreditCard className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5 rounded-lg border border-lilac/70 bg-white/75 p-4">
            <p className="text-xs font-semibold uppercase tracking-[0.14em] text-slate">
              Gói hiện tại
            </p>
            <p className="mt-2 text-2xl font-extrabold text-ink">
              {settings.billing.planName}
            </p>
            <p className="mt-1 text-sm font-medium text-plum">
              Trạng thái {settings.billing.status} • gia hạn {settings.billing.renewal}
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
                      {formatPlanPrice(plan.price, plan.currency)}
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
                      ? 'Đang dùng'
                      : billingState === plan.name
                        ? 'Đang tạo'
                        : 'Chọn gói này'}
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
                Chưa tải được danh sách gói từ API billing.
              </div>
            )}
          </div>
        </Card>
      </div>
      </DashboardShell>
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
              const result = (await apiFetch('/billing/me/checkout-session', {
                method: 'POST',
                body: JSON.stringify({
                  planName: checkoutPlan.name,
                  provider: 'MANUAL',
                  description: `Upgrade intent from dashboard to ${checkoutPlan.title}`,
                }),
              })) as CheckoutResult;
              setCheckoutResult(result);

              // No external payment provider is wired yet, so settle the
              // pending payment through the manual confirmation endpoint to
              // actually activate the subscription instead of leaving it
              // PENDING forever.
              const paymentId = result.payment?.id;
              if (!result.configured && paymentId) {
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
                    note: `Đã kích hoạt gói ${
                      activated.subscription?.planName ?? checkoutPlan.title
                    }. Subscription chuyển sang ${
                      activated.subscription?.status ?? 'ACTIVE'
                    }.`,
                  },
                });
                triggerRefresh();
                pushToast({
                  tone: 'success',
                  title: `Đã kích hoạt ${checkoutPlan.title}`,
                  message:
                    'Thanh toán đã được xác nhận và gói đã được kích hoạt.',
                });
              } else {
                triggerRefresh();
                pushToast({
                  tone: 'info',
                  title: `Đã tạo yêu cầu ${checkoutPlan.title}`,
                  message:
                    result.checkout?.note ??
                    'Backend đã ghi nhận checkout intent cho gói này.',
                });
              }
            } catch {
              pushToast({
                tone: 'error',
                title: 'Không hoàn tất được nâng cấp',
                message: 'Kiểm tra backend billing rồi thử lại.',
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

function QuickAddReminder({
  defaultTitle,
  onCreated,
}: {
  defaultTitle: string;
  onCreated: () => void;
}) {
  const pushToast = useUiStore((state) => state.pushToast);
  const [time, setTime] = useState(() => {
    const d = new Date();
    d.setHours(d.getHours() + 1, 0, 0, 0);
    return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
  });
  const [busy, setBusy] = useState(false);

  return (
    <div className="mt-3 flex flex-wrap items-end gap-3">
      <label className="flex-1 min-w-[120px]">
        <span className="text-xs font-semibold text-[var(--app-muted,theme(colors.slate))]">
          Giờ nhắc
        </span>
        <input
          className="mt-2 h-11 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 text-sm font-semibold text-[var(--app-text,theme(colors.ink))] outline-none"
          onChange={(event) => setTime(event.target.value)}
          type="time"
          value={time}
        />
      </label>
      <Button
        disabled={busy || !time}
        onClick={async () => {
          if (!time) return;
          setBusy(true);
          try {
            const [hh, mm] = time.split(':').map(Number);
            const scheduled = new Date();
            scheduled.setHours(hh ?? 9, mm ?? 0, 0, 0);
            if (scheduled.getTime() < Date.now()) {
              scheduled.setDate(scheduled.getDate() + 1);
            }
            await apiFetch('/reminders/me', {
              method: 'POST',
              body: JSON.stringify({
                title: defaultTitle,
                message: 'Nhắc nhẹ trong ngày từ Quick add.',
                type: 'BREATHING',
                scheduledAt: scheduled.toISOString(),
                isActive: true,
              }),
            });
            onCreated();
            pushToast({ tone: 'success', title: `Đã thêm nhắc ${time}` });
          } catch {
            pushToast({ tone: 'error', title: 'Không thêm được nhắc' });
          } finally {
            setBusy(false);
          }
        }}
        variant="secondary"
      >
        <Save className="h-4 w-4" />
        {busy ? 'Đang thêm' : 'Thêm nhanh'}
      </Button>
    </div>
  );
}

function CheckoutModal({
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
  const creating = billingState === plan.name;
  const currentPlan = currentPlanName === plan.name;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-ink/55 p-4 backdrop-blur-sm sm:items-center">
      <div className="w-full max-w-xl rounded-2xl border border-[var(--panel-border)] bg-[var(--panel-strong)] p-5 text-[var(--app-text)] shadow-2xl">
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.18em] text-violet">
              Checkout intent
            </p>
            <h2 className="mt-2 text-2xl font-extrabold">Tạo thanh khoản</h2>
            <p className="mt-1 text-sm font-medium text-[var(--app-muted)]">
              Xác nhận gói để backend tạo payment pending và trả trạng thái provider.
            </p>
          </div>
          <button
            aria-label="Đóng checkout"
            className="rounded-full border border-[var(--field-border)] p-2 text-[var(--app-text)] transition hover:bg-violet/10"
            onClick={onClose}
            type="button"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="mt-5 rounded-xl border border-[var(--field-border)] bg-[var(--panel-bg)] p-4">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <p className="text-xl font-extrabold">{plan.title}</p>
              <p className="mt-1 text-sm font-semibold text-violet">
                {formatPlanPrice(plan.price, plan.currency)}
              </p>
            </div>
            <span className="rounded-full bg-cloud px-3 py-1 text-xs font-bold text-ink">
              {currentPlan ? 'Gói hiện tại' : 'Có thể nâng cấp'}
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

        {result ? (
          <div className="mt-4 rounded-xl border border-mint/40 bg-mint/10 p-4">
            <p className="font-extrabold text-mint">Backend đã tạo intent</p>
            <div className="mt-3 grid gap-2 text-sm font-semibold sm:grid-cols-2">
              <span>Payment: {result.payment?.id ?? '-'}</span>
              <span>Status: {result.payment?.status ?? '-'}</span>
              <span>Provider: {result.provider ?? 'MANUAL'}</span>
              <span>
                Amount:{' '}
                {formatPlanPrice(
                  result.payment?.amount ?? plan.price,
                  result.payment?.currency ?? plan.currency,
                )}
              </span>
            </div>
            <p className="mt-3 text-sm font-medium text-[var(--app-muted)]">
              {result.checkout?.note ??
                'Payment pending đã được ghi vào database. Khi cấu hình provider, chỗ này sẽ nhận checkout URL thật.'}
            </p>
          </div>
        ) : null}

        <div className="mt-5 flex flex-wrap justify-end gap-3">
          <Button onClick={onClose} type="button" variant="secondary">
            Đóng
          </Button>
          <Button
            disabled={creating || currentPlan}
            onClick={onConfirm}
            type="button"
          >
            <CreditCard className="h-4 w-4" />
            {creating ? 'Đang tạo intent' : currentPlan ? 'Đang dùng' : 'Tạo thanh khoản'}
          </Button>
        </div>
      </div>
    </div>
  );
}

function Field({
  label,
  value,
  type = 'text',
  onChange,
  select = false,
  options = [],
}: {
  label: string;
  value: string;
  type?: string;
  onChange?: (value: string) => void;
  select?: boolean;
  options?: string[];
}) {
  return (
    <label>
      <span className="text-sm font-semibold text-slate">{label}</span>
      {select ? (
        <select
          className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
          onChange={(event) => onChange?.(event.target.value)}
          value={value}
        >
          {options.map((option) => (
            <option key={option} value={option}>
              {option}
            </option>
          ))}
        </select>
      ) : (
        <input
          className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
          onChange={(event) => onChange?.(event.target.value)}
          readOnly={!onChange}
          type={type}
          value={value}
        />
      )}
    </label>
  );
}

function ToggleCard({
  checked,
  icon: Icon,
  label,
  onClick,
}: {
  checked: boolean;
  icon: LucideIcon;
  label: string;
  onClick: () => void;
}) {
  return (
    <button
      className={`rounded-lg border p-4 text-left transition ${
        checked
          ? 'border-violet bg-violet text-white'
          : 'border-lilac/70 bg-white/75 text-ink'
      }`}
      onClick={onClick}
      type="button"
    >
      <Icon className="h-5 w-5" />
      <p className="mt-4 font-bold">{label}</p>
      <p
        className={`mt-1 text-xs font-semibold ${
          checked ? 'text-white/70' : 'text-slate'
        }`}
      >
        {checked ? 'Enabled' : 'Disabled'}
      </p>
    </button>
  );
}

function DerivedCard({
  icon: Icon,
  label,
  note,
  value,
}: {
  icon: LucideIcon;
  label: string;
  note: string;
  value: string;
}) {
  return (
    <div className="rounded-lg border border-lilac/70 bg-white/75 p-4">
      <Icon className="h-5 w-5 text-violet" />
      <p className="mt-4 text-sm font-semibold text-slate">{label}</p>
      <p className="mt-1 text-xl font-extrabold text-ink">{value}</p>
      <p className="mt-1 text-xs font-medium text-plum">{note}</p>
    </div>
  );
}

function StatusMiniCard({
  title,
  value,
  note,
}: {
  title: string;
  value: string;
  note: string;
}) {
  return (
    <div className="rounded-lg border border-lilac/70 bg-white/75 p-4">
      <p className="text-xs font-semibold uppercase tracking-[0.14em] text-slate">
        {title}
      </p>
      <p className="mt-2 text-sm font-extrabold text-ink">{value}</p>
      <p className="mt-1 text-xs font-medium text-plum">{note}</p>
    </div>
  );
}

function CompanionAssetCard({
  asset,
  selected,
  onSelect,
}: {
  asset: CompanionAsset;
  selected: boolean;
  onSelect: () => void;
}) {
  return (
    <button
      className={`overflow-hidden rounded-xl border text-left transition ${
        selected
          ? 'border-violet bg-violet/5 shadow-panel'
          : 'border-lilac/70 bg-white/75 hover:border-violet'
      }`}
      onClick={onSelect}
      type="button"
    >
      <div
        className="h-28 w-full"
        style={{ background: asset.secondaryColor || 'rgba(255,255,255,0.72)' }}
      >
        {asset.previewImageUrl ? (
          <SafeCompanionImage
            alt={asset.name}
            className="h-full w-full object-cover"
            src={asset.previewImageUrl}
          />
        ) : null}
      </div>
      <div className="p-4">
        <p className="font-extrabold text-ink">{asset.name}</p>
        <p className="mt-1 text-sm text-slate">
          {asset.description || 'Linh thú đồng hành'}
        </p>
      </div>
    </button>
  );
}

function SafeCompanionImage({
  alt,
  className,
  src,
}: {
  alt: string;
  className: string;
  src: string;
}) {
  const [failed, setFailed] = useState(false);

  if (failed) {
    return (
      <div
        className={`${className} flex items-center justify-center bg-violet/10 text-xs font-bold text-violet`}
      >
        Preview chưa tải được
      </div>
    );
  }

  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      alt={alt}
      className={className}
      onError={() => setFailed(true)}
      referrerPolicy="no-referrer"
      src={src}
    />
  );
}

function normalizeBirthdayValue(value: string) {
  if (!value || value === '-') {
    return '';
  }

  // Already YYYY-MM-DD — accept as-is so the date input keeps it.
  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return value;
  }

  // vi-VN locale string "DD/MM/YYYY" — what live-dashboard.formatDate
  // happens to spit out. Parse the parts directly so we don't fall into
  // `new Date("10/3/2003")` which JS interprets as MM/DD/YYYY (US) and
  // would swap day↔month.
  const localeMatch = value.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (localeMatch) {
    const [, day, month, year] = localeMatch;
    return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
  }

  // ISO with time (e.g. "2003-03-10T00:00:00Z"). Use UTC parts so a VN
  // +07 browser doesn't roll back/forward a day.
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return '';
  }
  const year = parsed.getUTCFullYear();
  const month = String(parsed.getUTCMonth() + 1).padStart(2, '0');
  const day = String(parsed.getUTCDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function nextLocalReminderTime() {
  const date = new Date();
  date.setHours(date.getHours() + 1, 0, 0, 0);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hour = String(date.getHours()).padStart(2, '0');
  const minute = String(date.getMinutes()).padStart(2, '0');
  return `${year}-${month}-${day}T${hour}:${minute}`;
}

function formatPlanPrice(price: number, currency: string) {
  if (price <= 0) {
    return 'Miễn phí';
  }

  try {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency,
      maximumFractionDigits: 0,
    }).format(price);
  } catch {
    return `${new Intl.NumberFormat('vi-VN', {
      maximumFractionDigits: 0,
    }).format(price)} ${currency}`;
  }
}

function toDashboardThemeMode(mode: ThemeMode): DashboardThemeMode {
  return mode.toLowerCase() as DashboardThemeMode;
}

function dispatchDashboardTheme(
  mode: ThemeMode,
  palette: DashboardThemePalette | null,
) {
  const dashboardMode = toDashboardThemeMode(mode);
  applyDashboardTheme(dashboardMode, palette);
  window.dispatchEvent(
    new CustomEvent(DASHBOARD_THEME_APPLIED_EVENT, {
      detail: {
        mode: dashboardMode,
        palette,
      },
    }),
  );
}

function modeLabel(mode: CompanionMode) {
  if (mode === 'ZODIAC') return 'Theo cung hoàng đạo';
  if (mode === 'CHINESE_ZODIAC') return 'Theo 12 con giáp';
  if (mode === 'CUSTOM') return 'Tự chọn linh thú';
  return 'Mặc định';
}
