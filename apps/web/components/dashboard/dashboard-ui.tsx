'use client';

import { cloneElement, useEffect, useMemo, useRef, useState } from 'react';
import { io } from 'socket.io-client';
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  ComposedChart,
  Line,
  Pie,
  PieChart,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import {
  Activity,
  CheckCircle2,
  CloudSun,
  Database,
  type LucideIcon,
  RefreshCcw,
  Sparkles,
  Wifi,
  WifiOff,
} from 'lucide-react';
import { API_URL, ApiError, apiFetch, getStoredAccessToken, refreshAuthSession } from '@/lib/api';
import { cn } from '@/lib/utils';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { useMounted } from '@/hooks/use-mounted';
import { useTranslation } from '@/lib/i18n/i18n-provider';

const colors = ['#7357f6', '#40c9a2', '#ef767a', '#f7c948', '#9f7aea', '#7c8cf8'];

export function DataSyncBadge({ endpoint }: { endpoint: string }) {
  const { t } = useTranslation();
  const [state, setState] = useState<'checking' | 'live' | 'error'>('checking');
  const [errorCode, setErrorCode] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    const resetTimer = window.setTimeout(() => {
      if (!cancelled) {
        setState('checking');
        setErrorCode(null);
      }
    }, 0);

    apiFetch(endpoint)
      .then(() => {
        if (!cancelled) {
          setState('live');
        }
      })
      .catch((error) => {
        if (!cancelled) {
          setState('error');
          setErrorCode(error instanceof ApiError ? error.code : 'API_UNAVAILABLE');
        }
      });

    return () => {
      cancelled = true;
      window.clearTimeout(resetTimer);
    };
  }, [endpoint]);

  const label =
    state === 'checking'
      ? t('status.probing')
      : state === 'live'
        ? 'Live API'
        : t('status.apiError');
  const Icon = state === 'live' ? Wifi : state === 'error' ? WifiOff : RefreshCcw;

  return (
    <Badge
      className={cn(
        'max-w-full normal-case tracking-normal',
        state === 'live' && 'bg-mint/15 text-mint',
        state === 'error' && 'bg-coral/15 text-ink',
      )}
    >
      <Icon className={cn('mr-2 h-3.5 w-3.5 shrink-0', state === 'checking' && 'animate-spin')} />
      <span className="min-w-0 truncate">
        {label}: {endpoint}
        {errorCode ? ` (${errorCode})` : ''}
      </span>
    </Badge>
  );
}

export function RealtimeStatusBadge({
  onEvent,
}: {
  onEvent?: (eventName: string, payload?: unknown) => void;
}) {
  const { t } = useTranslation();
  const [state, setState] = useState<'idle' | 'connecting' | 'live' | 'offline'>('idle');
  const [lastEvent, setLastEvent] = useState(() => t('status.rt.connecting'));

  useEffect(() => {
    const token = getStoredAccessToken();
    if (!token) {
      const offlineTimer = window.setTimeout(() => {
        setState('offline');
        setLastEvent('No access token');
      }, 0);
      return () => window.clearTimeout(offlineTimer);
    }

    const connectingTimer = window.setTimeout(() => setState('connecting'), 0);
    const socket = io(`${API_URL}/realtime`, {
      auth: { token },
      reconnectionAttempts: 2,
      transports: ['websocket'],
    });

    socket.on('connect', () => {
      setState('live');
      setLastEvent(t('status.rt.connected'));
    });
    socket.on('realtime.ready', () => {
      setState('live');
      setLastEvent(t('status.rt.connected'));
    });
    socket.on('realtime.auth_failed', async () => {
      try {
        const refreshed = await refreshAuthSession();
        socket.auth = { token: refreshed.accessToken };
        socket.connect();
      } catch {
        setState('offline');
        setLastEvent(t('status.rt.needsLogin'));
      }
    });
    socket.on('connect_error', () => {
      setState('offline');
      setLastEvent(t('status.rt.disconnected'));
    });

    for (const eventName of [
      'notification.created',
      'companion.updated',
      'analytics.updated',
      'mood.updated',
      'relax-session.updated',
      'journal.created',
    ]) {
      socket.on(eventName, (payload?: unknown) => {
        setLastEvent(eventName);
        onEvent?.(eventName, payload);
      });
    }

    return () => {
      window.clearTimeout(connectingTimer);
      socket.disconnect();
    };
  }, [onEvent]);

  const Icon = state === 'live' ? Wifi : state === 'connecting' ? RefreshCcw : WifiOff;

  return (
    <Badge
      className={cn(
        'max-w-full normal-case tracking-normal',
        state === 'live' && 'bg-mint/15 text-mint',
        state === 'offline' && 'bg-sun/20 text-ink',
      )}
    >
      <Icon className={cn('mr-2 h-3.5 w-3.5 shrink-0', state === 'connecting' && 'animate-spin')} />
      <span className="min-w-0 truncate">{lastEvent}</span>
    </Badge>
  );
}

export function MetricCard({
  label,
  value,
  note,
  icon: Icon = Activity,
  tone = 'violet',
}: {
  label: string;
  value: string | number;
  note?: string;
  icon?: LucideIcon;
  tone?: 'violet' | 'mint' | 'coral' | 'sun' | 'lilac';
}) {
  const toneClass = {
    violet: 'bg-violet text-white',
    mint: 'bg-mint/15 text-mint',
    coral: 'bg-coral/15 text-coral',
    sun: 'bg-sun/25 text-ink',
    lilac: 'bg-lilac/70 text-plum',
  }[tone];

  // Long values like "PREMIUM_ANNUAL" used to overflow the card. Auto
  // shrink to a smaller size when the value is long, and always allow
  // word-break + ellipsis so it never escapes the card.
  const valueString = String(value);
  const valueClass =
    valueString.length > 14
      ? 'text-lg sm:text-xl'
      : valueString.length > 10
        ? 'text-2xl'
        : 'text-3xl';
  return (
    <Card className="min-h-[156px] overflow-hidden">
      <div className={cn('flex h-11 w-11 items-center justify-center rounded-lg', toneClass)}>
        <Icon className="h-5 w-5" />
      </div>
      <p className="mt-5 text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">{label}</p>
      <p
        className={cn(
          'mt-2 font-extrabold break-words leading-tight text-[var(--app-text,theme(colors.ink))]',
          valueClass,
        )}
        title={valueString}
      >
        {valueString}
      </p>
      {note ? <p className="mt-1 break-words text-sm font-medium text-[var(--app-muted,theme(colors.plum))]">{note}</p> : null}
    </Card>
  );
}

export function SectionTitle({
  title,
  copy,
  action,
}: {
  title: string;
  copy?: string;
  action?: React.ReactNode;
}) {
  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
      <div>
        <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--app-muted,theme(colors.plum))]">
          Khu vực
        </p>
        <h3 className="mt-2 text-xl font-extrabold text-[var(--app-text,theme(colors.ink))]">{title}</h3>
        {copy ? <p className="mt-1 text-sm text-[var(--app-muted,theme(colors.slate))]">{copy}</p> : null}
      </div>
      {action}
    </div>
  );
}

export function ProgressList({
  items,
  valueKey = 'percent',
}: {
  items: Array<Record<string, string | number>>;
  valueKey?: string;
}) {
  return (
    <div className="space-y-4">
      {items.map((item) => {
        const value = Number(item[valueKey] ?? item.value ?? 0);

        return (
          <div
            className="grid grid-cols-[112px_minmax(0,1fr)_48px] items-center gap-3"
            key={String(item.mood ?? item.label ?? item.name)}
          >
            <p className="truncate text-sm font-semibold text-ink">
              {String(item.mood ?? item.label ?? item.name)}
            </p>
            <div className="h-3 overflow-hidden rounded-full bg-cloud">
              <div
                className="h-full rounded-full bg-violet"
                style={{ width: `${Math.min(value, 100)}%` }}
              />
            </div>
            <p className="text-right text-sm font-bold text-ink">{value}%</p>
          </div>
        );
      })}
    </div>
  );
}

export function DataTable({
  columns,
  rows,
}: {
  columns: string[];
  rows: Array<Array<React.ReactNode>>;
}) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full min-w-[640px] border-separate border-spacing-0 text-left text-sm">
        <thead>
          <tr>
            {columns.map((column, columnIndex) => (
              <th
                className="border-b border-[var(--field-border,theme(colors.lilac/70))] px-3 py-3 font-bold text-[var(--app-muted,theme(colors.slate))]"
                key={`${column}-${columnIndex}`}
              >
                {column}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, rowIndex) => (
            <tr key={rowIndex}>
              {row.map((cell, cellIndex) => (
                <td
                  className="border-b border-[var(--field-border,theme(colors.lilac/45))] px-3 py-3 font-medium text-[var(--app-text,theme(colors.ink))]"
                  key={`${rowIndex}-${cellIndex}`}
                >
                  {cell}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export function MoodAreaDashboardChart({
  data,
}: {
  data: Array<Record<string, string | number>>;
}) {
  const { t } = useTranslation();
  const mounted = useMounted();

  return (
    <Card className="min-h-[380px]">
      <SectionTitle
        title={t('chart.moodTimeline.title')}
        copy={t('chart.moodTimeline.copy')}
      />
      <ChartFrame mounted={mounted}>
        <AreaChart data={data} margin={{ left: -18, right: 8, top: 16 }}>
          <defs>
            <linearGradient id="moodDashboardFill" x1="0" x2="0" y1="0" y2="1">
              <stop offset="5%" stopColor="#7357f6" stopOpacity={0.25} />
              <stop offset="95%" stopColor="#7357f6" stopOpacity={0.02} />
            </linearGradient>
            <linearGradient id="stressDashboardFill" x1="0" x2="0" y1="0" y2="1">
              <stop offset="5%" stopColor="#ef767a" stopOpacity={0.18} />
              <stop offset="95%" stopColor="#ef767a" stopOpacity={0.01} />
            </linearGradient>
          </defs>
          <CartesianGrid stroke="#e7e4f5" strokeDasharray="4 4" />
          <XAxis dataKey="label" tick={{ fill: '#536071', fontSize: 12 }} tickLine={false} axisLine={false} />
          <YAxis domain={[0, 100]} tick={{ fill: '#536071', fontSize: 12 }} tickLine={false} axisLine={false} />
          <Tooltip contentStyle={tooltipStyle} />
          <Area dataKey="moodScore" name="Mood score" type="monotone" stroke="#7357f6" strokeWidth={3} fill="url(#moodDashboardFill)" />
          <Area dataKey="stressScore" name="Stress score" type="monotone" stroke="#ef767a" strokeWidth={3} fill="url(#stressDashboardFill)" />
        </AreaChart>
      </ChartFrame>
      <p className="mt-3 text-xs font-semibold text-slate">
        {t('chart.moodTimeline.copy')}
      </p>
    </Card>
  );
}

export function DistributionChart({
  data,
}: {
  data: Array<{ mood: string; count: number; percent: number }>;
}) {
  const { t } = useTranslation();
  const mounted = useMounted();

  return (
    <Card className="min-h-[380px]">
      <SectionTitle
        title={t('chart.moodDistribution.title')}
        copy={t('chart.moodDistribution.copy')}
      />
      <ChartFrame mounted={mounted}>
        <BarChart data={data} margin={{ left: -18, right: 8, top: 16 }}>
          <CartesianGrid stroke="#e7e4f5" strokeDasharray="4 4" />
          <XAxis dataKey="mood" tick={{ fill: '#536071', fontSize: 12 }} tickLine={false} axisLine={false} />
          <YAxis tick={{ fill: '#536071', fontSize: 12 }} tickLine={false} axisLine={false} />
          <Tooltip contentStyle={tooltipStyle} />
          <Bar dataKey="count" radius={[8, 8, 0, 0]}>
            {data.map((entry, index) => (
              <Cell fill={colors[index % colors.length]} key={entry.mood} />
            ))}
          </Bar>
        </BarChart>
      </ChartFrame>
    </Card>
  );
}

export function WeeklyStatsChart({
  data,
}: {
  data: Array<Record<string, string | number>>;
}) {
  const { t } = useTranslation();
  const mounted = useMounted();

  return (
    <Card className="min-h-[380px]">
      <SectionTitle
        title={t('chart.weeklyStats.title')}
        copy={t('chart.weeklyStats.copy')}
      />
      <ChartFrame mounted={mounted}>
        <ComposedChart data={data} margin={{ left: -18, right: 8, top: 16 }}>
          <CartesianGrid stroke="#e7e4f5" strokeDasharray="4 4" />
          <XAxis dataKey="weekStart" tick={{ fill: '#536071', fontSize: 12 }} tickLine={false} axisLine={false} />
          <YAxis tick={{ fill: '#536071', fontSize: 12 }} tickLine={false} axisLine={false} />
          <Tooltip contentStyle={tooltipStyle} />
          <Bar dataKey="avgScore" fill="#7357f6" radius={[8, 8, 0, 0]} />
          <Line dataKey="stressReducePct" stroke="#40c9a2" strokeWidth={3} type="monotone" />
        </ComposedChart>
      </ChartFrame>
    </Card>
  );
}

export function RelaxActivityChart({
  data,
}: {
  data: Array<Record<string, string | number>>;
}) {
  const { t } = useTranslation();
  const mounted = useMounted();

  return (
    <Card className="min-h-[340px]">
      <SectionTitle
        title={t('chart.relaxEffect.title')}
        copy={t('chart.relaxEffect.copy')}
      />
      <ChartFrame height="h-[230px]" mounted={mounted}>
        <ComposedChart data={data} margin={{ left: -18, right: 8, top: 16 }}>
          <CartesianGrid stroke="#e7e4f5" strokeDasharray="4 4" />
          <XAxis dataKey="title" tick={{ fill: '#536071', fontSize: 12 }} tickLine={false} axisLine={false} />
          <YAxis tick={{ fill: '#536071', fontSize: 12 }} tickLine={false} axisLine={false} />
          <Tooltip contentStyle={tooltipStyle} />
          <Bar dataKey="sessions" fill="#7357f6" radius={[8, 8, 0, 0]} />
          <Line dataKey="relief" stroke="#ef767a" strokeWidth={3} type="monotone" />
        </ComposedChart>
      </ChartFrame>
    </Card>
  );
}

export function AdminGrowthChart({
  data,
}: {
  data: Array<Record<string, string | number>>;
}) {
  const { t } = useTranslation();
  const mounted = useMounted();

  return (
    <Card className="min-h-[390px]">
      <SectionTitle title={t('chart.adminGrowth.title')} copy={t('chart.adminGrowth.copy')} />
      <ChartFrame mounted={mounted}>
        <ComposedChart data={data} margin={{ left: -18, right: 8, top: 16 }}>
          <CartesianGrid stroke="#e7e4f5" strokeDasharray="4 4" />
          <XAxis dataKey="label" tick={{ fill: '#536071', fontSize: 12 }} tickLine={false} axisLine={false} />
          <YAxis tick={{ fill: '#536071', fontSize: 12 }} tickLine={false} axisLine={false} />
          <Tooltip contentStyle={tooltipStyle} />
          <Bar dataKey="users" fill="#40c9a2" radius={[8, 8, 0, 0]} />
          <Line dataKey="active" stroke="#7357f6" strokeWidth={3} type="monotone" />
          <Line dataKey="revenue" stroke="#ef767a" strokeWidth={3} type="monotone" />
        </ComposedChart>
      </ChartFrame>
    </Card>
  );
}

export function DonutChart({
  data,
}: {
  data: Array<{ name: string; value: number }>;
}) {
  const { t } = useTranslation();
  const mounted = useMounted();

  return (
    <Card className="min-h-[390px]">
      <SectionTitle title={t('chart.contentEngagement.title')} copy={t('chart.contentEngagement.copy')} />
      <ChartFrame mounted={mounted}>
        <PieChart>
          <Tooltip contentStyle={tooltipStyle} />
          <Pie data={data} dataKey="value" innerRadius={68} outerRadius={110} paddingAngle={4}>
            {data.map((entry, index) => (
              <Cell fill={colors[index % colors.length]} key={entry.name} />
            ))}
          </Pie>
        </PieChart>
      </ChartFrame>
      <div className="mt-4 grid gap-2 sm:grid-cols-2">
        {data.map((item, index) => (
          <div className="flex items-center justify-between text-sm" key={item.name}>
            <span className="flex items-center gap-2 font-semibold text-ink">
              <span
                className="h-2.5 w-2.5 rounded-full"
                style={{ backgroundColor: colors[index % colors.length] }}
              />
              {item.name}
            </span>
            <span className="font-bold text-plum">{item.value}%</span>
          </div>
        ))}
      </div>
    </Card>
  );
}

export function CompanionStatusCard({
  companion,
}: {
  companion: {
    level: number;
    affection: number;
    energy: number;
    mood: string;
    action: string;
    totalInteractions: number;
  };
}) {
  return (
    <Card className="bg-night text-white">
      <div className="flex items-start justify-between gap-4">
        <div>
          <Badge className="bg-white/10 text-lilac">Pet / Companion</Badge>
          <h3 className="mt-4 text-2xl font-extrabold">Pixel Cat level {companion.level}</h3>
          <p className="mt-2 text-sm text-mist/70">
            Mood: {companion.mood} • Action: {companion.action}
          </p>
        </div>
        <div className="flex h-14 w-14 items-center justify-center rounded-lg bg-violet">
          <Sparkles className="h-7 w-7" />
        </div>
      </div>
      <div className="mt-6 grid gap-4 sm:grid-cols-3">
        <DarkProgress label="Affection" value={companion.affection} />
        <DarkProgress label="Energy" value={companion.energy} />
        <DarkProgress label="Interactions" value={Math.min(companion.totalInteractions, 100)} raw={companion.totalInteractions} />
      </div>
    </Card>
  );
}

export function WeatherCard({
  weather,
}: {
  weather: {
    greeting: { title: string; subtitle: string };
    current: { temperature: number; weatherCode: number };
    forecast: Array<{ day: string; temperature: number; rainChance: number }>;
  };
}) {
  return (
    <Card>
      <div className="flex items-start justify-between gap-4">
        <div>
          <Badge>
            <CloudSun className="mr-2 h-3.5 w-3.5" />
            Weather
          </Badge>
          <h3 className="mt-4 text-xl font-extrabold text-ink">{weather.greeting.title}</h3>
          <p className="mt-1 text-sm text-slate">{weather.greeting.subtitle}</p>
        </div>
        <p className="text-4xl font-extrabold text-violet">{weather.current.temperature}°</p>
      </div>
      <div className="mt-5 grid grid-cols-7 gap-2">
        {weather.forecast.map((day) => (
          <div className="rounded-lg bg-lilac/40 p-2 text-center" key={day.day}>
            <p className="text-xs font-bold text-slate">{day.day}</p>
            <p className="mt-1 text-sm font-extrabold text-ink">{day.temperature}°</p>
            <p className="text-[11px] font-semibold text-plum">{day.rainChance}%</p>
          </div>
        ))}
      </div>
    </Card>
  );
}

function DarkProgress({
  label,
  value,
  raw,
}: {
  label: string;
  value: number;
  raw?: number;
}) {
  return (
    <div>
      <div className="flex items-center justify-between text-sm font-semibold">
        <span>{label}</span>
        <span>{raw ?? value}</span>
      </div>
      <div className="mt-2 h-2 overflow-hidden rounded-full bg-white/15">
        <div className="h-full rounded-full bg-mint" style={{ width: `${Math.min(value, 100)}%` }} />
      </div>
    </div>
  );
}

function ChartFrame({
  children,
  mounted,
  height = 'h-[286px]',
}: {
  children: React.ReactElement;
  mounted: boolean;
  height?: string;
}) {
  const frameRef = useRef<HTMLDivElement>(null);
  const chartHeight = parseChartHeight(height);
  const [chartWidth, setChartWidth] = useState(0);

  useEffect(() => {
    if (!mounted || !frameRef.current) {
      return;
    }

    const node = frameRef.current;
    const updateSize = () => setChartWidth(Math.max(0, Math.floor(node.clientWidth)));
    updateSize();

    const observer = new ResizeObserver(updateSize);
    observer.observe(node);

    return () => observer.disconnect();
  }, [mounted]);

  return mounted ? (
    <div className={cn('mt-5 min-h-[220px] min-w-0 w-full overflow-hidden', height)} ref={frameRef}>
      {chartWidth > 0
        ? cloneElement(children, {
            height: chartHeight,
            width: chartWidth,
          } as Record<string, number>)
        : null}
    </div>
  ) : (
    <div className={cn('mt-5 animate-pulse rounded-lg bg-lilac/40', height)} />
  );
}

function parseChartHeight(heightClass: string) {
  const match = heightClass.match(/h-\[(\d+)px\]/);
  return match ? Number(match[1]) : 286;
}

export function EndpointRow({
  endpoint,
  ok = true,
}: {
  endpoint: string;
  ok?: boolean;
}) {
  return (
    <span className="inline-flex max-w-full items-center gap-2 rounded-md bg-cloud px-2 py-1 font-mono text-xs text-ink">
      {ok ? <CheckCircle2 className="h-3.5 w-3.5 shrink-0 text-mint" /> : <Database className="h-3.5 w-3.5 shrink-0 text-coral" />}
      <span className="min-w-0 truncate">{endpoint}</span>
    </span>
  );
}

const tooltipStyle = {
  border: '1px solid #dcd6ff',
  borderRadius: 8,
  boxShadow: '0 16px 40px rgba(23, 19, 52, 0.12)',
};
