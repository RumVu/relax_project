'use client';

import { useCallback, useEffect, useState } from 'react';
import {
  TrendingUp,
  TrendingDown,
  Minus,
  AlertTriangle,
  BarChart3,
} from 'lucide-react';
import { apiFetch } from '@/lib/api';
import { Badge } from '@/components/ui/badge';
import { Card } from '@/components/ui/card';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

interface ForecastDay {
  date: string;
  dayOfWeek: number;
  predictedScore: number;
  predictedMood: string;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH';
  confidence: number;
  suggestion: string;
}

interface Trigger {
  trigger: string;
  count: number;
  negativeRate: number;
}

interface ForecastData {
  forecast: ForecastDay[];
  recentTrend: { direction: string; magnitude: number };
  topTriggers: Trigger[];
}

const DAY_LABELS = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

const RISK_COLOR: Record<string, string> = {
  HIGH: 'bg-red-500/15 text-red-500',
  MEDIUM: 'bg-amber-500/15 text-amber-500',
  LOW: 'bg-mint/15 text-mint',
};

export function MoodForecastPanel() {
  const { t } = useTranslation();
  const refreshNonce = useDashboardStore((s) => s.refreshNonce);
  const [data, setData] = useState<ForecastData | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await apiFetch<ForecastData>(
        '/mood-forecast/me/predictions?days=7',
      );
      setData(res);
    } catch {
      // silent
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load, refreshNonce]);

  const trend = data?.recentTrend;
  const TrendIcon =
    trend?.direction === 'improving'
      ? TrendingUp
      : trend?.direction === 'declining'
        ? TrendingDown
        : Minus;

  const trendColor =
    trend?.direction === 'improving'
      ? 'text-mint'
      : trend?.direction === 'declining'
        ? 'text-red-500'
        : 'text-violet';

  return (
    <Card>
      <SectionTitle
        title={t('moodForecast.title' as any)}
        copy={t('moodForecast.copy' as any)}
        action={<BarChart3 className="h-5 w-5 text-violet" />}
      />

      {loading && !data && (
        <p className="py-8 text-center text-sm text-muted">
          {t('moodForecast.loading' as any)}
        </p>
      )}

      {!loading && !data?.forecast?.length && (
        <div className="flex flex-col items-center gap-3 py-8 text-center">
          <span className="text-3xl">🔮</span>
          <p className="text-sm text-muted">
            {t('moodForecast.empty' as any)}
          </p>
        </div>
      )}

      {data?.forecast?.length ? (
        <>
          {/* Trend badge */}
          <div className="mt-4 flex items-center gap-2">
            <TrendIcon className={`h-5 w-5 ${trendColor}`} />
            <span className="text-sm font-bold">
              {trend?.direction === 'improving'
                ? t('moodForecast.trendUp' as any)
                : trend?.direction === 'declining'
                  ? t('moodForecast.trendDown' as any)
                  : t('moodForecast.trendStable' as any)}
            </span>
          </div>

          {/* Bar chart */}
          <div className="mt-5 flex items-end gap-2" style={{ height: 120 }}>
            {data.forecast.map((day) => {
              const h = `${day.predictedScore}%`;
              const barColor =
                day.riskLevel === 'HIGH'
                  ? 'bg-red-500'
                  : day.riskLevel === 'MEDIUM'
                    ? 'bg-amber-500'
                    : 'bg-mint';
              return (
                <div
                  key={day.date}
                  className="flex flex-1 flex-col items-center"
                >
                  <span className="mb-1 text-[10px] font-bold text-muted">
                    {day.predictedScore}
                  </span>
                  <div className="w-full max-w-[28px] overflow-hidden rounded-md">
                    <div
                      className={`w-full ${barColor} transition-all`}
                      style={{ height: `${Math.max(day.predictedScore, 8)}px` }}
                    />
                  </div>
                  <span className="mt-1 text-[10px] font-semibold text-muted">
                    {DAY_LABELS[day.dayOfWeek]}
                  </span>
                </div>
              );
            })}
          </div>

          {/* Triggers warning */}
          {data.topTriggers.length > 0 && (
            <div className="mt-5 rounded-xl border border-amber-500/20 bg-amber-50 p-3 dark:bg-amber-950/20">
              <div className="flex items-center gap-2 text-sm font-bold text-amber-700 dark:text-amber-400">
                <AlertTriangle className="h-4 w-4" />
                {t('moodForecast.triggers' as any)}
              </div>
              <ul className="mt-2 space-y-1">
                {data.topTriggers.map((trig) => (
                  <li
                    key={trig.trigger}
                    className="text-xs text-amber-800 dark:text-amber-300"
                  >
                    &bull; {trig.trigger} — {trig.negativeRate}%{' '}
                    {t('moodForecast.negative' as any)} ({trig.count}{' '}
                    {t('moodForecast.times' as any)})
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Day details */}
          <div className="mt-5 space-y-2">
            {data.forecast.map((day) => (
              <div
                key={day.date}
                className="flex items-center gap-3 rounded-xl border border-border bg-surface-alt p-3"
              >
                <span className="text-lg">
                  {day.predictedMood === 'HAPPY'
                    ? '😊'
                    : day.predictedMood === 'CALM'
                      ? '😌'
                      : day.predictedMood === 'NEUTRAL'
                        ? '😐'
                        : day.predictedMood === 'TIRED'
                          ? '🥱'
                          : day.predictedMood === 'ANXIOUS'
                            ? '😰'
                            : '😫'}
                </span>
                <div className="flex-1">
                  <p className="text-sm font-bold">{day.date}</p>
                  <p className="text-xs text-muted">
                    {day.suggestion.slice(0, 60)}
                    {day.suggestion.length > 60 ? '…' : ''}
                  </p>
                </div>
                <Badge className={RISK_COLOR[day.riskLevel]}>
                  {day.riskLevel}
                </Badge>
              </div>
            ))}
          </div>
        </>
      ) : null}
    </Card>
  );
}
