'use client';

/**
 * Modal "Lịch sử đăng nhập" — hiển thị:
 *   1. Thiết bị HIỆN TẠI (parse navigator.userAgent + userAgentData)
 *   2. Tất cả phiên đăng nhập của user từ GET /sessions/me
 *      → mỗi row: device summary, OS, browser, version, IP, login time
 *      → có nút copy raw UA cho debug
 *
 * Sessions chưa được revoke từ UI (backend chỉ cho admin) — chỉ là
 * "audit trail" cho user. Sau này có thể thêm endpoint user-self
 * revoke nếu cần.
 */

import { useCallback, useEffect, useState } from 'react';
import {
  Activity,
  Copy,
  Globe,
  Loader2,
  Monitor,
  Smartphone,
  Tablet,
  X,
} from 'lucide-react';
import { apiFetch, getStoredSessionId } from '@/lib/api';
import {
  ParsedUserAgent,
  formatUserAgentSummary,
  parseUserAgent,
} from '@/lib/user-agent-parser';
import { useUiStore } from '@/stores/use-ui-store';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

interface SessionRow {
  id: string;
  userAgent: string | null;
  ipAddress: string | null;
  createdAt: string;
  expiresAt: string;
}

interface CurrentDevice {
  parsed: ParsedUserAgent;
  loginTime: Date;
  clientHints: string | null;
}

function deviceIcon(type: ParsedUserAgent['deviceType']) {
  if (type === 'Mobile') return Smartphone;
  if (type === 'Tablet') return Tablet;
  if (type === 'Khác') return Globe;
  return Monitor;
}

function detectCurrentDevice(): CurrentDevice {
  const raw = typeof navigator !== 'undefined' ? navigator.userAgent : '';
  const parsed = parseUserAgent(raw);

  // Client Hints — Chromium-based browsers expose userAgentData.
  let clientHints: string | null = null;
  if (typeof navigator !== 'undefined') {
    const uad = (navigator as Navigator & {
      userAgentData?: {
        brands?: Array<{ brand: string; version: string }>;
        mobile?: boolean;
        platform?: string;
      };
    }).userAgentData;
    if (uad) {
      const brands =
        uad.brands?.map((b) => `${b.brand} ${b.version}`).join(', ') ?? '';
      clientHints = `${uad.platform ?? '?'} • ${uad.mobile ? 'mobile' : 'desktop'}${brands ? ` • ${brands}` : ''}`;
    }
  }

  return { parsed, loginTime: new Date(), clientHints };
}

function formatVnDateTime(value: string | Date) {
  try {
    const date = typeof value === 'string' ? new Date(value) : value;
    if (Number.isNaN(date.getTime())) return String(value);
    return date.toLocaleString('vi-VN', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  } catch {
    return String(value);
  }
}

export function DeviceSessionsModal({
  open,
  onClose,
}: {
  open: boolean;
  onClose: () => void;
}) {
  const pushToast = useUiStore((state) => state.pushToast);
  const [current, setCurrent] = useState<CurrentDevice | null>(null);
  const [sessions, setSessions] = useState<SessionRow[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const currentSessionId = open ? getStoredSessionId() : undefined;

  const loadSessions = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const rows = await apiFetch<SessionRow[]>('/sessions/me');
      setSessions(Array.isArray(rows) ? rows : []);
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Không tải được phiên đăng nhập.');
      setSessions([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (!open) return;
    // Detect device + load sessions every time modal opens (fresh data).
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setCurrent(detectCurrentDevice());
    void loadSessions();
  }, [open, loadSessions]);

  // Lock body scroll while open.
  useEffect(() => {
    if (typeof document === 'undefined') return;
    if (open) {
      const prev = document.body.style.overflow;
      document.body.style.overflow = 'hidden';
      return () => {
        document.body.style.overflow = prev;
      };
    }
  }, [open]);

  if (!open) return null;

  const copyToClipboard = async (value: string, label: string) => {
    try {
      await navigator.clipboard.writeText(value);
      pushToast({ tone: 'success', title: `Đã copy ${label}` });
    } catch {
      pushToast({ tone: 'error', title: 'Trình duyệt từ chối clipboard' });
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-start justify-center bg-night/55 p-4 backdrop-blur-sm sm:items-center"
      onClick={onClose}
    >
      <div
        className="my-6 w-full max-w-3xl overflow-hidden rounded-2xl border border-white/70 bg-white shadow-panel"
        onClick={(event) => event.stopPropagation()}
      >
        <header className="flex items-start justify-between gap-3 border-b border-cloud px-6 py-4">
          <div>
            <h3 className="text-xl font-extrabold text-ink">Lịch sử đăng nhập</h3>
            <p className="mt-1 text-sm text-slate">
              Thiết bị hiện tại + các phiên đã đăng nhập vào tài khoản của a.
            </p>
          </div>
          <button
            aria-label="Đóng"
            className="rounded-lg p-1 text-slate transition hover:bg-cloud hover:text-ink"
            onClick={onClose}
            type="button"
          >
            <X className="h-5 w-5" />
          </button>
        </header>

        <div className="max-h-[70vh] space-y-5 overflow-y-auto px-6 py-5">
          {/* ============ Thiết bị hiện tại ============ */}
          {current ? (
            <section>
              <h4 className="text-xs font-bold uppercase tracking-[0.18em] text-violet">
                Thiết bị hiện tại
              </h4>
              <div className="mt-2 rounded-xl border border-mint/40 bg-mint/5 p-4">
                <div className="flex items-start gap-3">
                  <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-violet text-white">
                    {(() => {
                      const Icon = deviceIcon(current.parsed.deviceType);
                      return <Icon className="h-5 w-5" />;
                    })()}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-base font-extrabold text-ink">
                      {formatUserAgentSummary(current.parsed)}
                    </p>
                    <p className="mt-0.5 text-xs font-semibold text-slate">
                      Đăng nhập lúc {formatVnDateTime(current.loginTime)}
                    </p>
                  </div>
                </div>
                <dl className="mt-4 grid grid-cols-2 gap-3 text-xs sm:grid-cols-3">
                  <Field label="Thiết bị" value={current.parsed.deviceType} />
                  <Field
                    label="OS"
                    value={
                      current.parsed.osVersion
                        ? `${current.parsed.os} ${current.parsed.osVersion}`
                        : current.parsed.os
                    }
                  />
                  <Field
                    label="Browser"
                    value={
                      current.parsed.browserVersion
                        ? `${current.parsed.browser} ${current.parsed.browserVersion}`
                        : current.parsed.browser
                    }
                  />
                  <Field
                    label="Client Hints"
                    value={current.clientHints ?? 'Không hỗ trợ'}
                    fullSpan
                  />
                </dl>
                <div className="mt-3 flex items-start gap-2 rounded-lg border border-cloud bg-white p-2 text-[11px] text-slate">
                  <div className="flex-1 break-all font-mono">{current.parsed.raw || '—'}</div>
                  {current.parsed.raw ? (
                    <button
                      aria-label="Copy User-Agent"
                      className="shrink-0 rounded-md p-1.5 text-slate transition hover:bg-cloud hover:text-ink"
                      onClick={() => copyToClipboard(current.parsed.raw, 'User-Agent')}
                      type="button"
                    >
                      <Copy className="h-3.5 w-3.5" />
                    </button>
                  ) : null}
                </div>
              </div>
            </section>
          ) : null}

          {/* ============ Tất cả sessions ============ */}
          <section>
            <div className="flex items-center justify-between">
              <h4 className="text-xs font-bold uppercase tracking-[0.18em] text-violet">
                Tất cả phiên đăng nhập
              </h4>
              <Button
                className="h-8 px-3 text-xs"
                onClick={loadSessions}
                variant="secondary"
              >
                {loading ? (
                  <Loader2 className="h-3.5 w-3.5 animate-spin" />
                ) : (
                  <Activity className="h-3.5 w-3.5" />
                )}
                Làm mới
              </Button>
            </div>

            {error ? (
              <p className="mt-2 rounded-lg border border-coral/40 bg-coral/10 p-3 text-sm font-semibold text-coral">
                {error}
              </p>
            ) : null}

            <div className="mt-3 space-y-2">
              {loading && sessions.length === 0 ? (
                <p className="rounded-lg border border-cloud bg-cloud/40 p-4 text-center text-sm text-slate">
                  Đang tải…
                </p>
              ) : sessions.length === 0 && !error ? (
                <p className="rounded-lg border border-cloud bg-cloud/40 p-4 text-center text-sm text-slate">
                  Chưa có phiên nào.
                </p>
              ) : (
                sessions.map((session) => {
                  const parsed = parseUserAgent(session.userAgent);
                  const Icon = deviceIcon(parsed.deviceType);
                  const isCurrent = session.id === currentSessionId;
                  return (
                    <div
                      className={cn(
                        'rounded-xl border p-3 transition',
                        isCurrent
                          ? 'border-mint/60 bg-mint/10'
                          : 'border-cloud bg-white hover:border-violet/40',
                      )}
                      key={session.id}
                    >
                      <div className="flex items-start gap-3">
                        <div
                          className={cn(
                            'flex h-9 w-9 shrink-0 items-center justify-center rounded-lg',
                            isCurrent ? 'bg-mint text-night' : 'bg-cloud text-slate',
                          )}
                        >
                          <Icon className="h-4 w-4" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex flex-wrap items-center gap-2">
                            <p className="text-sm font-bold text-ink">
                              {formatUserAgentSummary(parsed)}
                            </p>
                            {isCurrent ? (
                              <span className="rounded-full bg-mint px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide text-night">
                                Phiên này
                              </span>
                            ) : null}
                          </div>
                          <p className="mt-0.5 text-xs font-semibold text-slate">
                            {parsed.deviceType} • {parsed.os}
                            {parsed.osVersion ? ` ${parsed.osVersion}` : ''}
                          </p>
                          <dl className="mt-2 grid grid-cols-2 gap-2 text-[11px] sm:grid-cols-3">
                            <Field label="IP" value={session.ipAddress || '—'} />
                            <Field
                              label="Đăng nhập"
                              value={formatVnDateTime(session.createdAt)}
                            />
                            <Field
                              label="Hết hạn"
                              value={formatVnDateTime(session.expiresAt)}
                            />
                          </dl>
                          {session.userAgent ? (
                            <div className="mt-2 flex items-start gap-2 rounded-lg border border-cloud/60 bg-cloud/30 p-2 text-[10px] text-slate">
                              <div className="flex-1 break-all font-mono">
                                {session.userAgent}
                              </div>
                              <button
                                aria-label="Copy User-Agent"
                                className="shrink-0 rounded-md p-1 text-slate transition hover:bg-white hover:text-ink"
                                onClick={() =>
                                  copyToClipboard(session.userAgent ?? '', 'User-Agent')
                                }
                                type="button"
                              >
                                <Copy className="h-3 w-3" />
                              </button>
                            </div>
                          ) : null}
                        </div>
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </section>
        </div>

        <footer className="flex justify-end gap-2 border-t border-cloud px-6 py-3">
          <Button onClick={onClose} variant="secondary">
            Đóng
          </Button>
        </footer>
      </div>
    </div>
  );
}

function Field({
  label,
  value,
  fullSpan,
}: {
  label: string;
  value: string;
  fullSpan?: boolean;
}) {
  return (
    <div className={cn(fullSpan && 'col-span-2 sm:col-span-3')}>
      <dt className="text-[10px] font-bold uppercase tracking-[0.14em] text-slate/70">
        {label}
      </dt>
      <dd className="mt-0.5 break-all text-xs font-semibold text-ink">{value}</dd>
    </div>
  );
}
