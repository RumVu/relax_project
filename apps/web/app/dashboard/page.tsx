'use client';

import { useRouter } from 'next/navigation';
import {
  BarChart3,
  BookOpenText,
  Clock3,
  HeartPulse,
  Music2,
  Sparkles,
  Trophy,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  CompanionStatusCard,
  DataTable,
  DistributionChart,
  MetricCard,
  MoodAreaDashboardChart,
  ProgressList,
  RelaxActivityChart,
  SectionTitle,
  WeatherCard,
  WeeklyStatsChart,
} from '@/components/dashboard/dashboard-ui';
import { CozyQuoteCard } from '@/components/dashboard/cozy-quote-card';
import { QuestPanel } from '@/components/dashboard/quest-panel';
import { OnboardingTour } from '@/components/dashboard/onboarding-tour';
import { DashboardFilterBar, useDashboardFilters } from '@/components/dashboard/dashboard-filters';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { useUserDashboardData } from '@/lib/live-dashboard';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

export default function DashboardPage() {
  const router = useRouter();
  const { t } = useTranslation();
  const overviewFilters = useDashboardFilters('/analytics/me/overview', 'overview');
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const data = useUserDashboardData({
    refreshKey: refreshNonce,
    overviewQuery: overviewFilters.query,
    moodAnalyticsQuery: overviewFilters.query,
    weeklyStatsQuery: overviewFilters.query,
    relaxQuery: overviewFilters.query,
  });
  const summary = data.overview.summaryCards;
  const displayName = data.settings.profile.displayName;
  const title = displayName
    ? t('dashboard.titleWithName', { name: displayName })
    : t('dashboard.title');
  // Defensive: bất kỳ field nào pass thẳng vào recharts MUST là array.
  // Nếu data merge từ API/mock trả shape khác (object thay array), recharts
  // internal `.filter()` sẽ crash → error boundary → "Something went wrong"
  // → CI e2e fail (đã fail 30+ runs). Coerce mọi field về [] khi không phải
  // array để hard guarantee chart inputs.
  const safeTimeline = Array.isArray(data.timeline) ? data.timeline : [];
  const safeDistribution = Array.isArray(data.distribution) ? data.distribution : [];
  const safeWeeklyStats = Array.isArray(data.weeklyStats) ? data.weeklyStats : [];
  const safeRelaxActivities = Array.isArray(data.relaxActivities) ? data.relaxActivities : [];
  const safeRecentMoments = Array.isArray(data.overview?.relax?.recentMoments)
    ? data.overview.relax.recentMoments
    : [];

  return (
    <DashboardShell eyebrow={t('dashboard.eyebrow')} title={title}>
      <OnboardingTour />
      <CozyQuoteCard currentMood={data.overview.mood.currentMood} />
      <DashboardFilterBar {...overviewFilters} title={t('dashboard.filters.title')} />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-5">
        <MetricCard
          icon={Trophy}
          label={t('dashboard.metric.currentStreak')}
          note={t('dashboard.metric.currentStreak.note')}
          tone="sun"
          value={summary.currentStreak}
        />
        <MetricCard
          icon={Clock3}
          label={t('dashboard.metric.totalRelax')}
          note={t('dashboard.metric.totalRelax.note')}
          tone="lilac"
          value={summary.totalRelaxTime}
        />
        <MetricCard
          icon={BookOpenText}
          label={t('dashboard.metric.totalJournals')}
          note={t('dashboard.metric.totalJournals.note')}
          tone="mint"
          value={summary.totalJournals}
        />
        <MetricCard
          icon={Sparkles}
          label={t('dashboard.metric.companionAffection')}
          note={t('dashboard.metric.companionAffection.note')}
          tone="violet"
          value={`${summary.companionAffection}%`}
        />
        <MetricCard
          icon={HeartPulse}
          label={t('dashboard.metric.stressReduction')}
          note={t('dashboard.metric.stressReduction.note')}
          tone="coral"
          value={`${summary.stressReduction}%`}
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.15fr)_minmax(360px,0.85fr)]" data-tour="mood-hero">
        <Card className="overflow-hidden bg-night p-0 text-white">
          <div className="grid min-h-[420px] gap-4 p-5 lg:grid-cols-[minmax(0,1fr)_280px]">
            <div className="flex flex-col justify-between gap-8">
              <div>
                <Badge className="bg-white/10 text-lilac">
                  {t('dashboard.moodNow.badge')}
                </Badge>
                <p className="mt-6 max-w-xl text-3xl font-extrabold leading-tight md:text-4xl">
                  {data.overview.mood.prompt}
                </p>
                <p className="mt-4 text-sm font-semibold text-mist/70">
                  {t('dashboard.moodNow.current', {
                    mood: data.overview.mood.currentMood,
                    intensity: data.overview.mood.summary.averageIntensity,
                  })}
                </p>
              </div>
              <div className="flex flex-wrap gap-2">
                <Button onClick={() => router.push('/dashboard/mood')}>
                  <HeartPulse className="h-4 w-4" />
                  {t('dashboard.moodNow.checkin')}
                </Button>
                <Button onClick={() => router.push('/dashboard/breaks')} variant="secondary">
                  <Music2 className="h-4 w-4" />
                  {t('dashboard.moodNow.openRelax')}
                </Button>
              </div>
            </div>
            <div className="flex items-end justify-center rounded-lg border border-white/10 bg-[linear-gradient(180deg,rgba(115,87,246,0.22),rgba(64,201,162,0.08))] p-4">
              <div className="relative h-56 w-56">
                <div className="absolute left-8 top-8 h-16 w-16 rotate-[-18deg] rounded-lg bg-[#b88b6a]" />
                <div className="absolute right-8 top-8 h-16 w-16 rotate-[18deg] rounded-lg bg-[#b88b6a]" />
                <div className="absolute inset-x-6 bottom-7 h-36 rounded-[42%] border-4 border-[#4b3428] bg-[#caa083]" />
                <div className="absolute left-12 top-24 h-12 w-12 rounded-full bg-[#fff4dd]" />
                <div className="absolute right-12 top-24 h-12 w-12 rounded-full bg-[#fff4dd]" />
                <div className="absolute left-[74px] top-[124px] h-5 w-5 rounded-full bg-ink" />
                <div className="absolute right-[74px] top-[124px] h-5 w-5 rounded-full bg-ink" />
                <div className="absolute bottom-0 left-14 h-16 w-28 rounded-lg bg-violet shadow-panel" />
                <Sparkles className="absolute right-4 top-6 h-6 w-6 text-sun" />
                <Sparkles className="absolute bottom-16 left-2 h-5 w-5 text-mint" />
              </div>
            </div>
          </div>
        </Card>
        <CompanionStatusCard companion={data.overview.companion} />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.2fr)_minmax(340px,0.8fr)]">
        <MoodAreaDashboardChart data={safeTimeline} />
        <Card>
          <SectionTitle
            title={t('dashboard.section.moodTracking')}
            copy={t('dashboard.section.moodTracking.copy')}
            action={<BarChart3 className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5">
            <ProgressList items={safeDistribution} />
          </div>
        </Card>
      </div>

      <div className="grid gap-4 xl:grid-cols-2" data-tour="relax-activities">
        <RelaxActivityChart data={safeRelaxActivities} />
        <WeeklyStatsChart data={safeWeeklyStats} />
      </div>

      <div data-tour="quests">
        <QuestPanel />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(360px,0.8fr)_minmax(0,1.2fr)]" data-tour="recent-moments">
        <WeatherCard weather={data.overview.weather} />
        <Card>
          <SectionTitle
            title={t('dashboard.section.recentMoments')}
            copy={t('dashboard.section.recentMoments.copy')}
          />
          <div className="mt-5">
            <DataTable
              columns={[
                t('dashboard.table.activity'),
                t('dashboard.table.time'),
                t('dashboard.table.duration'),
                t('dashboard.table.relief'),
              ]}
              rows={safeRecentMoments.map((moment) => [
                moment.title,
                moment.time,
                moment.duration,
                `${moment.relief}%`,
              ])}
            />
          </div>
        </Card>
      </div>

      <DistributionChart data={safeDistribution} />
    </DashboardShell>
  );
}
