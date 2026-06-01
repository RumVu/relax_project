'use client';

import { useEffect, useMemo, useState } from 'react';
import {
  ChevronLeft,
  ChevronRight,
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
import type { TranslationKey } from '@/lib/i18n/dictionaries';

type Kind =
  | 'quotes'
  | 'sounds'
  | 'exercises'
  | 'themes'
  | 'onboarding'
  | 'companion-assets'
  | 'companion-messages';

type FieldType = 'text' | 'textarea' | 'number' | 'select' | 'boolean' | 'color' | 'url';

type FieldConfig = {
  key: string;
  label: string;
  type: FieldType;
  required?: boolean;
  options?: string[];
  defaultValue: string | boolean;
};

type CatalogItem = Record<string, unknown>;
type Draft = Record<string, string | boolean>;

const moodOptions = [
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
];

const companionMoods = [
  'CHILL',
  'HAPPY',
  'SLEEPY',
  'CURIOUS',
  'HUNGRY',
  'PLAYFUL',
  'CALM',
  'SAD',
];

const triggerOptions = [
  'RANDOM',
  'TIME_BASED',
  'MOOD_BASED',
  'FIRST_OPEN',
  'RETURNING_USER',
  'LONG_SESSION',
  'NIGHT_TIME',
  'MORNING',
  'AFTER_CHECKIN',
];

const catalogTextKeys: Record<string, TranslationKey> = {
  'Nội dung': 'catalog.field.content',
  'Mood': 'catalog.field.mood',
  'Tác giả': 'catalog.field.author',
  'Trạng thái': 'catalog.col.status',
  'Hành động': 'catalog.col.actions',
  'Ảnh minh hoạ': 'catalog.field.coverImage',
  'Đang publish': 'catalog.field.published',
  'Không tác giả': 'catalog.field.unknownAuthor',
  'Tên': 'catalog.field.name',
  'Category': 'catalog.field.category',
  'Âm thanh': 'catalog.field.soundCol',
  'Tên âm thanh': 'catalog.field.soundName',
  'Mô tả': 'catalog.field.description',
  'Sound URL': 'catalog.field.soundUrl',
  'Cover URL': 'catalog.field.coverUrl',
  'Duration seconds': 'catalog.field.durationSeconds',
  'Loại': 'catalog.field.kind',
  'Nhịp thở': 'catalog.field.breath',
  'Tên bài thở': 'catalog.field.exerciseName',
  'Inhale': 'catalog.field.inhale',
  'Hold': 'catalog.field.hold',
  'Exhale': 'catalog.field.exhale',
  'Cycles': 'catalog.field.cycles',
  'Image URL': 'catalog.field.imageUrl',
  'Tên theme': 'catalog.field.themeName',
  'Mode': 'catalog.field.mode',
  'Màu chính': 'catalog.field.primaryColor',
  'Background': 'catalog.field.background',
  'Surface': 'catalog.field.surface',
  'Primary': 'catalog.field.primary',
  'Secondary': 'catalog.field.secondary',
  'Accent': 'catalog.field.accent',
  'Text': 'catalog.field.text',
  'Muted text': 'catalog.field.mutedText',
  'Theme mặc định': 'catalog.field.defaultTheme',
  'Tiêu đề': 'catalog.field.title',
  'Subtitle': 'catalog.field.subtitle',
  'Thứ tự': 'catalog.field.order',
  'Animation URL': 'catalog.field.animationUrl',
  'Tên linh thú': 'catalog.field.companionName',
  'Preview URL': 'catalog.field.previewUrl',
  'Sprite sheet URL': 'catalog.field.spriteSheetUrl',
  'Idle animation URL': 'catalog.field.idleAnimationUrl',
  'Sleep animation URL': 'catalog.field.sleepAnimationUrl',
  'Walk animation URL': 'catalog.field.walkAnimationUrl',
  'Primary color': 'catalog.field.primaryColor',
  'Secondary color': 'catalog.field.secondaryColor',
  'Accent color': 'catalog.field.accentColor',
  'Linh thú mặc định': 'catalog.field.defaultCompanion',
  'Tin nhắn': 'catalog.field.message',
  'Trigger': 'catalog.field.trigger',
  'Giờ': 'catalog.field.hour',
  'Mood người dùng': 'catalog.field.userMood',
  'Mood linh thú': 'catalog.field.companionMood',
  'Từ giờ': 'catalog.field.hourFrom',
  'Đến giờ': 'catalog.field.hourTo',
  'Weight': 'catalog.field.weight',
  'mọi lúc': 'catalog.field.hourAlways',
};

const catalogConfig: Record<
  Kind,
  {
    fields: FieldConfig[];
    columns: string[];
    buildRow: (item: CatalogItem) => {
      id: string;
      name: string;
      secondary: string;
      config: string;
      status: string;
      active: boolean;
      raw: CatalogItem;
    };
  }
> = {
  quotes: {
    columns: ['Nội dung', 'Mood', 'Tác giả', 'Trạng thái', 'Hành động'],
    fields: [
      { key: 'content', label: 'Nội dung', type: 'textarea', required: true, defaultValue: '' },
      { key: 'author', label: 'Tác giả', type: 'text', defaultValue: '' },
      { key: 'mood', label: 'Mood', type: 'select', options: moodOptions, defaultValue: 'CALM' },
      { key: 'imageUrl', label: 'Ảnh minh hoạ', type: 'url', defaultValue: '' },
      { key: 'isActive', label: 'Đang publish', type: 'boolean', defaultValue: true },
    ],
    buildRow: (item) => ({
      id: itemId(item),
      raw: item,
      name: truncate(asString(item.content) ?? 'Quote', 64),
      secondary: asString(item.mood) ?? 'NEUTRAL',
      config: asString(item.author) ?? 'Không tác giả',
      status: statusText(item),
      active: isActive(item),
    }),
  },
  sounds: {
    columns: ['Tên', 'Category', 'Âm thanh', 'Trạng thái', 'Hành động'],
    fields: [
      { key: 'title', label: 'Tên âm thanh', type: 'text', required: true, defaultValue: '' },
      { key: 'description', label: 'Mô tả', type: 'textarea', defaultValue: '' },
      { key: 'category', label: 'Category', type: 'text', required: true, defaultValue: 'AMBIENT' },
      { key: 'soundUrl', label: 'Sound URL', type: 'url', required: true, defaultValue: '' },
      { key: 'imageUrl', label: 'Cover URL', type: 'url', defaultValue: '' },
      { key: 'duration', label: 'Duration seconds', type: 'number', defaultValue: '300' },
      { key: 'isActive', label: 'Đang publish', type: 'boolean', defaultValue: true },
    ],
    buildRow: (item) => ({
      id: itemId(item),
      raw: item,
      name: asString(item.title) ?? 'Sound',
      secondary: asString(item.category) ?? 'AMBIENT',
      config: `${asNumber(item.duration) ?? 0}s`,
      status: statusText(item),
      active: isActive(item),
    }),
  },
  exercises: {
    columns: ['Tên', 'Loại', 'Nhịp thở', 'Trạng thái', 'Hành động'],
    fields: [
      { key: 'title', label: 'Tên bài thở', type: 'text', required: true, defaultValue: '' },
      { key: 'description', label: 'Mô tả', type: 'textarea', defaultValue: '' },
      { key: 'inhaleSeconds', label: 'Inhale', type: 'number', defaultValue: '4' },
      { key: 'holdSeconds', label: 'Hold', type: 'number', defaultValue: '4' },
      { key: 'exhaleSeconds', label: 'Exhale', type: 'number', defaultValue: '6' },
      { key: 'cycles', label: 'Cycles', type: 'number', defaultValue: '4' },
      { key: 'duration', label: 'Duration seconds', type: 'number', defaultValue: '120' },
      { key: 'imageUrl', label: 'Image URL', type: 'url', defaultValue: '' },
      { key: 'isActive', label: 'Đang publish', type: 'boolean', defaultValue: true },
    ],
    buildRow: (item) => ({
      id: itemId(item),
      raw: item,
      name: asString(item.title) ?? 'Exercise',
      secondary: 'BREATHING',
      config: `${asNumber(item.inhaleSeconds) ?? 0}-${asNumber(item.holdSeconds) ?? 0}-${asNumber(item.exhaleSeconds) ?? 0} x ${asNumber(item.cycles) ?? 0}`,
      status: statusText(item),
      active: isActive(item),
    }),
  },
  themes: {
    columns: ['Tên theme', 'Mode', 'Màu chính', 'Trạng thái', 'Hành động'],
    fields: [
      { key: 'name', label: 'Tên theme', type: 'text', required: true, defaultValue: '' },
      { key: 'mode', label: 'Mode', type: 'select', options: ['LIGHT', 'DARK', 'SYSTEM'], defaultValue: 'LIGHT' },
      { key: 'backgroundColor', label: 'Background', type: 'color', required: true, defaultValue: '#f7f4ef' },
      { key: 'surfaceColor', label: 'Surface', type: 'color', required: true, defaultValue: '#ffffff' },
      { key: 'primaryColor', label: 'Primary', type: 'color', required: true, defaultValue: '#7357f6' },
      { key: 'secondaryColor', label: 'Secondary', type: 'color', defaultValue: '#40c9a2' },
      { key: 'accentColor', label: 'Accent', type: 'color', defaultValue: '#ef767a' },
      { key: 'textColor', label: 'Text', type: 'color', required: true, defaultValue: '#151229' },
      { key: 'mutedTextColor', label: 'Muted text', type: 'color', defaultValue: '#536071' },
      { key: 'isDefault', label: 'Theme mặc định', type: 'boolean', defaultValue: false },
      { key: 'isActive', label: 'Đang publish', type: 'boolean', defaultValue: true },
    ],
    buildRow: (item) => ({
      id: itemId(item),
      raw: item,
      name: asString(item.name) ?? 'Theme',
      secondary: asString(item.mode) ?? 'SYSTEM',
      config: asString(item.primaryColor) ?? '-',
      status: isActive(item) ? (asBoolean(item.isDefault) ? 'default' : 'active') : 'draft',
      active: isActive(item),
    }),
  },
  onboarding: {
    columns: ['Tiêu đề', 'Subtitle', 'Thứ tự', 'Trạng thái', 'Hành động'],
    fields: [
      { key: 'title', label: 'Tiêu đề', type: 'text', required: true, defaultValue: '' },
      { key: 'subtitle', label: 'Subtitle', type: 'text', defaultValue: '' },
      { key: 'description', label: 'Mô tả', type: 'textarea', defaultValue: '' },
      { key: 'imageUrl', label: 'Image URL', type: 'url', defaultValue: '' },
      { key: 'animationUrl', label: 'Animation URL', type: 'url', defaultValue: '' },
      { key: 'displayOrder', label: 'Thứ tự', type: 'number', defaultValue: '0' },
      { key: 'isActive', label: 'Đang publish', type: 'boolean', defaultValue: true },
    ],
    buildRow: (item) => ({
      id: itemId(item),
      raw: item,
      name: asString(item.title) ?? 'Slide',
      secondary: asString(item.subtitle) ?? 'Onboarding',
      config: String(asNumber(item.displayOrder) ?? 0),
      status: statusText(item),
      active: isActive(item),
    }),
  },
  'companion-assets': {
    columns: ['Tên linh thú', 'Loại', 'Màu chính', 'Trạng thái', 'Hành động'],
    fields: [
      { key: 'name', label: 'Tên linh thú', type: 'text', required: true, defaultValue: '' },
      { key: 'type', label: 'Loại', type: 'select', options: ['CAT', 'DOG', 'RABBIT', 'BIRD', 'CUSTOM'], defaultValue: 'CAT' },
      { key: 'description', label: 'Mô tả', type: 'textarea', defaultValue: '' },
      { key: 'previewImageUrl', label: 'Preview URL', type: 'url', defaultValue: '' },
      { key: 'spriteSheetUrl', label: 'Sprite sheet URL', type: 'url', defaultValue: '' },
      { key: 'idleAnimationUrl', label: 'Idle animation URL', type: 'url', defaultValue: '' },
      { key: 'sleepAnimationUrl', label: 'Sleep animation URL', type: 'url', defaultValue: '' },
      { key: 'walkAnimationUrl', label: 'Walk animation URL', type: 'url', defaultValue: '' },
      { key: 'primaryColor', label: 'Primary color', type: 'color', defaultValue: '#b88b6a' },
      { key: 'secondaryColor', label: 'Secondary color', type: 'color', defaultValue: '#fff4dd' },
      { key: 'accentColor', label: 'Accent color', type: 'color', defaultValue: '#7357f6' },
      { key: 'isDefault', label: 'Linh thú mặc định', type: 'boolean', defaultValue: false },
      { key: 'isActive', label: 'Đang publish', type: 'boolean', defaultValue: true },
    ],
    buildRow: (item) => ({
      id: itemId(item),
      raw: item,
      name: asString(item.name) ?? 'Companion',
      secondary: asString(item.type) ?? 'CAT',
      config: asString(item.primaryColor) ?? '-',
      status: isActive(item) ? (asBoolean(item.isDefault) ? 'default' : 'active') : 'draft',
      active: isActive(item),
    }),
  },
  'companion-messages': {
    columns: ['Tin nhắn', 'Trigger', 'Giờ', 'Trạng thái', 'Hành động'],
    fields: [
      { key: 'content', label: 'Tin nhắn', type: 'textarea', required: true, defaultValue: '' },
      { key: 'triggerType', label: 'Trigger', type: 'select', options: triggerOptions, defaultValue: 'RANDOM' },
      { key: 'mood', label: 'Mood người dùng', type: 'select', options: ['', ...moodOptions], defaultValue: '' },
      { key: 'companionMood', label: 'Mood linh thú', type: 'select', options: ['', ...companionMoods], defaultValue: '' },
      { key: 'minHour', label: 'Từ giờ', type: 'number', defaultValue: '' },
      { key: 'maxHour', label: 'Đến giờ', type: 'number', defaultValue: '' },
      { key: 'weight', label: 'Weight', type: 'number', defaultValue: '1' },
      { key: 'isActive', label: 'Đang publish', type: 'boolean', defaultValue: true },
    ],
    buildRow: (item) => ({
      id: itemId(item),
      raw: item,
      name: truncate(asString(item.content) ?? 'Message', 64),
      secondary: asString(item.triggerType) ?? 'RANDOM',
      config: hourRange(item),
      status: statusText(item),
      active: isActive(item),
    }),
  },
};

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
  }, [endpoint, fixedCategory, pushToast, query, statusFilter, title, page, pageSize, t]);

  const rows = useMemo(
    () => items.map(config.buildRow),
    [config, items],
  );
  const activeCount = items.filter(isActive).length;
  const draftCount = items.length - activeCount;

  async function saveItem() {
    setSaving(true);

    try {
      await apiFetch(editingId ? `${endpoint}/${editingId}` : endpoint, {
        method: editingId ? 'PATCH' : 'POST',
        body: JSON.stringify({
          ...buildPayload(config.fields, draft),
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
    } catch {
      pushToast({
        tone: 'error',
        title: t('catalog.toast.saveFailed'),
        message: t('catalog.toast.dataHint'),
      });
    } finally {
      setSaving(false);
    }
  }

  function resetDraft() {
    setEditingId(null);
    setDraft(createDraft(config.fields, fixedCategory));
  }

  function startEdit(item: CatalogItem) {
    const id = asString(item.id);
    if (!id) {
      return;
    }

    setEditingId(id);
    setDraft(draftFromItem(config.fields, item, fixedCategory));
  }

  async function uploadAsset(field: FieldConfig, file: File) {
    const upload = uploadConfigForField(field, fixedCategory);
    if (!upload) return;

    setUploadingField(field.key);
    try {
      const formData = new FormData();
      formData.append('file', file);
      formData.append('path', `${upload.pathPrefix}/${Date.now()}-${slugFileName(file.name)}`);
      formData.append('upsert', 'true');

      const uploaded = await apiFetch<{ publicUrl: string }>('/storage/admin/upload', {
        method: 'POST',
        body: formData,
      });

      setDraft((current) => ({ ...current, [field.key]: uploaded.publicUrl }));
      pushToast({
        tone: 'success',
        title: t('catalog.toast.uploaded'),
        message: file.name,
      });
    } catch (cause) {
      pushToast({
        tone: 'error',
        title: t('catalog.toast.uploadFailed'),
        message:
          cause instanceof ApiError
            ? formatAdminUploadError(cause)
            : t('catalog.toast.serverHint'),
      });
    } finally {
      setUploadingField(null);
    }
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
                onChange={(value) =>
                  setDraft((current) => ({ ...current, [field.key]: value }))
                }
                onUpload={(file) => void uploadAsset(field, file)}
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

function catalogQuery(
  query: string,
  statusFilter: 'ALL' | 'ACTIVE' | 'DRAFT',
  page: number,
  pageSize: number,
  category?: string,
) {
  return {
    q: query.trim() || undefined,
    category,
    isActive: statusFilter === 'ALL' ? undefined : statusFilter === 'ACTIVE',
    limit: pageSize,
    skip: page * pageSize,
  };
}

function extractTotal(payload: unknown, fallback: number): number {
  if (payload && typeof payload === 'object') {
    const total = (payload as { total?: unknown }).total;
    if (typeof total === 'number' && Number.isFinite(total)) {
      return total;
    }
    const items = (payload as { items?: unknown[] }).items;
    if (Array.isArray(items)) {
      return items.length;
    }
  }
  if (Array.isArray(payload)) {
    return payload.length;
  }
  return fallback;
}

function CatalogField({
  field,
  label,
  value,
  onChange,
  upload,
  uploading,
  onUpload,
}: {
  field: FieldConfig;
  label: string;
  value: string | boolean;
  onChange: (value: string | boolean) => void;
  upload?: { accept: string; pathPrefix: string };
  uploading?: boolean;
  onUpload?: (file: File) => void;
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
    </label>
  );
}

function createDraft(fields: FieldConfig[], fixedCategory?: string): Draft {
  return Object.fromEntries(
    fields.map((field) => [
      field.key,
      field.key === 'category' && fixedCategory ? fixedCategory : field.defaultValue,
    ]),
  );
}

function draftFromItem(fields: FieldConfig[], item: CatalogItem, fixedCategory?: string): Draft {
  return Object.fromEntries(
    fields.map((field) => {
      if (field.key === 'category' && fixedCategory) {
        return [field.key, fixedCategory];
      }

      if (field.type === 'boolean') {
        return [field.key, asBoolean(item[field.key]) ?? Boolean(field.defaultValue)];
      }

      const value = item[field.key];
      return [
        field.key,
        typeof value === 'number' ? String(value) : asString(value) ?? String(field.defaultValue),
      ];
    }),
  );
}

function uploadConfigForField(field: FieldConfig, fixedCategory?: string) {
  if (field.key === 'soundUrl') {
    return {
      accept: 'audio/*',
      pathPrefix: fixedCategory === 'PODCAST' ? 'podcasts' : 'ambient-sounds',
    };
  }

  if (field.key === 'imageUrl' || field.key === 'previewImageUrl') {
    return {
      accept: 'image/*',
      pathPrefix: fixedCategory === 'PODCAST' ? 'podcast-covers' : 'sound-covers',
    };
  }

  return undefined;
}

function formatAdminUploadError(error: ApiError) {
  const details = error.details as
    | { missingKeys?: string[]; invalidKeys?: string[] }
    | undefined;
  const missingKeys = details?.missingKeys ?? [];
  const invalidKeys = details?.invalidKeys ?? [];

  if (missingKeys.length || invalidKeys.length) {
    const parts = [
      missingKeys.length ? `Thiếu ${missingKeys.join(', ')}` : '',
      invalidKeys.length ? `Sai ${invalidKeys.join(', ')}` : '',
    ].filter(Boolean);

    return `Supabase storage chưa sẵn sàng trên backend: ${parts.join('; ')}.`;
  }

  return error.message;
}

function slugFileName(name: string) {
  const parts = name.split('.');
  const ext = parts.length > 1 ? parts.pop()?.toLowerCase() : '';
  const base =
    (parts.join('.') || 'upload')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .slice(0, 80) || 'upload';

  return ext ? `${base}.${ext.replace(/[^a-z0-9]/g, '')}` : base;
}

function buildPayload(fields: FieldConfig[], draft: Draft) {
  const payload: Record<string, string | number | boolean | undefined> = {};

  for (const field of fields) {
    const value = draft[field.key];

    if (field.type === 'boolean') {
      payload[field.key] = Boolean(value);
      continue;
    }

    if (field.type === 'number') {
      payload[field.key] = value === '' ? undefined : Number(value);
      continue;
    }

    payload[field.key] = String(value).trim() || undefined;
  }

  return payload;
}

function itemId(item: CatalogItem) {
  return asString(item.id) ?? crypto.randomUUID();
}

function isActive(item: CatalogItem) {
  return asBoolean(item.isActive) ?? true;
}

function statusText(item: CatalogItem) {
  return isActive(item) ? 'active' : 'draft';
}

function translateCatalogText(value: string, t: (key: TranslationKey, params?: Record<string, string | number>) => string) {
  const key = catalogTextKeys[value];
  return key ? t(key) : value;
}

function catalogStatusLabel(value: string, t: (key: TranslationKey, params?: Record<string, string | number>) => string) {
  if (value === 'active') return t('state.active');
  if (value === 'draft') return t('state.inactive');
  if (value === 'default') return t('catalog.status.default');
  return translateCatalogText(value, t);
}

function hourRange(item: CatalogItem) {
  const minHour = asNumber(item.minHour);
  const maxHour = asNumber(item.maxHour);

  if (minHour === undefined && maxHour === undefined) {
    return 'mọi lúc';
  }

  return `${minHour ?? 0}:00-${maxHour ?? 23}:00`;
}

function asString(value: unknown) {
  return typeof value === 'string' && value.trim().length > 0 ? value : undefined;
}

function asNumber(value: unknown) {
  return typeof value === 'number' && Number.isFinite(value) ? value : undefined;
}

function asBoolean(value: unknown) {
  return typeof value === 'boolean' ? value : undefined;
}

function truncate(value: string, length: number) {
  if (value.length <= length) {
    return value;
  }

  return `${value.slice(0, length - 1)}...`;
}

/**
 * Footer for the catalog table: lets the admin pick how many rows show
 * up per page (10 / 20 / 50) and step through pages. Hides itself when
 * the entire list fits in one page anyway.
 */
function PaginationBar({
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
