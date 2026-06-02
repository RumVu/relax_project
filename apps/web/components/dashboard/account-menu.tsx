'use client';

/**
 * Account dropdown ở góc trên-phải dashboard:
 *   - Trigger: avatar (initials) + tên + role
 *   - Header: tên + email + role badge
 *   - Quản lý profile  → /dashboard/settings
 *   - Lịch sử đăng nhập → mở DeviceSessionsModal
 *   - Đăng xuất         → POST /auth/logout + clearAuthSession + redirect
 */

import { useCallback, useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import {
  ChevronDown,
  Globe,
  LogOut,
  ShieldCheck,
  UserCog,
  History,
  User as UserIcon,
  Check,
} from 'lucide-react';
import {
  apiFetch,
  clearAuthSession,
  getStoredRole,
} from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { cn } from '@/lib/utils';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import {
  LOCALES,
  LOCALE_LABELS,
  LOCALE_SHORT,
  type Locale,
} from '@/lib/i18n/dictionaries';
import { DeviceSessionsModal } from './device-sessions-modal';
import { useDashboardStore } from '@/stores/use-dashboard-store';

interface MeResponse {
  id?: string;
  email?: string;
  name?: string | null;
  avatar?: string | null;
  role?: string;
  profile?: { displayName?: string | null } | null;
}

function initialsOf(name?: string | null, email?: string | null) {
  const source = (name || email || '?').trim();
  if (!source) return '?';
  const parts = source.split(/[\s.@_-]+/).filter(Boolean);
  const first = parts[0]?.[0] ?? '?';
  const second = parts[1]?.[0] ?? '';
  return (first + second).toUpperCase();
}

export function AccountMenu() {
  const router = useRouter();
  const pushToast = useUiStore((state) => state.pushToast);
  const { t, locale, setLocale } = useTranslation();
  const containerRef = useRef<HTMLDivElement>(null);
  const [open, setOpen] = useState(false);
  const [sessionsOpen, setSessionsOpen] = useState(false);
  const [languageOpen, setLanguageOpen] = useState(false);
  const [me, setMe] = useState<MeResponse | null>(null);
  const [loggingOut, setLoggingOut] = useState(false);
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const role = getStoredRole();

  // Refetch when dashboard chrome refreshes so settings/avatar uploads are
  // reflected in the navbar immediately.
  useEffect(() => {
    void apiFetch<MeResponse>('/auth/me')
      .then((data) => {
        setMe(data ?? null);
      })
      .catch(() => undefined);
  }, [refreshNonce]);

  // Close on outside click + Escape.
  useEffect(() => {
    if (!open) return;
    function handleClick(event: MouseEvent) {
      if (!containerRef.current) return;
      if (!containerRef.current.contains(event.target as Node)) {
        setOpen(false);
      }
    }
    function handleKey(event: KeyboardEvent) {
      if (event.key === 'Escape') setOpen(false);
    }
    document.addEventListener('mousedown', handleClick);
    document.addEventListener('keydown', handleKey);
    return () => {
      document.removeEventListener('mousedown', handleClick);
      document.removeEventListener('keydown', handleKey);
    };
  }, [open]);

  const handleLogout = useCallback(async () => {
    setLoggingOut(true);
    try {
      await apiFetch('/auth/logout', { method: 'POST' }).catch(() => undefined);
    } finally {
      clearAuthSession();
      pushToast({ tone: 'success', title: t('account.loggedOut') });
      router.push('/auth/login');
      router.refresh();
    }
  }, [pushToast, router, t]);

  const displayName =
    me?.profile?.displayName || me?.name || me?.email || t('account.you');
  const email = me?.email ?? '';
  const isAdmin = (role ?? me?.role) === 'ADMIN';
  const avatarSrc = me?.avatar
    ? `${me.avatar}${me.avatar.includes('?') ? '&' : '?'}v=${refreshNonce}`
    : null;

  return (
    <>
      <div className="relative" ref={containerRef}>
        <button
          aria-expanded={open}
          aria-haspopup="menu"
          className={cn(
            'inline-flex h-10 items-center gap-2 rounded-lg border border-lilac bg-white px-2 pr-3 text-sm font-semibold text-ink transition',
            'hover:border-violet hover:bg-cloud/40',
            open && 'border-violet bg-cloud/40',
          )}
          onClick={() => setOpen((current) => !current)}
          type="button"
        >
          <AvatarMark
            avatarSrc={avatarSrc}
            email={email}
            name={displayName}
            size="sm"
          />
          <span className="hidden max-w-[140px] truncate text-left sm:inline-flex sm:flex-col sm:leading-tight">
            <span className="truncate text-[13px] font-bold text-ink">
              {displayName}
            </span>
            {isAdmin ? (
              <span className="truncate text-[10px] font-bold uppercase tracking-[0.14em] text-violet">
                Admin
              </span>
            ) : email ? (
              <span className="truncate text-[10px] font-semibold text-slate">
                {email}
              </span>
            ) : null}
          </span>
          <ChevronDown
            className={cn('h-4 w-4 text-slate transition', open && 'rotate-180')}
          />
        </button>

        {open ? (
          <div
            className="absolute right-0 top-full z-50 mt-2 w-72 overflow-hidden rounded-xl border border-lilac bg-white shadow-panel"
            role="menu"
          >
            <div className="border-b border-cloud bg-[image:var(--hero-bg)] px-4 py-3">
              <div className="flex items-center gap-3">
                <AvatarMark
                  avatarSrc={avatarSrc}
                  email={email}
                  name={displayName}
                  size="md"
                />
                <div className="flex-1 min-w-0">
                  <p className="truncate text-sm font-extrabold text-ink">
                    {displayName}
                  </p>
                  {email ? (
                    <p className="truncate text-xs font-semibold text-slate">
                      {email}
                    </p>
                  ) : null}
                </div>
                {isAdmin ? (
                  <span className="inline-flex items-center gap-1 rounded-full bg-violet/10 px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide text-violet">
                    <ShieldCheck className="h-3 w-3" />
                    {t('account.role.admin')}
                  </span>
                ) : (
                  <span className="inline-flex items-center gap-1 rounded-full bg-cloud px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate">
                    <UserIcon className="h-3 w-3" />
                    {t('account.role.user')}
                  </span>
                )}
              </div>
            </div>
            <div className="py-1">
              <MenuItem
                icon={UserCog}
                label={t('account.profile')}
                hint={t('account.profile.hint')}
                onClick={() => {
                  setOpen(false);
                  router.push('/dashboard/settings');
                }}
              />
              <MenuItem
                icon={History}
                label={t('account.sessions')}
                hint={t('account.sessions.hint')}
                onClick={() => {
                  setOpen(false);
                  setSessionsOpen(true);
                }}
              />
              {isAdmin ? (
                <MenuItem
                  icon={ShieldCheck}
                  label={t('account.adminConsole')}
                  hint={t('account.adminConsole.hint')}
                  onClick={() => {
                    setOpen(false);
                    router.push('/admin');
                  }}
                />
              ) : null}
              <div className="my-1 h-px bg-cloud" />
              {/* Language section — inline expander, no nested popups. */}
              <button
                aria-expanded={languageOpen}
                className="flex w-full items-start gap-3 px-4 py-2.5 text-left text-sm text-ink transition hover:bg-cloud/60"
                onClick={() => setLanguageOpen((current) => !current)}
                type="button"
              >
                <Globe className="mt-0.5 h-4 w-4 shrink-0 text-violet" />
                <span className="flex flex-1 flex-col leading-tight">
                  <span className="text-sm font-semibold">
                    {t('account.language')}
                  </span>
                  <span className="text-[11px] font-semibold text-slate">
                    {LOCALE_LABELS[locale]}
                  </span>
                </span>
                <span className="rounded-md border border-lilac bg-cloud/60 px-1.5 py-0.5 text-[10px] font-extrabold text-violet">
                  {LOCALE_SHORT[locale]}
                </span>
              </button>
              {languageOpen ? (
                <div className="bg-cloud/30 px-2 py-1.5">
                  {LOCALES.map((option) => (
                    <button
                      className={cn(
                        'flex w-full items-center justify-between gap-2 rounded-lg px-3 py-2 text-left text-sm font-semibold transition',
                        option === locale
                          ? 'bg-violet/10 text-violet'
                          : 'text-ink hover:bg-white',
                      )}
                      key={option}
                      onClick={() => {
                        setLocale(option as Locale);
                        setLanguageOpen(false);
                      }}
                      type="button"
                    >
                      <span>{LOCALE_LABELS[option as Locale]}</span>
                      {option === locale ? <Check className="h-4 w-4" /> : null}
                    </button>
                  ))}
                </div>
              ) : null}
              <div className="my-1 h-px bg-cloud" />
              <MenuItem
                danger
                icon={LogOut}
                label={loggingOut ? t('account.loggingOut') : t('account.logout')}
                hint={t('account.logout.hint')}
                onClick={() => {
                  if (!loggingOut) void handleLogout();
                }}
              />
            </div>
          </div>
        ) : null}
      </div>

      <DeviceSessionsModal
        open={sessionsOpen}
        onClose={() => setSessionsOpen(false)}
      />
    </>
  );
}

function AvatarMark({
  avatarSrc,
  name,
  email,
  size,
}: {
  avatarSrc?: string | null;
  name?: string | null;
  email?: string | null;
  size: 'sm' | 'md';
}) {
  const dimension =
    size === 'sm'
      ? 'h-7 w-7 rounded-md text-[11px]'
      : 'h-10 w-10 rounded-lg text-sm';

  return (
    <span
      aria-hidden="true"
      className={cn(
        'flex shrink-0 items-center justify-center overflow-hidden bg-violet font-extrabold tracking-wide text-white',
        dimension,
      )}
    >
      {avatarSrc ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          alt=""
          className="h-full w-full object-cover"
          src={avatarSrc}
        />
      ) : (
        initialsOf(name, email)
      )}
    </span>
  );
}

function MenuItem({
  icon: Icon,
  label,
  hint,
  onClick,
  danger,
}: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  hint?: string;
  onClick: () => void;
  danger?: boolean;
}) {
  return (
    <button
      className={cn(
        'flex w-full items-start gap-3 px-4 py-2.5 text-left text-sm transition',
        danger
          ? 'text-coral hover:bg-coral/10'
          : 'text-ink hover:bg-cloud/60',
      )}
      onClick={onClick}
      role="menuitem"
      type="button"
    >
      <Icon className={cn('mt-0.5 h-4 w-4 shrink-0', danger ? 'text-coral' : 'text-violet')} />
      <span className="flex flex-1 flex-col leading-tight">
        <span className="text-sm font-semibold">{label}</span>
        {hint ? (
          <span className={cn('text-[11px] font-semibold', danger ? 'text-coral/70' : 'text-slate')}>
            {hint}
          </span>
        ) : null}
      </span>
    </button>
  );
}
