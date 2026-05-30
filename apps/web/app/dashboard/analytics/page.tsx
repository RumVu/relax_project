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
    dominantMood: 'Chưa có dữ liệu',
  };
  const insights = buildInsights(data);

  return (
    <DashboardShell eyebrow={t('analytics.eyebrow')} title={t('analytics.title')}>
      <DashboardFilterBar {...analyticsFilters} title="Bộ lọc biểu đồ mood" />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={Gauge}
          label="Avg score tuần"
          note="điểm trung bình tuần gần nhất"
          value={latestWeek.avgScore}
        />
        <MetricCard
          icon={TrendingDown}
          label="Stress giảm"
          note="so với giai đoạn trước"
          tone="mint"
          value={`${latestWeek.stressReducePct}%`}
        />
        <MetricCard
          icon={Trophy}
          label="Streak tuần"
          note="ngày"
          tone="sun"
          value={latestWeek.streakDays}
        />
        <MetricCard
          icon={Brain}
          label="Dominant mood"
          note="mood chiếm ưu thế"
          tone="lilac"
          value={latestWeek.dominantMood}
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.25fr)_minmax(340px,0.75fr)]">
        <MoodAreaDashboardChart data={data.timeline} />
        <Card>
          <SectionTitle
            title="Insight tự sinh"
            copy="Tóm tắt nhanh từ xu hướng mood, chuỗi check-in và hoạt động thư giãn gần đây."
            action={
              <Button
                onClick={() => {
                  triggerRefresh();
                  pushToast({
                    tone: 'info',
                    title: 'Đã làm mới analytics',
                    message: 'Mọi biểu đồ và phần tóm tắt đang nạp lại từ backend.',
                  });
                }}
                variant="secondary"
              >
                <RefreshCcw className="h-4 w-4" />
                Làm mới insight
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
            title="Tiến trình theo tuần"
            copy="Nhìn lại từng tuần để thấy rõ mood trung bình, chuỗi ngày giữ nhịp và mức giảm stress."
          />
          <div className="mt-5">
            <DataTable
              columns={['Tuần bắt đầu', 'Mood trung bình', 'Stress giảm', 'Streak', 'Mood chính']}
              rows={data.weeklyStats.map((week) => [
                week.weekStart,
                week.avgScore,
                `${week.stressReducePct}%`,
                `${week.streakDays} ngày`,
                week.dominantMood,
              ])}
            />
          </div>
        </Card>

        <Card>
          <SectionTitle
            title="Hoạt động giúp nhẹ đầu nhất"
            copy="Tổng hợp nhanh hoạt động nào được dùng nhiều và thường mang lại cảm giác nhẹ hơn."
          />
          <div className="mt-5">
            <DataTable
              columns={['Hoạt động', 'Số phiên', 'Thời lượng gợi ý', 'Relief']}
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
) {
  const latestWeek = data.weeklyStats[data.weeklyStats.length - 1] ?? {
    avgScore: 0,
    stressReducePct: 0,
  };
  const bestActivity = data.relaxActivities[0] ?? {
    title: 'Hoạt động thư giãn',
    relief: 0,
  };
  const strongestMood = data.distribution[0] ?? {
    mood: 'Chưa rõ',
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
    `${bestActivity.title} đang là hoạt động cho cảm giác nhẹ đầu tốt nhất với relief khoảng ${bestActivity.relief}%.`,
    `Tuần gần nhất mood trung bình ở mức ${latestWeek.avgScore} và stress đã giảm ${latestWeek.stressReducePct}% so với giai đoạn trước.`,
    `${strongestMood.mood} hiện là cảm xúc xuất hiện dày nhất, chiếm khoảng ${strongestMood.percent}% tổng phân bố.`,
    `Ngày ${lowestStressDay.label} có stress thấp nhất, trong khi ${highestRelaxDay.label} lại là lúc thời gian thư giãn cao nhất.`,
  ];
}
