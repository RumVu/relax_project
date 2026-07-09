'use client';

import { ChevronLeft, ChevronRight, UploadCloud } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import type { FieldConfig } from './admin-catalog-types';

export function CatalogField({
  field,
  label,
  value,
  onChange,
  upload,
  uploading,
  onUpload,
  pendingFileName,
}: {
  field: FieldConfig;
  label: string;
  value: string | boolean;
  onChange: (value: string | boolean) => void;
  upload?: { accept: string; pathPrefix: string };
  uploading?: boolean;
  onUpload?: (file: File) => void;
  pendingFileName?: string;
}) {
  const { t } = useTranslation();

  if (field.type === 'boolean') {
    return (
      <button
        className={`rounded-lg border p-4 text-left transition ${
          value ? 'border-violet bg-violet text-white' : 'border-lilac/70 bg-white/75 text-ink'
        }`}
        onClick={() => onChange(!value)}
        type="button"
      >
        <p className="font-bold">{label}</p>
        <p className={`mt-1 text-xs font-semibold ${value ? 'text-white/70' : 'text-slate'}`}>
          {value ? 'Enabled' : 'Disabled'}
        </p>
      </button>
    );
  }

  if (field.type === 'select') {
    return (
      <label className="block">
        <span className="text-sm font-semibold text-slate">{label}</span>
        <select
          className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
          onChange={(event) => onChange(event.target.value)}
          required={field.required}
          value={String(value)}
        >
          {field.options?.map((option) => (
            <option key={option || 'none'} value={option}>
              {option || '—'}
            </option>
          ))}
        </select>
      </label>
    );
  }

  if (field.type === 'textarea') {
    return (
      <label className="block">
        <span className="text-sm font-semibold text-slate">{label}</span>
        <textarea
          className="mt-2 min-h-[120px] w-full rounded-lg border border-lilac bg-white/85 px-3 py-3 text-sm font-semibold text-ink outline-none focus:border-violet"
          onChange={(event) => onChange(event.target.value)}
          required={field.required}
          value={String(value)}
        />
      </label>
    );
  }

  return (
    <label className="block">
      <span className="text-sm font-semibold text-slate">{label}</span>
      <div className={upload ? 'mt-2 grid gap-2 sm:grid-cols-[minmax(0,1fr)_auto]' : 'mt-2'}>
        <input
          className="h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
          onChange={(event) => onChange(event.target.value)}
          required={field.required}
          type={field.type === 'url' ? 'url' : field.type}
          value={String(value)}
        />
        {upload ? (
          <span className="relative inline-flex">
            <input
              accept={upload.accept}
              className="absolute inset-0 cursor-pointer opacity-0"
              disabled={uploading}
              onChange={(event) => {
                const file = event.target.files?.[0];
                if (file) onUpload?.(file);
                event.currentTarget.value = '';
              }}
              type="file"
            />
            <Button className="h-11" disabled={uploading} type="button" variant="secondary">
              <UploadCloud className="h-4 w-4" />
              {uploading ? t('catalog.uploading') : t('catalog.upload')}
            </Button>
          </span>
        ) : null}
      </div>
      {pendingFileName ? (
        <p className="mt-2 text-xs font-semibold text-[var(--app-muted,theme(colors.slate))]">
          {t('catalog.upload.staged', { filename: pendingFileName })}
        </p>
      ) : null}
    </label>
  );
}

/**
 * Footer for the catalog table: lets the admin pick how many rows show
 * up per page (10 / 20 / 50) and step through pages. Hides itself when
 * the entire list fits in one page anyway.
 */
export function PaginationBar({
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
  const { t } = useTranslation();
  const pageSizes = [10, 20, 50];
  const lastPage = Math.max(0, Math.ceil(total / pageSize) - 1);
  const showingFrom = total === 0 ? 0 : page * pageSize + 1;
  const showingTo = Math.min((page + 1) * pageSize, total);

  // Don't render at all when there's nothing to page through.
  if (total <= pageSizes[0]! && page === 0) {
    return null;
  }

  return (
    <div className="mt-4 flex flex-wrap items-center justify-between gap-3 rounded-lg border border-[var(--field-border)] bg-[var(--panel-bg)] p-3">
      <div className="flex items-center gap-2 text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
        <span>{t('catalog.pagination.show')}</span>
        <select
          aria-label={t('catalog.pagination.perPage')}
          className="h-9 rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-2 text-sm font-bold text-[var(--app-text)]"
          onChange={(event) => setPageSize(Number(event.target.value))}
          value={pageSize}
        >
          {pageSizes.map((size) => (
            <option key={size} value={size}>
              {size}
            </option>
          ))}
        </select>
        <span>{t('catalog.pagination.resultsPerPage')}</span>
      </div>
      <div className="flex items-center gap-3 text-sm font-semibold text-[var(--app-text)]">
        <span className="text-[var(--app-muted,theme(colors.slate))]">
          {total === 0
            ? '0 / 0'
            : `${showingFrom}–${showingTo} / ${total}`}
        </span>
        <div className="flex items-center gap-1">
          <button
            aria-label={t('catalog.pagination.prev')}
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
            aria-label={t('catalog.pagination.next')}
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
