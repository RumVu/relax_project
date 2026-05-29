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

const ICONS: Record<CapabilityName, typeof MapPin> = {
  geolocation: MapPin,
  notification: Bell,
  audio: Volume2,
  storage: Database,
};

const COPY: Record<CapabilityName, { what: string; why: string }> = {
  geolocation: {
    what: 'Định vị',
    why: 'Để lấy lat/long lưu vào profile cho /weather/me/current và /forecast.',
  },
  notification: {
    what: 'Thông báo OS',
    why: 'Để bắn popup "Đã tìm thấy thiết bị đăng nhập mới" khi tab background.',
  },
  audio: {
    what: 'Âm thanh in-app',
    why: 'Bóc-bóc chime khi có realtime notification.',
  },
  storage: {
    what: 'localStorage',
    why: 'Lưu access/refresh token để khỏi login lại sau khi reload.',
  },
};

/**
 * Settings panel that audits every browser capability the app uses,
 * surfaces a clear status badge, and exposes one-click "Yêu cầu quyền"
 * actions for the ones that need a permission prompt. Replaces the
 * silent-failure mode where users click a button and nothing happens.
 */
export function PermissionsPanel() {
  const pushToast = useUiStore((state) => state.pushToast);
  const [reports, setReports] = useState<CapabilityReport[]>([]);
  const [busy, setBusy] = useState<CapabilityName | null>(null);

  const refresh = useCallback(async () => {
    const next = await auditCapabilities();
    setReports(next);
  }, []);

  useEffect(() => {
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
            title: 'Đã cấp quyền định vị',
          });
        } else if (name === 'notification') {
          const result = await requestNotificationPermission();
          if (result === 'granted') {
            pushToast({
              tone: 'success',
              title: 'Đã cấp quyền thông báo',
            });
            // Fire one demo so user thấy ngay nó hoạt động.
            try {
              new Notification('Digital Cigarette Break', {
                body: 'Đã bật notification — sẽ ping a khi có sự kiện mới.',
                icon: '/favicon.ico',
              });
            } catch {
              /* ignore */
            }
          } else {
            pushToast({
              tone: 'error',
              title: 'Quyền thông báo bị từ chối',
              message:
                result === 'denied'
                  ? 'Vào setting browser bật lại thủ công.'
                  : `State: ${result}`,
            });
          }
        }
      } catch (error) {
        pushToast({
          tone: 'error',
          title: `Không cấp được quyền ${COPY[name].what.toLowerCase()}`,
          message: error instanceof Error ? error.message : 'Unknown',
        });
      } finally {
        setBusy(null);
        await refresh();
      }
    },
    [pushToast, refresh],
  );

  const summary = (() => {
    const blockers = reports.filter(
      (r) =>
        r.status === 'denied' ||
        r.status === 'insecure-context' ||
        r.status === 'unsupported',
    );
    if (blockers.length === 0) return { tone: 'mint', label: 'Tất cả OK' };
    if (
      blockers.some((b) => b.status === 'insecure-context')
    )
      return { tone: 'coral', label: 'Cần HTTPS / localhost' };
    return { tone: 'sun', label: `${blockers.length} cần xử lý` };
  })();

  return (
    <Card>
      <SectionTitle
        title="Quyền truy cập trình duyệt"
        copy="Mỗi tính năng cần quyền riêng — bấm 'Yêu cầu' để app xin quyền cho a. Nếu browser im ru, kiểm tra nhanh trạng thái dưới đây."
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
              aria-label="Refresh"
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
          const copy = COPY[report.name];
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
            ? 'Đã cấp'
            : needPrompt
              ? 'Chưa cấp'
              : insecure
                ? 'Origin không an toàn'
                : denied
                  ? 'Đã từ chối'
                  : 'Không hỗ trợ';

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
                      {copy.what}
                    </p>
                    <p className="mt-0.5 text-xs text-[var(--app-muted)]">
                      {copy.why}
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
                  {busy === report.name ? 'Đang xin' : 'Yêu cầu quyền'}
                </Button>
              ) : null}
            </div>
          );
        })}
      </div>
    </Card>
  );
}
