import { DashboardShell } from '@/components/layout/dashboard-shell';
import { MoodTrendChart } from '@/components/charts/mood-trend-chart';
import { MoodSummaryCard } from '@/components/mood/mood-summary-card';
import { BreakPlanCard } from '@/components/breaks/break-plan-card';
import { JournalEntryCard } from '@/components/journal/journal-entry-card';
import { dashboardStats } from '@/lib/constants';
import { Card } from '@/components/ui/card';

export default function DashboardPage() {
  return (
    <DashboardShell eyebrow="User workspace" title="Recovery overview">
      <div className="grid gap-4 md:grid-cols-3">
        {dashboardStats.map((stat) => (
          <Card key={stat.label}>
            <p className="text-sm text-ink/60">{stat.label}</p>
            <p className="mt-3 text-3xl font-extrabold text-ink">{stat.value}</p>
            <p className="mt-2 text-sm text-ink/70">{stat.note}</p>
          </Card>
        ))}
      </div>
      <div className="grid gap-4 xl:grid-cols-[1.4fr_0.9fr]">
        <MoodTrendChart />
        <div className="space-y-4">
          <MoodSummaryCard />
          <BreakPlanCard />
          <JournalEntryCard />
        </div>
      </div>
    </DashboardShell>
  );
}
