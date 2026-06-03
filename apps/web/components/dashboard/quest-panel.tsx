'use client';

/**
 * QuestPanel — daily mission cards drawn from /v1/quests/me.
 *
 * Each card shows a goal that maps to an action elsewhere in the app
 * (write a journal, check in your mood, finish a breathing session…),
 * auto-ticks when the matching count reaches the target, and offers
 * a per-card "reroll" button so users who don't fancy a particular
 * mission can swap to another random one without affecting the rest.
 *
 * The panel auto-refreshes when the shared refreshNonce changes — so any
 * "Refresh" button elsewhere on the page also re-evaluates progress.
 */

import { useCallback, useEffect, useState } from 'react';
import {
  BookOpenText,
  CheckCircle2,
  HeartPulse,
  Music2,
  PawPrint,
  RefreshCcw,
  Shuffle,
  Sparkles,
  Wind,
} from 'lucide-react';
import { apiFetch } from '@/lib/api';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { useUiStore } from '@/stores/use-ui-store';

interface Quest {
  id: string;
  templateCode: string;
  category: 'journal' | 'mood' | 'breathing' | 'sound' | 'companion' | 'streak';
  title: string;
  description: string;
  scope: 'today' | 'week' | 'all-time';
  target: number;
  progress: number;
  completed: boolean;
  completedAt: string | null;
  assignedAt: string;
}

const CATEGORY_ICONS = {
  journal: BookOpenText,
  mood: HeartPulse,
  breathing: Wind,
  sound: Music2,
  companion: PawPrint,
  streak: Sparkles,
} as const;

const CATEGORY_TONES: Record<Quest['category'], string> = {
  journal: 'bg-violet/15 text-violet',
  mood: 'bg-coral/15 text-coral',
  breathing: 'bg-mint/15 text-mint',
  sound: 'bg-sun/20 text-ink',
  companion: 'bg-lilac/40 text-plum',
  streak: 'bg-violet/15 text-violet',
};

export function QuestPanel({ heading }: { heading?: string }) {
  const { t, locale } = useTranslation();
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const pushToast = useUiStore((state) => state.pushToast);
  const [quests, setQuests] = useState<Quest[]>([]);
  const [loading, setLoading] = useState(true);
  const [rerollingId, setRerollingId] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const list = await apiFetch<Quest[]>(`/quests/me?locale=${locale}`);
      setQuests(list);
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      pushToast({
        tone: 'error',
        title: t('quests.toast.loadFailed'),
        message,
      });
    } finally {
      setLoading(false);
    }
  }, [locale, pushToast, t]);

  // Initial load + refetch whenever the shared refreshNonce is bumped or the
  // locale changes — so progress stays honest without the user clicking.
  useEffect(() => {
    const timer = setTimeout(() => { void load(); }, 0);
    return () => clearTimeout(timer);
  }, [load, refreshNonce]);

  const reroll = useCallback(
    async (quest: Quest) => {
      setRerollingId(quest.id);
      try {
        const next = await apiFetch<Quest>(
          `/quests/me/${quest.id}/reroll?locale=${locale}`,
          { method: 'POST' },
        );
        setQuests((prev) => prev.map((q) => (q.id === quest.id ? next : q)));
        pushToast({
          tone: 'success',
          title: t('quests.toast.rerolledTitle'),
          message: next.title,
        });
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        pushToast({
          tone: 'error',
          title: t('quests.toast.rerollFailed'),
          message,
        });
      } finally {
        setRerollingId(null);
      }
    },
    [locale, pushToast, t],
  );

  const completedCount = quests.filter((q) => q.completed).length;

  return (
    <Card>
      <SectionTitle
        title={heading ?? t('quests.section.title')}
        copy={t('quests.section.copy', {
          done: completedCount,
          total: quests.length,
        })}
        action={
          <Button
            disabled={loading}
            onClick={load}
            variant="secondary"
          >
            <RefreshCcw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
            {t('quests.action.reloadAll')}
          </Button>
        }
      />

      {loading && quests.length === 0 ? (
        <p className="mt-5 text-sm text-slate">{t('common.loading')}</p>
      ) : null}

      <div className="mt-5 grid gap-3 sm:grid-cols-2">
        {quests.map((quest) => {
          const Icon = CATEGORY_ICONS[quest.category] ?? Sparkles;
          const tone = CATEGORY_TONES[quest.category];
          const pct = quest.target > 0
            ? Math.min(100, Math.round((quest.progress / quest.target) * 100))
            : 0;
          const isRerolling = rerollingId === quest.id;
          return (
            <article
              className={`rounded-lg border p-4 transition ${
                quest.completed
                  ? 'border-mint/60 bg-mint/5'
                  : 'border-[var(--panel-border)] bg-[var(--panel-bg)]'
              }`}
              key={quest.id}
            >
              <div className="flex items-start gap-3">
                <div className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-lg ${tone}`}>
                  {quest.completed ? (
                    <CheckCircle2 className="h-5 w-5" />
                  ) : (
                    <Icon className="h-5 w-5" />
                  )}
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <h4
                      className={`text-sm font-bold ${
                        quest.completed
                          ? 'text-mint line-through decoration-mint/70'
                          : 'text-[var(--app-text)]'
                      }`}
                    >
                      {quest.title}
                    </h4>
                    <Badge className={tone}>
                      {t(`quests.scope.${quest.scope}`)}
                    </Badge>
                  </div>
                  <p className="mt-1 text-xs leading-relaxed text-[var(--app-muted,#94a3b8)]">
                    {quest.description}
                  </p>
                  <div className="mt-3">
                    <div className="h-1.5 w-full overflow-hidden rounded-full bg-[var(--field-bg,rgba(255,255,255,0.1))]">
                      <div
                        className={`h-full rounded-full transition-all ${
                          quest.completed ? 'bg-mint' : 'bg-violet'
                        }`}
                        style={{ width: `${pct}%` }}
                      />
                    </div>
                    <div className="mt-2 flex items-center justify-between text-xs">
                      <span className="font-semibold text-slate">
                        {quest.progress} / {quest.target}
                      </span>
                      <button
                        className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-semibold text-slate transition hover:text-violet disabled:opacity-50"
                        disabled={isRerolling}
                        onClick={() => reroll(quest)}
                        type="button"
                      >
                        <Shuffle className={`h-3 w-3 ${isRerolling ? 'animate-spin' : ''}`} />
                        {isRerolling
                          ? t('quests.action.rerolling')
                          : t('quests.action.reroll')}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </article>
          );
        })}
      </div>
    </Card>
  );
}
