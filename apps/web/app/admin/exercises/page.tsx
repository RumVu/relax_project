import { DashboardShell } from '@/components/layout/dashboard-shell';
import { Card } from '@/components/ui/card';

export default function AdminExercisesPage() {
  return (
    <DashboardShell admin eyebrow="Content" title="Exercises">
      <Card>
        <p className="text-sm font-semibold text-ink">Exercise management scaffold</p>
        <p className="mt-2 text-sm text-ink/70">Ready for breathing patterns, durations, guides, and difficulty levels.</p>
      </Card>
    </DashboardShell>
  );
}
