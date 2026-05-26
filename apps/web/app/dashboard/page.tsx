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
import { DashboardFilterBar, useDashboardFilters } from '@/components/dashboard/dashboard-filters';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { useUserDashboardData } from '@/lib/live-dashboard';
import { useDashboardStore } from '@/stores/use-dashboard-store';

export default function DashboardPage() {
  const router = useRouter();
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
  const title = displayName ? `Dashboard thư giãn của ${displayName}` : 'Dashboard thư giãn';

  return (
    <DashboardShell eyebrow="Trang tổng quan" title={title}>
      <DashboardFilterBar {...overviewFilters} title="Bộ lọc tổng quan" />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-5">
        <MetricCard
          icon={Trophy}
          label="Streak hiện tại"
          note="ngày liên tiếp"
          tone="sun"
          value={summary.currentStreak}
        />
        <MetricCard
          icon={Clock3}
          label="Tổng thời gian thư giãn"
          note="duration"
          tone="lilac"
          value={summary.totalRelaxTime}
        />
        <MetricCard
          icon={BookOpenText}
          label="Tổng nhật ký"
          note="entry count"
          tone="mint"
          value={summary.totalJournals}
        />
        <MetricCard
          icon={Sparkles}
          label="Độ thân thiết pet"
          note="0-100"
          tone="violet"
          value={`${summary.companionAffection}%`}
        />
        <MetricCard
          icon={HeartPulse}
          label="Giảm stress"
          note="so với tuần trước"
          tone="coral"
          value={`${summary.stressReduction}%`}
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.15fr)_minmax(360px,0.85fr)]">
        <Card className="overflow-hidden bg-night p-0 text-white">
          <div className="grid min-h-[420px] gap-4 p-5 lg:grid-cols-[minmax(0,1fr)_280px]">
            <div className="flex flex-col justify-between gap-8">
              <div>
                <Badge className="bg-white/10 text-lilac">Mood now</Badge>
                <p className="mt-6 max-w-xl text-3xl font-extrabold leading-tight md:text-4xl">
                  {data.overview.mood.prompt}
                </p>
                <p className="mt-4 text-sm font-semibold text-mist/70">
                  Current mood: {data.overview.mood.currentMood} • Average
                  intensity {data.overview.mood.summary.averageIntensity}/100
                </p>
              </div>
              <div className="flex flex-wrap gap-2">
                <Button onClick={() => router.push('/dashboard/mood')}>
                  <HeartPulse className="h-4 w-4" />
                  Check-in mới
                </Button>
                <Button onClick={() => router.push('/dashboard/breaks')} variant="secondary">
                  <Music2 className="h-4 w-4" />
                  Mở relax queue
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
        <MoodAreaDashboardChart data={data.timeline} />
        <Card>
          <SectionTitle
            title="Theo dõi cảm xúc"
            copy="Tỉ trọng các cảm xúc đang xuất hiện trong giai đoạn anh đang xem."
            action={<BarChart3 className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5">
            <ProgressList items={data.distribution} />
          </div>
        </Card>
      </div>

      <div className="grid gap-4 xl:grid-cols-2">
        <RelaxActivityChart data={data.relaxActivities} />
        <WeeklyStatsChart data={data.weeklyStats} />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(360px,0.8fr)_minmax(0,1.2fr)]">
        <WeatherCard weather={data.overview.weather} />
        <Card>
          <SectionTitle title="Khoảnh khắc thư giãn gần đây" copy="Những phiên thư giãn mới nhất được ghi nhận từ API." />
          <div className="mt-5">
            <DataTable
              columns={['Hoạt động', 'Thời gian', 'Duration', 'Relief']}
              rows={data.overview.relax.recentMoments.map((moment) => [
                moment.title,
                moment.time,
                moment.duration,
                `${moment.relief}%`,
              ])}
            />
          </div>
        </Card>
      </div>

      <DistributionChart data={data.distribution} />
    </DashboardShell>
  );
}
