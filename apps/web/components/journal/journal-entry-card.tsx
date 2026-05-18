import { Card } from '@/components/ui/card';

export function JournalEntryCard() {
  return (
    <Card>
      <p className="text-sm font-semibold text-ink">Latest journal theme</p>
      <h3 className="mt-3 text-xl font-bold text-ink">“Feeling overloaded, but clearer after stepping away.”</h3>
      <p className="mt-2 text-sm text-ink/60">
        This block can later hydrate from the API and highlight sentiment, tags, and writing cadence.
      </p>
    </Card>
  );
}
