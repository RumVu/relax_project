'use client';

import { useEffect, useState, useCallback } from 'react';
import Link from 'next/link';
import {
  Activity,
  CheckCircle2,
  Clock,
  Cloud,
  GitBranch,
  Globe,
  Rocket,
  RefreshCcw,
  Server,
  Shield,
  Smartphone,
  XCircle,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { API_URL, API_VERSION_PREFIX, apiFetch, getStoredAccessToken } from '@/lib/api';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type ServiceHealth = {
  name: string;
  url: string;
  status: 'up' | 'down' | 'checking';
  latencyMs: number | null;
  detail: string;
};

type DeployInfo = {
  platform: string;
  region: string;
  version: string;
  lastDeploy: string | null;
  branch: string;
};

async function fetchRaw(url: string): Promise<{ data: Record<string, unknown>; ms: number }> {
  const token = getStoredAccessToken();
  const headers: Record<string, string> = { Accept: 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;
  const start = performance.now();
  const res = await fetch(url, { headers, cache: 'no-store' });
  const ms = Math.round(performance.now() - start);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const text = await res.text();
  const data = text ? (JSON.parse(text) as Record<string, unknown>) : {};
  return { data, ms };
}

export default function ReleaseCenterPage() {
  const { t } = useTranslation();
  const [services, setServices] = useState<ServiceHealth[]>([]);
  const [deploy, setDeploy] = useState<DeployInfo>({
    platform: 'Railway',
    region: 'Singapore (ap-southeast-1)',
    version: '—',
    lastDeploy: null,
    branch: 'main',
  });
  const [loading, setLoading] = useState(false);
  const [lastRefresh, setLastRefresh] = useState<Date | null>(null);

  const probes = [
    { name: 'API Server', url: `${API_URL}/health` },
    { name: 'Redis Cache', url: `${API_URL}${API_VERSION_PREFIX}/redis/health` },
    { name: 'BullMQ Queues', url: `${API_URL}${API_VERSION_PREFIX}/queues/health` },
    { name: 'Realtime (Socket.IO)', url: `${API_URL}${API_VERSION_PREFIX}/realtime/health` },
  ];

  const refresh = useCallback(async () => {
    setLoading(true);

    const results = await Promise.all(
      probes.map(async ({ name, url }) => {
        try {
          const { data, ms } = await fetchRaw(url);
          const up =
            data.status === 'ok' ||
            data.status === 'ready' ||
            (data.configured === true && data.enabled !== false);
          const parts: string[] = [];
          if (typeof data.uptimeSeconds === 'number') {
            const h = Math.floor((data.uptimeSeconds as number) / 3600);
            const m = Math.floor(((data.uptimeSeconds as number) % 3600) / 60);
            parts.push(`uptime ${h}h${m}m`);
          }
          if (typeof data.mode === 'string') parts.push(data.mode);
          if (typeof data.queueCount === 'number') parts.push(`${data.queueCount} queues`);
          if (typeof data.enabled === 'boolean') parts.push(data.enabled ? 'enabled' : 'disabled');
          return {
            name,
            url,
            status: up ? 'up' : 'down',
            latencyMs: ms,
            detail: parts.join(' · ') || 'OK',
          } as ServiceHealth;
        } catch {
          return { name, url, status: 'down', latencyMs: null, detail: 'Unreachable' } as ServiceHealth;
        }
      }),
    );
    setServices(results);

    try {
      const { data } = await fetchRaw(`${API_URL}/health`);
      setDeploy((prev) => ({
        ...prev,
        version: typeof data.version === 'string' ? data.version : prev.version,
        lastDeploy:
          typeof data.timestamp === 'string'
            ? data.timestamp
            : prev.lastDeploy,
      }));
    } catch {}

    setLastRefresh(new Date());
    setLoading(false);
  }, []);

  useEffect(() => {
    void refresh();
    const timer = setInterval(refresh, 30_000);
    return () => clearInterval(timer);
  }, [refresh]);

  const allUp = services.length > 0 && services.every((s) => s.status === 'up');
  const upCount = services.filter((s) => s.status === 'up').length;
  const avgLatency =
    services.length > 0
      ? Math.round(
          services.reduce((sum, s) => sum + (s.latencyMs ?? 0), 0) / services.length,
        )
      : 0;

  return (
    <DashboardShell
      admin
      eyebrow={t('admin.eyebrow' as any)}
      title="Release Center"
    >
      {/* Status bar */}
      <div className="flex flex-wrap items-center gap-3">
        <span
          className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-bold ${
            allUp ? 'bg-mint/15 text-mint' : 'bg-coral/15 text-coral'
          }`}
        >
          {allUp ? (
            <CheckCircle2 className="h-3.5 w-3.5" />
          ) : (
            <XCircle className="h-3.5 w-3.5" />
          )}
          {allUp ? 'All Systems Operational' : `${upCount}/${services.length} Services Up`}
        </span>
        {lastRefresh && (
          <span className="text-xs text-[var(--app-muted)]">
            Last checked: {lastRefresh.toLocaleTimeString()}
          </span>
        )}
        <button
          className="ml-auto inline-flex h-9 w-9 items-center justify-center rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] text-[var(--app-text)] transition hover:bg-violet/10"
          disabled={loading}
          onClick={() => void refresh()}
          type="button"
        >
          <RefreshCcw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
        </button>
      </div>

      {/* Metric cards */}
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={Server}
          label="Services Up"
          value={`${upCount}/${services.length}`}
          tone="mint"
        />
        <MetricCard
          icon={Activity}
          label="Avg Latency"
          value={`${avgLatency}ms`}
          tone="violet"
        />
        <MetricCard
          icon={Cloud}
          label="Platform"
          value={deploy.platform}
          tone="mint"
        />
        <MetricCard
          icon={Globe}
          label="Region"
          value="Singapore"
          tone="violet"
        />
      </div>

      {/* Deployment info + Services grid */}
      <div className="grid gap-4 xl:grid-cols-2">
        {/* Deployment Info */}
        <Card>
          <SectionTitle
            title="Deployment Info"
            copy="Current production deployment details"
          />
          <div className="mt-4 space-y-3">
            <InfoRow icon={<Rocket className="h-4 w-4 text-violet" />} label="Platform" value="Railway (Hobby → Pro)" />
            <InfoRow icon={<Globe className="h-4 w-4 text-mint" />} label="Region" value="ap-southeast-1 (Singapore)" />
            <InfoRow icon={<GitBranch className="h-4 w-4 text-violet" />} label="Branch" value={deploy.branch} />
            <InfoRow
              icon={<Clock className="h-4 w-4 text-amber-500" />}
              label="Last Deploy"
              value={deploy.lastDeploy ? new Date(deploy.lastDeploy).toLocaleString() : '—'}
            />
            <InfoRow
              icon={<Shield className="h-4 w-4 text-mint" />}
              label="Auto-deploy"
              value="Enabled (push to main)"
            />

            <div className="mt-4 rounded-xl border border-[var(--field-border)] bg-[var(--panel-bg)] p-4">
              <p className="text-xs font-bold text-[var(--app-muted)] mb-2">ENVIRONMENTS</p>
              <div className="space-y-2">
                <EnvRow
                  name="Backend API"
                  url="backend-production-b8a5f.up.railway.app"
                  status={services.find((s) => s.name === 'API Server')?.status ?? 'checking'}
                />
                <EnvRow
                  name="Web Dashboard"
                  url="relax-project-web-dashboard.vercel.app"
                  status="up"
                />
                <EnvRow
                  name="Mobile App"
                  url="Flutter (iOS + Android)"
                  status="up"
                  isMobile
                />
              </div>
            </div>
          </div>
        </Card>

        {/* Services Health */}
        <Card>
          <SectionTitle
            title="Service Health"
            copy="Real-time service monitoring (auto-refresh 30s)"
          />
          <div className="mt-4 space-y-2">
            {services.map((svc) => {
              const ok = svc.status === 'up';
              return (
                <div
                  key={svc.name}
                  className="flex items-center justify-between gap-3 rounded-lg border border-[var(--field-border)] bg-[var(--panel-bg)] p-3"
                >
                  <div className="flex items-center gap-3 min-w-0">
                    {ok ? (
                      <CheckCircle2 className="h-5 w-5 shrink-0 text-mint" />
                    ) : (
                      <XCircle className="h-5 w-5 shrink-0 text-coral" />
                    )}
                    <div className="min-w-0">
                      <p className="truncate text-sm font-bold text-[var(--app-text)]">
                        {svc.name}
                      </p>
                      <p className="truncate text-xs text-[var(--app-muted)]">
                        {svc.detail}
                      </p>
                    </div>
                  </div>
                  <div className="text-right shrink-0">
                    <p className={`text-sm font-extrabold ${ok ? 'text-mint' : 'text-coral'}`}>
                      {ok ? 'UP' : 'DOWN'}
                    </p>
                    {svc.latencyMs != null && (
                      <p className="text-[11px] font-semibold text-[var(--app-muted)]">
                        {svc.latencyMs}ms
                      </p>
                    )}
                  </div>
                </div>
              );
            })}
            {services.length === 0 && (
              <p className="text-sm text-[var(--app-muted)]">Checking services...</p>
            )}
          </div>
        </Card>
      </div>

      {/* Quick Actions */}
      <Card>
        <SectionTitle
          title="Quick Actions"
          copy="Common deployment and monitoring tasks"
        />
        <div className="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          <Link href="/admin/health">
            <ActionCard
              icon={<Activity className="h-5 w-5 text-mint" />}
              title="Health Dashboard"
              desc="Detailed infra health checks"
            />
          </Link>
          <Link href="/admin/logs">
            <ActionCard
              icon={<Clock className="h-5 w-5 text-violet" />}
              title="Audit Logs"
              desc="Admin action history"
            />
          </Link>
          <Link href="/admin/feature-flags">
            <ActionCard
              icon={<GitBranch className="h-5 w-5 text-amber-500" />}
              title="Feature Flags"
              desc="Toggle features per environment"
            />
          </Link>
          <Link href="/admin/content-hub">
            <ActionCard
              icon={<Rocket className="h-5 w-5 text-coral" />}
              title="Content Hub"
              desc="Manage all content areas"
            />
          </Link>
        </div>
      </Card>

      {/* Release Checklist */}
      <Card>
        <SectionTitle
          title="Release Checklist"
          copy="Pre-deployment verification steps"
        />
        <div className="mt-4 space-y-2">
          <ChecklistItem label="All services healthy" checked={allUp} />
          <ChecklistItem label="API latency < 500ms" checked={avgLatency < 500} />
          <ChecklistItem label="Redis cache connected" checked={services.some((s) => s.name === 'Redis Cache' && s.status === 'up')} />
          <ChecklistItem label="Queue workers running" checked={services.some((s) => s.name === 'BullMQ Queues' && s.status === 'up')} />
          <ChecklistItem label="Realtime server active" checked={services.some((s) => s.name === 'Realtime (Socket.IO)' && s.status === 'up')} />
        </div>
        <div className="mt-4 flex gap-2">
          <span
            className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-bold ${
              allUp ? 'bg-mint/15 text-mint' : 'bg-amber-500/15 text-amber-600'
            }`}
          >
            {allUp ? '✓ Ready to deploy' : '⚠ Issues detected — review before deploying'}
          </span>
        </div>
      </Card>
    </DashboardShell>
  );
}

function InfoRow({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="flex items-center gap-3">
      {icon}
      <span className="text-xs font-bold text-[var(--app-muted)] w-24">{label}</span>
      <span className="text-sm font-semibold text-[var(--app-text)]">{value}</span>
    </div>
  );
}

function EnvRow({
  name,
  url,
  status,
  isMobile,
}: {
  name: string;
  url: string;
  status: 'up' | 'down' | 'checking';
  isMobile?: boolean;
}) {
  const ok = status === 'up';
  return (
    <div className="flex items-center justify-between gap-2">
      <div className="flex items-center gap-2 min-w-0">
        {isMobile ? (
          <Smartphone className="h-3.5 w-3.5 text-violet shrink-0" />
        ) : (
          <Globe className="h-3.5 w-3.5 text-mint shrink-0" />
        )}
        <span className="text-xs font-bold text-[var(--app-text)]">{name}</span>
      </div>
      <div className="flex items-center gap-2">
        <code className="text-[10px] text-[var(--app-muted)] truncate max-w-[200px]">{url}</code>
        <span
          className={`h-2 w-2 rounded-full shrink-0 ${
            ok ? 'bg-mint' : status === 'checking' ? 'bg-amber-400' : 'bg-coral'
          }`}
        />
      </div>
    </div>
  );
}

function ActionCard({ icon, title, desc }: { icon: React.ReactNode; title: string; desc: string }) {
  return (
    <div className="rounded-xl border border-[var(--field-border)] bg-[var(--panel-bg)] p-4 transition hover:border-violet/40 hover:bg-violet/5 cursor-pointer">
      <div className="mb-2">{icon}</div>
      <p className="text-sm font-bold text-[var(--app-text)]">{title}</p>
      <p className="text-xs text-[var(--app-muted)]">{desc}</p>
    </div>
  );
}

function ChecklistItem({ label, checked }: { label: string; checked: boolean }) {
  return (
    <div className="flex items-center gap-3 rounded-lg border border-[var(--field-border)] bg-[var(--panel-bg)] px-4 py-2.5">
      {checked ? (
        <CheckCircle2 className="h-4 w-4 text-mint shrink-0" />
      ) : (
        <XCircle className="h-4 w-4 text-coral shrink-0" />
      )}
      <span className={`text-sm font-semibold ${checked ? 'text-[var(--app-text)]' : 'text-coral'}`}>
        {label}
      </span>
    </div>
  );
}
