'use client';

import { useCallback, useEffect, useState } from 'react';
import {
  AlertTriangle,
  Bell,
  CheckCircle2,
  Database,
  MapPin,
  RefreshCcw,
  Shield,
  Volume2,
  XCircle,
} from 'lucide-react';
import {
  type CapabilityName,
  type CapabilityReport,
  auditCapabilities,
  requestGeolocation,
  requestNotificationPermission,
} from '@/lib/permissions';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import type { TranslationKey } from '@/lib/i18n/dictionaries';

const ICONS: Record<CapabilityName, typeof MapPin> = {
  geolocation: MapPin,
  notification: Bell,
  audio: Volume2,
  storage: Database,
};

const COPY_KEYS: Record<
  CapabilityName,
  { what: TranslationKey; why: TranslationKey }
> = {
  geolocation: {
    what: 'permissions.cap.geolocation.what',
    why: 'permissions.cap.geolocation.why',
  },
  notification: {
    what: 'permissions.cap.notification.what',
    why: 'permissions.cap.notification.why',
  },
  audio: {
    what: 'permissions.cap.audio.what',
    why: 'permissions.cap.audio.why',
  },
  storage: {
    what: 'permissions.cap.storage.what',
    why: 'permissions.cap.storage.why',
  },
};

/**
 * Settings panel that audits every browser capability the app uses,
 * surfaces a clear status badge, and exposes one-click "request"
 * actions for permissions that haven't been answered yet.
 */
export function PermissionsPanel() {
  const pushToast = useUiStore((state) => state.pushToast);
  const { t } = useTranslation();
  const [reports, setReports] = useState<CapabilityReport[]>([]);
  const [busy, setBusy] = useState<CapabilityName | null>(null);

  const refresh = useCallback(async () => {
    const next = await auditCapabilities();
    setReports(next);
  }, []);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void refresh();
  }, [refresh]);

  const requestPermission = useCallback(
    async (name: CapabilityName) => {
      setBusy(name);
      try {
        if (name === 'geolocation') {
          await requestGeolocation();
          pushToast({
            tone: 'success',
            title: t('permissions.granted.geolocation'),
          });
        } else if (name === 'notification') {
          const result = await requestNotificationPermission();
          if (result === 'granted') {
            pushToast({
              tone: 'success',
              title: t('permissions.granted.notification'),
            });
            try {
              new Notification('Digital Cigarette Break', {
                body: t('permissions.demo.notification.body'),
                icon: '/favicon.ico',
              });
            } catch {
              /* ignore */
            }
          } else {
            pushToast({
              tone: 'error',
              title: t('permissions.denied.notification'),
              message:
                result === 'denied'
                  ? t('permissions.denied.hint')
                  : `${t('permissions.status.notAsked')}: ${result}`,
            });
          }
        }
      } catch (error) {
        pushToast({
          tone: 'error',
          title: t('permissions.failed.title', {
            what: t(COPY_KEYS[name].what).toLowerCase(),
          }),
          message:
            error instanceof Error ? error.message : t('common.unknown'),
        });
      } finally {
        setBusy(null);
        await refresh();
      }
    },
    [pushToast, refresh, t],
  );

  const summary = (() => {
    const blockers = reports.filter(
      (r) =>
        r.status === 'denied' ||
        r.status === 'insecure-context' ||
        r.status === 'unsupported',
    );
    if (blockers.length === 0)
      return { tone: 'mint', label: t('permissions.summary.allOk') };
    if (blockers.some((b) => b.status === 'insecure-context'))
      return { tone: 'coral', label: t('permissions.summary.needsHttps') };
    return {
      tone: 'sun',
      label: t('permissions.summary.needsAction', { count: blockers.length }),
    };
  })();

  return (
    <Card>
      <SectionTitle
        title={t('permissions.section.title')}
        copy={t('permissions.section.copy')}
        action={
          <div className="flex items-center gap-2">
            <span
              className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-bold ${
                summary.tone === 'mint'
                  ? 'bg-mint/15 text-mint'
                  : summary.tone === 'sun'
                    ? 'bg-sun/25 text-ink'
                    : 'bg-coral/15 text-coral'
              }`}
            >
              <Shield className="h-3 w-3" />
              {summary.label}
            </span>
            <button
              aria-label={t('common.refresh')}
              className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)]"
              onClick={() => void refresh()}
              type="button"
            >
              <RefreshCcw className="h-4 w-4" />
            </button>
          </div>
        }
      />
      <div className="mt-5 grid gap-3 sm:grid-cols-2">
        {reports.map((report) => {
          const Icon = ICONS[report.name];
          const copyKey = COPY_KEYS[report.name];
          const ok = report.status === 'granted';
          const needPrompt = report.status === 'prompt';
          const insecure = report.status === 'insecure-context';
          const denied = report.status === 'denied';
          const unsupported = report.status === 'unsupported';
          const StatusIcon = ok
            ? CheckCircle2
            : insecure
              ? AlertTriangle
              : XCircle;
          const statusTone = ok
            ? 'text-mint'
            : insecure
              ? 'text-coral'
              : needPrompt
                ? 'text-violet'
                : 'text-coral';
          const statusLabel = ok
            ? t('permissions.status.granted')
            : needPrompt
              ? t('permissions.status.notAsked')
              : insecure
                ? t('permissions.status.insecure')
                : denied
                  ? t('permissions.status.denied')
                  : t('permissions.status.unsupported');

          return (
            <div
              className="rounded-lg border border-[var(--field-border)] bg-[var(--panel-bg)] p-4"
              key={report.name}
            >
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-start gap-3 min-w-0">
                  <Icon className="mt-0.5 h-5 w-5 shrink-0 text-violet" />
                  <div className="min-w-0">
                    <p className="font-extrabold text-[var(--app-text)]">
                      {t(copyKey.what)}
                    </p>
                    <p className="mt-0.5 text-xs text-[var(--app-muted)]">
                      {t(copyKey.why)}
                    </p>
                  </div>
                </div>
                <div
                  className={`flex shrink-0 items-center gap-1 text-xs font-bold ${statusTone}`}
                >
                  <StatusIcon className="h-4 w-4" />
                  {statusLabel}
                </div>
              </div>
              {report.hint ? (
                <p className="mt-3 rounded-md border border-[var(--field-border)] bg-[var(--field-bg)] px-3 py-2 text-xs font-medium text-[var(--app-muted)]">
                  {report.hint}
                </p>
              ) : null}
              {(needPrompt || denied) &&
              !insecure &&
              !unsupported &&
              (report.name === 'geolocation' ||
                report.name === 'notification') ? (
                <Button
                  className="mt-3 h-9 px-3 text-xs"
                  disabled={busy === report.name}
                  onClick={() => void requestPermission(report.name)}
                  variant="secondary"
                >
                  {busy === report.name
                    ? t('permissions.action.requesting')
                    : t('permissions.action.request')}
                </Button>
              ) : null}
            </div>
          );
        })}
      </div>
    </Card>
  );
}
