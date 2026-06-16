'use client';

import { FormEvent, useEffect, useMemo, useState } from 'react';
import {
  CreditCard,
  Search,
  ShieldCheck,
  ShieldX,
  UserCog,
  UserPlus,
  Users,
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
import { apiFetch } from '@/lib/api';
import { useAdminDashboardData } from '@/lib/live-dashboard';
import { isStrongPassword } from '@/lib/password';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import type { AdminUserRow } from './users-types';
import { randomPassword } from './users-utils';

export default function AdminUsersPage() {
  const { t } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const [refreshKey, setRefreshKey] = useState(0);
  const [query, setQuery] = useState('');
  const [filterRole, setFilterRole] = useState<'ALL' | 'ADMIN' | 'USER'>('ALL');
  const [filterStatus, setFilterStatus] = useState<'ALL' | 'ACTIVE' | 'INACTIVE'>('ALL');
  const [filterVerified, setFilterVerified] = useState<'ALL' | 'VERIFIED' | 'UNVERIFIED'>('ALL');
  const [busyKey, setBusyKey] = useState<string | null>(null);
  const [createOpen, setCreateOpen] = useState(false);
  const [planModalUser, setPlanModalUser] = useState<AdminUserRow | null>(null);
  // Cache the tier catalogue once so the change-plan modal can list options
  // without a round-trip every time it opens.
  const [tierCatalog, setTierCatalog] = useState<
    Array<{ name: string; title: string | null; price: number; currency: string; isActive: boolean }>
  >([]);
  useEffect(() => {
    apiFetch<typeof tierCatalog>('/admin/billing/tiers')
      .then(setTierCatalog)
      .catch(() => setTierCatalog([]));
  }, []);
  const users = useAdminDashboardData({
    refreshKey,
    usersQuery: {
      limit: 50,
      search: query.trim() || undefined,
      role: filterRole === 'ALL' ? undefined : filterRole,
      status: filterStatus === 'ALL' ? undefined : filterStatus,
      emailVerified:
        filterVerified === 'ALL' ? undefined : filterVerified === 'VERIFIED',
    },
  }).users as AdminUserRow[];

  const filteredUsers = useMemo(
    () => users,
    [users],
  );

  return (
    <DashboardShell admin eyebrow={t('admin.eyebrow')} title={t('admin.users.title')}>
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard icon={Users} label={t('admin.users.metric.total')} value={users.length} />
        <MetricCard
          icon={ShieldCheck}
          label={t('admin.users.filter.active')}
          tone="mint"
          value={users.filter((user) => user.status === 'ACTIVE').length}
        />
        <MetricCard
          icon={ShieldX}
          label={t('admin.users.filter.inactive')}
          tone="coral"
          value={users.filter((user) => user.status !== 'ACTIVE').length}
        />
        <MetricCard
          icon={UserCog}
          label="Admin"
          note={t('admin.users.metric.adminNote')}
          tone="lilac"
          value={users.filter((user) => user.role === 'ADMIN').length}
        />
      </div>

      <Card>
        <SectionTitle
          title={t('admin.users.control.title')}
          copy={t('admin.users.control.copy')}
          action={
            <div className="flex flex-wrap gap-2">
              <Button onClick={() => setCreateOpen(true)}>
                <UserPlus className="h-4 w-4" />
                {t('admin.users.create.submit')}
              </Button>
              <div className="flex h-10 items-center gap-2 rounded-lg border border-lilac bg-white px-3 text-sm">
                <Search className="h-4 w-4 text-violet" />
                <input
                  className="w-40 bg-transparent outline-none"
                  onChange={(event) => setQuery(event.target.value)}
                  placeholder={t('admin.users.searchPlaceholder')}
                  value={query}
                />
              </div>
              <select
                className="h-10 rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink"
                onChange={(event) =>
                  setFilterRole(event.target.value as 'ALL' | 'ADMIN' | 'USER')
                }
                value={filterRole}
              >
                <option value="ALL">{t('admin.users.filter.allRoles')}</option>
                <option value="ADMIN">Admin</option>
                <option value="USER">User</option>
              </select>
              <select
                className="h-10 rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink"
                onChange={(event) =>
                  setFilterStatus(event.target.value as 'ALL' | 'ACTIVE' | 'INACTIVE')
                }
                value={filterStatus}
              >
                <option value="ALL">{t('admin.users.filter.allStatuses')}</option>
                <option value="ACTIVE">{t('admin.users.filter.active')}</option>
                <option value="INACTIVE">{t('admin.users.filter.inactive')}</option>
              </select>
              <select
                className="h-10 rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink"
                onChange={(event) =>
                  setFilterVerified(event.target.value as 'ALL' | 'VERIFIED' | 'UNVERIFIED')
                }
                value={filterVerified}
              >
                <option value="ALL">{t('admin.users.filter.allVerified')}</option>
                <option value="VERIFIED">{t('admin.users.filter.verifiedYes')}</option>
                <option value="UNVERIFIED">{t('admin.users.filter.verifiedNo')}</option>
              </select>
            </div>
          }
        />
        <div className="mt-5">
          <DataTable
            columns={[
              t('admin.users.col.name'),
              t('admin.users.col.email'),
              t('admin.table.role'),
              t('admin.users.col.status'),
              t('admin.users.col.plan'),
              t('admin.users.col.verified'),
              t('admin.users.col.streak'),
              t('admin.users.col.lastLogin'),
              t('admin.table.actions'),
            ]}
            rows={filteredUsers.map((user) => [
              user.name,
              user.email,
              user.role,
              user.status === 'ACTIVE' ? t('admin.users.filter.active') : t('admin.users.filter.inactive'),
              user.plan,
              user.emailVerified ? t('admin.users.filter.verifiedYes') : t('admin.users.filter.verifiedNo'),
              user.streak,
              user.lastLogin,
              <div className="flex flex-wrap gap-2" key={user.id}>
                <Button
                  className="h-8 px-3 text-xs"
                  disabled={busyKey === `${user.id}:role`}
                  onClick={async () => {
                    setBusyKey(`${user.id}:role`);
                    try {
                      const nextRole = user.role === 'ADMIN' ? 'USER' : 'ADMIN';
                      await apiFetch(`/users/${user.id}`, {
                        method: 'PATCH',
                        body: JSON.stringify({ role: nextRole }),
                      });
                      setRefreshKey((current) => current + 1);
                      pushToast({
                        tone: 'success',
                        title: t('admin.users.toast.roleChanged', { role: nextRole }),
                        message: t('admin.users.toast.userUpdated', { email: user.email }),
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: t('admin.users.toast.roleFailed'),
                      });
                    } finally {
                      setBusyKey(null);
                    }
                  }}
                  variant="secondary"
                >
                  {user.role === 'ADMIN' ? t('admin.users.action.demote') : t('admin.users.action.promote')}
                </Button>
                <Button
                  className="h-8 px-3 text-xs"
                  disabled={busyKey === `${user.id}:status`}
                  onClick={async () => {
                    setBusyKey(`${user.id}:status`);
                    try {
                      const nextActive = user.status !== 'ACTIVE';
                      await apiFetch(`/users/${user.id}`, {
                        method: 'PATCH',
                        body: JSON.stringify({ isActive: nextActive }),
                      });
                      setRefreshKey((current) => current + 1);
                      pushToast({
                        tone: 'success',
                        title: nextActive ? t('admin.users.toast.activated') : t('admin.users.toast.deactivated'),
                        message: t('admin.users.toast.statusUpdated', { email: user.email }),
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: t('admin.users.toast.statusFailed'),
                      });
                    } finally {
                      setBusyKey(null);
                    }
                  }}
                >
                  {user.status === 'ACTIVE' ? t('admin.users.toggle.deactivate') : t('admin.users.toggle.activate')}
                </Button>
                <Button
                  className="h-8 px-3 text-xs"
                  disabled={busyKey === `${user.id}:sessions`}
                  onClick={async () => {
                    setBusyKey(`${user.id}:sessions`);
                    try {
                      await apiFetch(`/sessions/user/${user.id}`, {
                        method: 'DELETE',
                      });
                      pushToast({
                        tone: 'success',
                        title: t('admin.users.toast.sessionsRevoked'),
                        message: t('admin.users.toast.sessionsRevokedMessage', { email: user.email }),
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: t('admin.users.toast.sessionsRevokeFailed'),
                      });
                    } finally {
                      setBusyKey(null);
                    }
                  }}
                  variant="ghost"
                >
                  {t('admin.users.action.revokeSessions')}
                </Button>
                <Button
                  className="h-8 px-3 text-xs"
                  onClick={() => setPlanModalUser(user)}
                  variant="ghost"
                >
                  <CreditCard className="h-3.5 w-3.5" />
                  {t('admin.users.action.changePlan')}
                </Button>
              </div>,
            ])}
          />
        </div>
      </Card>
      {createOpen ? (
        <CreateUserModal
          onClose={() => setCreateOpen(false)}
          onCreated={() => {
            setCreateOpen(false);
            setRefreshKey((current) => current + 1);
            pushToast({
              tone: 'success',
              title: t('admin.users.create.success'),
              message: t('admin.users.create.successMessage'),
            });
          }}
        />
      ) : null}
      {planModalUser ? (
        <ChangePlanModal
          onChanged={() => {
            setPlanModalUser(null);
            setRefreshKey((current) => current + 1);
          }}
          onClose={() => setPlanModalUser(null)}
          tiers={tierCatalog}
          user={planModalUser}
        />
      ) : null}
    </DashboardShell>
  );
}

function ChangePlanModal({
  onChanged,
  onClose,
  tiers,
  user,
}: {
  onChanged: () => void;
  onClose: () => void;
  tiers: Array<{ name: string; title: string | null; price: number; currency: string; isActive: boolean }>;
  user: AdminUserRow;
}) {
  const { t } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  // Default to the user's current plan so it's clear what's selected; if their
  // current plan was deactivated, fall back to the first active tier.
  const initial =
    tiers.find((tier) => tier.name === user.plan?.split(' ·')[0]) ??
    tiers.find((tier) => tier.isActive) ??
    tiers[0];
  const [selected, setSelected] = useState(initial?.name ?? 'FREE');
  const [busy, setBusy] = useState(false);

  return (
    <div
      aria-modal="true"
      className="fixed inset-0 z-50 flex items-center justify-center bg-ink/70 p-4 backdrop-blur"
      onClick={onClose}
      role="dialog"
    >
      <Card className="w-full max-w-md">
        <div onClick={(e) => e.stopPropagation()}>
          <div className="flex items-start justify-between gap-3">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-violet">
                {t('admin.users.changePlan.eyebrow')}
              </p>
              <h3 className="mt-1 text-lg font-extrabold text-[var(--app-text)]">
                {user.name}
              </h3>
              <p className="text-xs text-[var(--app-muted,#94a3b8)]">{user.email}</p>
            </div>
            <button
              aria-label={t('common.close')}
              className="rounded-full p-1 text-slate transition hover:bg-white/10 hover:text-coral"
              onClick={onClose}
              type="button"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          <p className="mt-4 text-xs text-[var(--app-muted,#94a3b8)]">
            {t('admin.users.changePlan.hint')}
          </p>

          <div className="mt-4 space-y-2">
            {tiers.length === 0 ? (
              <p className="text-sm text-slate">{t('common.loading')}</p>
            ) : (
              tiers
                .filter((tier) => tier.isActive || tier.name === selected)
                .map((tier) => (
                  <label
                    className={`flex cursor-pointer items-center justify-between rounded-lg border p-3 transition ${
                      selected === tier.name
                        ? 'border-violet bg-violet/10'
                        : 'border-[var(--field-border)] bg-[var(--field-bg)] hover:border-violet/40'
                    }`}
                    key={tier.name}
                  >
                    <div className="flex items-center gap-3">
                      <input
                        checked={selected === tier.name}
                        className="h-4 w-4"
                        name="plan"
                        onChange={() => setSelected(tier.name)}
                        type="radio"
                        value={tier.name}
                      />
                      <div>
                        <p className="text-sm font-bold text-[var(--app-text)]">
                          {tier.title || tier.name}
                        </p>
                        <p className="text-xs text-slate">{tier.name}</p>
                      </div>
                    </div>
                    <p className="text-sm font-bold text-[var(--app-text)]">
                      {new Intl.NumberFormat('vi-VN').format(tier.price)}{' '}
                      <span className="text-xs font-medium text-slate">
                        {tier.currency}
                      </span>
                    </p>
                  </label>
                ))
            )}
          </div>

          <div className="mt-5 flex justify-end gap-2">
            <Button disabled={busy} onClick={onClose} variant="ghost">
              {t('common.cancel')}
            </Button>
            <Button
              disabled={busy || !selected}
              onClick={async () => {
                setBusy(true);
                try {
                  await apiFetch(`/admin/users/${user.id}/plan`, {
                    method: 'POST',
                    body: JSON.stringify({ planName: selected }),
                  });
                  pushToast({
                    tone: 'success',
                    title: t('admin.users.changePlan.successTitle'),
                    message: t('admin.users.changePlan.successMessage', {
                      email: user.email,
                      plan: selected,
                    }),
                  });
                  onChanged();
                } catch (err) {
                  const message =
                    err instanceof Error ? err.message : String(err);
                  pushToast({
                    tone: 'error',
                    title: t('admin.users.changePlan.failedTitle'),
                    message,
                  });
                } finally {
                  setBusy(false);
                }
              }}
            >
              {busy ? t('common.loading') : t('admin.users.changePlan.confirm')}
            </Button>
          </div>
        </div>
      </Card>
    </div>
  );
}

function CreateUserModal({
  onClose,
  onCreated,
}: {
  onClose: () => void;
  onCreated: () => void;
}) {
  const { t } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const [busy, setBusy] = useState(false);
  const [form, setForm] = useState({
    email: '',
    name: '',
    password: '',
    role: 'USER' as 'USER' | 'ADMIN',
    emailVerified: true,
    isActive: true,
  });

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!form.email || !form.password) return;
    if (!isStrongPassword(form.password)) {
      pushToast({
        tone: 'error',
        title: t('admin.users.create.failed'),
        message: t('admin.users.create.passwordRequirement'),
      });
      return;
    }
    setBusy(true);
    try {
      await apiFetch('/users', {
        method: 'POST',
        body: JSON.stringify({
          email: form.email.trim().toLowerCase(),
          name: form.name.trim() || undefined,
          password: form.password,
          role: form.role,
          emailVerified: form.emailVerified,
          isActive: form.isActive,
        }),
      });
      onCreated();
    } catch (error) {
      const message =
        error && typeof error === 'object' && 'message' in error
          ? String((error as { message?: string }).message)
          : t('admin.users.create.errorHint');
      pushToast({ tone: 'error', title: t('admin.users.create.failed'), message });
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-ink/55 p-4 backdrop-blur-sm sm:items-center">
      <form
        className="w-full max-w-lg rounded-2xl border border-[var(--panel-border)] bg-[var(--panel-strong)] p-5 text-[var(--app-text)] shadow-2xl"
        onSubmit={submit}
      >
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.18em] text-violet">
              Admin
            </p>
            <h2 className="mt-2 text-2xl font-extrabold">{t('admin.users.create.title')}</h2>
            <p className="mt-1 text-sm font-medium text-[var(--app-muted)]">
              {t('admin.users.create.copy')}
            </p>
          </div>
          <button
            aria-label={t('admin.users.create.close')}
            className="rounded-full border border-[var(--field-border)] p-2 transition hover:bg-violet/10"
            onClick={onClose}
            type="button"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="mt-5 grid gap-4">
          <label className="grid gap-2">
            <span className="text-xs font-semibold uppercase tracking-[0.12em] text-[var(--app-muted)]">
              Email <span className="text-coral">*</span>
            </span>
            <input
              autoComplete="off"
              className="h-11 rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 text-sm font-semibold"
              onChange={(e) =>
                setForm((f) => ({ ...f, email: e.target.value }))
              }
              placeholder="user@example.com"
              required
              type="email"
              value={form.email}
            />
          </label>

          <div className="grid gap-3 sm:grid-cols-2">
            <label className="grid gap-2">
              <span className="text-xs font-semibold uppercase tracking-[0.12em] text-[var(--app-muted)]">
                {t('admin.users.create.name')}
              </span>
              <input
                className="h-11 rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 text-sm font-semibold"
                onChange={(e) =>
                  setForm((f) => ({ ...f, name: e.target.value }))
                }
                placeholder={t('admin.users.create.optional')}
                value={form.name}
              />
            </label>
            <label className="grid gap-2">
              <span className="text-xs font-semibold uppercase tracking-[0.12em] text-[var(--app-muted)]">
                Role
              </span>
              <select
                className="h-11 rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 text-sm font-semibold"
                onChange={(e) =>
                  setForm((f) => ({
                    ...f,
                    role: e.target.value as 'USER' | 'ADMIN',
                  }))
                }
                value={form.role}
              >
                <option value="USER">USER</option>
                <option value="ADMIN">ADMIN</option>
              </select>
            </label>
          </div>

          <label className="grid gap-2">
            <span className="text-xs font-semibold uppercase tracking-[0.12em] text-[var(--app-muted)]">
              Password <span className="text-coral">*</span>
            </span>
            <input
              autoComplete="off"
              className="h-11 rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 text-sm font-semibold"
              maxLength={72}
              minLength={10}
              onChange={(e) =>
                setForm((f) => ({ ...f, password: e.target.value }))
              }
              placeholder={t('admin.users.create.passwordPlaceholder')}
              required
              type="text"
              value={form.password}
            />
            <span className="text-[11px] text-[var(--app-muted)]">
              {t('admin.users.create.passwordTip.before')} <code>{t('admin.users.create.generatePassword')}</code> {t('admin.users.create.passwordTip.after')}
            </span>
            <button
              className="self-start text-xs font-bold text-violet hover:underline"
              onClick={() =>
                setForm((f) => ({ ...f, password: randomPassword() }))
              }
              type="button"
            >
              {t('admin.users.create.generatePassword')}
            </button>
          </label>

          <div className="grid gap-3 sm:grid-cols-2">
            <label className="flex cursor-pointer items-center gap-3 rounded-lg border border-[var(--field-border)] p-3">
              <input
                checked={form.emailVerified}
                onChange={(e) =>
                  setForm((f) => ({ ...f, emailVerified: e.target.checked }))
                }
                type="checkbox"
              />
              <div>
                <p className="text-sm font-bold">{t('admin.users.create.verifyNow')}</p>
                <p className="text-xs text-[var(--app-muted)]">
                  {t('admin.users.create.verifyNowHint')}
                </p>
              </div>
            </label>
            <label className="flex cursor-pointer items-center gap-3 rounded-lg border border-[var(--field-border)] p-3">
              <input
                checked={form.isActive}
                onChange={(e) =>
                  setForm((f) => ({ ...f, isActive: e.target.checked }))
                }
                type="checkbox"
              />
              <div>
                <p className="text-sm font-bold">{t('admin.users.create.activeNow')}</p>
                <p className="text-xs text-[var(--app-muted)]">
                  {t('admin.users.create.activeNowHint')}
                </p>
              </div>
            </label>
          </div>
        </div>

        <div className="mt-5 flex flex-wrap justify-end gap-3">
          <Button onClick={onClose} type="button" variant="secondary">
            {t('common.cancel')}
          </Button>
          <Button
            disabled={busy || !form.email || !isStrongPassword(form.password)}
            type="submit"
          >
            <UserPlus className="h-4 w-4" />
            {busy ? t('admin.users.create.creating') : t('admin.users.create.submit')}
          </Button>
        </div>
      </form>
    </div>
  );
}
