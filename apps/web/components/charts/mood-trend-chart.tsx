'use client';

import { Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import { useMounted } from '@/hooks/use-mounted';
import { moodTrend } from '@/lib/constants';
import { Card } from '@/components/ui/card';

export function MoodTrendChart() {
  const mounted = useMounted();

  return (
    <Card>
      <div className="mb-4">
        <p className="text-sm font-semibold text-ink">Mood trend</p>
        <p className="text-sm text-ink/60">Track emotional stability against perceived stress.</p>
      </div>
      {mounted ? (
        <div className="h-72 min-h-72">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={moodTrend}>
              <XAxis dataKey="day" stroke="#5d6b61" />
              <YAxis stroke="#5d6b61" />
              <Tooltip />
              <Line type="monotone" dataKey="mood" stroke="#355f42" strokeWidth={3} />
              <Line type="monotone" dataKey="stress" stroke="#a6492d" strokeWidth={3} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      ) : (
        <div className="h-72 animate-pulse rounded-3xl bg-moss/8" />
      )}
    </Card>
  );
}
