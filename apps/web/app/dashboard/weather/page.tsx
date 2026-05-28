'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
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
  ResponsiveContainer,
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
import { useUiStore } from '@/stores/use-ui-store';

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
    apparentTemperature?: number;
    humidity?: number;
    windSpeed?: number;
    weatherCode?: number;
    isDay?: boolean;
    precipitation?: number;
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
  const pushToast = useUiStore((state) => state.pushToast);
  const [current, setCurrent] = useState<WeatherCurrent | null>(null);
  const [forecast, setForecast] = useState<WeatherForecast | null>(null);
  const [loading, setLoading] = useState(true);
  const [locating, setLocating] = useState(false);

  const reload = useCallback(async () => {
    setLoading(true);
    try {
      const [cur, fc] = await Promise.allSettled([
        apiFetch<WeatherCurrent>('/weather/me/current'),
        apiFetch<WeatherForecast>('/weather/me/forecast', undefined, {
          query: { forecastDays: 7 },
        }),
      ]);
      if (cur.status === 'fulfilled') setCurrent(cur.value);
      if (fc.status === 'fulfilled') setForecast(fc.value);
    } catch {
      // surfaced via the UI state below
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void reload();
  }, [reload]);

  const useMyLocation = useCallback(async () => {
    if (typeof navigator === 'undefined' || !navigator.geolocation) {
      pushToast({
        tone: 'error',
        title: 'Trình duyệt không hỗ trợ định vị',
      });
      return;
    }
    setLocating(true);
    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        try {
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
            title: 'Đã cập nhật vị trí',
            message: 'Đang lấy thời tiết theo vị trí hiện tại của anh.',
          });
          await reload();
        } catch {
          pushToast({ tone: 'error', title: 'Không lưu được vị trí' });
        } finally {
          setLocating(false);
        }
      },
      (err) => {
        setLocating(false);
        pushToast({
          tone: 'error',
          title: 'Không lấy được vị trí',
          message: err.message,
        });
      },
      { enableHighAccuracy: true, timeout: 10_000 },
    );
  }, [pushToast, reload]);

  const advice = useMemo(
    () => buildAdvice(current, forecast?.forecast?.[0]),
    [current, forecast],
  );

  const chartData = useMemo(
    () =>
      (forecast?.forecast ?? []).map((d) => ({
        day: formatDay(d.date),
        high: roundTemp(d.temperatureMax),
        low: roundTemp(d.temperatureMin),
        rain: Math.round(d.precipitationProbability ?? 0),
      })),
    [forecast],
  );

  const locationMissing =
    current?.configured === false || current?.reason === 'LOCATION_MISSING';

  return (
    <DashboardShell eyebrow="Atmosphere" title="Thời tiết">
      {locationMissing ? (
        <Card className="border-coral/40 bg-coral/10">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <p className="text-lg font-extrabold text-[var(--app-text,theme(colors.ink))]">
                Cần cấp vị trí cho app
              </p>
              <p className="mt-1 text-sm text-[var(--app-muted,theme(colors.slate))]">
                Bấm nút bên phải để dùng vị trí trình duyệt — app sẽ lưu
                lat/long và lấy thời tiết theo nơi anh đang ngồi.
              </p>
            </div>
            <Button disabled={locating} onClick={useMyLocation}>
              <Navigation className="h-4 w-4" />
              {locating ? 'Đang định vị…' : 'Dùng vị trí của tôi'}
            </Button>
          </div>
        </Card>
      ) : null}

      <Card>
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[var(--app-muted,theme(colors.plum))]">
              Khu vực
            </p>
            <h3 className="mt-2 text-2xl font-extrabold text-[var(--app-text,theme(colors.ink))]">
              {current?.greeting?.title ?? 'Đang tải…'}
            </h3>
            <p className="mt-1 text-sm text-[var(--app-muted,theme(colors.slate))]">
              {current?.greeting?.subtitle ?? '—'}
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
                cảm giác {formatTemp(current?.current?.apparentTemperature)}°
              </p>
            </div>
            <Button onClick={reload} variant="secondary">
              <RefreshCcw className="h-4 w-4" />
              Refresh
            </Button>
          </div>
        </div>
      </Card>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={Sun}
          label="Trạng thái"
          tone="sun"
          value={describeWeatherCode(
            current?.current?.weatherCode,
            current?.current?.isDay,
          )}
        />
        <MetricCard
          icon={Droplets}
          label="Độ ẩm"
          tone="lilac"
          value={
            current?.current?.humidity != null
              ? `${Math.round(current.current.humidity)}%`
              : '—'
          }
        />
        <MetricCard
          icon={Wind}
          label="Gió"
          tone="mint"
          value={
            current?.current?.windSpeed != null
              ? `${Math.round(current.current.windSpeed)} km/h`
              : '—'
          }
        />
        <MetricCard
          icon={CloudRain}
          label="Mưa hôm nay"
          value={
            forecast?.forecast?.[0]?.precipitationProbability != null
              ? `${Math.round(forecast.forecast[0].precipitationProbability)}%`
              : '—'
          }
        />
      </div>

      <Card>
        <SectionTitle
          title="Lời khuyên cho hôm nay"
          copy="Sinh ra từ thời tiết hiện tại + dự báo trong ngày."
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
          title="Dự báo 7 ngày"
          copy="Nhiệt độ cao/thấp và xác suất mưa từng ngày."
          action={<CloudSun className="h-5 w-5 text-violet" />}
        />
        <div className="mt-5 h-[260px]">
          {chartData.length > 0 ? (
            <ResponsiveContainer height="100%" width="100%">
              <LineChart data={chartData} margin={{ left: -18, right: 8, top: 16 }}>
                <CartesianGrid stroke="var(--field-border)" strokeDasharray="3 3" />
                <XAxis
                  dataKey="day"
                  stroke="var(--app-muted)"
                  tickLine={false}
                />
                <YAxis
                  domain={['auto', 'auto']}
                  stroke="var(--app-muted)"
                  tickLine={false}
                  width={32}
                />
                <Tooltip
                  contentStyle={{
                    background: 'var(--panel-strong)',
                    border: '1px solid var(--field-border)',
                    color: 'var(--app-text)',
                  }}
                />
                <Line
                  dataKey="high"
                  dot={{ r: 3 }}
                  name="Cao"
                  stroke="#ef767a"
                  strokeWidth={2}
                  type="monotone"
                />
                <Line
                  dataKey="low"
                  dot={{ r: 3 }}
                  name="Thấp"
                  stroke="#7357f6"
                  strokeWidth={2}
                  type="monotone"
                />
              </LineChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex h-full items-center justify-center text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
              {loading ? 'Đang tải dự báo…' : 'Chưa có dữ liệu — cấp vị trí trước.'}
            </div>
          )}
        </div>
        <div className="mt-4 h-[160px]">
          {chartData.length > 0 ? (
            <ResponsiveContainer height="100%" width="100%">
              <AreaChart data={chartData} margin={{ left: -18, right: 8, top: 8 }}>
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
                  name="Xác suất mưa"
                  stroke="#7357f6"
                  strokeWidth={2}
                  type="monotone"
                />
              </AreaChart>
            </ResponsiveContainer>
          ) : null}
        </div>
      </Card>

      <Card>
        <SectionTitle
          title="Chi tiết từng ngày"
          copy="Mỗi card là một ngày trong tuần tới."
          action={<CloudSun className="h-5 w-5 text-violet" />}
        />
        <div className="mt-5 grid gap-3 sm:grid-cols-3 xl:grid-cols-7">
          {(forecast?.forecast ?? []).map((day) => (
            <div
              className="rounded-xl border border-[var(--field-border)] bg-[var(--panel-bg)] p-3"
              key={day.date}
            >
              <p className="text-xs font-bold text-[var(--app-muted,theme(colors.slate))]">
                {formatDay(day.date)}
              </p>
              <p className="mt-2 text-lg font-extrabold text-[var(--app-text,theme(colors.ink))]">
                {formatTemp(day.temperatureMax)}° / {formatTemp(day.temperatureMin)}°
              </p>
              <p className="mt-1 text-xs font-semibold text-violet">
                {Math.round(day.precipitationProbability ?? 0)}% mưa
              </p>
              <p className="mt-1 text-[11px] text-[var(--app-muted,theme(colors.slate))]">
                {describeWeatherCode(day.weatherCode, true)}
              </p>
            </div>
          ))}
          {!forecast?.forecast?.length && !loading ? (
            <p className="col-span-full text-sm font-medium text-[var(--app-muted,theme(colors.slate))]">
              Chưa có dữ liệu dự báo.
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
): string[] {
  if (!current || current.configured === false) {
    return [
      'Cấp vị trí cho app để bắt đầu nhận thông tin thời tiết.',
      'Bấm "Dùng vị trí của tôi" ở trên — chỉ cần 1 click.',
    ];
  }
  const tips: string[] = [];
  const temp = current.current?.temperature;
  const apparent = current.current?.apparentTemperature ?? temp;
  const isDay = current.current?.isDay ?? true;
  const humidity = current.current?.humidity ?? 0;
  const wind = current.current?.windSpeed ?? 0;
  const rainChance = today?.precipitationProbability ?? 0;

  if (temp != null) {
    if (temp >= 33) {
      tips.push('Trời đang nóng (≥ 33°). Uống nhiều nước, tránh ra nắng từ 11–15h.');
    } else if (temp >= 28) {
      tips.push('Nắng ấm — mặc đồ thoáng, bôi kem chống nắng nếu ra ngoài.');
    } else if (temp >= 22) {
      tips.push('Nhiệt độ dễ chịu, hợp đi bộ nhẹ hoặc chạy bộ ngắn.');
    } else if (temp >= 16) {
      tips.push('Hơi mát — mang theo áo khoác mỏng nếu ra ngoài lâu.');
    } else {
      tips.push('Trời lạnh — mặc thêm lớp giữ ấm và uống đồ ấm.');
    }
  }

  if (apparent != null && Math.abs((apparent ?? 0) - (temp ?? 0)) >= 3) {
    tips.push(`Cảm giác ngoài trời ${Math.round(apparent)}° (chênh với nhiệt độ thực).`);
  }

  if (rainChance >= 60) {
    tips.push(`Xác suất mưa ${Math.round(rainChance)}% — mang ô / áo mưa.`);
  } else if (rainChance >= 30) {
    tips.push('Có khả năng mưa rải rác trong ngày, để ô gần cửa cho an tâm.');
  }

  if (humidity >= 85) {
    tips.push('Độ ẩm cao — phòng ngủ bật quạt/máy hút ẩm nếu có.');
  } else if (humidity <= 35) {
    tips.push('Không khí khô — uống thêm nước và dùng dưỡng ẩm.');
  }

  if (wind >= 35) {
    tips.push(`Gió mạnh (${Math.round(wind)} km/h) — cẩn thận khi đi xe máy.`);
  }

  if (!isDay) {
    tips.push('Đã muộn — nếu đi ngoài nhớ mặc đồ sáng màu cho dễ thấy.');
  }

  if (tips.length === 0) {
    tips.push('Thời tiết ổn định — tận hưởng một ngày yên ả nha.');
  }
  return tips;
}

function describeWeatherCode(code: number | undefined, isDay: boolean | undefined): string {
  // Open-Meteo WMO weather codes — abbreviated for the UI.
  if (code == null) return '—';
  if (code === 0) return isDay === false ? 'Trời quang (đêm)' : 'Trời quang';
  if (code <= 2) return 'Chủ yếu quang';
  if (code === 3) return 'Nhiều mây';
  if (code >= 45 && code <= 48) return 'Sương mù';
  if (code >= 51 && code <= 57) return 'Mưa phùn';
  if (code >= 61 && code <= 67) return 'Mưa';
  if (code >= 71 && code <= 77) return 'Tuyết';
  if (code >= 80 && code <= 82) return 'Mưa rào';
  if (code >= 85 && code <= 86) return 'Mưa tuyết';
  if (code >= 95) return 'Dông';
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

function formatDay(date: string | undefined): string {
  if (!date) return '—';
  try {
    const d = new Date(date);
    return d.toLocaleDateString('vi-VN', { weekday: 'short', day: '2-digit' });
  } catch {
    return date;
  }
}
