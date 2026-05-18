import { DashboardShell } from '@/components/layout/dashboard-shell';
import { Card } from '@/components/ui/card';

export default function AdminUsersPage() {
  return (
    <DashboardShell admin eyebrow="Moderation" title="Users">
      <Card>
        <p className="text-sm font-semibold text-ink">User management scaffold</p>
        <p className="mt-2 text-sm text-ink/70">Ready for search, role changes, bans, and subscription visibility.</p>
      </Card>
    </DashboardShell>
  );
}
