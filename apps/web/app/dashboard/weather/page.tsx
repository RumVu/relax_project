'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  CloudRain,
  CloudSun,
  Droplets,
  MapPin,
  Navigation,
  RefreshCcw,
  Sun,
  Thermometer,
  Wind,
} from 'lucide-react';
import {
  Area,
  AreaChart,
  CartesianGrid,
  Line,
  LineChart,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  MetricCard,
  SectionTitle,
} from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { PremiumGate } from '@/components/dashboard/premium-gate';
import { apiFetch } from '@/lib/api';
import { isSecureContext, requestGeolocation } from '@/lib/permissions';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { useUserDashboardData } from '@/lib/live-dashboard';
import type { WeatherCurrent, WeatherForecast } from './weather-types';
import { buildAdvice, buildWeatherGreeting, describeWeatherCode, formatTemp, roundTemp, formatDay } from './weather-utils';

export default function WeatherPage() {
  const { t, locale } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const accountRole = useDashboardStore((state) => state.accountProfile?.role);
  const dashData = useUserDashboardData({});
  const planName = dashData.settings.billing.planName;
  const [current, setCurrent] = useState<WeatherCurrent | null>(null);
  const [forecast, setForecast] = useState<WeatherForecast | null>(null);
  const [loading, setLoading] = useState(true);
  const [locating, setLocating] = useState(false);
  // recharts ResponsiveContainer needs a client-side mount to size
  // itself; otherwise SSR markup hydrates to a 0×0 wrapper and the
  // chart never appears in light mode (just empty white space). Gate
  // the chart on this flag the same way every other dashboard page does.
  const [mounted, setMounted] = useState(false);
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMounted(true);
  }, []);

  const [loadError, setLoadError] = useState<string | null>(null);
  const reload = useCallback(async () => {
    setLoading(true);
    setLoadError(null);
    try {
      const [cur, fc] = await Promise.allSettled([
        apiFetch<WeatherCurrent>('/weather/me/current'),
        apiFetch<WeatherForecast>('/weather/me/forecast', undefined, {
          query: { forecastDays: 7 },
        }),
      ]);
      if (cur.status === 'fulfilled') {
        setCurrent(cur.value);
        // Diagnostic: nếu backend trả 200 nhưng không có data thì log shape
        // ra để dễ chẩn đoán (vd configured=false vì lat/lng chưa có).
        if (!cur.value?.current?.temperature && cur.value?.configured !== false) {
          // eslint-disable-next-line no-console
          console.warn('Weather /current returned without temperature:', cur.value);
        }
      } else {
        // eslint-disable-next-line no-console
        console.error('Weather /current failed:', cur.reason);
      }
      if (fc.status === 'fulfilled') {
        setForecast(fc.value);
        if (!fc.value?.forecast?.length && fc.value?.configured !== false) {
          // eslint-disable-next-line no-console
          console.warn('Weather /forecast returned empty list:', fc.value);
        }
      } else {
        // eslint-disable-next-line no-console
        console.error('Weather /forecast failed:', fc.reason);
      }
      // Đẩy lỗi lên UI nếu BẤT KỲ endpoint nào chết (trước đây chỉ báo khi
      // cả 2 cùng fail, làm a thấy "Mưa hôm nay" và "Dự báo 7 ngày" trống
      // mà không có cảnh báo gì).
      const failed = [
        cur.status === 'rejected' ? { name: 'current', reason: cur.reason } : null,
        fc.status === 'rejected' ? { name: 'forecast', reason: fc.reason } : null,
      ].filter(Boolean) as Array<{ name: string; reason: unknown }>;
      if (failed.length > 0) {
        const reasons = failed
          .map(
            (f) =>
              `${f.name}: ${f.reason instanceof Error ? f.reason.message : String(f.reason)}`,
          )
          .join(' · ');
        setLoadError(reasons);
        pushToast({
          tone: 'error',
          title: t('weather.loadFailed.title'),
          message: reasons,
        });
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      // eslint-disable-next-line no-console
      console.error('Weather reload threw:', err);
      setLoadError(message);
      pushToast({
        tone: 'error',
        title: t('weather.loadFailed.title'),
        message,
      });
    } finally {
      setLoading(false);
    }
  }, [pushToast, t]);

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void reload();
  }, [reload]);

  const useMyLocation = useCallback(async () => {
    setLocating(true);
    try {
      const pos = await requestGeolocation();
      await apiFetch('/weather/me/location', {
        method: 'PATCH',
        body: JSON.stringify({
          latitude: pos.coords.latitude,
          longitude: pos.coords.longitude,
          weatherEnabled: true,
        }),
      });
      pushToast({
        tone: 'success',
        title: t('weather.locateGranted'),
        message: t('weather.locateGranted.message'),
      });
      await reload();
    } catch (error) {
      const message =
        error instanceof Error
          ? error.message
          : t('weather.locateFailed');
      pushToast({
        tone: 'error',
        title: t('weather.locateFailed.title'),
        message,
      });
    } finally {
      setLocating(false);
    }
  }, [pushToast, reload, t]);

  const advice = useMemo(
    () => buildAdvice(current, forecast?.forecast?.[0], t),
    [current, forecast, t],
  );
  const greeting = useMemo(() => buildWeatherGreeting(current, t), [current, t]);

  const chartData = useMemo(
    () =>
      (forecast?.forecast ?? []).map((d) => ({
        day: formatDay(d.date, locale),
        high: roundTemp(d.temperatureMax),
        low: roundTemp(d.temperatureMin),
        rain: Math.round(d.precipitationProbability ?? 0),
      })),
    [forecast, locale],
  );

  const locationMissing =
    current?.configured === false || current?.reason === 'LOCATION_MISSING';
  const [secure, setSecure] = useState(true);
  // eslint-disable-next-line react-hooks/set-state-in-effect
  useEffect(() => setSecure(isSecureContext()), []);

  return (
    <DashboardShell eyebrow={t('weather.eyebrow')} title={t('weather.title')}>
      {!secure ? (
        <Card className="border-coral/40 bg-coral/10">
          <p className="text-lg font-extrabold text-[var(--app-text,theme(colors.ink))]">
            {t('weather.insecure.title')}
          </p>
          <p className="mt-1 text-sm text-[var(--app-muted,theme(colors.slate))]">
            {t('weather.insecure.copy.before')}{' '}
            <code className="rounded bg-[var(--field-bg)] px-1 py-0.5 text-xs">
              {typeof window !== 'undefined' ? window.location.origin : 'http://…'}
            </code>{' '}
            {t('weather.insecure.copy.after')}
          </p>
          <ul className="mt-2 list-disc pl-6 text-sm text-[var(--app-muted,theme(colors.slate))]">
            <li>
              {t('weather.insecure.localhost.before')} <code>http://localhost:3233</code>{' '}
              {t('weather.insecure.localhost.after')}
            </li>
            <li>
              {t('weather.insecure.https')}
            </li>
          </ul>
        </Card>
      ) : null}
      {loadError ? (
        <Card className="border-coral/40 bg-coral/10">
          <p className="text-lg font-extrabold text-[var(--app-text,theme(colors.ink))]">
            {t('weather.loadFailed.title')}
          </p>
          <p className="mt-1 text-sm text-[var(--app-muted,theme(colors.slate))]">
            {loadError}
          </p>
          <p className="mt-2 text-xs text-[var(--app-muted,theme(colors.slate))]">
            {t('weather.loadFailed.hint')}
          </p>
        </Card>
      ) : null}
      {locationMissing ? (
        <Card className="border-coral/40 bg-coral/10">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <p className="text-lg font-extrabold text-[var(--app-text,theme(colors.ink))]">
                {t('weather.missing.title')}
              </p>
              <p className="mt-1 text-sm text-[var(--app-muted,theme(colors.slate))]">
                {t('weather.missing.copy')}
              </p>
            </div>
            <Button disabled={locating} onClick={useMyLocation}>
              <Navigation className="h-4 w-4" />
              {locating ? t('weather.locating') : t('weather.locate')}
            </Button>
          </div>
        </Card>
      ) : null}

      <Card>
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--app-muted,theme(colors.plum))]">
              {t('weather.location.heading')}
            </p>
            <h3 className="mt-2 text-2xl font-extrabold text-[var(--app-text,theme(colors.ink))]">
              {greeting.title}
            </h3>
            <p className="mt-1 text-sm text-[var(--app-muted,theme(colors.slate))]">
              {greeting.subtitle}
            </p>
            {current?.location?.name ? (
              <p className="mt-3 inline-flex items-center gap-2 rounded-full bg-[var(--field-bg)] px-3 py-1 text-xs font-bold text-[var(--app-text,theme(colors.ink))]">
                <MapPin className="h-3.5 w-3.5 text-violet" />
                {current.location.name}
              </p>
            ) : null}
          </div>
          <div className="flex items-center gap-3">
            <div className="text-right">
              <p className="text-5xl font-extrabold text-violet">
                {formatTemp(current?.current?.temperature)}°
              </p>
              <p className="text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
                {t('weather.metric.feelsLike')} {formatTemp(current?.current?.apparentTemperature)}°
              </p>
            </div>
            <Button onClick={reload} variant="secondary">
              <RefreshCcw className="h-4 w-4" />
              {t('common.refresh')}
            </Button>
          </div>
        </div>
      </Card>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={Sun}
          label={t('weather.metric.status')}
          tone="sun"
          value={describeWeatherCode(
            current?.current?.weatherCode,
            current?.current?.isDay,
            t,
          )}
        />
        <MetricCard
          icon={Droplets}
          label={t('weather.metric.humidity')}
          tone="lilac"
          value={
            current?.current?.humidity != null
              ? `${Math.round(current.current.humidity)}%`
              : '—'
          }
        />
        <MetricCard
          icon={Wind}
          label={t('weather.metric.wind')}
          tone="mint"
          value={
            current?.current?.windSpeed != null
              ? `${Math.round(current.current.windSpeed)} km/h`
              : '—'
          }
        />
        <MetricCard
          icon={CloudRain}
          label={t('weather.metric.rainToday')}
          value={
            forecast?.forecast?.[0]?.precipitationProbability != null
              ? `${Math.round(forecast.forecast[0].precipitationProbability)}%`
              : '—'
          }
        />
      </div>

      <Card>
        <SectionTitle
          title={t('weather.section.advice')}
          copy={t('weather.section.advice.copy')}
          action={<Thermometer className="h-5 w-5 text-violet" />}
        />
        <ul className="mt-4 grid gap-2 text-sm font-medium text-[var(--app-text,theme(colors.ink))] sm:grid-cols-2">
          {advice.map((tip, index) => (
            <li
              className="flex items-start gap-2 rounded-lg border border-[var(--field-border)] bg-[var(--panel-bg)] p-3"
              key={index}
            >
              <span className="mt-0.5 text-violet">•</span>
              <span>{tip}</span>
            </li>
          ))}
        </ul>
      </Card>

      <PremiumGate planName={planName} role={accountRole}>
      <div className="flex flex-col gap-4">
      <Card>
        <SectionTitle
          title={t('weather.forecast.title')}
          copy={t('weather.forecast.copy')}
          action={<CloudSun className="h-5 w-5 text-violet" />}
        />
        <ChartBox emptyHint={loading ? t('weather.forecast.loading') : t('weather.forecast.empty')} hasData={chartData.length > 0} height={260} mounted={mounted}>
          {(width) => (
            <LineChart data={chartData} height={260} margin={{ left: -18, right: 8, top: 16 }} width={width}>
              <CartesianGrid stroke="var(--field-border)" strokeDasharray="3 3" />
              <XAxis dataKey="day" stroke="var(--app-muted)" tickLine={false} />
              <YAxis domain={['auto', 'auto']} stroke="var(--app-muted)" tickLine={false} width={32} />
              <Tooltip
                contentStyle={{
                  background: 'var(--panel-strong)',
                  border: '1px solid var(--field-border)',
                  color: 'var(--app-text)',
                }}
              />
              <Line dataKey="high" dot={{ r: 3 }} name={t('weather.forecast.high')} stroke="#ef767a" strokeWidth={2} type="monotone" />
              <Line dataKey="low" dot={{ r: 3 }} name={t('weather.forecast.low')} stroke="#7357f6" strokeWidth={2} type="monotone" />
            </LineChart>
          )}
        </ChartBox>
        <ChartBox className="mt-4" emptyHint="" hasData={chartData.length > 0} height={160} mounted={mounted}>
          {(width) => (
            <AreaChart data={chartData} height={160} margin={{ left: -18, right: 8, top: 8 }} width={width}>
                <defs>
                  <linearGradient id="rainFill" x1="0" x2="0" y1="0" y2="1">
                    <stop offset="0%" stopColor="#7357f6" stopOpacity={0.45} />
                    <stop offset="100%" stopColor="#7357f6" stopOpacity={0.02} />
                  </linearGradient>
                </defs>
                <CartesianGrid stroke="var(--field-border)" strokeDasharray="3 3" />
                <XAxis
                  dataKey="day"
                  stroke="var(--app-muted)"
                  tickLine={false}
                />
                <YAxis
                  domain={[0, 100]}
                  stroke="var(--app-muted)"
                  tickLine={false}
                  unit="%"
                  width={36}
                />
                <Tooltip
                  contentStyle={{
                    background: 'var(--panel-strong)',
                    border: '1px solid var(--field-border)',
                    color: 'var(--app-text)',
                  }}
                />
                <Area
                  dataKey="rain"
                  fill="url(#rainFill)"
                  name={t('weather.forecast.rain')}
                  stroke="#7357f6"
                  strokeWidth={2}
                  type="monotone"
                />
              </AreaChart>
          )}
        </ChartBox>
      </Card>

      <Card>
        <SectionTitle
          title={t('weather.forecast.detailTitle')}
          copy={t('weather.forecast.detailCopy')}
          action={<CloudSun className="h-5 w-5 text-violet" />}
        />
        <div className="mt-5 grid gap-3 sm:grid-cols-3 xl:grid-cols-7">
          {(forecast?.forecast ?? []).map((day) => (
            <div
              className="rounded-xl border border-[var(--field-border)] bg-[var(--panel-bg)] p-3"
              key={day.date}
            >
              <p className="text-xs font-bold text-[var(--app-muted,theme(colors.slate))]">
                {formatDay(day.date, locale)}
              </p>
              <p className="mt-2 text-lg font-extrabold text-[var(--app-text,theme(colors.ink))]">
                {formatTemp(day.temperatureMax)}° / {formatTemp(day.temperatureMin)}°
              </p>
              <p className="mt-1 text-xs font-semibold text-violet">
                {t('weather.forecast.rainValue', { percent: Math.round(day.precipitationProbability ?? 0) })}
              </p>
              <p className="mt-1 text-[11px] text-[var(--app-muted,theme(colors.slate))]">
                {describeWeatherCode(day.weatherCode, true, t)}
              </p>
            </div>
          ))}
          {!forecast?.forecast?.length && !loading ? (
            <p className="col-span-full text-sm font-medium text-[var(--app-muted,theme(colors.slate))]">
              {t('weather.forecast.noData')}
            </p>
          ) : null}
        </div>
      </Card>
      </div>
      </PremiumGate>
    </DashboardShell>
  );
}

/**
 * Wraps a recharts chart in a width-measuring container. recharts'
 * ResponsiveContainer kept rendering as a 0×0 div under Next 16 canary,
 * so we measure the parent width ourselves with ResizeObserver and pass
 * it down. Same approach the analytics page uses (ChartFrame in
 * dashboard-ui), reproduced here without the prop coupling.
 */
function ChartBox({
  children,
  className,
  emptyHint,
  hasData,
  height,
  mounted,
}: {
  children: (width: number) => React.ReactElement;
  className?: string;
  emptyHint: string;
  hasData: boolean;
  height: number;
  mounted: boolean;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const [width, setWidth] = useState(0);

  useEffect(() => {
    if (!mounted || !ref.current) return;
    const observer = new ResizeObserver((entries) => {
      const next = Math.floor(entries[0]?.contentRect.width ?? 0);
      if (next > 0) setWidth(next);
    });
    observer.observe(ref.current);
    return () => observer.disconnect();
  }, [mounted]);

  return (
    <div
      className={className ?? 'mt-5'}
      ref={ref}
      style={{ height, width: '100%' }}
    >
      {mounted && hasData && width > 0 ? (
        children(width)
      ) : (
        <div className="flex h-full items-center justify-center text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
          {emptyHint}
        </div>
      )}
    </div>
  );
}
