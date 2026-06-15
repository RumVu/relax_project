'use client';

import { useMemo, useState } from 'react';
import {
  BookHeart,
  BookOpenText,
  Edit3,
  Heart,
  PenLine,
  Search,
  Star,
  Trash2,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  MetricCard,
  ProgressList,
  SectionTitle,
} from '@/components/dashboard/dashboard-ui';
import { DashboardFilterBar, useDashboardFilters } from '@/components/dashboard/dashboard-filters';
import { QuestPanel } from '@/components/dashboard/quest-panel';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUserDashboardData } from '@/lib/live-dashboard';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

const moodTypeOptions = [
  'HAPPY',
  'CALM',
  'TIRED',
  'SAD',
  'ANXIOUS',
  'STRESSED',
  'EXCITED',
  'NEUTRAL',
  'LONELY',
  'GRATEFUL',
  'POOPING',
];

export default function JournalPage() {
  const { t } = useTranslation();
  const journalFilters = useDashboardFilters('/journals/me', 'journal');
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const triggerRefresh = useDashboardStore((state) => state.triggerRefresh);
  const pushToast = useUiStore((state) => state.pushToast);
  const [query, setQuery] = useState('');
  const journals = useUserDashboardData({
    refreshKey: refreshNonce,
    journalQuery: { ...journalFilters.query, q: query.trim() || undefined },
  }).overview.journals;
  const [moodFilter, setMoodFilter] = useState('ALL');
  const [draft, setDraft] = useState('');
  const [draftTitle, setDraftTitle] = useState('');
  const [draftMood, setDraftMood] = useState('NEUTRAL');
  const [draftTags, setDraftTags] = useState('web-dashboard');
  const [editingId, setEditingId] = useState<string | null>(null);
  const [saveState, setSaveState] = useState<'idle' | 'saving' | 'saved' | 'error'>('idle');
  const [saveError, setSaveError] = useState<string | null>(null);
  const filtered = useMemo(
    () =>
      journals.recent.filter((journal) => {
        const matchesQuery =
          journal.title.toLowerCase().includes(query.toLowerCase()) ||
          journal.excerpt.toLowerCase().includes(query.toLowerCase()) ||
          journal.tags.join(' ').toLowerCase().includes(query.toLowerCase());
        const matchesMood = moodFilter === 'ALL' || journal.mood === moodFilter;

        return matchesQuery && matchesMood;
      }),
    [journals.recent, moodFilter, query],
  );
  const topMood = journals.byMood[0]?.mood ?? t('common.unknown');
  const moodOptions = useMemo(
    () => ['ALL', ...new Set(journals.byMood.map((item) => item.mood))],
    [journals.byMood],
  );

  return (
    <DashboardShell eyebrow={t('journal.eyebrow')} title={t('journal.title')}>
      <DashboardFilterBar {...journalFilters} title={t('journal.filterTitle')} />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard icon={BookOpenText} label={t('journal.metric.entries')} value={journals.total} />
        <MetricCard icon={Star} label={t('journal.metric.favorite')} tone="sun" value={journals.favorites} />
        <MetricCard
          icon={Heart}
          label={t('journal.metric.topMood')}
          note={t('journal.metric.topMood.note')}
          tone="coral"
          value={topMood}
        />
        <MetricCard
          icon={BookHeart}
          label={t('journal.metric.recent')}
          note={t('journal.metric.recent.note')}
          tone="mint"
          value={journals.recent.length}
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1fr)_360px]">
        <Card>
          <SectionTitle
            title={t('journal.list.title')}
            copy={t('journal.list.copy')}
            action={
              <div className="flex flex-wrap gap-2">
                <div className="flex h-10 items-center gap-2 rounded-lg border border-lilac bg-white px-3 text-sm">
                  <Search className="h-4 w-4 text-violet" />
                  <input
                    className="w-40 bg-transparent outline-none"
                    onChange={(event) => setQuery(event.target.value)}
                    placeholder={t('journal.list.searchPlaceholder')}
                    value={query}
                  />
                </div>
                <select
                  className="h-10 rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink"
                  onChange={(event) => setMoodFilter(event.target.value)}
                  value={moodFilter}
                >
                  {moodOptions.map((option) => (
                    <option key={option} value={option}>
                      {option === 'ALL' ? t('journal.list.moodAll') : option}
                    </option>
                  ))}
                </select>
              </div>
            }
          />
          <div className="mt-5 space-y-3">
            {filtered.length > 0 ? filtered.map((journal) => (
              <article
                className="rounded-lg border border-lilac/70 bg-white/75 p-4"
                key={journal.id}
              >
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <h3 className="text-lg font-extrabold text-ink">{journal.title}</h3>
                    <p className="mt-1 text-xs font-semibold text-slate">{journal.createdAt}</p>
                  </div>
                  <span className="rounded-md bg-lilac/50 px-2 py-1 text-xs font-bold text-plum">
                    {journal.mood}
                  </span>
                </div>
                <p className="mt-3 text-sm leading-6 text-slate">{journal.excerpt}</p>
                <div className="mt-4 flex flex-wrap gap-2">
                  {journal.tags.map((tag) => (
                    <span className="rounded-md bg-cloud px-2 py-1 text-xs font-bold text-ink" key={tag}>
                      #{tag}
                    </span>
                  ))}
                </div>
                <div className="mt-4 flex flex-wrap gap-2">
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={() => {
                      setEditingId(journal.id);
                      setDraftTitle(journal.title);
                      setDraft(journal.content || journal.excerpt);
                      setDraftMood(journal.moodType || 'NEUTRAL');
                      setDraftTags(journal.tags.join(', '));
                    }}
                    variant="secondary"
                  >
                    <Edit3 className="h-3.5 w-3.5" />
                    {t('btn.edit')}
                  </Button>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={async () => {
                      try {
                        await apiFetch(`/journals/${journal.id}`, {
                          method: 'PATCH',
                          body: JSON.stringify({ isFavorite: !journal.favorite }),
                        });
                        triggerRefresh();
                        pushToast({
                          tone: 'success',
                          title: journal.favorite
                            ? t('journal.toast.unfavorited')
                            : t('journal.toast.favorited'),
                        });
                      } catch (err) {
                        pushToast({
                          tone: 'error',
                          title: t('journal.toast.favoriteFailed'),
                          message:
                            err instanceof Error ? err.message : String(err),
                        });
                      }
                    }}
                    variant="secondary"
                  >
                    <Heart className="h-3.5 w-3.5" />
                    {journal.favorite ? t('journal.action.unmarkFavorite') : t('journal.action.markFavorite')}
                  </Button>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={async () => {
                      try {
                        await apiFetch(`/journals/${journal.id}`, { method: 'DELETE' });
                        triggerRefresh();
                        pushToast({
                          tone: 'success',
                          title: t('journal.toast.deleted'),
                          message: journal.title,
                        });
                      } catch (err) {
                        pushToast({
                          tone: 'error',
                          title: t('journal.toast.deleteFailed'),
                          message:
                            err instanceof Error ? err.message : String(err),
                        });
                      }
                    }}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                    {t('btn.delete')}
                  </Button>
                </div>
              </article>
            )) : (
              <div className="rounded-lg border border-dashed border-lilac bg-white/70 p-6 text-sm font-medium text-slate">
                {t('journal.empty.filtered')}
              </div>
            )}
          </div>
        </Card>

        <Card>
          <SectionTitle
            title={editingId ? t('journal.draft.editHeading') : t('journal.draft.heading')}
            copy={t('journal.draft.copy')}
            action={<PenLine className="h-5 w-5 text-violet" />}
          />
          <input
            className="mt-5 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
            onChange={(event) => setDraftTitle(event.target.value)}
            placeholder={t('journal.draft.titlePlaceholder')}
            value={draftTitle}
          />
          <div className="mt-3 grid gap-3 sm:grid-cols-2">
            <select
              className="h-11 rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
              onChange={(event) => setDraftMood(event.target.value)}
              value={draftMood}
            >
              {moodTypeOptions.map((option) => (
                <option key={option} value={option}>
                  {option}
                </option>
              ))}
            </select>
            <input
            className="h-11 rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
            onChange={(event) => setDraftTags(event.target.value)}
            placeholder={t('journal.draft.tagsPlaceholder')}
            value={draftTags}
          />
          </div>
          <textarea
            className="mt-3 min-h-[220px] w-full rounded-lg border border-lilac bg-white/85 p-3 text-sm outline-none focus:border-violet"
            onChange={(event) => setDraft(event.target.value)}
            placeholder={t('journal.draft.contentPlaceholder')}
            value={draft}
          />
          <div className="mt-4 flex items-center justify-between gap-3">
            <p className="text-sm font-semibold text-slate">{draft.length}/600</p>
            <Button
              disabled={saveState === 'saving' || draft.trim().length === 0}
              onClick={async () => {
                setSaveState('saving');
                setSaveError(null);
                try {
                  const payload = {
                    title:
                      draftTitle.trim() ||
                      draft.trim().slice(0, 60) ||
                      'Quick reflection',
                    content: draft,
                    mood: draftMood,
                    tags: draftTags
                      .split(',')
                      .map((tag) => tag.trim().replace(/^#/, ''))
                      .filter(Boolean)
                      .slice(0, 10),
                  };

                  if (editingId) {
                    await apiFetch(`/journals/${editingId}`, {
                      method: 'PATCH',
                      body: JSON.stringify(payload),
                    });
                  } else {
                    await apiFetch('/journals/me', {
                      method: 'POST',
                      body: JSON.stringify({
                        ...payload,
                        isPrivate: true,
                      }),
                    });
                  }
                  setSaveState('saved');
                  setEditingId(null);
                  setDraftTitle('');
                  setDraft('');
                  setDraftMood('NEUTRAL');
                  setDraftTags('web-dashboard');
                  triggerRefresh();
                  pushToast({
                    tone: 'success',
                    title: editingId ? t('journal.toast.updated') : t('journal.toast.saved'),
                    message: t('journal.toast.savedMessage'),
                  });
                } catch (err) {
                  // Trước đây catch im lặng nên toast chỉ hiện "Save failed"
                  // mà không có lý do — bài này lưu được trên backend, lỗi
                  // thật là client (token hết hạn / mất mạng / CORS) bị giấu.
                  const message =
                    err instanceof Error ? err.message : String(err);
                  setSaveState('error');
                  setSaveError(message);
                  pushToast({
                    tone: 'error',
                    title: t('journal.toast.saveFailed'),
                    message,
                  });
                }
              }}
            >
              <PenLine className="h-4 w-4" />
              {saveState === 'saving' ? t('journal.draft.saving') : editingId ? t('journal.draft.update') : t('journal.draft.save')}
            </Button>
          </div>
          {editingId ? (
            <Button
              className="mt-3"
              onClick={() => {
                setEditingId(null);
                setDraftTitle('');
                setDraft('');
                setDraftMood('NEUTRAL');
                setDraftTags('web-dashboard');
              }}
              variant="secondary"
            >
              {t('journal.draft.cancelEdit')}
            </Button>
          ) : null}
          {saveState === 'saved' || saveState === 'error' ? (
            <p
              className={`mt-3 text-sm font-semibold ${
                saveState === 'saved' ? 'text-mint' : 'text-coral'
              }`}
            >
              {saveState === 'saved'
                ? t('journal.saveState.saved')
                : (saveError ?? t('journal.saveState.failed'))}
            </p>
          ) : null}
          <div className="mt-6">
            <ProgressList
              items={journals.byMood.map((item) => ({
                mood: item.mood,
                percent: Math.round((item.count / journals.total) * 100),
              }))}
            />
          </div>
        </Card>
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,0.9fr)_minmax(0,1.1fr)]">
        <Card>
          <SectionTitle
            title={t('journal.distribution.title')}
            copy={t('journal.distribution.copy')}
          />
          <div className="mt-5">
            <ProgressList
              items={journals.byMood.map((item) => ({
                mood: item.mood,
                percent:
                  journals.total > 0 ? Math.round((item.count / journals.total) * 100) : 0,
              }))}
            />
          </div>
        </Card>

        <QuestPanel />
      </div>
    </DashboardShell>
  );
}
