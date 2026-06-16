'use client';

import { useCallback, useEffect, useRef, useState } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import {
  Activity,
  BarChart3,
  Bell,
  BookOpenText,
  CloudSun,
  FileClock,
  Headphones,
  Home,
  Leaf,
  Menu,
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
  X,
} from 'lucide-react';
import { adminNav, primaryNav } from '@/lib/constants';
import { apiFetch, getStoredRole } from '@/lib/api';
import { requestNotificationPermission } from '@/lib/permissions';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { RealtimeStatusBadge } from '@/components/dashboard/dashboard-ui';
import { AccountMenu } from '@/components/dashboard/account-menu';
import { OnboardingTour } from '@/components/dashboard/onboarding-tour';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import type { TranslationKey } from '@/lib/i18n/dictionaries';

// Map sidebar nav label → i18n key. The constant list keeps `label`
// untranslated so we can switch language at runtime without re-fetching.
const NAV_TRANSLATION_KEYS: Record<string, TranslationKey> = {
  Overview: 'nav.overview',
  Mood: 'nav.mood',
  Breaks: 'nav.breaks',
  Journal: 'nav.journal',
  Analytics: 'nav.analytics',
  Weather: 'nav.weather',
  Settings: 'nav.settings',
  'Admin Home': 'nav.adminHome',
  Users: 'nav.users',
  Search: 'nav.search',
  Logs: 'nav.logs',
  Quotes: 'nav.quotes',
  Sounds: 'nav.sounds',
  Podcasts: 'nav.podcasts',
  Exercises: 'nav.exercises',
  Meditations: 'nav.meditations',
  Themes: 'nav.themes',
  Onboarding: 'nav.onboarding',
  'Companion Assets': 'nav.companionAssets',
  'Companion Messages': 'nav.companionMessages',
  'Feature Flags': 'nav.featureFlags',
  Health: 'nav.health',
};

const iconMap = {
  Overview: Home,
  Mood: SmilePlus,
  Breaks: Wind,
  Journal: BookOpenText,
  Analytics: BarChart3,
  Weather: CloudSun,
  Settings,
  'Admin Home': Shield,
  Users,
  Search,
  Logs: FileClock,
  Quotes: Sparkles,
  Sounds: Volume2,
  Podcasts: Headphones,
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
  const { t, locale } = useTranslation();
  const [role] = useState<string | undefined>(() => getStoredRole());
  const [alertOpen, setAlertOpen] = useState(false);
  // Mobile drawer state — opens the sidebar as an off-canvas overlay
  // on viewports < lg (1024px) so phones/tablets get the full nav
  // without the horizontal-scroll chip strip.
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  // Close the drawer whenever the user navigates so they don't have to
  // tap "close" manually after picking a destination.
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMobileNavOpen(false);
  }, [pathname]);
  // Lock body scroll while drawer is open so the page underneath stays
  // put while the user scrolls the drawer.
  useEffect(() => {
    if (typeof document === 'undefined') return;
    if (mobileNavOpen) {
      const prev = document.body.style.overflow;
      document.body.style.overflow = 'hidden';
      return () => {
        document.body.style.overflow = prev;
      };
    }
  }, [mobileNavOpen]);
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
  // For `notification.created` we also pop a toast + a browser-level
  // Notification (if the user granted permission) + a short "bóc bóc"
  // beep so a brand-new device login is impossible to miss.
  const handleRealtimeEvent = useCallback(
    (eventName: string, payload?: unknown) => {
      const now = Date.now();
      if (now - lastRealtimeRefreshRef.current > 1500) {
        lastRealtimeRefreshRef.current = now;
        triggerRefresh();
      }

      if (eventName === 'notification.created') {
        const p = (payload ?? {}) as {
          title?: string;
          message?: string;
          type?: string;
        };
        const title = p.title || t('shell.notifications.new');
        const message = p.message || '';

        pushToast({
          tone: title.toLowerCase().includes('thiết bị') || title.toLowerCase().includes('device') ? 'info' : 'success',
          title,
          message,
        });

        playNotifyChime();
        showBrowserNotification(title, message);
      }
    },
    [pushToast, t, triggerRefresh],
  );

  // Ask for browser-level Notification permission once per session so
  // realtime events can pop a native OS toast even if the dashboard tab
  // is in the background. Uses the centralised helper so insecure
  // contexts (http://LAN-IP) silently no-op instead of looking broken.
  useEffect(() => {
    const t = window.setTimeout(() => {
      void requestNotificationPermission().catch(() => undefined);
    }, 2000);
    return () => window.clearTimeout(t);
  }, []);

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
          time: formatReminderTime(scheduledAt, locale),
        });
      }
    } catch {
      setNotifications([]);
      setUnreadCount(0);
      setNextReminder(null);
    }
  }, [locale]);

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
        // NOTE: overflow-x-hidden intentionally NOT set here — it would
        // create a new scroll containing block and break `lg:sticky` on
        // the sidebar. Horizontal overflow is handled on <body> in
        // globals.css instead.
        'min-h-screen px-3 py-4 text-ink transition sm:px-5 lg:px-6',
        focusMode && 'bg-[radial-gradient(circle_at_top,rgba(64,201,162,0.12),transparent_32%)]',
      )}
    >
      {/* Mobile topbar (< lg). The desktop hero already houses the
       *  realtime badge / notification button, so the topbar only needs
       *  the brand mark + the hamburger menu. */}
      <div className="mx-auto mb-3 flex w-full max-w-[1800px] items-center justify-between gap-3 rounded-lg border border-[var(--panel-border)] bg-[var(--panel-strong)] p-3 shadow-panel lg:hidden">
        <div className="flex items-center gap-2">
          <div className="flex h-9 w-9 items-center justify-center overflow-hidden rounded-lg bg-violet text-white">
            <img src="/logo.jpg" alt="Relax Time !" className="h-full w-full object-cover" />
          </div>
          <div>
            <p className="text-[10px] font-semibold uppercase tracking-[0.18em] text-[var(--app-muted)]">
              {t('brand.tagline')}
            </p>
            <p className="text-sm font-bold text-[var(--app-text)]">
              {admin ? t('brand.adminConsole') : t('brand.cozyControl')}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <AccountMenu />
          <button
            aria-label={t('shell.openMenu')}
            className="inline-flex h-10 w-10 items-center justify-center rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] text-[var(--app-text)] transition hover:bg-violet/10"
            onClick={() => setMobileNavOpen(true)}
            type="button"
          >
            <Menu className="h-5 w-5" />
          </button>
        </div>
      </div>

      {/* Mobile drawer backdrop */}
      {mobileNavOpen ? (
        <div
          aria-hidden="true"
          className="fixed inset-0 z-40 bg-ink/55 backdrop-blur-sm lg:hidden"
          onClick={() => setMobileNavOpen(false)}
        />
      ) : null}

      <div className="mx-auto grid w-full max-w-[1800px] min-w-0 gap-4 lg:grid-cols-[248px_minmax(0,1fr)]">
        <aside
          className={cn(
            // Mobile: off-canvas drawer (translate-x); desktop: in-grid sticky.
            'min-w-0 rounded-lg border border-white/10 bg-night p-4 text-mist shadow-panel transition-transform duration-200',
            // Drawer behaviour on phones/tablets.
            'fixed inset-y-0 left-0 z-50 w-[280px] max-w-[85vw] overflow-y-auto',
            mobileNavOpen ? 'translate-x-0' : '-translate-x-full',
            // Desktop overrides — back to in-flow, sticky.
            'lg:static lg:z-auto lg:w-auto lg:max-w-none lg:translate-x-0 lg:sticky lg:top-6 lg:h-[calc(100vh-48px)] lg:overflow-y-auto',
          )}
        >
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-3">
              <div className="flex h-11 w-11 items-center justify-center overflow-hidden rounded-lg bg-violet text-white">
                <img src="/logo.jpg" alt="Relax Time !" className="h-full w-full object-cover" />
              </div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-mist/60">
                  {t('brand.tagline')}
                </p>
                <h1 className="text-lg font-bold">
                  {admin ? t('brand.adminConsole') : t('brand.cozyControl')}
                </h1>
              </div>
            </div>
            <button
              aria-label={t('shell.closeMenu')}
              className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-white/15 text-mist transition hover:bg-white/10 lg:hidden"
              onClick={() => setMobileNavOpen(false)}
              type="button"
            >
              <X className="h-4 w-4" />
            </button>
          </div>

          {/* Nav: vertical stack on every breakpoint (mobile drawer +
           *  desktop sidebar are both columns). */}
          <nav className="mt-6 space-y-1">
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

          <div className="mt-6 grid grid-cols-2 gap-2 sm:grid-cols-2 lg:grid-cols-1">
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
                {nextReminder?.title ?? t('shell.reminder.fallbackLabel')}
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
                  title: focusMode ? t('shell.focus.off') : t('shell.focus.on'),
                  message: focusMode
                    ? t('shell.focus.offMessage')
                    : t('shell.focus.onMessage'),
                });
              }}
              type="button"
            >
              <div className="flex items-center gap-2 text-sm font-semibold">
                <Sparkles className="h-4 w-4 text-sun" />
                {t('shell.focus.label')}
              </div>
              <p className="mt-1 text-xs text-mist/60">
                {focusMode ? t('shell.focus.on') : t('shell.focus.off')}
              </p>
            </button>
          </div>
        </aside>

        <section className="min-w-0 space-y-4">
          <div className="rounded-lg border border-[var(--panel-border)] bg-[image:var(--hero-bg)] p-5 shadow-panel">
            {/* Hero header layout strategy:
             *  - Title (eyebrow + h2) wraps freely thanks to `min-w-0`.
             *  - Action group (realtime/notif/refresh + AccountMenu) is
             *    a single `inline-flex` row pinned top-right on desktop
             *    via `lg:flex-row lg:items-start lg:justify-between`,
             *    stacking BELOW the title on smaller widths.
             *  - The action group itself wraps internally only when the
             *    viewport is so narrow even smallest buttons overflow.
             */}
            <div className="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
              <div className="min-w-0 flex-1">
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-plum">
                  {eyebrow}
                </p>
                <h2 className="mt-2 break-words text-2xl font-extrabold text-[var(--app-text)] sm:text-3xl md:text-4xl">
                  {title}
                </h2>
              </div>
              <div className="flex flex-wrap items-center gap-2 lg:flex-nowrap">
                <RealtimeStatusBadge onEvent={handleRealtimeEvent} />
                <button
                  className="relative inline-flex h-10 items-center gap-2 rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink transition hover:border-violet"
                  onClick={() => {
                    setAlertOpen((current) => !current);
                    if (!alertOpen) {
                      void loadChromeData();
                    }
                  }}
                  type="button"
                >
                  <Bell className="h-4 w-4 text-coral" />
                  <span className="hidden sm:inline">
                    {t('shell.notifications.count', { count: unreadCount })}
                  </span>
                  <span className="sm:hidden">{unreadCount}</span>
                  {unreadCount > 0 ? (
                    <span className="absolute -right-1 -top-1 inline-flex h-4 min-w-[1rem] items-center justify-center rounded-full bg-coral px-1 text-[10px] font-bold text-white sm:hidden">
                      {unreadCount > 9 ? '9+' : unreadCount}
                    </span>
                  ) : null}
                </button>
                <Button
                  onClick={() => {
                    triggerRefresh();
                    void loadChromeData();
                    pushToast({
                      tone: 'info',
                      title: t('shell.refresh.title'),
                      message: t('shell.refresh.message'),
                    });
                  }}
                  variant="secondary"
                >
                  <RefreshCcw className="h-4 w-4" />
                  {t('common.refresh')}
                </Button>
                {/* Account menu — hidden on mobile (already in mobile
                 *  topbar) so the desktop hero row doesn't double-up. */}
                <div className="hidden lg:block">
                  <AccountMenu />
                </div>
              </div>
            </div>
          </div>
          {alertOpen ? (
            <div className="relative">
              <div className="mt-4 rounded-lg border border-lilac bg-white/95 p-4 shadow-panel">
                <div className="flex items-center justify-between gap-3">
                  <div>
                    <p className="text-sm font-extrabold text-ink">
                      {t('shell.notifications.recent')}
                    </p>
                    <p className="text-xs font-semibold text-slate">
                      {t('shell.notifications.unread', { count: unreadCount })}
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
                          title: t('shell.notifications.markedRead'),
                        });
                      } catch {
                        pushToast({
                          tone: 'error',
                          title: t('shell.notifications.markFailed'),
                        });
                      }
                    }}
                    variant="secondary"
                  >
                    {t('shell.notifications.readAll')}
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
                              title: t('shell.notifications.openFailed'),
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
                      {t('shell.notifications.empty')}
                    </p>
                  )}
                </div>
              </div>
            </div>
          ) : null}
          {children}
          <OnboardingTour />
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
  const { t } = useTranslation();
  const Icon = iconMap[label as keyof typeof iconMap] ?? Home;
  const translationKey = NAV_TRANSLATION_KEYS[label];
  const translated = translationKey ? t(translationKey) : label;

  const tourId =
    label === 'Breaks'
      ? 'tour-nav-breaks'
      : label === 'Journal'
        ? 'tour-nav-journal'
        : label === 'Settings'
          ? 'tour-nav-settings'
          : undefined;

  return (
    <Link
      data-tour={tourId}
      className={cn(
        'flex min-w-fit items-center gap-3 rounded-lg px-3 py-3 text-sm font-semibold transition',
        active
          ? 'bg-white text-ink'
          : 'text-mist/70 hover:bg-white/10 hover:text-white',
      )}
      href={href}
    >
      <Icon className="h-4 w-4 shrink-0" />
      <span>{translated}</span>
    </Link>
  );
}

function formatReminderTime(value: string, locale: string) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return '21:00';
  }

  return date.toLocaleTimeString(locale === 'vi' ? 'vi-VN' : 'en-US', {
    hour: '2-digit',
    minute: '2-digit',
  });
}

/**
 * Play a short two-note "bóc bóc" chime using the WebAudio API — no
 * static audio asset required, no permission needed beyond the usual
 * autoplay rule (which is satisfied because the chime only fires in
 * response to a realtime event after the user has interacted with the
 * page).
 */
function playNotifyChime() {
  if (typeof window === 'undefined') return;
  const Ctx =
    window.AudioContext ||
    (window as unknown as { webkitAudioContext?: typeof AudioContext })
      .webkitAudioContext;
  if (!Ctx) return;

  try {
    const ctx = new Ctx();
    const now = ctx.currentTime;
    const tones: Array<[number, number]> = [
      [880, now],         // first beep at A5
      [660, now + 0.18],  // second beep at E5 — "bóc bóc"
    ];

    for (const [freq, start] of tones) {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.value = freq;
      gain.gain.setValueAtTime(0, start);
      gain.gain.linearRampToValueAtTime(0.18, start + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.16);
      osc.connect(gain).connect(ctx.destination);
      osc.start(start);
      osc.stop(start + 0.18);
    }
    // Auto-close the context shortly after the second tone finishes so
    // we don't leak an open AudioContext on every notification.
    window.setTimeout(() => ctx.close().catch(() => undefined), 500);
  } catch {
    // WebAudio refused (rare) — silently ignore. The in-app toast still
    // fires regardless.
  }
}

/**
 * Pop a native OS-level notification if the user previously granted
 * permission. Falls back to silent no-op otherwise — the in-app toast
 * still surfaces the same content.
 */
function showBrowserNotification(title: string, body: string) {
  if (typeof window === 'undefined') return;
  if (!('Notification' in window)) return;
  if (Notification.permission !== 'granted') return;
  try {
    const n = new Notification(title, {
      body,
      icon: '/favicon.ico',
      tag: 'digital-break-notification',
    });
    // Auto-dismiss after 8s so notifications don't pile up.
    window.setTimeout(() => n.close(), 8000);
  } catch {
    // Notification constructor can throw in service-worker-only contexts.
  }
}
