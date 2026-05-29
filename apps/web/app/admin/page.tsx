'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import {
  Activity,
  Bell,
  CheckCircle2,
  CreditCard,
  Database,
  FileClock,
  RefreshCcw,
  Search,
  ServerCog,
  Users,
  XCircle,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  AdminGrowthChart,
  DataTable,
  DonutChart,
  MetricCard,
  SectionTitle,
} from '@/components/dashboard/dashboard-ui';
import { DashboardFilterBar, useDashboardFilters } from '@/components/dashboard/dashboard-filters';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useAdminDashboardData } from '@/lib/live-dashboard';

const metricIcons = [Activity, Users, Users, CreditCard, Activity, Bell];
const catalogLinks = [
  { area: 'Quotes', href: '/admin/quotes' },
  { area: 'Sounds', href: '/admin/sounds' },
  { area: 'Exercises', href: '/admin/exercises' },
  { area: 'Themes', href: '/admin/themes' },
  { area: 'Onboarding', href: '/admin/onboarding' },
  { area: 'Companion Assets', href: '/admin/companion-assets' },
  { area: 'Companion Messages', href: '/admin/companion-messages' },
];

export default function AdminPage() {
  const adminFilters = useDashboardFilters('/admin/analytics/overview', 'overview');
  const data = useAdminDashboardData({
    overviewQuery: adminFilters.query,
  });

  return (
    <DashboardShell admin eyebrow="Operations" title="Admin dashboard">
      <DashboardFilterBar {...adminFilters} title="Bộ lọc admin aggregate" />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-6">
        {data.metrics.map((metric, index) => {
          const Icon = metricIcons[index] ?? Activity;

          return (
            <MetricCard
              icon={Icon}
              key={metric.label}
              label={metric.label}
              note={metric.delta}
              tone={index % 2 === 0 ? 'violet' : 'mint'}
              value={metric.value}
            />
          );
        })}
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.2fr)_minmax(340px,0.8fr)]">
        {data.userGrowth.length > 0 ? (
          <AdminGrowthChart data={data.userGrowth} />
        ) : (
          <EmptyAdminPanel
            copy="Chưa có dữ liệu aggregate từ /admin/analytics/overview."
            title="DAU / user mới / doanh thu"
          />
        )}
        {data.contentEngagement.length > 0 ? (
          <DonutChart data={data.contentEngagement} />
        ) : (
          <EmptyAdminPanel
            copy="Chưa có dữ liệu engagement từ backend."
            title="Engagement nội dung"
          />
        )}
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1fr)_420px]">
        <Card>
          <SectionTitle title="Quản lý user" copy="Các tài khoản đang hoạt động và mức gắn bó gần đây." />
          <div className="mt-5">
            <DataTable
              columns={['Name', 'Email', 'Status', 'Plan', 'Streak', 'Last login']}
              rows={data.users.map((user) => [
                user.name,
                user.email,
                user.status,
                user.plan,
                user.streak,
                user.lastLogin,
              ])}
            />
          </div>
        </Card>

        <InfraHealthCard />
      </div>

      <Card>
        <SectionTitle
          title="Quản lý nội dung"
          copy="Số lượng publish/draft lấy trực tiếp từ /admin/analytics/overview.content."
          action={
            <div className="flex flex-wrap gap-2">
              <Link href="/admin/search">
                <Button className="h-8 px-3 text-xs" variant="secondary">
                  <Search className="h-4 w-4" />
                  Global search
                </Button>
              </Link>
              <Link href="/admin/logs">
                <Button className="h-8 px-3 text-xs" variant="secondary">
                  <FileClock className="h-4 w-4" />
                  Audit logs
                </Button>
              </Link>
            </div>
          }
        />
        <div className="mt-5">
          <DataTable
            columns={['Khu vực', 'Endpoint', 'Live', 'Draft', 'Hành động']}
            rows={(data.content.length > 0 ? data.content : catalogLinks).map((item) => {
              const href =
                catalogLinks.find((link) => link.area === item.area)?.href ?? '/admin';

              return [
                item.area,
                'endpoint' in item ? item.endpoint : '-',
                'live' in item ? item.live : 0,
                'drafts' in item ? item.drafts : 0,
                <Link href={href} key={href}>
                  <Button className="h-8 px-3 text-xs" variant="secondary">
                    Mở quản lý
                  </Button>
                </Link>,
              ];
            })}
          />
        </div>
      </Card>
    </DashboardShell>
  );
}

function EmptyAdminPanel({ title, copy }: { title: string; copy: string }) {
  return (
    <Card className="min-h-[390px]">
      <SectionTitle title={title} copy={copy} />
      <div className="mt-5 rounded-2xl border border-dashed border-[var(--field-border,theme(colors.lilac))] bg-[var(--panel-bg)] p-8 text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
        Chưa có dữ liệu thật để vẽ biểu đồ.
      </div>
    </Card>
  );
}

type InfraHealth = {
  service: string;
  status: 'up' | 'down' | 'unknown';
  latencyMs: number | null;
  detail?: string;
  endpoint: string;
};

function InfraHealthCard() {
  const [items, setItems] = useState<InfraHealth[]>([]);
  const [loading, setLoading] = useState(false);

  const probes: Array<{ service: string; endpoint: string }> = [
    { service: 'API server', endpoint: '/health' },
    { service: 'Redis cache', endpoint: '/redis/health' },
    { service: 'BullMQ queues', endpoint: '/queues/health' },
    { service: 'Realtime (Socket.IO)', endpoint: '/realtime/health' },
  ];

  async function refresh() {
    setLoading(true);
    const next: InfraHealth[] = await Promise.all(
      probes.map(async ({ service, endpoint }) => {
        const start = performance.now();
        try {
          const payload = (await apiFetch<Record<string, unknown>>(endpoint)) as {
            status?: string;
            uptimeSeconds?: number;
            adapter?: string;
            mode?: string;
          };
          const ms = Math.round(performance.now() - start);
          return {
            service,
            endpoint,
            status: (payload.status === 'ok' || payload.status === 'ready')
              ? 'up'
              : 'down',
            latencyMs: ms,
            detail:
              payload.adapter ||
              payload.mode ||
              (typeof payload.uptimeSeconds === 'number'
                ? `uptime ${Math.round(payload.uptimeSeconds)}s`
                : undefined),
          };
        } catch (error) {
          return {
            service,
            endpoint,
            status: 'down' as const,
            latencyMs: null,
            detail:
              error && typeof error === 'object' && 'message' in error
                ? String((error as { message?: string }).message)
                : 'không phản hồi',
          };
        }
      }),
    );
    setItems(next);
    setLoading(false);
  }

  useEffect(() => {
    void refresh();
    const t = window.setInterval(refresh, 15000); // refresh mỗi 15s
    return () => window.clearInterval(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const allUp = items.length > 0 && items.every((s) => s.status === 'up');

  return (
    <Card>
      <SectionTitle
        title="Sức khoẻ hạ tầng"
        copy="Theo dõi các dịch vụ lõi phục vụ dashboard và realtime. Tự refresh mỗi 15s."
        action={
          <div className="flex items-center gap-2">
            <span
              className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-bold ${
                allUp
                  ? 'bg-mint/15 text-mint'
                  : 'bg-coral/15 text-coral'
              }`}
            >
              {allUp ? 'Tất cả OK' : 'Có dịch vụ lỗi'}
            </span>
            <button
              aria-label="Refresh health"
              className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] text-[var(--app-text)] transition hover:bg-violet/10"
              disabled={loading}
              onClick={() => void refresh()}
              type="button"
            >
              <RefreshCcw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
            </button>
          </div>
        }
      />
      <div className="mt-5 space-y-2">
        {items.length === 0 && !loading ? (
          <p className="text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
            Đang chờ dữ liệu sức khoẻ...
          </p>
        ) : null}
        {items.map((service) => {
          const ok = service.status === 'up';
          return (
            <div
              className="flex items-center justify-between gap-3 rounded-lg border border-[var(--field-border)] bg-[var(--panel-bg)] p-3"
              key={service.service}
            >
              <div className="flex items-center gap-3 min-w-0">
                {ok ? (
                  <CheckCircle2 className="h-5 w-5 shrink-0 text-mint" />
                ) : (
                  <XCircle className="h-5 w-5 shrink-0 text-coral" />
                )}
                <div className="min-w-0">
                  <p className="truncate text-sm font-bold text-[var(--app-text)]">
                    {service.service}
                  </p>
                  <p className="truncate text-xs text-[var(--app-muted,theme(colors.slate))]">
                    {service.detail || service.endpoint}
                  </p>
                </div>
              </div>
              <div className="text-right">
                <p
                  className={`text-sm font-extrabold ${
                    ok ? 'text-mint' : 'text-coral'
                  }`}
                >
                  {ok ? 'UP' : 'DOWN'}
                </p>
                <p className="text-[11px] font-semibold text-[var(--app-muted,theme(colors.slate))]">
                  {service.latencyMs != null
                    ? `${service.latencyMs}ms`
                    : '—'}
                </p>
              </div>
            </div>
          );
        })}
      </div>
    </Card>
  );
}
