import { DashboardShell } from '@/components/layout/dashboard-shell';
import { Card } from '@/components/ui/card';

export default function AdminQuotesPage() {
  return (
    <DashboardShell admin eyebrow="Content" title="Quotes">
      <Card>
        <p className="text-sm font-semibold text-ink">Quote library scaffold</p>
        <p className="mt-2 text-sm text-ink/70">Ready for CRUD over inspiration content and activation states.</p>
      </Card>
    </DashboardShell>
  );
}
