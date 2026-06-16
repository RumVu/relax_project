'use client';

import { useState } from 'react';
import { Smartphone } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { apiFetch } from '@/lib/api';

interface PushDevicesSectionProps {
  t: any;
  locale: 'vi' | 'en';
  copy: any;
  settings: any;
  triggerRefresh: () => void;
  setRefreshKey: (updater: (prev: number) => number) => void;
  pushToast: (toast: any) => void;
}

export function PushDevicesSection({
  t,
  locale,
  copy,
  settings,
  triggerRefresh,
  setRefreshKey,
  pushToast,
}: PushDevicesSectionProps) {
  const [deviceState, setDeviceState] = useState<'idle' | 'saving'>('idle');

  return (
    <Card>
      <SectionTitle
        title={copy.pushDevicesTitle}
        copy={copy.pushDevicesCopy}
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
                  timezone: settings.preferences.timezone,
                  enabled: true,
                }),
              });
              setRefreshKey((current) => current + 1);
              triggerRefresh();
              pushToast({
                tone: 'success',
                title: copy.pushDeviceAdded,
                message: copy.pushDeviceAddedMessage,
              });
            } catch {
              pushToast({
                tone: 'error',
                title: copy.pushDeviceAddFailed,
                message: t('settings.toast.serverHint'),
              });
            } finally {
              setDeviceState('idle');
            }
          }}
        >
          <Smartphone className="h-4 w-4" />
          {deviceState === 'saving' ? copy.adding : copy.registerCurrentBrowser}
        </Button>
      </div>
      <div className="mt-5 grid gap-3">
        {settings.pushDevices.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-violet/20 bg-violet/5 p-6 text-center text-sm text-slate-500">
            {t('settings.devices.empty')}
          </div>
        ) : (
          settings.pushDevices.map((device: any) => {
            const platformLower = device.platform?.toLowerCase() ?? '';
            const platformIcon = platformLower.includes('ios')
              ? '🍎'
              : platformLower.includes('android')
                ? '🤖'
                : platformLower.includes('web')
                  ? '🌐'
                  : '📱';
            const platformLabel = platformLower.includes('ios')
              ? 'iOS'
              : platformLower.includes('android')
                ? 'Android'
                : platformLower.includes('web')
                  ? 'Web'
                  : device.platform || 'Device';
            const lastSeen = device.lastSeenAt
              ? new Date(device.lastSeenAt).toLocaleString(locale, {
                  dateStyle: 'short',
                  timeStyle: 'short',
                })
              : '—';
            const firstSeen = device.createdAt
              ? new Date(device.createdAt).toLocaleDateString(locale, {
                  dateStyle: 'short',
                } as Intl.DateTimeFormatOptions)
              : null;
            return (
              <div
                key={device.id}
                className="rounded-2xl border border-violet/15 bg-white/70 p-4 shadow-sm transition hover:border-violet/30 hover:shadow-md"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-start gap-3 min-w-0 flex-1">
                    <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-violet/10 text-2xl">
                      {platformIcon}
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <p className="truncate text-sm font-semibold text-ink">
                          {device.label}
                        </p>
                        <span className="rounded-full bg-violet/10 px-2 py-0.5 text-[10px] font-medium uppercase tracking-wide text-violet">
                          {platformLabel}
                        </span>
                        {device.active ? (
                          <span className="rounded-full bg-emerald-50 px-2 py-0.5 text-[10px] font-medium text-emerald-700">
                            ● {t('state.active')}
                          </span>
                        ) : (
                          <span className="rounded-full bg-slate-100 px-2 py-0.5 text-[10px] font-medium text-slate-500">
                            ○ {t('state.inactive')}
                          </span>
                        )}
                      </div>
                      <dl className="mt-2 grid grid-cols-2 gap-x-4 gap-y-1 text-xs text-slate-500 sm:grid-cols-3">
                        {device.deviceId ? (
                          <div className="truncate">
                            <dt className="inline text-slate-400">ID: </dt>
                            <dd className="inline font-mono text-[11px] text-slate-600">
                              {device.deviceId.slice(0, 12)}
                              {device.deviceId.length > 12 ? '…' : ''}
                            </dd>
                          </div>
                        ) : null}
                        {device.appVersion ? (
                          <div className="truncate">
                            <dt className="inline text-slate-400">
                              {t('settings.devices.appVersion')}:{' '}
                            </dt>
                            <dd className="inline text-slate-600">
                              {device.appVersion}
                            </dd>
                          </div>
                        ) : null}
                        {device.timezone ? (
                          <div className="truncate">
                            <dt className="inline text-slate-400">
                              {t('settings.devices.timezone')}:{' '}
                            </dt>
                            <dd className="inline text-slate-600">
                              {device.timezone}
                            </dd>
                          </div>
                        ) : null}
                        {device.provider ? (
                          <div className="truncate">
                            <dt className="inline text-slate-400">
                              {t('settings.devices.provider')}:{' '}
                            </dt>
                            <dd className="inline uppercase text-slate-600">
                              {device.provider}
                            </dd>
                          </div>
                        ) : null}
                        <div className="truncate col-span-2 sm:col-span-3">
                          <dt className="inline text-slate-400">
                            {t('settings.devices.lastSeen')}:{' '}
                          </dt>
                          <dd className="inline text-slate-600">{lastSeen}</dd>
                          {firstSeen ? (
                            <span className="ml-2 text-slate-400">
                              · {t('settings.devices.firstSeen')} {firstSeen}
                            </span>
                          ) : null}
                        </div>
                      </dl>
                    </div>
                  </div>
                  <Button
                    className="h-8 shrink-0 px-3 text-xs"
                    onClick={async () => {
                      try {
                        await apiFetch(
                          `/notifications/me/devices/${device.id}`,
                          { method: 'DELETE' },
                        );
                        setRefreshKey((current) => current + 1);
                        triggerRefresh();
                        pushToast({
                          tone: 'success',
                          title: copy.pushDeviceRemoved,
                        });
                      } catch {
                        pushToast({
                          tone: 'error',
                          title: copy.pushDeviceRemoveFailed,
                        });
                      }
                    }}
                    variant="secondary"
                  >
                    {copy.remove}
                  </Button>
                </div>
              </div>
            );
          })
        )}
      </div>
    </Card>
  );
}
