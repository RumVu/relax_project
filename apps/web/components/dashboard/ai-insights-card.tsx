'use client';

/**
 * AiInsightsCard — shows the latest AI-generated insights + recommendations
 * for the signed-in user, with a Refresh button that forces regeneration
 * via /v1/ai/insights/me/refresh. Provider name is surfaced as a small
 * badge so the user knows whether the insight was Gemini or the
 * deterministic fallback.
 *
 * Falls back gracefully to a friendly empty state when the API is
 * unreachable — the analytics page keeps its hand-rolled heuristic
 * insights so nothing disappears.
 */

import { useCallback, useEffect, useState } from 'react';
import { Brain, RefreshCcw, Sparkles, ThumbsDown, ThumbsUp } from 'lucide-react';
import { apiFetch } from '@/lib/api';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { SectionTitle } from '@/components/dashboard/dashboard-ui';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { useUiStore } from '@/stores/use-ui-store';

// Map nhãn loại insight về key i18n đã khai báo trước, fallback về string thô
// để TypeScript không phải kiểm tra template literal qua hàm t().
function translateInsightType(
  t: ReturnType<typeof useTranslation>['t'],
  type: string,
): string {
  switch (type) {
    case 'weekly-summary':
      return t('aiInsights.type.weekly-summary');
    case 'mood-pattern':
      return t('aiInsights.type.mood-pattern');
    case 'risk-flag':
      return t('aiInsights.type.risk-flag');
    case 'celebration':
      return t('aiInsights.type.celebration');
    case 'recommendation':
      return t('aiInsights.type.recommendation');
    default:
      return type;
  }
}

interface AIInsightRow {
  id: string;
  type: string;
  title: string;
  content: string;
  aiProvider: string;
  isUseful: boolean | null;
  createdAt: string;
}

interface RecommendationRow {
  id: string;
  contentType: string;
  contentId: string;
  reason: string;
  score: number;
  createdAt: string;
}

interface InsightsResponse {
  provider: string;
  generatedAt: string | null;
  insights: AIInsightRow[];
  recommendations: RecommendationRow[];
}

export function AiInsightsCard() {
  const { t } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const [data, setData] = useState<InsightsResponse | null>(null);
  const [busy, setBusy] = useState(false);

  const load = useCallback(async (force = false) => {
    setBusy(true);
    try {
      const path = force ? '/ai/insights/me/refresh' : '/ai/insights/me';
      const res = await apiFetch<InsightsResponse>(path, {
        method: force ? 'POST' : 'GET',
      });
      setData(res);
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      pushToast({
        tone: 'error',
        title: t('aiInsights.toast.loadFailed'),
        message,
      });
    } finally {
      setBusy(false);
    }
  }, [pushToast, t]);

  useEffect(() => {
    void load(false);
  }, [load]);

  const setFeedback = useCallback(
    async (insightId: string, useful: boolean) => {
      try {
        await apiFetch(`/ai/insights/me/${insightId}/feedback`, {
          method: 'PATCH',
          body: JSON.stringify({ useful }),
        });
        // Optimistic update so user sees feedback persist immediately.
        setData((prev) =>
          prev
            ? {
                ...prev,
                insights: prev.insights.map((i) =>
                  i.id === insightId ? { ...i, isUseful: useful } : i,
                ),
              }
            : prev,
        );
        pushToast({
          tone: 'success',
          title: t('aiInsights.toast.feedbackSaved'),
        });
      } catch (err) {
        const message = err instanceof Error ? err.message : String(err);
        pushToast({
          tone: 'error',
          title: t('aiInsights.toast.feedbackFailed'),
          message,
        });
      }
    },
    [pushToast, t],
  );

  const providerLabel = data?.provider === 'gemini' ? 'Gemini' : data?.provider;

  return (
    <Card>
      <SectionTitle
        title={t('aiInsights.section.title')}
        copy={t('aiInsights.section.copy')}
        action={
          <div className="flex items-center gap-2">
            {data?.provider ? (
              <Badge className="bg-violet/15 text-violet">{providerLabel}</Badge>
            ) : null}
            <Button
              disabled={busy}
              onClick={() => load(true)}
              variant="secondary"
            >
              <RefreshCcw className={`h-4 w-4 ${busy ? 'animate-spin' : ''}`} />
              {t('aiInsights.action.refresh')}
            </Button>
          </div>
        }
      />

      <div className="mt-5 space-y-4">
        {data && data.insights.length > 0 ? (
          data.insights.map((insight) => (
            <article
              key={insight.id}
              className="rounded-lg border border-lilac/40 bg-white/80 p-4 shadow-sm"
            >
              <div className="flex items-start justify-between gap-3">
                <h4 className="text-base font-bold text-ink">{insight.title}</h4>
                <Badge
                  className={
                    insight.type === 'risk-flag'
                      ? 'bg-coral/15 text-coral'
                      : insight.type === 'celebration'
                        ? 'bg-mint/15 text-mint'
                        : 'bg-lilac/20 text-violet'
                  }
                >
                  {translateInsightType(t, insight.type)}
                </Badge>
              </div>
              <p className="mt-2 text-sm text-ink/80">{insight.content}</p>
              <div className="mt-3 flex items-center gap-2 text-xs">
                <button
                  className={`inline-flex items-center gap-1 rounded-full border px-2 py-1 transition ${
                    insight.isUseful === true
                      ? 'border-mint bg-mint/15 text-mint'
                      : 'border-slate/20 text-slate hover:border-mint hover:text-mint'
                  }`}
                  onClick={() => setFeedback(insight.id, true)}
                  type="button"
                >
                  <ThumbsUp className="h-3 w-3" />
                  {t('aiInsights.feedback.useful')}
                </button>
                <button
                  className={`inline-flex items-center gap-1 rounded-full border px-2 py-1 transition ${
                    insight.isUseful === false
                      ? 'border-coral bg-coral/15 text-coral'
                      : 'border-slate/20 text-slate hover:border-coral hover:text-coral'
                  }`}
                  onClick={() => setFeedback(insight.id, false)}
                  type="button"
                >
                  <ThumbsDown className="h-3 w-3" />
                  {t('aiInsights.feedback.notUseful')}
                </button>
              </div>
            </article>
          ))
        ) : (
          <p className="rounded-lg border border-dashed border-slate/20 bg-white/60 p-4 text-sm text-slate">
            <Brain className="mr-2 inline h-4 w-4" />
            {t('aiInsights.empty')}
          </p>
        )}

        {data && data.recommendations.length > 0 ? (
          <div className="space-y-2">
            <p className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-slate">
              <Sparkles className="h-3.5 w-3.5" />
              {t('aiInsights.recommendations.title')}
            </p>
            {data.recommendations.map((rec) => (
              <div
                key={rec.id}
                className="flex items-center justify-between gap-3 rounded-lg border border-mint/30 bg-mint/5 p-3"
              >
                <p className="text-sm text-ink/85">{rec.reason}</p>
                <Badge className="bg-mint/15 text-mint">
                  {Math.round(rec.score * 100)}%
                </Badge>
              </div>
            ))}
          </div>
        ) : null}
      </div>
    </Card>
  );
}
