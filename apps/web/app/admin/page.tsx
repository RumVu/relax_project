'use client';

import Link from 'next/link';
import {
  Activity,
  Bell,
  CreditCard,
  Database,
  FileClock,
  Search,
  ServerCog,
  Users,
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

        <Card>
          <SectionTitle title="Sức khoẻ hạ tầng" copy="Theo dõi các dịch vụ lõi phục vụ dashboard và realtime." action={<ServerCog className="h-5 w-5 text-violet" />} />
          <div className="mt-5 space-y-3">
            {data.infra.map((service) => (
              <div
                className="flex items-center justify-between rounded-lg border border-lilac/70 bg-white/75 p-4"
                key={service.service}
              >
                <span className="flex items-center gap-3 text-sm font-bold text-ink">
                  <Database className="h-4 w-4 text-violet" />
                  {service.service}
                </span>
                <span className="text-right text-xs font-bold text-mint">
                  {service.status}
                  <br />
                  {service.latency}
                </span>
              </div>
            ))}
          </div>
        </Card>
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
      <div className="mt-5 rounded-2xl border border-dashed border-lilac bg-white/70 p-8 text-sm font-semibold text-slate">
        Chưa có dữ liệu thật để vẽ biểu đồ.
      </div>
    </Card>
  );
}
