'use client';

import { useCallback, useEffect, useRef, useState } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import {
  Activity,
  BarChart3,
  Bell,
  BookOpenText,
  FileClock,
  Home,
  Leaf,
  Moon,
  RefreshCcw,
  Search,
  Settings,
  Shield,
  SmilePlus,
  Sparkles,
  Users,
  Volume2,
  Wind,
} from 'lucide-react';
import { adminNav, primaryNav } from '@/lib/constants';
import { apiFetch, getStoredRole } from '@/lib/api';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { RealtimeStatusBadge } from '@/components/dashboard/dashboard-ui';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';

const iconMap = {
  Overview: Home,
  Mood: SmilePlus,
  Breaks: Wind,
  Journal: BookOpenText,
  Analytics: BarChart3,
  Settings,
  'Admin Home': Shield,
  Users,
  Search,
  Logs: FileClock,
  Quotes: Sparkles,
  Sounds: Volume2,
  Exercises: Activity,
};

export function DashboardShell({
  title,
  eyebrow,
  children,
  admin = false,
}: {
  title: string;
  eyebrow: string;
  children: React.ReactNode;
  admin?: boolean;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const nav = admin ? adminNav : primaryNav;
  const { focusMode, refreshNonce, toggleFocusMode, triggerRefresh } =
    useDashboardStore();
  const pushToast = useUiStore((state) => state.pushToast);
  const [role] = useState<string | undefined>(() => getStoredRole());
  const [alertOpen, setAlertOpen] = useState(false);
  const [unreadCount, setUnreadCount] = useState(0);
  const [notifications, setNotifications] = useState<
    Array<{ id: string; title: string; read: boolean; type: string }>
  >([]);
  const [nextReminder, setNextReminder] = useState<{
    id: string;
    title: string;
    time: string;
  } | null>(null);
  const lastRealtimeRefreshRef = useRef(0);

  // Realtime events arrive on /realtime; refetch dashboard + chrome data,
  // throttled so a burst of events does not trigger a refetch storm.
  const handleRealtimeEvent = useCallback(() => {
    const now = Date.now();
    if (now - lastRealtimeRefreshRef.current < 1500) {
      return;
    }
    lastRealtimeRefreshRef.current = now;
    triggerRefresh();
  }, [triggerRefresh]);

  const loadChromeData = useCallback(async () => {
    try {
      const [notificationList, unreadPayload, reminders] = await Promise.all([
        apiFetch<{ items?: Array<Record<string, unknown>> }>('/notifications/me', undefined, {
          query: { limit: 5 },
        }),
        apiFetch<{ count?: number }>('/notifications/me/unread-count'),
        apiFetch<{ items?: Array<Record<string, unknown>> }>('/reminders/me', undefined, {
          query: { limit: 3 },
        }),
      ]);

      setUnreadCount(unreadPayload.count ?? 0);
      setNotifications(
        (notificationList.items ?? []).map((item, index) => ({
          id: String(item.id ?? `notification-${index}`),
          title: String(item.title ?? 'Notification'),
          read: Boolean(item.isRead),
          type: String(item.type ?? 'IN_APP'),
        })),
      );

      const firstReminder = reminders.items?.[0];
      if (firstReminder) {
        const scheduledAt = String(firstReminder.scheduledAt ?? '');
        setNextReminder({
          id: String(firstReminder.id ?? 'reminder'),
          title: String(firstReminder.title ?? 'Reminder'),
          time: formatReminderTime(scheduledAt),
        });
      }
    } catch {
      setNotifications([]);
      setUnreadCount(0);
      setNextReminder(null);
    }
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadChromeData();
    }, 0);

    return () => {
      window.clearTimeout(timer);
    };
  }, [loadChromeData, refreshNonce]);

  return (
    <main
      className={cn(
        'min-h-screen overflow-x-hidden px-3 py-4 text-ink transition sm:px-5 lg:px-6',
        focusMode && 'bg-[radial-gradient(circle_at_top,rgba(64,201,162,0.12),transparent_32%)]',
      )}
    >
      <div className="mx-auto grid w-full max-w-[1440px] min-w-0 gap-4 lg:grid-cols-[248px_minmax(0,1fr)]">
        <aside className="min-w-0 overflow-hidden rounded-lg border border-white/10 bg-night p-4 text-mist shadow-panel lg:sticky lg:top-6 lg:h-[calc(100vh-48px)]">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-violet text-white">
              <Leaf className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-mist/60">
                Digital Break
              </p>
              <h1 className="text-lg font-bold">
                {admin ? 'Admin Console' : 'Cozy Control'}
              </h1>
            </div>
          </div>

          <nav className="mt-6 flex max-w-full flex-wrap gap-2 pb-1 lg:block lg:space-y-1 lg:pb-0">
            {nav.map((item) => (
              <NavLink
                active={pathname === item.href}
                href={item.href}
                key={item.href}
                label={item.label}
              />
            ))}
            {!admin && role === 'ADMIN' ? (
              <NavLink active={pathname.startsWith('/admin')} href="/admin" label="Admin Home" />
            ) : null}
            {admin ? <NavLink active={pathname === '/dashboard'} href="/dashboard" label="Overview" /> : null}
          </nav>

          <div className="mt-6 grid grid-cols-2 gap-2 lg:grid-cols-1">
            <button
              className="rounded-lg border border-white/10 bg-white/10 p-3 text-left transition hover:bg-white/15"
              onClick={() => router.push('/dashboard/settings')}
              type="button"
            >
              <div className="flex items-center gap-2 text-sm font-semibold">
                <Moon className="h-4 w-4 text-lilac" />
                {nextReminder?.time ?? '21:00'}
              </div>
              <p className="mt-1 text-xs text-mist/60">
                {nextReminder?.title ?? 'Evening reminder'}
              </p>
            </button>
            <button
              className={cn(
                'rounded-lg border p-3 text-left transition',
                focusMode
                  ? 'border-mint/70 bg-mint/20'
                  : 'border-white/10 bg-white/10 hover:bg-white/15',
              )}
              onClick={() => {
                toggleFocusMode();
                pushToast({
                  tone: 'info',
                  title: focusMode ? 'Đã tắt focus mode' : 'Đã bật focus mode',
                  message: focusMode
                    ? 'Giao diện đã trở lại chế độ bình thường.'
                    : 'Giảm xao nhãng để tập trung thư giãn.',
                });
              }}
              type="button"
            >
              <div className="flex items-center gap-2 text-sm font-semibold">
                <Sparkles className="h-4 w-4 text-sun" />
                Focus
              </div>
              <p className="mt-1 text-xs text-mist/60">
                {focusMode ? 'On' : 'Off'}
              </p>
            </button>
          </div>
        </aside>

        <section className="min-w-0 space-y-4">
          <div className="rounded-lg border border-[var(--panel-border)] bg-[image:var(--hero-bg)] p-5 shadow-panel">
            <div className="flex flex-col gap-4 xl:flex-row xl:items-center xl:justify-between">
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-plum">
                  {eyebrow}
                </p>
                <h2 className="mt-2 text-3xl font-extrabold text-[var(--app-text)] md:text-4xl">
                  {title}
                </h2>
              </div>
              <div className="flex flex-wrap items-center gap-2">
                <RealtimeStatusBadge onEvent={handleRealtimeEvent} />
                <button
                  className="inline-flex h-10 items-center gap-2 rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink"
                  onClick={() => {
                    setAlertOpen((current) => !current);
                    if (!alertOpen) {
                      void loadChromeData();
                    }
                  }}
                  type="button"
                >
                  <Bell className="h-4 w-4 text-coral" />
                  {unreadCount} thông báo
                </button>
                <Button
                  onClick={() => {
                    triggerRefresh();
                    void loadChromeData();
                    pushToast({
                      tone: 'info',
                      title: 'Đang làm mới dữ liệu',
                      message: 'Dashboard sẽ refetch lại dữ liệu live.',
                    });
                  }}
                  variant="secondary"
                >
                  <RefreshCcw className="h-4 w-4" />
                  Refresh
                </Button>
              </div>
            </div>
          </div>
          {alertOpen ? (
            <div className="relative">
              <div className="mt-4 rounded-lg border border-lilac bg-white/95 p-4 shadow-panel">
                <div className="flex items-center justify-between gap-3">
                  <div>
                    <p className="text-sm font-extrabold text-ink">Thông báo gần đây</p>
                    <p className="text-xs font-semibold text-slate">
                      {unreadCount} chưa đọc
                    </p>
                  </div>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={async () => {
                      try {
                        await apiFetch('/notifications/me/read-all', { method: 'PATCH' });
                        await loadChromeData();
                        pushToast({
                          tone: 'success',
                          title: 'Đã đánh dấu đã đọc',
                        });
                      } catch {
                        pushToast({
                          tone: 'error',
                          title: 'Không đánh dấu được thông báo',
                        });
                      }
                    }}
                    variant="secondary"
                  >
                    Read all
                  </Button>
                </div>
                <div className="mt-4 space-y-2">
                  {notifications.length ? (
                    notifications.map((notification) => (
                      <button
                        className={cn(
                          'w-full rounded-lg border p-3 text-left transition hover:border-violet',
                          notification.read
                            ? 'border-lilac/60 bg-white'
                            : 'border-mint/50 bg-mint/10',
                        )}
                        key={notification.id}
                        onClick={async () => {
                          try {
                            if (!notification.read) {
                              await apiFetch(
                                `/notifications/me/${notification.id}/read`,
                                { method: 'PATCH' },
                              );
                              await loadChromeData();
                            }
                          } catch {
                            pushToast({
                              tone: 'error',
                              title: 'Không mở được thông báo',
                            });
                          }
                        }}
                        type="button"
                      >
                        <p className="text-sm font-bold text-ink">{notification.title}</p>
                        <p className="mt-1 text-xs font-semibold text-slate">
                          {notification.type}
                        </p>
                      </button>
                    ))
                  ) : (
                    <p className="text-sm font-semibold text-slate">
                      Chưa có thông báo mới.
                    </p>
                  )}
                </div>
              </div>
            </div>
          ) : null}
          {children}
        </section>
      </div>
    </main>
  );
}

function NavLink({
  active,
  href,
  label,
}: {
  active: boolean;
  href: string;
  label: string;
}) {
  const Icon = iconMap[label as keyof typeof iconMap] ?? Home;

  return (
    <Link
      className={cn(
        'flex min-w-fit items-center gap-3 rounded-lg px-3 py-3 text-sm font-semibold transition',
        active
          ? 'bg-white text-ink'
          : 'text-mist/70 hover:bg-white/10 hover:text-white',
      )}
      href={href}
    >
      <Icon className="h-4 w-4 shrink-0" />
      <span>{label}</span>
    </Link>
  );
}

function formatReminderTime(value: string) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return '21:00';
  }

  return date.toLocaleTimeString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
  });
}
