'use client';

import { useEffect, useMemo, useState } from 'react';
import { Edit3, Plus, RefreshCcw, Search, ToggleRight, Trash2 } from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import { DataTable, MetricCard, SectionTitle } from '@/components/dashboard/dashboard-ui';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { apiFetch } from '@/lib/api';
import { useUiStore } from '@/stores/use-ui-store';

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
}: {
  kind: Kind;
  title: string;
  endpoint: string;
  copy: string;
}) {
  const config = catalogConfig[kind];
  const pushToast = useUiStore((state) => state.pushToast);
  const [items, setItems] = useState<CatalogItem[]>([]);
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [draft, setDraft] = useState<Draft>(() => createDraft(config.fields));

  async function loadItems(showSpinner = true) {
    if (showSpinner) {
      setLoading(true);
    }

    try {
      const payload = await apiFetch<CatalogItem[]>(endpoint);
      setItems(Array.isArray(payload) ? payload : []);
    } catch {
      pushToast({
        tone: 'error',
        title: `Không tải được ${title.toLowerCase()}`,
        message: 'Kiểm tra token admin hoặc backend.',
      });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    let cancelled = false;

    async function bootstrap() {
      try {
        const payload = await apiFetch<CatalogItem[]>(endpoint);
        if (!cancelled) {
          setItems(Array.isArray(payload) ? payload : []);
        }
      } catch {
        if (!cancelled) {
          pushToast({
            tone: 'error',
            title: `Không tải được ${title.toLowerCase()}`,
            message: 'Kiểm tra token admin hoặc backend.',
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
  }, [endpoint, pushToast, title]);

  const rows = useMemo(
    () =>
      items
        .map(config.buildRow)
        .filter((row) => {
          const haystack = `${row.name} ${row.secondary} ${row.config}`.toLowerCase();
          return haystack.includes(query.toLowerCase());
        }),
    [config, items, query],
  );
  const activeCount = items.filter(isActive).length;
  const draftCount = items.length - activeCount;

  async function saveItem() {
    setSaving(true);

    try {
      await apiFetch(editingId ? `${endpoint}/${editingId}` : endpoint, {
        method: editingId ? 'PATCH' : 'POST',
        body: JSON.stringify(buildPayload(config.fields, draft)),
      });

      resetDraft();
      await loadItems(false);
      pushToast({
        tone: 'success',
        title: editingId ? 'Đã cập nhật nội dung' : 'Đã tạo nội dung mới',
        message: `${title} đã được lưu vào backend.`,
      });
    } catch {
      pushToast({
        tone: 'error',
        title: 'Lưu nội dung thất bại',
        message: 'Kiểm tra dữ liệu nhập hoặc quyền admin.',
      });
    } finally {
      setSaving(false);
    }
  }

  function resetDraft() {
    setEditingId(null);
    setDraft(createDraft(config.fields));
  }

  function startEdit(item: CatalogItem) {
    const id = asString(item.id);
    if (!id) {
      return;
    }

    setEditingId(id);
    setDraft(draftFromItem(config.fields, item));
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
        title: 'Đã đổi trạng thái publish',
      });
    } catch {
      pushToast({
        tone: 'error',
        title: 'Không đổi được trạng thái publish',
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
        title: 'Đã xoá nội dung',
      });
    } catch {
      pushToast({
        tone: 'error',
        title: 'Xoá nội dung thất bại',
      });
    }
  }

  return (
    <DashboardShell admin eyebrow="Content" title={title}>
      <div className="grid gap-4 sm:grid-cols-3">
        <MetricCard icon={ToggleRight} label="Live" tone="mint" value={activeCount} />
        <MetricCard icon={Edit3} label="Draft" tone="sun" value={draftCount} />
        <MetricCard icon={Plus} label="Total" value={items.length} />
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
                    placeholder="Tìm nội dung"
                    value={query}
                  />
                </div>
                <Button onClick={() => void loadItems(false)} variant="secondary">
                  <RefreshCcw className="h-4 w-4" />
                  Reload
                </Button>
                <Button onClick={resetDraft}>
                  <Plus className="h-4 w-4" />
                  New
                </Button>
              </div>
            }
          />
          <div className="mt-5">
            <DataTable
              columns={config.columns}
              rows={rows.map((row) => [
                row.name,
                row.secondary,
                row.config,
                row.status,
                <div className="flex flex-wrap gap-2" key={row.id}>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={() => startEdit(row.raw)}
                    variant="secondary"
                  >
                    Sửa
                  </Button>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={() => void toggleItem(row.raw)}
                    variant="secondary"
                  >
                    {row.active ? 'Ẩn' : 'Bật'}
                  </Button>
                  <Button className="h-8 px-3 text-xs" onClick={() => void removeItem(row.raw)}>
                    <Trash2 className="h-3.5 w-3.5" />
                    Xoá
                  </Button>
                </div>,
              ])}
            />
            {loading ? (
              <p className="mt-4 text-sm font-semibold text-slate">Đang tải dữ liệu catalog...</p>
            ) : null}
            {!loading && rows.length === 0 ? (
              <p className="mt-4 rounded-lg border border-dashed border-lilac bg-white/70 p-4 text-sm font-semibold text-slate">
                Chưa có nội dung nào khớp bộ lọc hiện tại.
              </p>
            ) : null}
          </div>
        </Card>

        <Card>
          <SectionTitle
            title={editingId ? `Chỉnh sửa ${title}` : `Tạo ${title} mới`}
            copy="Các thay đổi được ghi trực tiếp vào backend sau khi lưu."
          />
          <div className="mt-5 space-y-4">
            {config.fields.map((field) => (
              <CatalogField
                field={field}
                key={field.key}
                onChange={(value) =>
                  setDraft((current) => ({ ...current, [field.key]: value }))
                }
                value={draft[field.key]}
              />
            ))}
          </div>
          <div className="mt-5 flex gap-2">
            <Button disabled={saving} onClick={() => void saveItem()}>
              <Plus className="h-4 w-4" />
              {saving ? 'Đang lưu' : editingId ? 'Cập nhật' : 'Tạo mới'}
            </Button>
            {editingId ? (
              <Button onClick={resetDraft} variant="secondary">
                Huỷ sửa
              </Button>
            ) : null}
          </div>
        </Card>
      </div>
    </DashboardShell>
  );
}

function CatalogField({
  field,
  value,
  onChange,
}: {
  field: FieldConfig;
  value: string | boolean;
  onChange: (value: string | boolean) => void;
}) {
  if (field.type === 'boolean') {
    return (
      <button
        className={`rounded-lg border p-4 text-left transition ${
          value ? 'border-violet bg-violet text-white' : 'border-lilac/70 bg-white/75 text-ink'
        }`}
        onClick={() => onChange(!value)}
        type="button"
      >
        <p className="font-bold">{field.label}</p>
        <p className={`mt-1 text-xs font-semibold ${value ? 'text-white/70' : 'text-slate'}`}>
          {value ? 'Enabled' : 'Disabled'}
        </p>
      </button>
    );
  }

  if (field.type === 'select') {
    return (
      <label className="block">
        <span className="text-sm font-semibold text-slate">{field.label}</span>
        <select
          className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
          onChange={(event) => onChange(event.target.value)}
          required={field.required}
          value={String(value)}
        >
          {field.options?.map((option) => (
            <option key={option || 'none'} value={option}>
              {option || 'Không chọn'}
            </option>
          ))}
        </select>
      </label>
    );
  }

  if (field.type === 'textarea') {
    return (
      <label className="block">
        <span className="text-sm font-semibold text-slate">{field.label}</span>
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
      <span className="text-sm font-semibold text-slate">{field.label}</span>
      <input
        className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
        onChange={(event) => onChange(event.target.value)}
        required={field.required}
        type={field.type === 'url' ? 'url' : field.type}
        value={String(value)}
      />
    </label>
  );
}

function createDraft(fields: FieldConfig[]): Draft {
  return Object.fromEntries(fields.map((field) => [field.key, field.defaultValue]));
}

function draftFromItem(fields: FieldConfig[], item: CatalogItem): Draft {
  return Object.fromEntries(
    fields.map((field) => {
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
