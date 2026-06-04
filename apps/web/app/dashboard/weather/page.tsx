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
import { apiFetch } from '@/lib/api';
import { isSecureContext, requestGeolocation } from '@/lib/permissions';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import type { TranslationKey } from '@/lib/i18n/dictionaries';

type TranslationFn = (key: TranslationKey, params?: Record<string, string | number>) => string;

type WeatherCurrent = {
  configured?: boolean;
  reason?: string;
  greeting?: {
    title?: string;
    subtitle?: string;
    iconKey?: string;
    displayName?: string;
  };
  current?: {
    temperature?: number;
    temperatureUnit?: string;
    apparentTemperature?: number;
    humidity?: number;
    humidityUnit?: string;
    windSpeed?: number;
    windSpeedUnit?: string;
    windDirection?: number;
    precipitation?: number;
    precipitationUnit?: string;
    weatherCode?: number;
    isDay?: boolean;
  };
  location?: {
    name?: string;
    latitude?: number;
    longitude?: number;
    timezone?: string;
  };
};

type ForecastDay = {
  date: string;
  temperatureMax?: number;
  temperatureMin?: number;
  precipitationProbability?: number;
  precipitationSum?: number;
  windSpeedMax?: number;
  weatherCode?: number;
};

type WeatherForecast = {
  configured?: boolean;
  reason?: string;
  forecast?: ForecastDay[];
  hourly?: Array<{
    time: string;
    temperature?: number;
    precipitationProbability?: number;
  }>;
};

export default function WeatherPage() {
  const { t, locale } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
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
    </DashboardShell>
  );
}

function buildAdvice(
  current: WeatherCurrent | null,
  today: ForecastDay | undefined,
  t: TranslationFn,
): string[] {
  if (!current || current.configured === false) {
    return [
      t('weather.advice.needLocation'),
      t('weather.advice.needLocationAction'),
    ];
  }
  const tips: string[] = [];
  const temp = current.current?.temperature;
  const apparent = current.current?.apparentTemperature ?? temp;
  const isDay = current.current?.isDay ?? true;
  const humidity = current.current?.humidity ?? 0;
  const wind = current.current?.windSpeed ?? 0;
  const rainChance = today?.precipitationProbability ?? 0;
  const code = current.current?.weatherCode;
  const todayHigh = today?.temperatureMax;
  const todayLow = today?.temperatureMin;
  const now = new Date();
  const hour = now.getHours();
  const day = now.getDay(); // 0=Sun ... 6=Sat
  const isWeekend = day === 0 || day === 6;
  const month = now.getMonth() + 1;

  // ---- Temperature buckets ------------------------------------------------
  if (temp != null) {
    if (temp >= 36) {
      tips.push(t('weather.advice.temp.extreme'));
      tips.push(t('weather.advice.temp.water'));
    } else if (temp >= 33) {
      tips.push(t('weather.advice.temp.hot'));
      tips.push(t('weather.advice.temp.lightLunch'));
    } else if (temp >= 28) {
      tips.push(t('weather.advice.temp.warm'));
    } else if (temp >= 24) {
      tips.push(t('weather.advice.temp.comfort'));
    } else if (temp >= 20) {
      tips.push(t('weather.advice.temp.cool'));
    } else if (temp >= 16) {
      tips.push(t('weather.advice.temp.chilly'));
    } else if (temp >= 10) {
      tips.push(t('weather.advice.temp.cold'));
    } else {
      tips.push(t('weather.advice.temp.freezing'));
    }
  }

  // ---- Apparent vs actual -------------------------------------------------
  if (apparent != null && temp != null && Math.abs(apparent - temp) >= 3) {
    const direction = apparent > temp ? t('weather.advice.apparent.hotter') : t('weather.advice.apparent.cooler');
    tips.push(
      t('weather.advice.apparent', { apparent: Math.round(apparent), direction, temp: Math.round(temp) }),
    );
  }

  // ---- Day temp swing -----------------------------------------------------
  if (todayHigh != null && todayLow != null && todayHigh - todayLow >= 10) {
    tips.push(
      t('weather.advice.swing', { low: Math.round(todayLow), high: Math.round(todayHigh) }),
    );
  }

  // ---- Rain ---------------------------------------------------------------
  if (rainChance >= 80) {
    tips.push(t('weather.advice.rain.veryHigh', { percent: Math.round(rainChance) }));
    tips.push(t('weather.advice.rain.flood'));
  } else if (rainChance >= 60) {
    tips.push(t('weather.advice.rain.high', { percent: Math.round(rainChance) }));
  } else if (rainChance >= 40) {
    tips.push(t('weather.advice.rain.scattered'));
  } else if (rainChance >= 20) {
    tips.push(t('weather.advice.rain.low'));
  }

  // ---- Humidity -----------------------------------------------------------
  if (humidity >= 90) {
    tips.push(t('weather.advice.humidity.veryHigh'));
  } else if (humidity >= 80) {
    tips.push(t('weather.advice.humidity.high'));
  } else if (humidity <= 30) {
    tips.push(t('weather.advice.humidity.dry'));
  } else if (humidity <= 45) {
    tips.push(t('weather.advice.humidity.slightDry'));
  }

  // ---- Wind ---------------------------------------------------------------
  if (wind >= 50) {
    tips.push(t('weather.advice.wind.veryStrong', { wind: Math.round(wind) }));
  } else if (wind >= 30) {
    tips.push(t('weather.advice.wind.strong', { wind: Math.round(wind) }));
  } else if (wind >= 15) {
    tips.push(t('weather.advice.wind.light'));
  }

  // ---- Storm / specific weather codes -------------------------------------
  if (code != null && code >= 95) {
    tips.push(t('weather.advice.code.storm'));
  }
  if (code != null && code >= 45 && code <= 48) {
    tips.push(t('weather.advice.code.fog'));
  }
  if (code != null && code >= 80 && code <= 82) {
    tips.push(t('weather.advice.code.showers'));
  }

  // ---- Time of day --------------------------------------------------------
  if (hour >= 5 && hour < 9) {
    tips.push(t('weather.advice.time.morning'));
  } else if (hour >= 11 && hour < 14) {
    tips.push(t('weather.advice.time.noon'));
  } else if (hour >= 14 && hour < 17) {
    tips.push(t('weather.advice.time.afternoon'));
  } else if (hour >= 17 && hour < 20) {
    tips.push(t('weather.advice.time.evening'));
  } else if (hour >= 20 && hour < 23) {
    tips.push(t('weather.advice.time.night'));
  } else if (hour >= 23 || hour < 5) {
    tips.push(t('weather.advice.time.late'));
  }

  // ---- Weekend / weekday --------------------------------------------------
  if (isWeekend) {
    tips.push(t('weather.advice.weekend'));
  } else {
    tips.push(t('weather.advice.weekday'));
  }

  // ---- Seasonal hints (VN miền Nam) ---------------------------------------
  if (month >= 5 && month <= 10) {
    tips.push(t('weather.advice.season.rainy'));
  } else if (month >= 11 || month <= 2) {
    tips.push(t('weather.advice.season.dry'));
  } else {
    tips.push(t('weather.advice.season.transition'));
  }

  // ---- Day/night ----------------------------------------------------------
  if (!isDay) {
    tips.push(t('weather.advice.dayNight.night'));
  } else if (temp != null && temp >= 28) {
    tips.push(t('weather.advice.dayNight.sun'));
  }

  // ---- Always-on mindfulness ---------------------------------------------
  tips.push(t('weather.advice.mindfulness'));

  return tips;
}

function buildWeatherGreeting(current: WeatherCurrent | null, t: TranslationFn) {
  if (!current) {
    return { title: t('common.loading'), subtitle: '—' };
  }
  if (current.configured === false) {
    return {
      title: t('weather.missing.title'),
      subtitle: t('weather.missing.copy'),
    };
  }

  const temp = current.current?.temperature;
  const code = current.current?.weatherCode;
  const isDay = current.current?.isDay;
  const hour = new Date().getHours();
  const period =
    hour >= 23 || hour < 5
      ? 'late'
      : hour < 11
        ? 'morning'
        : hour < 17
          ? 'day'
          : hour < 21
            ? 'evening'
            : 'night';
  const condition = describeWeatherCode(code, isDay, t).toLowerCase();
  const tempLabel = temp == null ? '' : t('weather.greeting.temp', { temp: Math.round(temp) });

  return {
    title: t(`weather.greeting.${period}` as TranslationKey),
    subtitle: tempLabel
      ? t('weather.greeting.subtitleWithTemp', { condition, temp: tempLabel })
      : t('weather.greeting.subtitle', { condition }),
  };
}

function describeWeatherCode(code: number | undefined, isDay: boolean | undefined, t: TranslationFn): string {
  // Open-Meteo WMO weather codes — abbreviated for the UI.
  if (code == null) return '—';
  if (code === 0) return isDay === false ? t('weather.code.clearNight') : t('weather.code.clear');
  if (code <= 2) return t('weather.code.mainlyClear');
  if (code === 3) return t('weather.code.cloudy');
  if (code >= 45 && code <= 48) return t('weather.code.fog');
  if (code >= 51 && code <= 57) return t('weather.code.drizzle');
  if (code >= 61 && code <= 67) return t('weather.code.rain');
  if (code >= 71 && code <= 77) return t('weather.code.snow');
  if (code >= 80 && code <= 82) return t('weather.code.showers');
  if (code >= 85 && code <= 86) return t('weather.code.snowShowers');
  if (code >= 95) return t('weather.code.thunderstorm');
  return '—';
}

function formatTemp(value: number | undefined): string {
  if (value == null || Number.isNaN(value)) return '—';
  return String(Math.round(value));
}

function roundTemp(value: number | undefined): number | null {
  if (value == null || Number.isNaN(value)) return null;
  return Math.round(value);
}

function formatDay(date: string | undefined, locale: string): string {
  if (!date) return '—';
  try {
    const d = new Date(date);
    return d.toLocaleDateString(locale === 'vi' ? 'vi-VN' : 'en-US', { weekday: 'short', day: '2-digit' });
  } catch {
    return date;
  }
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
