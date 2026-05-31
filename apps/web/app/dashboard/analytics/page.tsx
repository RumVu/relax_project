'use client';

import { BarChart3, Brain, Gauge, RefreshCcw, TrendingDown, Trophy } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  DataTable,
  DistributionChart,
  MetricCard,
  MoodAreaDashboardChart,
  RelaxActivityChart,
  SectionTitle,
  WeeklyStatsChart,
} from '@/components/dashboard/dashboard-ui';
import { DashboardFilterBar, useDashboardFilters } from '@/components/dashboard/dashboard-filters';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { useUserDashboardData } from '@/lib/live-dashboard';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function AnalyticsPage() {
  const { t } = useTranslation();
  const analyticsFilters = useDashboardFilters('/mood-checkins/me/analytics', 'analytics');
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const triggerRefresh = useDashboardStore((state) => state.triggerRefresh);
  const pushToast = useUiStore((state) => state.pushToast);
  const data = useUserDashboardData({
    refreshKey: refreshNonce,
    moodAnalyticsQuery: analyticsFilters.query,
    weeklyStatsQuery: analyticsFilters.query,
    relaxQuery: analyticsFilters.query,
  });
  const latestWeek = data.weeklyStats[data.weeklyStats.length - 1] ?? {
    avgScore: 0,
    stressReducePct: 0,
    streakDays: 0,
    dominantMood: t('ui.empty'),
  };
  const insights = buildInsights(data, t);

  return (
    <DashboardShell eyebrow={t('analytics.eyebrow')} title={t('analytics.title')}>
      <DashboardFilterBar {...analyticsFilters} title={t('analytics.filterTitle')} />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={Gauge}
          label={t('analytics.metric.weekScore')}
          note={t('analytics.metric.weekScore.note')}
          value={latestWeek.avgScore}
        />
        <MetricCard
          icon={TrendingDown}
          label={t('analytics.metric.reduction')}
          note={t('analytics.metric.reduction.note')}
          tone="mint"
          value={`${latestWeek.stressReducePct}%`}
        />
        <MetricCard
          icon={Trophy}
          label={t('analytics.metric.streak')}
          note={t('analytics.metric.streak.note')}
          tone="sun"
          value={latestWeek.streakDays}
        />
        <MetricCard
          icon={Brain}
          label={t('analytics.metric.dominant')}
          note={t('analytics.metric.dominant.note')}
          tone="lilac"
          value={latestWeek.dominantMood}
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.25fr)_minmax(340px,0.75fr)]">
        <MoodAreaDashboardChart data={data.timeline} />
        <Card>
          <SectionTitle
            title={t('analytics.section.insights')}
            copy={t('analytics.section.insights.copy')}
            action={
              <Button
                onClick={() => {
                  triggerRefresh();
                  pushToast({
                    tone: 'info',
                    title: t('analytics.toast.refreshed'),
                    message: t('analytics.toast.refreshedMessage'),
                  });
                }}
                variant="secondary"
              >
                <RefreshCcw className="h-4 w-4" />
                {t('analytics.action.refreshInsights')}
              </Button>
            }
          />
          <div className="mt-5 space-y-3">
            {insights.map((insight) => (
              <Insight key={insight} text={insight} />
            ))}
          </div>
        </Card>
      </div>

      <div className="grid gap-4 xl:grid-cols-2">
        <WeeklyStatsChart data={data.weeklyStats} />
        <DistributionChart data={data.distribution} />
      </div>

      <RelaxActivityChart data={data.relaxActivities} />

      <div className="grid gap-4 xl:grid-cols-2">
        <Card>
          <SectionTitle
            title={t('analytics.section.weeklyTimeline')}
            copy={t('analytics.section.weeklyTimeline.copy')}
          />
          <div className="mt-5">
            <DataTable
              columns={[t('analytics.col.weekStart'), t('analytics.col.avgMood'), t('analytics.col.stressReduced'), t('analytics.col.streak'), t('analytics.col.dominantMood')]}
              rows={data.weeklyStats.map((week) => [
                week.weekStart,
                week.avgScore,
                `${week.stressReducePct}%`,
                t('analytics.value.days', { count: week.streakDays }),
                week.dominantMood,
              ])}
            />
          </div>
        </Card>

        <Card>
          <SectionTitle
            title={t('analytics.section.relaxActivities')}
            copy={t('analytics.section.relaxActivities.copy')}
          />
          <div className="mt-5">
            <DataTable
              columns={[t('analytics.col.activity'), t('analytics.col.sessions'), t('analytics.col.duration'), t('analytics.col.relief')]}
              rows={data.relaxActivities.map((activity) => [
                activity.title,
                activity.sessions,
                activity.duration,
                `${activity.relief}%`,
              ])}
            />
          </div>
        </Card>
      </div>
    </DashboardShell>
  );
}

function Insight({ text }: { text: string }) {
  return (
    <div className="rounded-lg border border-lilac/70 bg-white/75 p-4 text-sm font-medium text-ink">
      {text}
    </div>
  );
}

function buildInsights(
  data: ReturnType<typeof useUserDashboardData>,
  t: ReturnType<typeof useTranslation>['t'],
) {
  const latestWeek = data.weeklyStats[data.weeklyStats.length - 1] ?? {
    avgScore: 0,
    stressReducePct: 0,
  };
  const bestActivity = data.relaxActivities[0] ?? {
    title: t('analytics.fallback.relaxActivity'),
    relief: 0,
  };
  const strongestMood = data.distribution[0] ?? {
    mood: t('common.unknown'),
    percent: 0,
  };
  const lowestStressDay = data.timeline[0] ?? { label: '--', stressScore: 0 };
  const highestRelaxDay = data.timeline[0] ?? { label: '--', relaxMinutes: 0 };

  for (const activity of data.relaxActivities) {
    if (activity.relief > bestActivity.relief) {
      Object.assign(bestActivity, activity);
    }
  }

  for (const item of data.timeline) {
    if (item.stressScore < lowestStressDay.stressScore) {
      Object.assign(lowestStressDay, item);
    }
    if (item.relaxMinutes > highestRelaxDay.relaxMinutes) {
      Object.assign(highestRelaxDay, item);
    }
  }

  return [
    t('analytics.insight.bestActivity', { activity: bestActivity.title, relief: bestActivity.relief }),
    t('analytics.insight.latestWeek', { score: latestWeek.avgScore, reduction: latestWeek.stressReducePct }),
    t('analytics.insight.strongestMood', { mood: strongestMood.mood, percent: strongestMood.percent }),
    t('analytics.insight.bestDays', { lowDay: lowestStressDay.label, relaxDay: highestRelaxDay.label }),
  ];
}
