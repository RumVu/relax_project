import {
  asBoolean,
  asNumber,
  asString,
  hourRange,
  isActive,
  itemId,
  statusText,
  truncate,
} from './admin-catalog-utils';

export type Kind =
  | 'quotes'
  | 'sounds'
  | 'exercises'
  | 'themes'
  | 'onboarding'
  | 'companion-assets'
  | 'companion-messages'
  | 'meditations';

export type FieldType = 'text' | 'textarea' | 'number' | 'select' | 'boolean' | 'color' | 'url';

export type FieldConfig = {
  key: string;
  label: string;
  type: FieldType;
  required?: boolean;
  options?: string[];
  defaultValue: string | boolean;
};

export type CatalogItem = Record<string, unknown>;
export type Draft = Record<string, string | boolean>;
export type PendingUpload = {
  file: File;
  pathPrefix: string;
};

export const moodOptions = [
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

export const companionMoods = [
  'CHILL',
  'HAPPY',
  'SLEEPY',
  'CURIOUS',
  'HUNGRY',
  'PLAYFUL',
  'CALM',
  'SAD',
];

export const triggerOptions = [
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

export const catalogConfig: Record<
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
  'meditations': {
    columns: ['Tên', 'Loại', 'Thời lượng', 'Trạng thái', 'Hành động'],
    fields: [
      { key: 'title', label: 'Tên', type: 'text', required: true, defaultValue: '' },
      { key: 'description', label: 'Mô tả', type: 'textarea', defaultValue: '' },
      { key: 'type', label: 'Loại', type: 'select', options: ['GUIDED', 'UNGUIDED', 'BODY_SCAN', 'LOVING_KINDNESS', 'VISUALIZATION'], defaultValue: 'GUIDED' },
      { key: 'durationMinutes', label: 'Thời lượng (phút)', type: 'number', defaultValue: '5' },
      { key: 'audioUrl', label: 'Audio URL', type: 'url', defaultValue: '' },
      { key: 'imageUrl', label: 'Image URL', type: 'url', defaultValue: '' },
      { key: 'isActive', label: 'Đang publish', type: 'boolean', defaultValue: true },
    ],
    buildRow: (item) => ({
      id: itemId(item),
      raw: item,
      name: asString(item.title) ?? 'Meditation',
      secondary: asString(item.type) ?? 'GUIDED',
      config: `${asNumber(item.durationMinutes) ?? 0} phút`,
      status: statusText(item),
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
