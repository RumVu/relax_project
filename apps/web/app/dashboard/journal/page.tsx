import { DashboardShell } from '@/components/layout/dashboard-shell';
import { JournalEntryCard } from '@/components/journal/journal-entry-card';
import { Card } from '@/components/ui/card';

export default function JournalPage() {
  return (
    <DashboardShell eyebrow="Reflection" title="Journal space">
      <div className="grid gap-4 md:grid-cols-2">
        <JournalEntryCard />
        <Card>
          <p className="text-sm font-semibold text-ink">Prompt bank</p>
          <ul className="mt-4 space-y-3 text-sm text-ink/70">
            <li>What pushed the user into recovery mode today?</li>
            <li>Which ritual actually reduced tension fastest?</li>
            <li>What should tomorrow’s break plan protect space for?</li>
          </ul>
        </Card>
      </div>
    </DashboardShell>
  );
}
