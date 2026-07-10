'use client';

import { useEffect, useMemo, useState } from 'react';
import {
  Edit3,
  Plus,
  RefreshCcw,
  Search,
  ToggleRight,
  Trash2,
  UploadCloud,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { DataTable, MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { ApiError, apiFetch, extractList } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import type { CatalogItem, Draft, FieldConfig, Kind, PendingUpload } from './admin-catalog-types';
import { catalogConfig } from './admin-catalog-types';
import {
  asString,
  buildPayload,
  catalogQuery,
  catalogStatusLabel,
  createDraft,
  draftFromItem,
  extractTotal,
  formatAdminUploadError,
  isActive,
  slugFileName,
  translateCatalogText,
  uploadConfigForField,
} from './admin-catalog-utils';
import { CatalogField, PaginationBar } from './admin-catalog-fields';

export function AdminCatalogPage({
  kind,
  title,
  endpoint,
  copy,
  fixedCategory,
}: {
  kind: Kind;
  title: string;
  endpoint: string;
  copy: string;
  fixedCategory?: string;
}) {
  const { t } = useTranslation();
  const config = catalogConfig[kind];
  const pushToast = useUiStore((state) => state.pushToast);
  const [items, setItems] = useState<CatalogItem[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(0); // zero-based
  const [pageSize, setPageSize] = useState(20);
  const [query, setQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'ALL' | 'ACTIVE' | 'DRAFT'>('ALL');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [draft, setDraft] = useState<Draft>(() =>
    createDraft(config.fields, fixedCategory),
  );
  const [pendingUploads, setPendingUploads] = useState<Record<string, PendingUpload>>({});
  const [uploadingField, setUploadingField] = useState<string | null>(null);
  const visibleFields = fixedCategory
    ? config.fields.filter((field) => field.key !== 'category')
    : config.fields;

  // Reset to first page whenever the search / filter / page-size changes
  // so the user doesn't end up on an empty page.
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setPage(0);
  }, [query, statusFilter, pageSize]);

  async function loadItems(showSpinner = true) {
    if (showSpinner) {
      setLoading(true);
    }

    try {
      const payload = await apiFetch<unknown>(endpoint, undefined, {
        query: catalogQuery(query, statusFilter, page, pageSize, fixedCategory),
      });
      setItems(extractList<CatalogItem>(payload));
      setTotal(extractTotal(payload, pageSize));
    } catch {
      pushToast({
        tone: 'error',
        title: t('catalog.toast.loadFailed', { title: title.toLowerCase() }),
        message: t('catalog.toast.serverHint'),
      });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    let cancelled = false;

    async function bootstrap() {
      try {
        const payload = await apiFetch<unknown>(endpoint, undefined, {
          query: catalogQuery(query, statusFilter, page, pageSize, fixedCategory),
        });
        if (!cancelled) {
          setItems(extractList<CatalogItem>(payload));
          setTotal(extractTotal(payload, pageSize));
        }
      } catch {
        if (!cancelled) {
          pushToast({
            tone: 'error',
            title: t('catalog.toast.loadFailed', { title: title.toLowerCase() }),
            message: t('catalog.toast.serverHint'),
          });
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    void bootstrap();

    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [endpoint, fixedCategory, query, statusFilter, page, pageSize]);

  const rows = useMemo(
    () => items.map(config.buildRow),
    [config, items],
  );
  const activeCount = items.filter(isActive).length;
  const draftCount = items.length - activeCount;

  async function saveItem() {
    setSaving(true);
    let uploadedPaths: string[] = [];

    try {
      const uploaded = await uploadPendingAssets(draft);
      uploadedPaths = uploaded.paths;
      await apiFetch(editingId ? `${endpoint}/${editingId}` : endpoint, {
        method: editingId ? 'PATCH' : 'POST',
        body: JSON.stringify({
          ...buildPayload(config.fields, uploaded.draft),
          ...(fixedCategory ? { category: fixedCategory } : {}),
        }),
      });

      resetDraft();
      await loadItems(false);
      pushToast({
        tone: 'success',
        title: editingId ? t('catalog.toast.updated') : t('catalog.toast.created'),
        message: title,
      });
    } catch (cause) {
      if (uploadedPaths.length) {
        void apiFetch('/storage/objects', {
          method: 'DELETE',
          body: JSON.stringify({ paths: uploadedPaths }),
        }).catch(() => undefined);
      }

      pushToast({
        tone: 'error',
        title:
          cause instanceof ApiError
            ? t('catalog.toast.uploadFailed')
            : t('catalog.toast.saveFailed'),
        message:
          cause instanceof ApiError
            ? formatAdminUploadError(cause)
            : t('catalog.toast.dataHint'),
      });
    } finally {
      setSaving(false);
    }
  }

  function resetDraft() {
    setEditingId(null);
    setDraft(createDraft(config.fields, fixedCategory));
    setPendingUploads({});
  }

  function startEdit(item: CatalogItem) {
    const id = asString(item.id);
    if (!id) {
      return;
    }

    setEditingId(id);
    setDraft(draftFromItem(config.fields, item, fixedCategory));
    setPendingUploads({});
  }

  function stageAsset(field: FieldConfig, file: File) {
    const upload = uploadConfigForField(field, fixedCategory);
    if (!upload) return;

    setPendingUploads((current) => ({
      ...current,
      [field.key]: { file, pathPrefix: upload.pathPrefix },
    }));
    setDraft((current) => ({ ...current, [field.key]: file.name }));
    pushToast({
      tone: 'success',
      title: t('catalog.toast.staged'),
      message: t('catalog.toast.stagedHint'),
    });
  }

  function updateDraftValue(fieldKey: string, value: string | boolean) {
    if (pendingUploads[fieldKey]) {
      setPendingUploads((uploads) => {
        const next = { ...uploads };
        delete next[fieldKey];
        return next;
      });
    }

    setDraft((current) => ({ ...current, [fieldKey]: value }));
  }

  async function uploadPendingAssets(currentDraft: Draft) {
    const nextDraft = { ...currentDraft };
    const paths: string[] = [];

    try {
      for (const [fieldKey, pending] of Object.entries(pendingUploads)) {
        setUploadingField(fieldKey);
        const formData = new FormData();
        formData.append('file', pending.file);
        formData.append(
          'path',
          `${pending.pathPrefix}/${Date.now()}-${slugFileName(pending.file.name)}`,
        );
        formData.append('upsert', 'true');

        const uploaded = await apiFetch<{ publicUrl: string; path?: string }>(
          '/storage/admin/upload',
          {
            method: 'POST',
            body: formData,
          },
        );
        nextDraft[fieldKey] = uploaded.publicUrl;
        if (uploaded.path) {
          paths.push(uploaded.path);
        }
      }
    } finally {
      setUploadingField(null);
    }

    setPendingUploads({});
    setDraft(nextDraft);
    return { draft: nextDraft, paths };
  }

  async function toggleItem(item: CatalogItem) {
    const id = asString(item.id);
    if (!id) {
      return;
    }

    try {
      await apiFetch(`${endpoint}/${id}`, {
        method: 'PATCH',
        body: JSON.stringify({
          isActive: !isActive(item),
        }),
      });
      await loadItems(false);
      pushToast({
        tone: 'success',
        title: t('catalog.toast.toggled'),
      });
    } catch {
      pushToast({
        tone: 'error',
        title: t('catalog.toast.toggleFailed'),
      });
    }
  }

  async function removeItem(item: CatalogItem) {
    const id = asString(item.id);
    if (!id) {
      return;
    }

    try {
      await apiFetch(`${endpoint}/${id}`, { method: 'DELETE' });
      await loadItems(false);
      pushToast({
        tone: 'success',
        title: t('catalog.toast.removed'),
      });
    } catch {
      pushToast({
        tone: 'error',
        title: t('catalog.toast.removeFailed'),
      });
    }
  }

  return (
    <DashboardShell admin eyebrow={t('admin.eyebrow')} title={title}>
      <div className="grid gap-4 sm:grid-cols-3">
        <MetricCard icon={ToggleRight} label={t('catalog.filter.active')} tone="mint" value={activeCount} />
        <MetricCard icon={Edit3} label={t('catalog.filter.inactive')} tone="sun" value={draftCount} />
        <MetricCard icon={Plus} label={t('catalog.filter.all')} value={items.length} />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,0.9fr)_minmax(340px,0.8fr)]">
        <Card>
          <SectionTitle
            title={title}
            copy={copy}
            action={
              <div className="flex flex-wrap gap-2">
                <div className="flex h-10 items-center gap-2 rounded-lg border border-lilac bg-white px-3 text-sm">
                  <Search className="h-4 w-4 text-violet" />
                  <input
                    className="w-40 bg-transparent outline-none"
                    onChange={(event) => setQuery(event.target.value)}
                    placeholder={t('catalog.searchPlaceholder')}
                    value={query}
                  />
                </div>
                <select
                  className="h-10 rounded-lg border border-lilac bg-white px-3 text-sm font-semibold text-ink"
                  onChange={(event) =>
                    setStatusFilter(event.target.value as 'ALL' | 'ACTIVE' | 'DRAFT')
                  }
                  value={statusFilter}
                >
                  <option value="ALL">{t('catalog.filter.all')}</option>
                  <option value="ACTIVE">{t('catalog.filter.active')}</option>
                  <option value="DRAFT">{t('catalog.filter.inactive')}</option>
                </select>
                <Button onClick={() => void loadItems(false)} variant="secondary">
                  <RefreshCcw className="h-4 w-4" />
                  {t('catalog.refresh')}
                </Button>
                {['quotes', 'sounds', 'meditations'].includes(kind) ? (
                  <span className="relative inline-flex">
                    <input
                      accept=".csv"
                      className="absolute inset-0 cursor-pointer opacity-0"
                      onChange={(event) => {
                        const file = event.target.files?.[0];
                        if (file) {
                          const reader = new FileReader();
                          reader.onload = async (e) => {
                            const text = e.target?.result as string;
                            if (text) {
                              try {
                                const endpointMap: Record<string, string> = {
                                  quotes: '/content/import/quotes',
                                  sounds: '/content/import/sounds',
                                  meditations: '/content/import/meditations',
                                };
                                const impUrl = endpointMap[kind];
                                if (!impUrl) return;

                                const res = await apiFetch<{
                                  imported: number;
                                  skipped: number;
                                  total: number;
                                }>(impUrl, {
                                  method: 'POST',
                                  body: JSON.stringify({ csvData: text }),
                                });

                                pushToast({
                                  tone: 'success',
                                  title: t('catalog.toast.imported', {
                                    count: String(res.imported),
                                  }),
                                  message: `Total: ${res.total}, Skipped: ${res.skipped}`,
                                });
                                void loadItems(false);
                              } catch (err) {
                                pushToast({
                                  tone: 'error',
                                  title: t('catalog.toast.importFailed'),
                                  message:
                                    err instanceof Error
                                      ? err.message
                                      : 'Unknown error',
                                });
                              }
                            }
                          };
                          reader.readAsText(file);
                        }
                        event.currentTarget.value = '';
                      }}
                      type="file"
                    />
                    <Button variant="secondary">
                      <UploadCloud className="h-4 w-4" />
                      {t('admin.btn.importCsv')}
                    </Button>
                  </span>
                ) : null}
                <Button onClick={resetDraft}>
                  <Plus className="h-4 w-4" />
                  {t('catalog.create.new')}
                </Button>
              </div>
            }
          />
          <div className="mt-5">
            <DataTable
              columns={config.columns.map((column) => translateCatalogText(column, t))}
              rows={rows.map((row) => [
                row.name,
                row.secondary,
                translateCatalogText(row.config, t),
                catalogStatusLabel(row.status, t),
                <div className="flex flex-wrap gap-2" key={row.id}>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={() => startEdit(row.raw)}
                    variant="secondary"
                  >
                    {t('btn.edit')}
                  </Button>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={() => void toggleItem(row.raw)}
                    variant="secondary"
                  >
                    {row.active ? t('state.inactive') : t('state.active')}
                  </Button>
                  <Button className="h-8 px-3 text-xs" onClick={() => void removeItem(row.raw)}>
                    <Trash2 className="h-3.5 w-3.5" />
                    {t('btn.delete')}
                  </Button>
                </div>,
              ])}
            />
            {loading ? (
              <p className="mt-4 text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
                {t('catalog.loading')}
              </p>
            ) : null}
            {!loading && rows.length === 0 ? (
              <p className="mt-4 rounded-lg border border-dashed border-[var(--field-border,theme(colors.lilac))] bg-[var(--panel-bg)] p-4 text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
                {t('catalog.empty')}
              </p>
            ) : null}
            <PaginationBar
              page={page}
              pageSize={pageSize}
              setPage={setPage}
              setPageSize={setPageSize}
              total={total}
            />
          </div>
        </Card>

        <Card>
          <SectionTitle
            title={editingId ? t('catalog.edit.title') : t('catalog.create.title')}
            copy={copy}
          />
          <div className="mt-5 space-y-4">
            {visibleFields.map((field) => (
              <CatalogField
                field={field}
                key={field.key}
                label={translateCatalogText(field.label, t)}
                onChange={(value) => updateDraftValue(field.key, value)}
                onUpload={(file) => stageAsset(field, file)}
                pendingFileName={pendingUploads[field.key]?.file.name}
                upload={uploadConfigForField(field, fixedCategory)}
                uploading={uploadingField === field.key}
                value={draft[field.key]}
              />
            ))}
          </div>
          <div className="mt-5 flex gap-2">
            <Button disabled={saving} onClick={() => void saveItem()}>
              <Plus className="h-4 w-4" />
              {saving ? t('mood.checkin.saving') : editingId ? t('btn.update') : t('btn.create')}
            </Button>
            {editingId ? (
              <Button onClick={resetDraft} variant="secondary">
                {t('btn.cancel')}
              </Button>
            ) : null}
          </div>
        </Card>
      </div>
    </DashboardShell>
  );
}
