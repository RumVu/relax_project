import { BookOpenText, Heart, PenLine } from 'lucide-react';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';

export function JournalEntryCard() {
  return (
    <Card>
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-sm font-semibold text-ink">Latest journal</p>
          <h3 className="mt-3 text-xl font-extrabold text-ink">
            “Clearer after stepping away.”
          </h3>
        </div>
        <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-mint/15 text-mint">
          <BookOpenText className="h-5 w-5" />
        </div>
      </div>
      <div className="mt-4 flex flex-wrap gap-2">
        <span className="inline-flex items-center gap-1 rounded-md bg-lilac/50 px-2 py-1 text-xs font-semibold text-plum">
          <Heart className="h-3 w-3" />
          lighter
        </span>
        <span className="rounded-md bg-sun/20 px-2 py-1 text-xs font-semibold text-ink">
          evening
        </span>
      </div>
      <Button className="mt-5 w-full" variant="secondary">
        <PenLine className="h-4 w-4" />
        Write
      </Button>
    </Card>
  );
}
