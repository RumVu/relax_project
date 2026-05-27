'use client';

import { useMemo, useState } from 'react';
import { Search, ShieldCheck, ShieldX, UserCog, Users } from 'lucide-react';
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
  const pushToast = useUiStore((state) => state.pushToast);
  const [refreshKey, setRefreshKey] = useState(0);
  const [query, setQuery] = useState('');
  const [filterRole, setFilterRole] = useState<'ALL' | 'ADMIN' | 'USER'>('ALL');
  const [filterStatus, setFilterStatus] = useState<'ALL' | 'ACTIVE' | 'INACTIVE'>('ALL');
  const [filterVerified, setFilterVerified] = useState<'ALL' | 'VERIFIED' | 'UNVERIFIED'>('ALL');
  const [busyKey, setBusyKey] = useState<string | null>(null);
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
    <DashboardShell admin eyebrow="Moderation" title="Users">
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
    </DashboardShell>
  );
}
