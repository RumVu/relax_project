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
import {
  API_URL,
  API_VERSION_PREFIX,
  apiFetch,
  getStoredAccessToken,
} from '@/lib/api';
import { useAdminDashboardData } from '@/lib/live-dashboard';
import { useTranslation } from '@/lib/i18n/i18n-provider';

const metricIcons = [Activity, Users, Users, CreditCard, Activity, Bell];
const catalogLinks = [
  { area: 'Quotes', href: '/admin/quotes' },
  { area: 'Sounds', href: '/admin/sounds' },
  { area: 'Podcasts', href: '/admin/podcasts' },
  { area: 'Exercises', href: '/admin/exercises' },
  { area: 'Themes', href: '/admin/themes' },
  { area: 'Onboarding', href: '/admin/onboarding' },
  { area: 'Companion Assets', href: '/admin/companion-assets' },
  { area: 'Companion Messages', href: '/admin/companion-messages' },
];

export default function AdminPage() {
  const { t } = useTranslation();
  const adminFilters = useDashboardFilters('/admin/analytics/overview', 'overview');
  const data = useAdminDashboardData({
    overviewQuery: adminFilters.query,
  });

  return (
    <DashboardShell admin eyebrow={t('admin.eyebrow')} title={t('admin.dashboard.title')}>
      <DashboardFilterBar {...adminFilters} title={t('admin.filters.title')} />

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
            copy={t('admin.empty.growth.copy')}
            title={t('admin.empty.growth.title')}
          />
        )}
        {data.contentEngagement.length > 0 ? (
          <DonutChart data={data.contentEngagement} />
        ) : (
          <EmptyAdminPanel
            copy={t('admin.empty.engagement.copy')}
            title={t('admin.empty.engagement.title')}
          />
        )}
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1fr)_420px]">
        <Card>
          <SectionTitle title={t('admin.users.heading')} copy={t('admin.users.copy')} />
          <div className="mt-5">
            <DataTable
              columns={[
                t('admin.users.col.name'),
                t('admin.users.col.email'),
                t('admin.users.col.status'),
                t('admin.users.col.plan'),
                t('admin.users.col.streak'),
                t('admin.users.col.lastLogin'),
              ]}
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
          title={t('admin.content.heading')}
          copy={t('admin.content.copy')}
          action={
            <div className="flex flex-wrap gap-2">
              <Link href="/admin/search">
                <Button className="h-8 px-3 text-xs" variant="secondary">
                  <Search className="h-4 w-4" />
                  {t('admin.btn.globalSearch')}
                </Button>
              </Link>
              <Link href="/admin/logs">
                <Button className="h-8 px-3 text-xs" variant="secondary">
                  <FileClock className="h-4 w-4" />
                  {t('admin.btn.auditLogs')}
                </Button>
              </Link>
            </div>
          }
        />
        <div className="mt-5">
          <DataTable
            columns={[
              t('admin.content.col.area'),
              t('admin.content.col.endpoint'),
              t('admin.content.col.live'),
              t('admin.content.col.drafts'),
              t('admin.content.col.action'),
            ]}
            rows={catalogLinks.map((link) => {
              // ALWAYS render the full 7-area catalog; pull live/draft
              // figures from data.content by area name. Avoids the
              // partial-data render (Quotes filled, rest dashes) that
              // happened when data.content arrived out-of-order.
              const stats = data.content.find(
                (item) => item.area === link.area,
              );
              const live = stats?.live ?? 0;
              const drafts = stats?.drafts ?? 0;
              const endpoint = stats?.endpoint ?? '—';

              return [
        <span className="font-bold" key={`${link.area}-area`}>
                  {t(areaKey(link.area))}
                </span>,
                <code
                  className="rounded bg-[var(--field-bg)] px-2 py-1 text-xs"
                  key={`${link.area}-endpoint`}
                >
                  {endpoint}
                </code>,
                <span
                  className={`font-extrabold ${live > 0 ? 'text-mint' : 'text-[var(--app-muted)]'}`}
                  key={`${link.area}-live`}
                >
                  {live}
                </span>,
                <span className="font-bold" key={`${link.area}-drafts`}>
                  {drafts}
                </span>,
                <Link href={link.href} key={link.href}>
                  <Button className="h-8 px-3 text-xs" variant="secondary">
                    {t('admin.content.open')}
                  </Button>
                </Link>,
              ];
            })}
          />
          {data.content.length === 0 ? (
            <p className="mt-3 text-xs font-semibold text-[var(--app-muted,theme(colors.slate))]">
              {t('admin.content.loading')}
            </p>
          ) : null}
        </div>
      </Card>
    </DashboardShell>
  );
}

function EmptyAdminPanel({ title, copy }: { title: string; copy: string }) {
  const { t } = useTranslation();
  return (
    <Card className="min-h-[390px]">
      <SectionTitle title={title} copy={copy} />
      <div className="mt-5 rounded-2xl border border-dashed border-[var(--field-border,theme(colors.lilac))] bg-[var(--panel-bg)] p-8 text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
        {t('admin.empty.chartData')}
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

/**
 * Different health probes return wildly different payload shapes:
 * /health             → { status, timestamp, uptimeSeconds }
 * /redis/health       → { status, mode, enabled }
 * /queues/health      → { status, enabled, queueCount }
 * /realtime/health    → { status, adapter: { provider, namespace, mode, … } }
 *
 * Distill any of them down to a short single-line string for the card so
 * we never accidentally try to render an object (which is what produced
 * the "Objects are not valid as a React child {provider, namespace, mode,
 * redisConfigured, redisConnected}" crash).
 */
/**
 * Hits an endpoint WITHOUT the /v1 global prefix that apiFetch hard-codes.
 * Used for the small set of infra routes (/, /health, /ready) the backend
 * explicitly excludes from versioning.
 */
async function fetchUnversioned(
  path: string,
): Promise<Record<string, unknown>> {
  const token = getStoredAccessToken();
  const headers: Record<string, string> = { Accept: 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;
  // Strip the /v1 prefix that API_VERSION_PREFIX adds — we just want
  // `${API_URL}${path}`.
  void API_VERSION_PREFIX;
  const response = await fetch(`${API_URL}${path}`, {
    headers,
    cache: 'no-store',
  });
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  const text = await response.text();
  try {
    return text ? (JSON.parse(text) as Record<string, unknown>) : {};
  } catch {
    return { raw: text };
  }
}

function summariseHealthPayload(payload: Record<string, unknown>): string {
  const parts: string[] = [];

  // adapter: prefer "<provider> on <namespace>" if it's an object.
  const adapter = payload.adapter;
  if (typeof adapter === 'string' && adapter) {
    parts.push(adapter);
  } else if (adapter && typeof adapter === 'object') {
    const a = adapter as Record<string, unknown>;
    const provider = typeof a.provider === 'string' ? a.provider : null;
    const namespace = typeof a.namespace === 'string' ? a.namespace : null;
    const mode = typeof a.mode === 'string' ? a.mode : null;
    const tag = [provider, namespace ? `ns=${namespace}` : null, mode]
      .filter(Boolean)
      .join(' · ');
    if (tag) parts.push(tag);
  }

  if (typeof payload.mode === 'string' && payload.mode) {
    parts.push(`mode ${payload.mode}`);
  }
  if (typeof payload.enabled === 'boolean') {
    parts.push(payload.enabled ? 'enabled' : 'disabled');
  }
  if (typeof payload.queueCount === 'number') {
    parts.push(`${payload.queueCount} queue`);
  }
  if (typeof payload.uptimeSeconds === 'number') {
    parts.push(`uptime ${Math.round(payload.uptimeSeconds)}s`);
  }
  if (typeof payload.redisConnected === 'boolean') {
    parts.push(`redis ${payload.redisConnected ? '✓' : '✗'}`);
  }

  return parts.join(' • ') || 'OK';
}

function InfraHealthCard() {
  const { t } = useTranslation();
  const [items, setItems] = useState<InfraHealth[]>([]);
  const [loading, setLoading] = useState(false);

  // /health is NOT versioned (excluded from the /v1 global prefix in
  // backend main.ts); the others ARE. `versioned: false` makes the probe
  // hit /health directly instead of /v1/health which 404s.
  const probes: Array<{
    service: string;
    endpoint: string;
    versioned?: boolean;
  }> = [
    { service: 'API server', endpoint: '/health', versioned: false },
    { service: 'Redis cache', endpoint: '/redis/health' },
    { service: 'BullMQ queues', endpoint: '/queues/health' },
    { service: 'Realtime (Socket.IO)', endpoint: '/realtime/health' },
  ];

  async function refresh() {
    setLoading(true);
    const next: InfraHealth[] = await Promise.all(
      probes.map(async ({ service, endpoint, versioned = true }) => {
        const start = performance.now();
        try {
          const payload = versioned
            ? await apiFetch<Record<string, unknown>>(endpoint)
            : await fetchUnversioned(endpoint);
          const ms = Math.round(performance.now() - start);
          // Some probes don't have a "status" field but are healthy
          // (e.g. /v1/redis/health returns {configured, enabled, ...}).
          // Treat ok-status OR configured+enabled OR a non-error
          // response as UP.
          const status =
            payload.status === 'ok' ||
            payload.status === 'ready' ||
            (payload.configured === true && payload.enabled !== false)
              ? 'up'
              : 'down';
          return {
            service,
            endpoint,
            status,
            latencyMs: ms,
            detail: summariseHealthPayload(payload),
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
                : t('infra.error.failedToFetch'),
          };
        }
      }),
    );
    setItems(next);
    setLoading(false);
  }

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void refresh();
    const t = window.setInterval(refresh, 15000); // refresh mỗi 15s
    return () => window.clearInterval(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const allUp = items.length > 0 && items.every((s) => s.status === 'up');

  return (
    <Card>
      <SectionTitle
        title={t('infra.heading')}
        copy={t('infra.copy', { seconds: 15 })}
        action={
          <div className="flex items-center gap-2">
            <span
              className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-bold ${
                allUp
                  ? 'bg-mint/15 text-mint'
                  : 'bg-coral/15 text-coral'
              }`}
            >
              {allUp ? t('infra.allOk') : t('infra.hasIssues')}
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
            {t('common.loading')}
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
                  {ok ? t('infra.status.up') : t('infra.status.down')}
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

function areaKey(area: string) {
  const keys: Record<string, Parameters<ReturnType<typeof useTranslation>['t']>[0]> = {
    Quotes: 'nav.quotes',
    Sounds: 'nav.sounds',
    Podcasts: 'nav.podcasts',
    Exercises: 'nav.exercises',
    Themes: 'nav.themes',
    Onboarding: 'nav.onboarding',
    'Companion Assets': 'nav.companionAssets',
    'Companion Messages': 'nav.companionMessages',
  };
  return keys[area] ?? 'admin.content.col.area';
}
