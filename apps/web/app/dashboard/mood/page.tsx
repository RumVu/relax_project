import { DashboardShell } from '@/components/layout/dashboard-shell';
import { MoodTrendChart } from '@/components/charts/mood-trend-chart';
import { MoodSummaryCard } from '@/components/mood/mood-summary-card';

export default function MoodPage() {
  return (
    <DashboardShell eyebrow="Mood intelligence" title="Emotional tracking">
      <div className="grid gap-4 xl:grid-cols-[1.3fr_0.8fr]">
        <MoodTrendChart />
        <MoodSummaryCard />
      </div>
    </DashboardShell>
  );
}
