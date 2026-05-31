'use client';

import { FormEvent, useCallback, useEffect, useState } from 'react';
import { Database, RefreshCcw, Search, Tag } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { DataTable, MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type SearchIndexItem = {
  id: string;
  entityType: string;
  entityId: string;
  title: string;
  content: string;
  tags: string[];
  updatedAt: string;
};

type SearchPayload = {
  total?: number;
  note?: string;
  items?: SearchIndexItem[];
};

const entityOptions = [
  { label: 'All content', value: '' },
  { label: 'Quotes', value: 'COZY_QUOTE' },
  { label: 'Sounds', value: 'AMBIENT_SOUND' },
  { label: 'Breathing', value: 'BREATHING_EXERCISE' },
  { label: 'Themes', value: 'APP_THEME' },
  { label: 'Onboarding', value: 'ONBOARDING_SLIDE' },
  { label: 'Companion assets', value: 'COMPANION_ASSET' },
  { label: 'Companion messages', value: 'COMPANION_MESSAGE' },
];

const quickQueries = ['stress', 'calm', 'companion', 'podcast', 'breathing', 'onboarding'];

export default function AdminSearchPage() {
  const { t, locale } = useTranslation();
  const pushToast = useUiStore((state) => state.pushToast);
  const [query, setQuery] = useState('');
  const [entityType, setEntityType] = useState('');
  const [items, setItems] = useState<SearchIndexItem[]>([]);
  const [total, setTotal] = useState(0);
  const [note, setNote] = useState('');
  const [loading, setLoading] = useState(false);

  const runSearch = useCallback(async (
    event?: FormEvent<HTMLFormElement>,
    nextQuery = '',
    nextEntityType = '',
  ) => {
    event?.preventDefault();
    setLoading(true);

    try {
      const payload = await apiFetch<SearchPayload>('/admin/search', undefined, {
        query: {
          q: nextQuery.trim() || undefined,
          entityType: nextEntityType || undefined,
          limit: 50,
        },
      });

      setItems(payload.items ?? []);
      setTotal(payload.total ?? payload.items?.length ?? 0);
      setNote(payload.note ?? '');
    } catch {
      pushToast({
        tone: 'error',
        title: t('admin.search.toast.failed'),
        message: t('admin.search.toast.queryHint'),
      });
    } finally {
      setLoading(false);
    }
  }, [pushToast, t]);

  useEffect(() => {
    let cancelled = false;

    async function bootstrap() {
      try {
        const payload = await apiFetch<SearchPayload>('/admin/search', undefined, {
          query: { limit: 50 },
        });

        if (!cancelled) {
          setItems(payload.items ?? []);
          setTotal(payload.total ?? payload.items?.length ?? 0);
          setNote(payload.note ?? '');
        }
      } catch {
        if (!cancelled) {
          pushToast({
            tone: 'error',
            title: t('admin.search.toast.failed'),
            message: t('catalog.toast.serverHint'),
          });
        }
      }
    }

    void bootstrap();

    return () => {
      cancelled = true;
    };
  }, [pushToast, t]);

  function searchQuick(value: string) {
    setQuery(value);
    void runSearch(undefined, value, entityType);
  }

  return (
    <DashboardShell admin eyebrow={t('admin.eyebrow')} title={t('admin.search.title')}>
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        <MetricCard icon={Search} label={t('admin.search.metric.results')} value={total} />
        <MetricCard icon={Database} label="Index source" tone="mint" value="SearchIndex" />
        <MetricCard icon={Tag} label={t('admin.search.entity')} tone="lilac" value={entityType || t('admin.search.allContent')} />
      </div>

      <Card>
        <SectionTitle
          title={t('admin.search.globalTitle')}
          copy={t('admin.search.globalCopy')}
        />
        <form
          className="mt-5 grid gap-3 lg:grid-cols-[minmax(0,1fr)_260px_auto]"
          onSubmit={(event) => void runSearch(event, query, entityType)}
        >
          <label className="text-sm font-bold text-slate">
            {t('admin.search.input')}
            <input
              className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white px-3 text-ink outline-none"
              onChange={(event) => setQuery(event.target.value)}
              placeholder={t('admin.search.inputPlaceholder')}
              value={query}
            />
          </label>
          <label className="text-sm font-bold text-slate">
            {t('admin.search.entity')}
            <select
              className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white px-3 text-ink outline-none"
              onChange={(event) => setEntityType(event.target.value)}
              value={entityType}
            >
              {entityOptions.map((option) => (
                <option key={option.value || 'all'} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </label>
          <Button className="self-end" disabled={loading || query.trim().length === 1} type="submit">
            <Search className="h-4 w-4" />
            {loading ? t('admin.search.running') : t('admin.search.run')}
          </Button>
        </form>
        <div className="mt-4 flex flex-wrap gap-2">
          {quickQueries.map((value) => (
            <Button
              className="h-8 px-3 text-xs"
              key={value}
              onClick={() => searchQuick(value)}
              variant="secondary"
            >
              {value}
            </Button>
          ))}
          <Button
            className="h-8 px-3 text-xs"
            onClick={() => {
              setQuery('');
              setEntityType('');
              void runSearch(undefined, '');
            }}
            variant="secondary"
          >
            <RefreshCcw className="h-3.5 w-3.5" />
            {t('admin.search.latest')}
          </Button>
        </div>
        {note ? (
          <p className="mt-4 rounded-lg border border-sun/40 bg-sun/10 p-3 text-sm font-semibold text-ink">
            {note}
          </p>
        ) : null}
      </Card>

      <Card>
        <SectionTitle title={t('admin.search.resultsTitle')} copy={t('admin.search.resultsCopy')} />
        <div className="mt-5">
          <DataTable
            columns={[t('admin.search.col.type'), t('admin.search.col.title'), t('admin.search.col.content'), t('admin.search.col.entityId'), t('admin.search.col.tags'), t('admin.search.col.updated')]}
            rows={items.map((item) => [
              item.entityType,
              item.title,
              truncate(item.content, 110),
              item.entityId,
              item.tags.join(', ') || '-',
              formatDateTime(item.updatedAt, locale),
            ])}
          />
        </div>
      </Card>
    </DashboardShell>
  );
}

function truncate(value: string, length: number) {
  return value.length <= length ? value : `${value.slice(0, length - 1)}...`;
}

function formatDateTime(value: string, locale: string) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return '-';
  }

  return date.toLocaleString(locale === 'vi' ? 'vi-VN' : 'en-US', {
    dateStyle: 'short',
    timeStyle: 'short',
  });
}
