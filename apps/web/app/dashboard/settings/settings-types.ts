export type ThemeMode = 'SYSTEM' | 'LIGHT' | 'DARK';

export type ReminderDraft = {
  title: string;
  message: string;
  type: 'WATER' | 'REST' | 'BREATHING' | 'JOURNAL' | 'SLEEP' | 'CUSTOM';
  scheduledAt: string;
};

export type BillingPlan = {
  name: string;
  title: string;
  price: number;
  currency: string;
  features: string[];
};

export type CheckoutResult = {
  configured?: boolean;
  provider?: string;
  plan?: {
    name?: string;
    title?: string;
    price?: number;
    currency?: string;
  };
  payment?: {
    id?: string;
    status?: string;
    amount?: number;
    currency?: string;
  };
  checkout?: {
    status?: string;
    note?: string;
    checkoutUrl?: string;
    checkoutFormfields?: Record<string, string>;
    qrUrl?: string;
    qrCodeUrl?: string;
    transferContent?: string;
    bankId?: string;
    bankName?: string;
    accountNo?: string;
    bankAccount?: string;
    accountName?: string;
    amount?: number;
    paymentId?: string;
  };
};

export type ConfirmResult = {
  payment?: {
    id?: string;
    status?: string;
  };
  subscription?: {
    status?: string;
    planName?: string;
  };
};

export type CompanionMode = 'DEFAULT' | 'ZODIAC' | 'CHINESE_ZODIAC' | 'CUSTOM';

export type CompanionAsset = {
  id: string;
  name: string;
  description?: string;
  previewImageUrl?: string;
  primaryColor?: string;
  secondaryColor?: string;
  accentColor?: string;
  zodiacSign?: string | null;
  chineseZodiac?: string | null;
  isDefault?: boolean;
};

export type CompanionOptionGroup = {
  mode: CompanionMode;
  label: string;
  key?: string | null;
  available: boolean;
  assets: CompanionAsset[];
};

export type CompanionState = {
  name: string;
  personalizationMode: CompanionMode;
  level: number;
  affection: number;
  energy: number;
  mood: string;
  action: string;
  assetId?: string | null;
  asset?: CompanionAsset | null;
};

export type ThemeCard = {
  id: string;
  name: string;
  mode: ThemeMode;
  backgroundColor: string;
  surfaceColor: string;
  primaryColor: string;
  secondaryColor?: string | null;
  textColor: string;
  mutedTextColor?: string | null;
  accentColor?: string | null;
  isDefault: boolean;
  isActive: boolean;
};
