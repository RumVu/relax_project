'use client';

import { useCallback, useEffect, useState } from 'react';
import {
  CheckCircle2,
  Flag,
  Flame,
  SmilePlus,
  Target,
} from 'lucide-react';
import { apiFetch } from '@/lib/api';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

interface GoalProgress {
  current: number;
  target: number;
  percentage: number;
}

interface Milestone {
  id: string;
  title: string;
  target: number;
  reached: boolean;
  reachedAt: string | null;
}

interface MoodGoal {
  id: string;
  title: string;
  description: string | null;
  type: 'TARGET_MOOD' | 'REDUCE_MOOD' | 'STREAK' | 'CHECKIN_COUNT';
  status: 'ACTIVE' | 'COMPLETED' | 'FAILED' | 'CANCELLED';
  targetMood: string | null;
  targetCount: number | null;
  currentCount: number;
  milestones: Milestone[];
  progress: GoalProgress;
}

interface GoalSummary {
  active: number;
  completed: number;
  total: number;
  completionRate: number;
}

const TYPE_ICON: Record<string, typeof Flag> = {
  TARGET_MOOD: SmilePlus,
  REDUCE_MOOD: Target,
  STREAK: Flame,
  CHECKIN_COUNT: CheckCircle2,
};

const TYPE_LABEL_KEY: Record<string, string> = {
  TARGET_MOOD: 'moodGoals.type.targetMood',
  REDUCE_MOOD: 'moodGoals.type.reduceMood',
  STREAK: 'moodGoals.type.streak',
  CHECKIN_COUNT: 'moodGoals.type.checkinCount',
};

export function MoodGoalsPanel() {
  const { t } = useTranslation();
  const refreshNonce = useDashboardStore((s) => s.refreshNonce);
  const [goals, setGoals] = useState<MoodGoal[]>([]);
  const [summary, setSummary] = useState<GoalSummary | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [goalsRes, summaryRes] = await Promise.allSettled([
        apiFetch<MoodGoal[]>('/mood-goals/me/progress'),
        apiFetch<GoalSummary>('/mood-goals/me/summary'),
      ]);
      if (goalsRes.status === 'fulfilled' && Array.isArray(goalsRes.value))
        setGoals(goalsRes.value);
      if (summaryRes.status === 'fulfilled') setSummary(summaryRes.value);
    } catch {
      // silent
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load, refreshNonce]);

  return (
    <Card>
      <SectionTitle
        title={t('moodGoals.title')}
        copy={t('moodGoals.copy')}
        action={<Flag className="h-5 w-5 text-violet" />}
      />

      {summary && (
        <div className="mt-4 grid grid-cols-3 gap-3">
          <SummaryBadge label={t('moodGoals.active')} value={summary.active} />
          <SummaryBadge label={t('moodGoals.completed')} value={summary.completed} />
          <SummaryBadge
            label={t('moodGoals.rate')}
            value={`${Math.round(summary.completionRate * 100)}%`}
          />
        </div>
      )}

      <div className="mt-5 space-y-3">
        {loading && goals.length === 0 && (
          <p className="py-8 text-center text-sm text-muted">
            {t('moodGoals.loading')}
          </p>
        )}

        {!loading && goals.length === 0 && (
          <div className="flex flex-col items-center gap-3 py-8 text-center">
            <span className="text-3xl">🎯</span>
            <p className="text-sm text-muted">
              {t('moodGoals.empty')}
            </p>
          </div>
        )}

        {goals.map((goal) => (
          <GoalCard key={goal.id} goal={goal} />
        ))}
      </div>
    </Card>
  );
}

function SummaryBadge({
  label,
  value,
}: {
  label: string;
  value: string | number;
}) {
  return (
    <div className="flex flex-col items-center rounded-xl border border-border bg-surface-alt p-3">
      <span className="text-lg font-extrabold">{value}</span>
      <span className="text-xs text-muted">{label}</span>
    </div>
  );
}

function GoalCard({ goal }: { goal: MoodGoal }) {
  const { t } = useTranslation();
  const Icon = TYPE_ICON[goal.type] ?? Flag;
  const pct = goal.progress.percentage;
  const labelKey = TYPE_LABEL_KEY[goal.type];

  return (
    <div className="rounded-xl border border-border bg-surface-alt p-4">
      <div className="flex items-start gap-3">
        <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-violet/10">
          <Icon className="h-4 w-4 text-violet" />
        </div>
        <div className="flex-1">
          <p className="font-bold">{goal.title}</p>
          <p className="text-xs text-muted">
            {labelKey ? t(labelKey as any) : goal.type}
          </p>
        </div>
        <Badge className={pct >= 100 ? 'bg-mint/20 text-mint' : 'bg-violet/10 text-violet'}>
          {pct}%
        </Badge>
      </div>

      <div className="mt-3">
        <div className="h-2 w-full overflow-hidden rounded-full bg-border">
          <div
            className="h-full rounded-full bg-violet transition-all"
            style={{ width: `${Math.min(pct, 100)}%` }}
          />
        </div>
        <p className="mt-1 text-xs text-muted">
          {goal.progress.current} / {goal.progress.target}
        </p>
      </div>

      {goal.milestones.length > 0 && (
        <div className="mt-3 space-y-1">
          {goal.milestones.map((ms) => (
            <div key={ms.id} className="flex items-center gap-2 text-xs">
              {ms.reached ? (
                <CheckCircle2 className="h-3.5 w-3.5 text-mint" />
              ) : (
                <div className="h-3.5 w-3.5 rounded-full border border-muted" />
              )}
              <span className={ms.reached ? 'line-through text-muted' : ''}>
                {ms.title}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
