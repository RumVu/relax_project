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
import { AiInsightsCard } from '@/components/dashboard/ai-insights-card';
import { PremiumGate } from '@/components/dashboard/premium-gate';
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
  const accountRole = useDashboardStore((state) => state.accountProfile?.role);
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

  return (
    <DashboardShell eyebrow={t('analytics.eyebrow')} title={t('analytics.title')}>
      <DashboardFilterBar {...analyticsFilters} title={t('analytics.filterTitle')} />

      <PremiumGate planName={data.settings.billing.planName} role={accountRole}>
        <div className="flex flex-col gap-4">

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
        <AiInsightsCard />
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
        </div>
      </PremiumGate>
    </DashboardShell>
  );
}
