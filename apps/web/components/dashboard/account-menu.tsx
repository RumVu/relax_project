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
  LogOut,
  ShieldCheck,
  UserCog,
  History,
  User as UserIcon,
} from 'lucide-react';
import {
  apiFetch,
  clearAuthSession,
  getStoredRefreshToken,
  getStoredRole,
} from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { cn } from '@/lib/utils';
import { DeviceSessionsModal } from './device-sessions-modal';

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
  const containerRef = useRef<HTMLDivElement>(null);
  const [open, setOpen] = useState(false);
  const [sessionsOpen, setSessionsOpen] = useState(false);
  const [me, setMe] = useState<MeResponse | null>(null);
  const [loggingOut, setLoggingOut] = useState(false);
  const role = getStoredRole();

  // Fetch profile once on mount; harmless if /auth/me fails (we fall back
  // to email-only label using nothing — initials become "?").
  useEffect(() => {
    void apiFetch<MeResponse>('/auth/me')
      .then((data) => {
        setMe(data ?? null);
      })
      .catch(() => undefined);
  }, []);

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
    const refreshToken = getStoredRefreshToken();
    try {
      if (refreshToken) {
        await apiFetch('/auth/logout', {
          method: 'POST',
          body: JSON.stringify({ refreshToken }),
        }).catch(() => undefined); // server-side revoke best-effort
      }
    } finally {
      clearAuthSession();
      pushToast({ tone: 'success', title: 'Đã đăng xuất' });
      router.push('/auth/login');
      router.refresh();
    }
  }, [pushToast, router]);

  const displayName = me?.profile?.displayName || me?.name || me?.email || 'Bạn';
  const email = me?.email ?? '';
  const isAdmin = (role ?? me?.role) === 'ADMIN';

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
          <span
            aria-hidden="true"
            className="flex h-7 w-7 items-center justify-center rounded-md bg-violet text-[11px] font-extrabold tracking-wide text-white"
          >
            {initialsOf(displayName, email)}
          </span>
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
                <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-violet text-sm font-extrabold text-white">
                  {initialsOf(displayName, email)}
                </div>
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
                    Admin
                  </span>
                ) : (
                  <span className="inline-flex items-center gap-1 rounded-full bg-cloud px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide text-slate">
                    <UserIcon className="h-3 w-3" />
                    User
                  </span>
                )}
              </div>
            </div>
            <div className="py-1">
              <MenuItem
                icon={UserCog}
                label="Quản lý profile"
                hint="Tên, avatar, mật khẩu"
                onClick={() => {
                  setOpen(false);
                  router.push('/dashboard/settings');
                }}
              />
              <MenuItem
                icon={History}
                label="Lịch sử đăng nhập"
                hint="Thiết bị + IP + browser"
                onClick={() => {
                  setOpen(false);
                  setSessionsOpen(true);
                }}
              />
              {isAdmin ? (
                <MenuItem
                  icon={ShieldCheck}
                  label="Vào Admin Console"
                  hint="Quản trị hệ thống"
                  onClick={() => {
                    setOpen(false);
                    router.push('/admin');
                  }}
                />
              ) : null}
              <div className="my-1 h-px bg-cloud" />
              <MenuItem
                danger
                icon={LogOut}
                label={loggingOut ? 'Đang đăng xuất…' : 'Đăng xuất'}
                hint="Kết thúc phiên này"
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
