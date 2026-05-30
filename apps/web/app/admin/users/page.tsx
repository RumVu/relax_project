'use client';

import { FormEvent, useMemo, useState } from 'react';
import {
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
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type AdminUserRow = {
  id: string;
  name: string;
  email: string;
  role: string;
  emailVerified: boolean;
  status: string;
  plan: string;
  streak: number;
  lastLogin: string;
};

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
        <MetricCard icon={Users} label="Tổng user" value={users.length} />
        <MetricCard
          icon={ShieldCheck}
          label="Đang hoạt động"
          tone="mint"
          value={users.filter((user) => user.status === 'ACTIVE').length}
        />
        <MetricCard
          icon={ShieldX}
          label="Đã khoá"
          tone="coral"
          value={users.filter((user) => user.status !== 'ACTIVE').length}
        />
        <MetricCard
          icon={UserCog}
          label="Admin"
          note="có quyền quản trị"
          tone="lilac"
          value={users.filter((user) => user.role === 'ADMIN').length}
        />
      </div>

      <Card>
        <SectionTitle
          title="Điều khiển user"
          copy="Khóa/mở tài khoản, đổi role và revoke toàn bộ session của từng người ngay tại đây."
          action={
            <div className="flex flex-wrap gap-2">
              <Button onClick={() => setCreateOpen(true)}>
                <UserPlus className="h-4 w-4" />
                Tạo user
              </Button>
              <div className="flex h-10 items-center gap-2 rounded-lg border border-lilac bg-white px-3 text-sm">
                <Search className="h-4 w-4 text-violet" />
                <input
                  className="w-40 bg-transparent outline-none"
                  onChange={(event) => setQuery(event.target.value)}
                  placeholder="Tìm user"
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
                <option value="ALL">Tất cả role</option>
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
                <option value="ALL">Tất cả trạng thái</option>
                <option value="ACTIVE">Đang mở</option>
                <option value="INACTIVE">Đã khoá</option>
              </select>
              <select
                className="h-10 rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink"
                onChange={(event) =>
                  setFilterVerified(event.target.value as 'ALL' | 'VERIFIED' | 'UNVERIFIED')
                }
                value={filterVerified}
              >
                <option value="ALL">Tất cả xác thực</option>
                <option value="VERIFIED">Đã xác thực</option>
                <option value="UNVERIFIED">Chưa xác thực</option>
              </select>
            </div>
          }
        />
        <div className="mt-5">
          <DataTable
            columns={[
              'Tên',
              'Email',
              'Role',
              'Trạng thái',
              'Plan',
              'Xác thực',
              'Streak',
              'Last login',
              'Hành động',
            ]}
            rows={filteredUsers.map((user) => [
              user.name,
              user.email,
              user.role,
              user.status === 'ACTIVE' ? 'Đang mở' : 'Đã khoá',
              user.plan,
              user.emailVerified ? 'Verified' : 'Chưa verify',
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
                        title: `Đã đổi role sang ${nextRole}`,
                        message: `${user.email} đã được cập nhật quyền.`,
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: 'Không đổi được role',
                      });
                    } finally {
                      setBusyKey(null);
                    }
                  }}
                  variant="secondary"
                >
                  {user.role === 'ADMIN' ? 'Hạ xuống USER' : 'Nâng lên ADMIN'}
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
                        title: nextActive ? 'Đã mở user' : 'Đã khoá user',
                        message: `${user.email} vừa được cập nhật trạng thái.`,
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: 'Không đổi được trạng thái user',
                      });
                    } finally {
                      setBusyKey(null);
                    }
                  }}
                >
                  {user.status === 'ACTIVE' ? 'Khoá user' : 'Mở user'}
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
                        title: 'Đã revoke session',
                        message: `Toàn bộ session của ${user.email} đã bị thu hồi.`,
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: 'Không revoke được session',
                      });
                    } finally {
                      setBusyKey(null);
                    }
                  }}
                  variant="ghost"
                >
                  Revoke session
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
              title: 'Đã tạo user mới',
              message: 'User mới sẽ xuất hiện trong bảng điều khiển.',
            });
          }}
        />
      ) : null}
    </DashboardShell>
  );
}

function CreateUserModal({
  onClose,
  onCreated,
}: {
  onClose: () => void;
  onCreated: () => void;
}) {
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
          : 'Có thể email đã tồn tại hoặc password chưa đủ mạnh.';
      pushToast({ tone: 'error', title: 'Không tạo được user', message });
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
            <h2 className="mt-2 text-2xl font-extrabold">Tạo user mới</h2>
            <p className="mt-1 text-sm font-medium text-[var(--app-muted)]">
              User được tạo ở đây sẽ login bằng email + password ngay (LOCAL provider).
            </p>
          </div>
          <button
            aria-label="Đóng tạo user"
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
                Tên hiển thị
              </span>
              <input
                className="h-11 rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 text-sm font-semibold"
                onChange={(e) =>
                  setForm((f) => ({ ...f, name: e.target.value }))
                }
                placeholder="Tuỳ chọn"
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
              minLength={8}
              onChange={(e) =>
                setForm((f) => ({ ...f, password: e.target.value }))
              }
              placeholder="≥ 8 ký tự, có chữ + số + ký tự đặc biệt"
              required
              type="text"
              value={form.password}
            />
            <span className="text-[11px] text-[var(--app-muted)]">
              Tip: bấm <code>Tạo password</code> để sinh password ngẫu nhiên.
            </span>
            <button
              className="self-start text-xs font-bold text-violet hover:underline"
              onClick={() =>
                setForm((f) => ({ ...f, password: randomPassword() }))
              }
              type="button"
            >
              Tạo password ngẫu nhiên
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
                <p className="text-sm font-bold">Coi như đã verify email</p>
                <p className="text-xs text-[var(--app-muted)]">
                  Bỏ qua bước xác minh hộp thư.
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
                <p className="text-sm font-bold">Active ngay</p>
                <p className="text-xs text-[var(--app-muted)]">
                  Bỏ tick = user bị khoá ngay từ đầu.
                </p>
              </div>
            </label>
          </div>
        </div>

        <div className="mt-5 flex flex-wrap justify-end gap-3">
          <Button onClick={onClose} type="button" variant="secondary">
            Huỷ
          </Button>
          <Button disabled={busy || !form.email || !form.password} type="submit">
            <UserPlus className="h-4 w-4" />
            {busy ? 'Đang tạo' : 'Tạo user'}
          </Button>
        </div>
      </form>
    </div>
  );
}

function randomPassword(): string {
  // 12-char password — at least 1 upper, 1 lower, 1 digit, 1 symbol. Good
  // enough to satisfy the backend's StrongPassword validator.
  const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  const lower = 'abcdefghijkmnpqrstuvwxyz';
  const digit = '23456789';
  const symbol = '!@#$%^&*()_+-=';
  const pick = (set: string) => set[Math.floor(Math.random() * set.length)];
  const base = [pick(upper), pick(lower), pick(digit), pick(symbol)];
  while (base.length < 12) {
    base.push(pick(upper + lower + digit + symbol));
  }
  return base.sort(() => Math.random() - 0.5).join('');
}
