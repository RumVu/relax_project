'use client';

import { ChevronLeft, ChevronRight } from 'lucide-react';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { VI_SETTINGS_COPY, EN_SETTINGS_COPY } from '../settings-copy';

export function SessionsPagination({
  page,
  pageSize,
  setPage,
  setPageSize,
  total,
}: {
  page: number;
  pageSize: number;
  setPage: (next: number) => void;
  setPageSize: (next: number) => void;
  total: number;
}) {
  const { locale } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;
  const pageSizes = [10, 20, 50];
  const lastPage = Math.max(0, Math.ceil(total / pageSize) - 1);
  const showingFrom = total === 0 ? 0 : page * pageSize + 1;
  const showingTo = Math.min((page + 1) * pageSize, total);
  if (total <= pageSizes[0]! && page === 0) return null;
  return (
    <div className="mt-3 flex flex-wrap items-center justify-between gap-3 rounded-lg border border-[var(--field-border)] bg-[var(--panel-bg)] p-3">
      <div className="flex items-center gap-2 text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
        <span>{copy.show}</span>
        <select
          aria-label={copy.sessionsPerPage}
          className="h-9 rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-2 text-sm font-bold text-[var(--app-text)]"
          onChange={(event) => {
            setPageSize(Number(event.target.value));
            setPage(0);
          }}
          value={pageSize}
        >
          {pageSizes.map((s) => (
            <option key={s} value={s}>
              {s}
            </option>
          ))}
        </select>
        <span>{copy.sessionsPerPage}</span>
      </div>
      <div className="flex items-center gap-3 text-sm font-semibold text-[var(--app-text)]">
        <span className="text-[var(--app-muted,theme(colors.slate))]">
          {showingFrom}–{showingTo} / {total}
        </span>
        <div className="flex items-center gap-1">
          <button
            aria-label={copy.previousPage}
            className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] disabled:opacity-40"
            disabled={page <= 0}
            onClick={() => setPage(Math.max(0, page - 1))}
            type="button"
          >
            <ChevronLeft className="h-4 w-4" />
          </button>
          <span className="px-2 text-xs font-bold">
            {page + 1} / {Math.max(1, lastPage + 1)}
          </span>
          <button
            aria-label={copy.nextPage}
            className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] disabled:opacity-40"
            disabled={page >= lastPage}
            onClick={() => setPage(Math.min(lastPage, page + 1))}
            type="button"
          >
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
}

export function PaymentsPagination({
  page,
  pageSize,
  setPage,
  setPageSize,
  total,
}: {
  page: number;
  pageSize: 10 | 20 | 50;
  setPage: (next: number) => void;
  setPageSize: (next: 10 | 20 | 50) => void;
  total: number;
}) {
  const { t } = useTranslation();
  const pageSizes: Array<10 | 20 | 50> = [10, 20, 50];
  const lastPage = Math.max(0, Math.ceil(total / pageSize) - 1);
  const showingFrom = total === 0 ? 0 : page * pageSize + 1;
  const showingTo = Math.min((page + 1) * pageSize, total);
  // Hide controls entirely when there's nothing to paginate.
  if (total <= pageSizes[0]) return null;
  return (
    <div className="mt-3 flex flex-wrap items-center justify-between gap-3 rounded-lg border border-[var(--field-border)] bg-[var(--panel-bg)] p-3">
      <div className="flex items-center gap-2 text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
        {pageSizes.map((s) => (
          <button
            className={`h-8 rounded-lg px-3 text-xs font-bold transition ${
              pageSize === s
                ? 'bg-violet text-white'
                : 'border border-[var(--field-border)] bg-[var(--field-bg)] text-[var(--app-text)] hover:border-violet/40'
            }`}
            key={s}
            onClick={() => setPageSize(s)}
            type="button"
          >
            {t('payments.pagination.pageSize', { count: s })}
          </button>
        ))}
      </div>
      <div className="flex items-center gap-3 text-sm font-semibold text-[var(--app-text)]">
        <span className="text-[var(--app-muted,theme(colors.slate))]">
          {showingFrom}–{showingTo} / {total}
        </span>
        <div className="flex items-center gap-1">
          <button
            aria-label={t('payments.pagination.prev')}
            className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] disabled:opacity-40"
            disabled={page <= 0}
            onClick={() => setPage(Math.max(0, page - 1))}
            type="button"
          >
            <ChevronLeft className="h-4 w-4" />
          </button>
          <span className="px-2 text-xs font-bold">
            {t('payments.pagination.page', {
              current: page + 1,
              total: Math.max(1, lastPage + 1),
            })}
          </span>
          <button
            aria-label={t('payments.pagination.next')}
            className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] disabled:opacity-40"
            disabled={page >= lastPage}
            onClick={() => setPage(Math.min(lastPage, page + 1))}
            type="button"
          >
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
}

