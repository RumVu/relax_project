'use client';

import { useCallback, useEffect, useState } from 'react';
import { Activity, CheckCircle, Clock, Database, HardDrive, RefreshCcw, Server, Users, Wifi, XCircle, Zap } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type OpsData = {
  status: string;
  timestamp: string;
  uptimeSeconds: number;
  api: { status: string };
  database: { connected: boolean; latencyMs: number };
  redis: { connected: boolean; configured: boolean; latencyMs: number | null };
  queue: { configured: boolean; enabled: boolean; registeredQueues: string[] };
  providers: {
    push: { ready: boolean };
    email: { ready: boolean };
    billing: { ready: boolean };
    storage: { ready: boolean; bucket?: string };
  };
  users: { total: number; activeToday: number };
  lastWeeklyStatsJob: { success: boolean; processedUsers: number; failedUsers?: number; ranAt: string } | null;
};

export default function HealthDashboardPage() {
  const { t } = useTranslation();
  const pushToast = useUiStore((s) => s.pushToast);
  const [ops, setOps] = useState<OpsData | null>(null);
  const [loading, setLoading] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await apiFetch<OpsData>('/ops', undefined, { skipVersionPrefix: true }).catch(() => null);
      setOps(data);
    } catch {
      pushToast({ tone: 'error', title: 'Failed to load ops data' });
    } finally {
      setLoading(false);
    }
  }, [pushToast]);

  useEffect(() => {
    void load();
  }, [load]);

  const uptimeFormatted = ops?.uptimeSeconds ? formatUptime(ops.uptimeSeconds) : '-';

  return (
    <DashboardShell admin eyebrow={t('admin.eyebrow')} title="Ops Dashboard">
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={Server}
          label="API Status"
          value={ops?.api?.status === 'online' ? 'Online' : ops?.status ?? 'Unknown'}
        />
        <MetricCard icon={Clock} label="Uptime" tone="mint" value={uptimeFormatted} />
        <MetricCard icon={Users} label="Total Users" tone="lilac" value={ops?.users?.total ?? 0} />
        <MetricCard icon={Activity} label="Active Today" tone="mint" value={ops?.users?.activeToday ?? 0} />
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        {/* Infrastructure Status */}
        <Card>
          <SectionTitle
            title="Infrastructure"
            copy="Database, Redis, and Queue status"
            action={
              <Button variant="secondary" onClick={() => void load()} disabled={loading}>
                <RefreshCcw className="h-4 w-4" />
                {loading ? 'Loading...' : 'Refresh'}
              </Button>
            }
          />
          <div className="mt-4 space-y-3">
            <_StatusRow
              label="Database"
              ok={ops?.database?.connected ?? false}
              detail={ops?.database?.latencyMs != null ? `${ops.database.latencyMs}ms` : undefined}
            />
            <_StatusRow
              label="Redis"
              ok={ops?.redis?.connected ?? false}
              detail={
                !ops?.redis?.configured
                  ? 'Not configured'
                  : ops?.redis?.latencyMs != null
                    ? `${ops.redis.latencyMs}ms`
                    : undefined
              }
            />
            <_StatusRow
              label="Job Queue"
              ok={ops?.queue?.enabled ?? false}
              detail={
                ops?.queue?.registeredQueues?.length
                  ? `${ops.queue.registeredQueues.length} queues`
                  : 'Not configured'
              }
            />
            <_Row
              label="Server Time"
              value={ops?.timestamp ? new Date(ops.timestamp).toLocaleString() : '-'}
            />
          </div>
        </Card>

        {/* Provider Status */}
        <Card>
          <SectionTitle title="Providers" copy="External service readiness" />
          <div className="mt-4 space-y-3">
            <_StatusRow label="Push Notification" ok={ops?.providers?.push?.ready ?? false} />
            <_StatusRow label="Email" ok={ops?.providers?.email?.ready ?? false} />
            <_StatusRow label="Billing (Stripe)" ok={ops?.providers?.billing?.ready ?? false} />
            <_StatusRow
              label="Storage"
              ok={ops?.providers?.storage?.ready ?? false}
              detail={ops?.providers?.storage?.bucket ?? undefined}
            />
          </div>
        </Card>
      </div>

      {/* Weekly Stats Job */}
      <Card>
        <SectionTitle title="Background Jobs" copy="Scheduled job status and last run info" />
        <div className="mt-4 space-y-3">
          {ops?.lastWeeklyStatsJob ? (
            <>
              <_StatusRow
                label="Weekly Mood Stats"
                ok={ops.lastWeeklyStatsJob.success}
              />
              <_Row label="Last Run" value={new Date(ops.lastWeeklyStatsJob.ranAt).toLocaleString()} />
              <_Row label="Processed Users" value={ops.lastWeeklyStatsJob.processedUsers} />
              {ops.lastWeeklyStatsJob.failedUsers != null && (
                <_Row label="Failed Users" value={ops.lastWeeklyStatsJob.failedUsers} />
              )}
            </>
          ) : (
            <_Row label="Weekly Mood Stats" value="No runs yet" />
          )}
          {ops?.queue?.registeredQueues && ops.queue.registeredQueues.length > 0 && (
            <_Row label="Registered Queues" value={ops.queue.registeredQueues.join(', ')} />
          )}
        </div>
      </Card>
    </DashboardShell>
  );
}

function _StatusRow({ label, ok, detail }: { label: string; ok: boolean; detail?: string }) {
  return (
    <div className="flex items-center justify-between rounded-lg border border-lilac/20 px-4 py-3">
      <span className="text-sm text-slate font-medium">{label}</span>
      <div className="flex items-center gap-2">
        {detail && <span className="text-xs text-slate">{detail}</span>}
        <span className={`inline-flex items-center gap-1.5 text-sm font-bold ${ok ? 'text-mint' : 'text-coral'}`}>
          {ok ? <CheckCircle className="h-3.5 w-3.5" /> : <XCircle className="h-3.5 w-3.5" />}
          {ok ? 'Ready' : 'Offline'}
        </span>
      </div>
    </div>
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
