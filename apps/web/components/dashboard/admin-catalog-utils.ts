import type { TranslationKey } from '@/lib/i18n/dictionaries';
import { ApiError } from '@/lib/api';
import type { CatalogItem, Draft, FieldConfig } from './admin-catalog-types';

export const catalogTextKeys: Record<string, TranslationKey> = {
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

export function catalogQuery(
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

export function extractTotal(payload: unknown, fallback: number): number {
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

export function createDraft(fields: FieldConfig[], fixedCategory?: string): Draft {
  return Object.fromEntries(
    fields.map((field) => [
      field.key,
      field.key === 'category' && fixedCategory ? fixedCategory : field.defaultValue,
    ]),
  );
}

export function draftFromItem(fields: FieldConfig[], item: CatalogItem, fixedCategory?: string): Draft {
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

export function uploadConfigForField(field: FieldConfig, fixedCategory?: string) {
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

export function formatAdminUploadError(error: ApiError) {
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

export function slugFileName(name: string) {
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

export function buildPayload(fields: FieldConfig[], draft: Draft) {
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

export function itemId(item: CatalogItem) {
  return asString(item.id) ?? crypto.randomUUID();
}

export function isActive(item: CatalogItem) {
  return asBoolean(item.isActive) ?? true;
}

export function statusText(item: CatalogItem) {
  return isActive(item) ? 'active' : 'draft';
}

export function translateCatalogText(value: string, t: (key: TranslationKey, params?: Record<string, string | number>) => string) {
  const key = catalogTextKeys[value];
  return key ? t(key) : value;
}

export function catalogStatusLabel(value: string, t: (key: TranslationKey, params?: Record<string, string | number>) => string) {
  if (value === 'active') return t('state.active');
  if (value === 'draft') return t('state.inactive');
  if (value === 'default') return t('catalog.status.default');
  return translateCatalogText(value, t);
}

export function hourRange(item: CatalogItem) {
  const minHour = asNumber(item.minHour);
  const maxHour = asNumber(item.maxHour);

  if (minHour === undefined && maxHour === undefined) {
    return 'mọi lúc';
  }

  return `${minHour ?? 0}:00-${maxHour ?? 23}:00`;
}

export function asString(value: unknown) {
  return typeof value === 'string' && value.trim().length > 0 ? value : undefined;
}

export function asNumber(value: unknown) {
  return typeof value === 'number' && Number.isFinite(value) ? value : undefined;
}

export function asBoolean(value: unknown) {
  return typeof value === 'boolean' ? value : undefined;
}

export function truncate(value: string, length: number) {
  if (value.length <= length) {
    return value;
  }

  return `${value.slice(0, length - 1)}...`;
}
