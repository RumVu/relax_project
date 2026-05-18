import { DashboardShell } from '@/components/layout/dashboard-shell';
import { Card } from '@/components/ui/card';

export default function AdminSoundsPage() {
  return (
    <DashboardShell admin eyebrow="Content" title="Sounds">
      <Card>
        <p className="text-sm font-semibold text-ink">Sound catalog scaffold</p>
        <p className="mt-2 text-sm text-ink/70">Ready for uploads, durations, categories, and publication toggles.</p>
      </Card>
    </DashboardShell>
  );
}
