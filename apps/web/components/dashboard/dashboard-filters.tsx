'use client';

import { useMemo, useState } from 'react';
import { CalendarDays, Clock3, Filter, SlidersHorizontal, type LucideIcon } from 'lucide-react';
import { clampLimit, clampSkip, withQuery } from '@/lib/api';
import { Badge } from '@/components/ui/badge';
import { Card } from '@/components/ui/card';
import { SectionTitle } from './dashboard-ui';
import { useTranslation } from '@/lib/i18n/i18n-provider';

type FilterMode = 'overview' | 'mood' | 'analytics' | 'journal' | 'relax' | 'notification';

type FilterValue = string | boolean | number | undefined;

type DashboardFilterState = {
  period: string;
  timezone: string;
  compare: boolean;
  from: string;
  to: string;
  skip: number;
  limit: number;
  mood: string;
  tag: string;
  isFavorite: string;
  activityType: string;
  notificationType: string;
  isRead: string;
};

const periodOptions = ['week', 'month', 'quarter', 'year'];
const customPeriodOptions = [...periodOptions, 'custom'];
const timezoneOptions = ['Asia/Ho_Chi_Minh', 'UTC', 'America/New_York', 'Europe/London', 'Asia/Tokyo'];
const moodOptions = ['ALL', 'HAPPY', 'CALM', 'TIRED', 'SAD', 'ANXIOUS', 'STRESSED', 'EXCITED', 'NEUTRAL', 'LONELY', 'GRATEFUL'];
const activityOptions = ['ALL', 'MUSIC', 'PODCAST', 'JOURNAL', 'BREATHING', 'MYSTERY', 'MEDITATION'];
const notificationOptions = ['ALL', 'IN_APP', 'PUSH', 'EMAIL', 'SMS'];

export function useDashboardFilters(baseEndpoint: string, mode: FilterMode) {
  const [state, setState] = useState<DashboardFilterState>({
    period: mode === 'mood' || mode === 'journal' || mode === 'notification' ? '' : 'week',
    timezone: 'Asia/Ho_Chi_Minh',
    compare: true,
    from: '',
    to: '',
    skip: 0,
    limit: 20,
    mood: 'ALL',
    tag: '',
    isFavorite: 'ALL',
    activityType: 'ALL',
    notificationType: 'ALL',
    isRead: 'ALL',
  });

  const setField = (key: keyof DashboardFilterState, value: FilterValue) => {
    setState((current) => ({
      ...current,
      [key]:
        key === 'limit'
          ? clampLimit(String(value), 20)
          : key === 'skip'
            ? clampSkip(String(value), 0)
            : value,
    }));
  };

  const query = useMemo(() => {
    const params: Record<string, string | number | boolean | undefined> = {};
    const supportsTimezone =
      mode === 'overview' || mode === 'analytics' || mode === 'relax';

    if (supportsTimezone) {
      params.timezone = state.timezone;
    }

    if (state.period) {
      params.period = state.period;
    }

    if (state.period === 'custom') {
      params.from = state.from || undefined;
      params.to = state.to || undefined;
    } else if (mode === 'mood' || mode === 'journal') {
      params.from = state.from || undefined;
      params.to = state.to || undefined;
    }

    if (mode === 'analytics') {
      params.compare = state.compare;
    }

    if (mode === 'mood' || mode === 'journal') {
      params.mood = state.mood === 'ALL' ? undefined : state.mood;
    }

    if (mode === 'journal') {
      params.tag = state.tag || undefined;
      params.isFavorite =
        state.isFavorite === 'ALL' ? undefined : state.isFavorite === 'true';
    }

    if (mode === 'relax') {
      params.activityType = state.activityType === 'ALL' ? undefined : state.activityType;
    }

    if (mode === 'notification') {
      params.type = state.notificationType === 'ALL' ? undefined : state.notificationType;
      params.isRead = state.isRead === 'ALL' ? undefined : state.isRead === 'true';
    }

    if (['mood', 'journal', 'relax', 'notification'].includes(mode)) {
      params.skip = state.skip;
      params.limit = state.limit;
    }

    return params;
  }, [mode, state]);

  return {
    endpoint: withQuery(baseEndpoint, query),
    mode,
    query,
    setField,
    state,
  };
}

export function DashboardFilterBar({
  endpoint,
  mode,
  setField,
  state,
  title,
}: ReturnType<typeof useDashboardFilters> & { title?: string }) {
  const { t } = useTranslation();
  const resolvedTitle = title ?? t('dashboard.filters.title');
  const showPeriod = ['overview', 'analytics', 'relax'].includes(mode);
  const showDateRange = mode !== 'overview';
  const showTimezone = ['overview', 'analytics', 'relax'].includes(mode);
  const showPagination = ['mood', 'journal', 'relax', 'notification'].includes(mode);

  return (
    <Card className="border-violet/25 bg-white/80">
      <SectionTitle
        title={resolvedTitle}
        copy={t('filter.area')}
        action={
          <Badge className="bg-violet/10 text-plum">
            <SlidersHorizontal className="mr-2 h-3.5 w-3.5" />
            {t('filter.maxItems', { count: 100 })}
          </Badge>
        }
      />
      <div className="mt-5 grid gap-3 md:grid-cols-2 xl:grid-cols-4">
        {showPeriod ? (
          <Field label={t('filter.period.label')} icon={Clock3}>
            <select
              className={inputClass}
              onChange={(event) => setField('period', event.target.value)}
              value={state.period}
            >
              {(mode === 'overview' ? periodOptions : customPeriodOptions).map((period) => (
                <option key={period} value={period}>
                  {period}
                </option>
              ))}
            </select>
          </Field>
        ) : null}

        {showTimezone ? (
          <Field label={t('filter.timezone.label')} icon={CalendarDays}>
            <select
              className={inputClass}
              onChange={(event) => setField('timezone', event.target.value)}
              value={state.timezone}
            >
              {timezoneOptions.map((timezone) => (
                <option key={timezone} value={timezone}>
                  {timezone}
                </option>
              ))}
            </select>
          </Field>
        ) : null}

        {showDateRange ? (
          <>
            <Field label={t('filter.fromDate')} icon={CalendarDays}>
              <input
                className={inputClass}
                onChange={(event) => setField('from', event.target.value)}
                type="date"
                value={state.from}
              />
            </Field>
            <Field label={t('filter.toDate')} icon={CalendarDays}>
              <input
                className={inputClass}
                onChange={(event) => setField('to', event.target.value)}
                type="date"
                value={state.to}
              />
            </Field>
          </>
        ) : null}

        {mode === 'analytics' ? (
          <Field label={t('filter.compare')} icon={Filter}>
            <select
              className={inputClass}
              onChange={(event) => setField('compare', event.target.value === 'true')}
              value={String(state.compare)}
            >
              <option value="true">{t('common.confirm')}</option>
              <option value="false">{t('common.cancel')}</option>
            </select>
          </Field>
        ) : null}

        {mode === 'mood' || mode === 'journal' ? (
          <Field label={t('nav.mood')} icon={Filter}>
            <select
              className={inputClass}
              onChange={(event) => setField('mood', event.target.value)}
              value={state.mood}
            >
              {moodOptions.map((mood) => (
                <option key={mood} value={mood}>
                  {mood}
                </option>
              ))}
            </select>
          </Field>
        ) : null}

        {mode === 'journal' ? (
          <>
            <Field label="Tag" icon={Filter}>
              <input
                className={inputClass}
                onChange={(event) => setField('tag', event.target.value)}
                placeholder="evening"
                value={state.tag}
              />
            </Field>
            <Field label="Favorite" icon={Filter}>
              <select
                className={inputClass}
                onChange={(event) => setField('isFavorite', event.target.value)}
                value={state.isFavorite}
              >
                <option value="ALL">ALL</option>
                <option value="true">true</option>
                <option value="false">false</option>
              </select>
            </Field>
          </>
        ) : null}

        {mode === 'relax' ? (
          <Field label={t('dashboard.table.activity')} icon={Filter}>
            <select
              className={inputClass}
              onChange={(event) => setField('activityType', event.target.value)}
              value={state.activityType}
            >
              {activityOptions.map((activity) => (
                <option key={activity} value={activity}>
                  {activity}
                </option>
              ))}
            </select>
          </Field>
        ) : null}

        {mode === 'notification' ? (
          <>
            <Field label="Type" icon={Filter}>
              <select
                className={inputClass}
                onChange={(event) => setField('notificationType', event.target.value)}
                value={state.notificationType}
              >
                {notificationOptions.map((type) => (
                  <option key={type} value={type}>
                    {type}
                  </option>
                ))}
              </select>
            </Field>
            <Field label="Read" icon={Filter}>
              <select
                className={inputClass}
                onChange={(event) => setField('isRead', event.target.value)}
                value={state.isRead}
              >
                <option value="ALL">ALL</option>
                <option value="true">true</option>
                <option value="false">false</option>
              </select>
            </Field>
          </>
        ) : null}

        {showPagination ? (
          <>
            <Field label="Skip" icon={Filter}>
              <input
                className={inputClass}
                min={0}
                onChange={(event) => setField('skip', event.target.value)}
                type="number"
                value={state.skip}
              />
            </Field>
            <Field label="Limit" icon={Filter}>
              <input
                className={inputClass}
                max={100}
                min={1}
                onChange={(event) => setField('limit', event.target.value)}
                type="number"
                value={state.limit}
              />
            </Field>
          </>
        ) : null}
      </div>
      <div className="mt-5 flex flex-wrap items-center gap-2">
        <Badge className="bg-sun/25 text-ink">{t('filter.moodScoreHint')}</Badge>
      </div>
    </Card>
  );
}

function Field({
  children,
  icon: Icon,
  label,
}: {
  children: React.ReactNode;
  icon: LucideIcon;
  label: string;
}) {
  return (
    <label className="block">
      <span className="mb-2 flex items-center gap-2 text-xs font-bold uppercase tracking-[0.12em] text-slate">
        <Icon className="h-3.5 w-3.5 text-violet" />
        {label}
      </span>
      {children}
    </label>
  );
}

const inputClass =
  'h-10 w-full rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink outline-none transition focus:border-violet';
