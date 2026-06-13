'use client';

import { useCallback, useEffect, useState } from 'react';
import { Activity, Clock, Database, HardDrive, RefreshCcw, Server, Users } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type HealthData = {
  status: string;
  uptime?: number;
  timestamp?: string;
  users?: { total: number; active: number; newToday: number };
  sessions?: { active: number };
  jobs?: { weeklyMoodStats?: { enabled: boolean; lastRun?: { processedUsers: number; failedUsers: number } | null } };
  database?: { connected: boolean };
};

export default function HealthDashboardPage() {
  const { t } = useTranslation();
  const pushToast = useUiStore((s) => s.pushToast);
  const [health, setHealth] = useState<HealthData | null>(null);
  const [overview, setOverview] = useState<Record<string, unknown> | null>(null);
  const [loading, setLoading] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [healthRes, overviewRes] = await Promise.all([
        apiFetch<HealthData>('/health').catch(() => null),
        apiFetch<Record<string, unknown>>('/admin/analytics/overview').catch(() => null),
      ]);
      setHealth(healthRes);
      setOverview(overviewRes);
    } catch {
      pushToast({ tone: 'error', title: 'Failed to load health data' });
    } finally {
      setLoading(false);
    }
  }, [pushToast]);

  useEffect(() => {
    void load();
  }, [load]);

  const uptimeFormatted = health?.uptime
    ? formatUptime(health.uptime)
    : '-';

  const userMetrics = overview as Record<string, unknown> | null;
  const totalUsers = (userMetrics?.totalUsers as number) ?? health?.users?.total ?? 0;
  const activeUsers = (userMetrics?.activeUsersToday as number) ?? health?.users?.active ?? 0;
  const newToday = (userMetrics?.newUsersToday as number) ?? health?.users?.newToday ?? 0;

  return (
    <DashboardShell admin eyebrow={t('admin.eyebrow')} title="System Health">
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={Server}
          label="Status"
          value={health?.status === 'ok' ? 'Healthy' : health?.status ?? 'Unknown'}
        />
        <MetricCard icon={Clock} label="Uptime" tone="mint" value={uptimeFormatted} />
        <MetricCard icon={Users} label="Total Users" tone="lilac" value={totalUsers} />
        <MetricCard icon={Activity} label="Active Today" tone="mint" value={activeUsers} />
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <SectionTitle
            title="User Metrics"
            copy="Current user statistics"
            action={
              <Button variant="secondary" onClick={() => void load()} disabled={loading}>
                <RefreshCcw className="h-4 w-4" />
                {loading ? 'Loading...' : 'Refresh'}
              </Button>
            }
          />
          <div className="mt-4 space-y-3">
            <_Row label="Total Users" value={totalUsers} />
            <_Row label="Active Today" value={activeUsers} />
            <_Row label="New Today" value={newToday} />
            <_Row
              label="Active Sessions"
              value={health?.sessions?.active ?? '-'}
            />
          </div>
        </Card>

        <Card>
          <SectionTitle title="Infrastructure" copy="Database and background jobs" />
          <div className="mt-4 space-y-3">
            <_Row
              label="Database"
              value={
                <span className={`inline-flex items-center gap-1.5 text-sm font-bold ${health?.database?.connected !== false ? 'text-mint' : 'text-coral'}`}>
                  <Database className="h-3.5 w-3.5" />
                  {health?.database?.connected !== false ? 'Connected' : 'Disconnected'}
                </span>
              }
            />
            <_Row
              label="Weekly Stats Job"
              value={health?.jobs?.weeklyMoodStats?.enabled ? 'Enabled' : 'Disabled'}
            />
            {health?.jobs?.weeklyMoodStats?.lastRun && (
              <>
                <_Row
                  label="Last Run — Processed"
                  value={health.jobs.weeklyMoodStats.lastRun.processedUsers}
                />
                <_Row
                  label="Last Run — Failed"
                  value={health.jobs.weeklyMoodStats.lastRun.failedUsers}
                />
              </>
            )}
            <_Row
              label="Server Time"
              value={health?.timestamp ? new Date(health.timestamp).toLocaleString() : '-'}
            />
          </div>
        </Card>
      </div>

      {overview && (
        <Card>
          <SectionTitle title="Raw Overview Data" copy="Full admin analytics payload for debugging." />
          <pre className="mt-4 max-h-80 overflow-auto rounded-lg bg-lavender/20 p-4 text-xs text-ink">
            {JSON.stringify(overview, null, 2)}
          </pre>
        </Card>
      )}
    </DashboardShell>
  );
}

function _Row({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between rounded-lg border border-lilac/20 px-4 py-3">
      <span className="text-sm text-slate font-medium">{label}</span>
      <span className="text-sm font-bold text-ink">{typeof value === 'number' ? value.toLocaleString() : value}</span>
    </div>
  );
}

function formatUptime(seconds: number): string {
  const d = Math.floor(seconds / 86400);
  const h = Math.floor((seconds % 86400) / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const parts: string[] = [];
  if (d > 0) parts.push(`${d}d`);
  if (h > 0) parts.push(`${h}h`);
  parts.push(`${m}m`);
  return parts.join(' ');
}
