import { DashboardShell } from '@/components/layout/dashboard-shell';
import { Card } from '@/components/ui/card';

export default function AdminPage() {
  return (
    <DashboardShell admin eyebrow="Operations" title="Admin overview">
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <p className="text-sm text-ink/60">Users flagged</p>
          <p className="mt-3 text-3xl font-extrabold text-ink">14</p>
        </Card>
        <Card>
          <p className="text-sm text-ink/60">Pending feedback</p>
          <p className="mt-3 text-3xl font-extrabold text-ink">9</p>
        </Card>
        <Card>
          <p className="text-sm text-ink/60">Content items live</p>
          <p className="mt-3 text-3xl font-extrabold text-ink">127</p>
        </Card>
      </div>
    </DashboardShell>
  );
}
