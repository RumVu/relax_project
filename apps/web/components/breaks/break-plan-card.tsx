import { Card } from '@/components/ui/card';

export function BreakPlanCard() {
  return (
    <Card>
      <p className="text-sm font-semibold text-ink">Break planner</p>
      <ul className="mt-4 space-y-3 text-sm text-ink/70">
        <li>09:30 • 5 minute breathing reset</li>
        <li>13:00 • 15 minute mindful walk</li>
        <li>16:00 • Fake cigarette break with ambient sound</li>
      </ul>
    </Card>
  );
}
