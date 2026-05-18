import { DashboardShell } from '@/components/layout/dashboard-shell';
import { BreakPlanCard } from '@/components/breaks/break-plan-card';
import { Card } from '@/components/ui/card';

export default function BreaksPage() {
  return (
    <DashboardShell eyebrow="Break orchestration" title="Mindful breaks">
      <div className="grid gap-4 md:grid-cols-2">
        <BreakPlanCard />
        <Card>
          <p className="text-sm font-semibold text-ink">Suggested sequences</p>
          <ul className="mt-4 space-y-3 text-sm text-ink/70">
            <li>4-7-8 breathing • 3 cycles</li>
            <li>Ambient rain • 10 minutes</li>
            <li>Reflective prompt • 1 short paragraph</li>
          </ul>
        </Card>
      </div>
    </DashboardShell>
  );
}
