import { DashboardShell } from '@/components/layout/dashboard-shell';
import { MoodTrendChart } from '@/components/charts/mood-trend-chart';
import { Card } from '@/components/ui/card';

export default function AnalyticsPage() {
  return (
    <DashboardShell eyebrow="Progress signals" title="Analytics">
      <div className="grid gap-4 xl:grid-cols-[1.2fr_0.8fr]">
        <MoodTrendChart />
        <Card>
          <p className="text-sm font-semibold text-ink">Weekly highlights</p>
          <ul className="mt-4 space-y-3 text-sm text-ink/70">
            <li>Stress trend down 18%</li>
            <li>Most effective ritual: sound + breathing</li>
            <li>Peak fatigue window: 3pm to 5pm</li>
          </ul>
        </Card>
      </div>
    </DashboardShell>
  );
}
