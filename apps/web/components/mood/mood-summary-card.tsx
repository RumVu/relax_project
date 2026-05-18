import { Card } from '@/components/ui/card';

export function MoodSummaryCard() {
  return (
    <Card>
      <p className="text-sm font-semibold text-ink">Mood capture prompt</p>
      <h3 className="mt-3 text-2xl font-bold text-ink">How is the user holding up right now?</h3>
      <p className="mt-2 text-sm text-ink/60">
        Suggested quick actions: log a check-in, trigger a short breathing loop, or start a fake cigarette break ritual.
      </p>
    </Card>
  );
}
