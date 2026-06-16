'use client';

import { useState } from 'react';
import { Save, Navigation, Bell, MapPin, Moon, Repeat } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { apiFetch } from '@/lib/api';
import { requestGeolocation } from '@/lib/permissions';
import { Field, ToggleCard, StatusMiniCard } from '../components/ui-cards';
import { QuickAddReminder } from '../components/quick-add-reminder';
import { dispatchDashboardTheme } from '../settings-utils';
import type { ThemeMode, ThemeCard } from '../settings-types';

interface PreferencesSectionProps {
  t: any;
  settings: any;
  themeCatalog: ThemeCard[];
  activeThemeId: string | null;
  triggerRefresh: () => void;
  setRefreshKey: (updater: (prev: number) => number) => void;
  pushToast: (toast: any) => void;
}

export function PreferencesSection({
  t,
  settings,
  themeCatalog,
  activeThemeId,
  triggerRefresh,
  setRefreshKey,
  pushToast,
}: PreferencesSectionProps) {
  const [draftPreferences, setDraftPreferences] = useState<{
    weatherEnabled: boolean;
    pushEnabled: boolean;
    soundEnabled: boolean;
    timezone: string;
    locationName: string;
    themeMode: ThemeMode;
  } | null>(null);
  const [saveState, setSaveState] = useState<'idle' | 'saving'>('idle');

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

  return (
    <Card>
      <SectionTitle
        title={t('settings.section.preferences.title')}
        copy={t('settings.section.preferences.copy')}
      />
      <div className="mt-5 grid gap-4">
        <div className="grid gap-4 sm:grid-cols-3">
          <Field
            label={t('settings.field.themeMode')}
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
            label={t('settings.metric.location')}
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
            label={t('settings.section.weather.title')}
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
            label={t('settings.field.notifyPush')}
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
            label={t('settings.field.notifySound')}
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
            note={t('settings.theme.systemNote')}
            title={t('settings.theme.current')}
            value={themeMode}
          />
          <StatusMiniCard
            note={weatherEnabled ? t('settings.weather.on') : t('settings.weather.off')}
            title={t('settings.weather.location')}
            value={locationName}
          />
          <StatusMiniCard
            note={t('settings.reminders.quickNote')}
            title={t('settings.reminders.dailyRhythm')}
            value={
              settings.preferences.reminderTimes.length > 0
                ? settings.preferences.reminderTimes.join(' • ')
                : t('settings.reminders.empty.full')
            }
          />
        </div>
      </div>

      <div className="mt-5">
        <p className="mb-2 text-xs font-semibold uppercase tracking-[0.14em] text-[var(--app-muted,theme(colors.slate))]">
          {t('settings.reminders.quickAdd')}
        </p>
        <div className="flex flex-wrap items-center gap-2">
          {settings.preferences.reminderTimes.map((time: string) => (
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
              {t('settings.reminders.quickEmpty')}
            </span>
          ) : null}
        </div>
        <QuickAddReminder
          defaultTitle={t('settings.reminders.defaultBreathing')}
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
                title: t('settings.toast.preferencesSaved'),
                message: t('settings.toast.preferencesSavedMessage'),
              });
            } catch {
              pushToast({
                tone: 'error',
                title: t('settings.toast.preferencesFailed'),
                message: t('settings.toast.serverHint'),
              });
            } finally {
              setSaveState('idle');
            }
          }}
        >
          <Save className="h-4 w-4" />
          {saveState === 'saving' ? t('settings.btn.savingPreferences') : t('settings.btn.savePreferences')}
        </Button>
        <Button
          onClick={async () => {
            try {
              const pos = await requestGeolocation();
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
                title: t('weather.locateGranted'),
                message: t('settings.toast.locationSavedMessage'),
              });
            } catch (error) {
              pushToast({
                tone: 'error',
                title: t('weather.locateFailed.title'),
                message:
                  error instanceof Error ? error.message : 'Unknown',
              });
            }
          }}
          variant="secondary"
        >
          <Navigation className="h-4 w-4" />
          {t('weather.locate')}
        </Button>
        <Button
          onClick={async () => {
            try {
              await apiFetch('/notifications/me/test', {
                method: 'POST',
                body: JSON.stringify({
                  title: t('settings.notification.testTitle'),
                  message: t('settings.notification.testMessage'),
                  type: 'IN_APP',
                }),
              });
              setRefreshKey((current) => current + 1);
              triggerRefresh();
              pushToast({
                tone: 'info',
                title: t('settings.toast.testNotificationCreated'),
                message: t('settings.toast.testNotificationMessage'),
              });
            } catch {
              pushToast({
                tone: 'error',
                title: t('settings.toast.testNotificationFailed'),
                message: t('settings.toast.serverHint'),
              });
            }
          }}
          variant="secondary"
        >
          <Bell className="h-4 w-4" />
          {t('settings.btn.testNotification')}
        </Button>
      </div>
    </Card>
  );
}
