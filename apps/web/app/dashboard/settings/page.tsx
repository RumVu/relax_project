import { DashboardShell } from '@/components/layout/dashboard-shell';
import { Card } from '@/components/ui/card';

export default function SettingsPage() {
  return (
    <DashboardShell eyebrow="Personal controls" title="Settings">
      <Card>
        <p className="text-sm font-semibold text-ink">Preferences scaffold</p>
        <p className="mt-2 text-sm text-ink/70">
          This section is ready for notification preferences, break defaults, privacy controls, and timezone settings.
        </p>
      </Card>
    </DashboardShell>
  );
}
