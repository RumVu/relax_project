'use client';

import { useEffect, useState } from 'react';
import {
  Bell,
  ChevronLeft,
  ChevronRight,
  CreditCard,
  Globe2,
  KeyRound,
  Laptop,
  type LucideIcon,
  MapPin,
  Moon,
  Navigation,
  Repeat,
  Save,
  Smartphone,
  Trash2,
  UserRound,
  WandSparkles,
  X,
} from 'lucide-react';
import { DashboardShell } from '@/components/layout/dashboard-shell';
import {
  DataTable,
  MetricCard,
  SectionTitle,
} from '@/components/dashboard/dashboard-ui';
import { PermissionsPanel } from '@/components/dashboard/permissions-panel';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import {
  DASHBOARD_THEME_APPLIED_EVENT,
  applyDashboardTheme,
  type DashboardThemeMode,
  type DashboardThemePalette,
} from '@/components/providers/theme-provider';
import { apiFetch, extractList } from '@/lib/api';
import { getReadableTextColor } from '@/lib/contrast';
import { useUserDashboardData } from '@/lib/live-dashboard';
import { isStrongPassword } from '@/lib/password';
import { requestGeolocation } from '@/lib/permissions';
import { describeBrowser, describeDevice } from '@/lib/user-agent';
import {
  chineseZodiacLabel,
  computeZodiac,
  zodiacLabel,
} from '@/lib/zodiac';
import { useDashboardStore } from '@/stores/use-dashboard-store';
import { useUiStore } from '@/stores/use-ui-store';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import { AvatarUploader } from '@/components/dashboard/avatar-uploader';

type ThemeMode = 'SYSTEM' | 'LIGHT' | 'DARK';

type ReminderDraft = {
  title: string;
  message: string;
  type: 'WATER' | 'REST' | 'BREATHING' | 'JOURNAL' | 'SLEEP' | 'CUSTOM';
  scheduledAt: string;
};

type BillingPlan = {
  name: string;
  title: string;
  price: number;
  currency: string;
  features: string[];
};

type CheckoutResult = {
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
  };
};

type ConfirmResult = {
  payment?: {
    id?: string;
    status?: string;
  };
  subscription?: {
    status?: string;
    planName?: string;
  };
};

type CompanionMode = 'DEFAULT' | 'ZODIAC' | 'CHINESE_ZODIAC' | 'CUSTOM';

type CompanionAsset = {
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

type CompanionOptionGroup = {
  mode: CompanionMode;
  label: string;
  key?: string | null;
  available: boolean;
  assets: CompanionAsset[];
};

type CompanionState = {
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

type ThemeCard = {
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

const VI_SETTINGS_COPY = {
  defaultReminderTitle: 'Nhắc thở nhẹ',
  defaultReminderMessage: 'Đến lúc nghỉ một chút rồi hít thở nào.',
  companionTitle: 'Companion studio',
  companionCopy:
    'Đây là chỗ để anh nuôi, đặt tên và đổi linh thú theo ngày sinh, cung hoàng đạo, con giáp hoặc tự chọn.',
  noPreview: 'Chưa có preview',
  companionName: 'Tên linh thú',
  companionDefaultLabel: 'Linh thú',
  currentLevel: 'cấp độ hiện tại',
  affection: 'độ thân thiết',
  energy: 'năng lượng',
  renamedCompanion: 'Đã đổi tên linh thú',
  renameCompanionFailed: 'Không đổi được tên linh thú',
  saveName: 'Lưu tên',
  petted: 'Đã vuốt ve linh thú',
  fed: 'Đã cho linh thú ăn',
  played: 'Đã chơi với linh thú',
  interactFailed: 'Không tương tác được với linh thú',
  pet: 'Vuốt ve',
  feed: 'Cho ăn',
  play: 'Chơi',
  currentMode: 'mode đang áp dụng',
  currentMood: 'cảm xúc hiện tại',
  currentAction: 'trạng thái chuyển động',
  mappedBy: (key: string) => `Đang map theo ${key}`,
  customMode: 'Tự chọn linh thú theo ý anh',
  defaultMode: 'Dùng asset mặc định của hệ thống',
  changedMode: (mode: string) => `Đã chuyển sang ${mode}`,
  changeModeFailed: 'Không đổi được mode linh thú',
  selectAssetBelow: 'Chọn asset bên dưới',
  inUse: 'Đang dùng',
  apply: 'Áp dụng',
  applying: 'Đang áp dụng',
  syncedMode: (mode: string) => `Đã sync linh thú theo ${mode}`,
  syncModeFailed: 'Không đổi được linh thú theo mode này',
  customLibrary: 'Kho linh thú tự chọn',
  customLibraryCopy:
    'Đây là chỗ anh tự nạp linh thú cho profile hiện tại thay vì bị ràng theo cung hay con giáp.',
  loadedAsset: (name: string) => `Đã nạp linh thú ${name}`,
  loadAssetFailed: 'Không nạp được linh thú custom',
  assetFallbackDescription: 'Linh thú đồng hành',
  previewLoadFailed: 'Preview chưa tải được',
  companionLoading: 'Đang tải studio linh thú...',
  themeGalleryTitle: 'Theme gallery',
  themeGalleryCopy:
    'Chọn giao diện hợp mood của anh. Khi bấm áp dụng, app sẽ lưu mode và theme tương ứng vào preferences.',
  themeApplied: (name: string) => `Đã áp dụng theme ${name}`,
  themeApplyFailed: 'Không áp dụng được theme',
  systemDefaultSuffix: '• mặc định hệ thống',
  sessionsTitle: 'Thiết bị đăng nhập',
  sessionsCopy:
    'Theo dõi các phiên đã đăng nhập gần đây để biết tài khoản đang mở ở đâu.',
  currentSession: 'Phiên hiện tại',
  savedSession: 'Đã lưu',
  sessionsNote:
    'Bảng này đóng vai trò lịch sử đăng nhập. Cột Thiết bị chỉ hiển thị OS + dòng máy vì browser không cho phép app đọc tên máy thật (privacy). Muốn đặt tên thiết bị riêng, hãy đăng ký nó dưới mục Thiết bị push bên cạnh.',
  pushDevicesTitle: 'Thiết bị push',
  pushDevicesCopy:
    'Đăng ký nhanh trình duyệt hiện tại để test thông báo, hoặc gỡ những thiết bị không còn dùng nữa.',
  pushDeviceAdded: 'Đã thêm thiết bị web',
  pushDeviceAddedMessage:
    'Anh có thể dùng nó để test push/in-app notification ngay trong dashboard.',
  pushDeviceAddFailed: 'Không thêm được thiết bị',
  adding: 'Đang thêm',
  registerCurrentBrowser: 'Đăng ký trình duyệt này',
  pushDeviceRemoved: 'Đã gỡ thiết bị push',
  pushDeviceRemoveFailed: 'Không gỡ được thiết bị push',
  remove: 'Gỡ',
  remindersTitle: 'Nhắc nhở',
  remindersCopy:
    'Tạo các mốc nhắc mới, bật tắt nhanh hoặc xoá hẳn khi lịch sống của anh thay đổi.',
  titleLabel: 'Tiêu đề',
  typeLabel: 'Loại',
  datetimeLabel: 'Thời gian',
  reminderCreated: 'Đã tạo reminder',
  reminderCreatedMessage: (title: string) =>
    `"${title}" — lưu OK. Title giữ nguyên cho lần tạo tiếp.`,
  reminderCreateFailed: 'Tạo reminder thất bại',
  creating: 'Đang tạo',
  createReminder: 'Tạo reminder',
  savedReminderCount: (count: number) => `${count} nhắc đang lưu`,
  confirmDeleteAllReminders: (count: number) =>
    `Xoá tất cả ${count} nhắc? Hành động này không hoàn tác được.`,
  deletedReminderCount: (count: number) => `Đã xoá ${count} nhắc`,
  deleteAll: 'Xoá tất cả',
  scheduleLabel: 'Lịch',
  on: 'On',
  off: 'Off',
  reminderDisabled: 'Đã tắt reminder',
  reminderEnabled: 'Đã bật reminder',
  reminderStatusFailed: 'Không đổi được trạng thái reminder',
  disable: 'Tắt',
  enable: 'Bật',
  reminderDeleted: 'Đã xoá reminder',
  reminderDeleteFailed: 'Xoá reminder thất bại',
  billingTitle: 'Gói cước & nâng cấp',
  billingCopy:
    'Xem plan đang dùng và tạo checkout intent để backend ghi nhận nhu cầu nâng cấp.',
  currentPlan: 'Gói hiện tại',
  billingStatus: (status: string, renewal: string) =>
    `Trạng thái ${status} • gia hạn ${renewal}`,
  choosePlan: 'Chọn gói này',
  billingEmpty: 'Chưa tải được danh sách gói từ API billing.',
  activatedNote: (plan: string, status: string) =>
    `Đã kích hoạt gói ${plan}. Subscription chuyển sang ${status}.`,
  activatedTitle: (plan: string) => `Đã kích hoạt ${plan}`,
  activatedMessage: 'Thanh toán đã được xác nhận và gói đã được kích hoạt.',
  intentCreated: (plan: string) => `Đã tạo yêu cầu ${plan}`,
  intentRecorded: 'Backend đã ghi nhận checkout intent cho gói này.',
  upgradeFailed: 'Không hoàn tất được nâng cấp',
  upgradeFailedMessage: 'Kiểm tra backend billing rồi thử lại.',
  show: 'Hiển thị',
  sessionsPerPage: 'phiên / trang',
  previousPage: 'Trang trước',
  nextPage: 'Trang sau',
  reminderTime: 'Giờ nhắc',
  quickAddMessage: 'Nhắc nhẹ trong ngày từ Quick add.',
  quickAdded: (time: string) => `Đã thêm nhắc ${time}`,
  quickAddFailed: 'Không thêm được nhắc',
  quickAdd: 'Thêm nhanh',
  checkoutTitle: 'Tạo thanh khoản',
  checkoutCopy:
    'Xác nhận gói để backend tạo payment pending và trả trạng thái provider.',
  closeCheckout: 'Đóng checkout',
  upgradable: 'Có thể nâng cấp',
  intentReady: 'Backend đã tạo intent',
  paymentPendingNote:
    'Payment pending đã được ghi vào database. Khi cấu hình provider, chỗ này sẽ nhận checkout URL thật.',
  creatingIntent: 'Đang tạo intent',
  createCheckout: 'Tạo thanh khoản',
  modeZodiac: 'Theo cung hoàng đạo',
  modeChineseZodiac: 'Theo 12 con giáp',
  modeCustom: 'Tự chọn linh thú',
  modeDefault: 'Mặc định',
  free: 'Miễn phí',
  historyTitle: 'Lịch sử giao dịch',
  historyCopy: 'Lịch sử nạp tiền và nâng cấp gói cước.',
  colPlan: 'Gói',
  colAmount: 'Số tiền',
  colOrderCode: 'Mã đơn hàng',
  colTxCode: 'Mã giao dịch',
  colMethod: 'Cổng',
  colStatus: 'Trạng thái',
  colDate: 'Thời gian',
  statusSuccess: 'Thành công',
  statusPending: 'Đang chờ',
  statusFailed: 'Thất bại',
};

const EN_SETTINGS_COPY: typeof VI_SETTINGS_COPY = {
  ...VI_SETTINGS_COPY,
  defaultReminderTitle: 'Gentle breathing reminder',
  defaultReminderMessage: 'Time to pause for a quick breath.',
  companionTitle: 'Companion studio',
  companionCopy:
    'Name, nurture and switch your companion by birthday, zodiac, Chinese zodiac or a custom pick.',
  noPreview: 'No preview yet',
  companionName: 'Companion name',
  companionDefaultLabel: 'Companion',
  currentLevel: 'current level',
  affection: 'affection',
  energy: 'energy',
  renamedCompanion: 'Companion renamed',
  renameCompanionFailed: 'Could not rename companion',
  saveName: 'Save name',
  petted: 'Companion petted',
  fed: 'Companion fed',
  played: 'Played with companion',
  interactFailed: 'Could not interact with companion',
  pet: 'Pet',
  feed: 'Feed',
  play: 'Play',
  currentMode: 'current mode',
  currentMood: 'current mood',
  currentAction: 'current action',
  mappedBy: (key: string) => `Mapped by ${key}`,
  customMode: 'Choose your own companion',
  defaultMode: 'Use the system default asset',
  changedMode: (mode: string) => `Switched to ${mode}`,
  changeModeFailed: 'Could not change companion mode',
  selectAssetBelow: 'Select an asset below',
  inUse: 'In use',
  apply: 'Apply',
  applying: 'Applying',
  syncedMode: (mode: string) => `Synced companion by ${mode}`,
  syncModeFailed: 'Could not switch companion for this mode',
  customLibrary: 'Custom companion library',
  customLibraryCopy:
    'Pick a custom companion for this profile instead of binding it to zodiac or Chinese zodiac.',
  loadedAsset: (name: string) => `Loaded companion ${name}`,
  loadAssetFailed: 'Could not load custom companion',
  assetFallbackDescription: 'Companion buddy',
  previewLoadFailed: 'Preview could not load',
  companionLoading: 'Loading companion studio...',
  themeGalleryTitle: 'Theme gallery',
  themeGalleryCopy:
    'Choose a theme that matches your mood. Applying saves the matching mode and theme to preferences.',
  themeApplied: (name: string) => `Applied theme ${name}`,
  themeApplyFailed: 'Could not apply theme',
  systemDefaultSuffix: '• system default',
  sessionsTitle: 'Signed-in devices',
  sessionsCopy:
    'Review recent signed-in sessions and where the account is currently open.',
  currentSession: 'Current session',
  savedSession: 'Saved',
  sessionsNote:
    'This table is your login history. The Device column only shows OS and model because browsers do not expose the real device name for privacy. To set a friendly device name, register it under Push devices.',
  pushDevicesTitle: 'Push devices',
  pushDevicesCopy:
    'Register the current browser to test notifications, or remove devices you no longer use.',
  pushDeviceAdded: 'Web device added',
  pushDeviceAddedMessage:
    'You can use it to test push or in-app notifications from the dashboard.',
  pushDeviceAddFailed: 'Could not add device',
  adding: 'Adding',
  registerCurrentBrowser: 'Register this browser',
  pushDeviceRemoved: 'Push device removed',
  pushDeviceRemoveFailed: 'Could not remove push device',
  remove: 'Remove',
  remindersTitle: 'Reminders',
  remindersCopy:
    'Create reminder times, toggle them quickly or delete them when your routine changes.',
  titleLabel: 'Title',
  typeLabel: 'Type',
  datetimeLabel: 'Time',
  reminderCreated: 'Reminder created',
  reminderCreatedMessage: (title: string) =>
    `"${title}" was saved. The title stays for the next reminder.`,
  reminderCreateFailed: 'Could not create reminder',
  creating: 'Creating',
  createReminder: 'Create reminder',
  savedReminderCount: (count: number) => `${count} reminders saved`,
  confirmDeleteAllReminders: (count: number) =>
    `Delete all ${count} reminders? This cannot be undone.`,
  deletedReminderCount: (count: number) => `Deleted ${count} reminders`,
  deleteAll: 'Delete all',
  scheduleLabel: 'Schedule',
  on: 'On',
  off: 'Off',
  reminderDisabled: 'Reminder disabled',
  reminderEnabled: 'Reminder enabled',
  reminderStatusFailed: 'Could not update reminder status',
  disable: 'Disable',
  enable: 'Enable',
  reminderDeleted: 'Reminder deleted',
  reminderDeleteFailed: 'Could not delete reminder',
  billingTitle: 'Plans & upgrades',
  billingCopy:
    'Review the current plan and create a checkout intent so the backend records the upgrade request.',
  currentPlan: 'Current plan',
  billingStatus: (status: string, renewal: string) =>
    `Status ${status} • renews ${renewal}`,
  choosePlan: 'Choose this plan',
  billingEmpty: 'Could not load billing plans from the API.',
  activatedNote: (plan: string, status: string) =>
    `Activated ${plan}. Subscription moved to ${status}.`,
  activatedTitle: (plan: string) => `${plan} activated`,
  activatedMessage: 'Payment was confirmed and the plan was activated.',
  intentCreated: (plan: string) => `Created request for ${plan}`,
  intentRecorded: 'Backend recorded the checkout intent for this plan.',
  upgradeFailed: 'Could not complete upgrade',
  upgradeFailedMessage: 'Check backend billing and try again.',
  show: 'Show',
  sessionsPerPage: 'sessions / page',
  previousPage: 'Previous page',
  nextPage: 'Next page',
  reminderTime: 'Reminder time',
  quickAddMessage: 'Quick daily reminder.',
  quickAdded: (time: string) => `Added reminder at ${time}`,
  quickAddFailed: 'Could not add reminder',
  quickAdd: 'Quick add',
  checkoutTitle: 'Create checkout intent',
  checkoutCopy:
    'Confirm the plan so the backend can create a pending payment and return provider status.',
  closeCheckout: 'Close checkout',
  upgradable: 'Upgradeable',
  intentReady: 'Backend created the intent',
  paymentPendingNote:
    'A pending payment was written to the database. Once a provider is configured, this area can receive a real checkout URL.',
  creatingIntent: 'Creating intent',
  createCheckout: 'Create intent',
  modeZodiac: 'By zodiac',
  modeChineseZodiac: 'By Chinese zodiac',
  modeCustom: 'Custom companion',
  modeDefault: 'Default',
  free: 'Free',
  historyTitle: 'Billing History',
  historyCopy: 'Transaction history for upgrades and deposits.',
  colPlan: 'Plan',
  colAmount: 'Amount',
  colOrderCode: 'Order Code',
  colTxCode: 'Tx Ref',
  colMethod: 'Gateway',
  colStatus: 'Status',
  colDate: 'Date',
  statusSuccess: 'Success',
  statusPending: 'Pending',
  statusFailed: 'Failed',
};

export default function SettingsPage() {
  const { locale, t } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;
  const accountProfile = useDashboardStore((state) => state.accountProfile);
  const refreshNonce = useDashboardStore((state) => state.refreshNonce);
  const setAccountProfile = useDashboardStore((state) => state.setAccountProfile);
  const triggerRefresh = useDashboardStore((state) => state.triggerRefresh);
  const [refreshKey, setRefreshKey] = useState(0);
  const settings = useUserDashboardData({ refreshKey: refreshNonce + refreshKey }).settings;
  const pushToast = useUiStore((state) => state.pushToast);
  const [draftPreferences, setDraftPreferences] = useState<{
    weatherEnabled: boolean;
    pushEnabled: boolean;
    soundEnabled: boolean;
    timezone: string;
    locationName: string;
    themeMode: ThemeMode;
  } | null>(null);
  const [profileDraft, setProfileDraft] = useState<{
    displayName: string;
    birthday: string;
  } | null>(null);
  const [passwordDraft, setPasswordDraft] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
  });
  const [avatarOverride, setAvatarOverride] = useState<string | null | undefined>(
    undefined,
  );
  const [reminderDraft, setReminderDraft] = useState<ReminderDraft>({
    title:
      locale === 'en'
        ? EN_SETTINGS_COPY.defaultReminderTitle
        : VI_SETTINGS_COPY.defaultReminderTitle,
    message:
      locale === 'en'
        ? EN_SETTINGS_COPY.defaultReminderMessage
        : VI_SETTINGS_COPY.defaultReminderMessage,
    type: 'BREATHING',
    scheduledAt: nextLocalReminderTime(),
  });
  const [saveState, setSaveState] = useState<'idle' | 'saving'>('idle');
  const [profileState, setProfileState] = useState<'idle' | 'saving'>('idle');
  const [passwordState, setPasswordState] = useState<'idle' | 'saving'>('idle');
  const [reminderState, setReminderState] = useState<'idle' | 'saving'>('idle');
  const [deviceState, setDeviceState] = useState<'idle' | 'saving'>('idle');
  const [billingState, setBillingState] = useState<string | null>(null);
  const [billingPlans, setBillingPlans] = useState<BillingPlan[]>([]);
  const [checkoutPlan, setCheckoutPlan] = useState<BillingPlan | null>(null);
  const [checkoutResult, setCheckoutResult] = useState<CheckoutResult | null>(null);
  const [companion, setCompanion] = useState<CompanionState | null>(null);
  const [companionOptions, setCompanionOptions] = useState<CompanionOptionGroup[]>([]);
  const [customAssets, setCustomAssets] = useState<CompanionAsset[]>([]);
  const [companionNameDraft, setCompanionNameDraft] = useState('');
  const [companionState, setCompanionState] = useState<'idle' | 'saving'>('idle');
  const [themeCatalog, setThemeCatalog] = useState<ThemeCard[]>([]);
  const [themeState, setThemeState] = useState<string | null>(null);
  const [activeThemeId, setActiveThemeId] = useState<string | null>(null);
  const [sessionsPage, setSessionsPage] = useState(0);
  const [sessionsPageSize, setSessionsPageSize] = useState(10);
  const weatherEnabled =
    draftPreferences?.weatherEnabled ?? settings.preferences.weatherEnabled;
  const pushEnabled = draftPreferences?.pushEnabled ?? settings.preferences.pushEnabled;
  const soundEnabled =
    draftPreferences?.soundEnabled ?? settings.preferences.soundEnabled;
  const timezone = draftPreferences?.timezone ?? settings.preferences.timezone;
  const locationName = draftPreferences?.locationName ?? settings.preferences.locationName;
  const themeMode =
    draftPreferences?.themeMode ??
    (settings.preferences.theme.toUpperCase() as ThemeMode);
  const displayName = profileDraft?.displayName ?? settings.profile.displayName;
  const birthday =
    profileDraft?.birthday ?? normalizeBirthdayValue(settings.profile.birthday);
  const avatar =
    avatarOverride !== undefined
      ? avatarOverride
      : accountProfile?.avatar ?? settings.profile.avatar;

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const params = new URLSearchParams(window.location.search);
      const paymentStatus = params.get('payment');
      if (paymentStatus === 'success') {
        pushToast({
          tone: 'success',
          title: 'Thanh toán thành công',
          message: 'Cảm ơn anh! Gói cước của anh đang được hệ thống kích hoạt tự động.',
        });
        window.history.replaceState({}, '', window.location.pathname);
      } else if (paymentStatus === 'error' || paymentStatus === 'cancel') {
        pushToast({
          tone: 'error',
          title: 'Thanh toán không thành công',
          message: 'Giao dịch thanh toán đã bị huỷ hoặc có lỗi xảy ra. Vui lòng thử lại.',
        });
        window.history.replaceState({}, '', window.location.pathname);
      }
    }
  }, [pushToast]);

  useEffect(() => {
    let cancelled = false;

    void Promise.allSettled([
      apiFetch('/billing/plans'),
      apiFetch('/user-companions/me'),
      apiFetch('/user-companions/me/personalization-options'),
      apiFetch('/companion-assets'),
      apiFetch('/app-themes'),
      apiFetch('/user-preferences/me/preferences'),
    ]).then((results) => {
      if (cancelled) {
        return;
      }

      const [plansResult, companionResult, optionsResult, assetsResult, themesResult, preferencesResult] =
        results;

      if (plansResult.status === 'fulfilled' && Array.isArray(plansResult.value)) {
        setBillingPlans(
          plansResult.value.map((plan) => ({
            name: String((plan as { name?: string }).name ?? 'FREE'),
            title: String(
              (plan as { title?: string }).title ??
                (plan as { name?: string }).name ??
                'FREE',
            ),
            price: Number((plan as { price?: number }).price ?? 0),
            currency: String((plan as { currency?: string }).currency ?? 'VND'),
            features: Array.isArray((plan as { features?: string[] }).features)
              ? (plan as { features?: string[] }).features ?? []
              : [],
          })),
        );
      }

      if (companionResult.status === 'fulfilled' && companionResult.value) {
        const payload = companionResult.value as Record<string, unknown>;
        const asset = (payload.asset ?? null) as Record<string, unknown> | null;
        setCompanion({
          name: String(payload.name ?? 'Mon Leo'),
          personalizationMode: String(
            payload.personalizationMode ?? 'DEFAULT',
          ) as CompanionMode,
          level: Number(payload.level ?? 1),
          affection: Number(payload.affection ?? 0),
          energy: Number(payload.energy ?? 100),
          mood: String(payload.mood ?? 'CHILL'),
          action: String(payload.action ?? 'IDLE'),
          assetId: String(payload.assetId ?? asset?.id ?? ''),
          asset: asset
            ? {
                id: String(asset.id ?? ''),
                name: String(asset.name ?? 'Companion'),
                description: String(asset.description ?? ''),
                previewImageUrl: String(asset.previewImageUrl ?? ''),
                primaryColor: String(asset.primaryColor ?? ''),
                secondaryColor: String(asset.secondaryColor ?? ''),
                accentColor: String(asset.accentColor ?? ''),
                zodiacSign: (asset.zodiacSign as string | null | undefined) ?? null,
                chineseZodiac:
                  (asset.chineseZodiac as string | null | undefined) ?? null,
                isDefault: Boolean(asset.isDefault),
              }
            : null,
        });
        setCompanionNameDraft(String(payload.name ?? 'Mon Leo'));
      }

      if (optionsResult.status === 'fulfilled' && optionsResult.value) {
        const modes = Array.isArray(
          (optionsResult.value as { modes?: unknown[] }).modes,
        )
          ? ((optionsResult.value as { modes?: unknown[] }).modes as Array<Record<string, unknown>>)
          : [];

        setCompanionOptions(
          modes.map((option) => ({
            mode: String(option.mode ?? 'DEFAULT') as CompanionMode,
            label: String(option.label ?? copy.companionDefaultLabel),
            key: (option.key as string | null | undefined) ?? null,
            available: Boolean(option.available),
            assets: Array.isArray(option.assets)
              ? option.assets.map((asset) => ({
                  id: String((asset as { id?: string }).id ?? ''),
                  name: String((asset as { name?: string }).name ?? 'Companion'),
                  description: String(
                    (asset as { description?: string }).description ?? '',
                  ),
                  previewImageUrl: String(
                    (asset as { previewImageUrl?: string }).previewImageUrl ?? '',
                  ),
                  primaryColor: String(
                    (asset as { primaryColor?: string }).primaryColor ?? '',
                  ),
                  secondaryColor: String(
                    (asset as { secondaryColor?: string }).secondaryColor ?? '',
                  ),
                  accentColor: String(
                    (asset as { accentColor?: string }).accentColor ?? '',
                  ),
                  zodiacSign:
                    ((asset as { zodiacSign?: string | null }).zodiacSign ?? null),
                  chineseZodiac:
                    ((asset as { chineseZodiac?: string | null }).chineseZodiac ??
                      null),
                  isDefault: Boolean((asset as { isDefault?: boolean }).isDefault),
                }))
              : [],
          })),
        );
      }

      if (assetsResult.status === 'fulfilled') {
        setCustomAssets(
          extractList<Record<string, unknown>>(assetsResult.value)
            .filter(
              (asset) =>
                !asset.zodiacSign &&
                !asset.chineseZodiac &&
                !Boolean(asset.isDefault) &&
                Boolean(asset.isActive ?? true),
            )
            .map((asset) => ({
              id: String(asset.id ?? ''),
              name: String(asset.name ?? 'Companion'),
              description: String(asset.description ?? ''),
              previewImageUrl: String(asset.previewImageUrl ?? ''),
              primaryColor: String(asset.primaryColor ?? ''),
              secondaryColor: String(asset.secondaryColor ?? ''),
              accentColor: String(asset.accentColor ?? ''),
            })),
        );
      }

      if (themesResult.status === 'fulfilled') {
        setThemeCatalog(
          extractList<Record<string, unknown>>(themesResult.value)
            .filter((theme) => Boolean(theme.isActive ?? true))
            .map((theme) => ({
              id: String(theme.id ?? ''),
              name: String(theme.name ?? 'Theme'),
              mode: String(theme.mode ?? 'LIGHT') as ThemeMode,
              backgroundColor: String(theme.backgroundColor ?? '#ffffff'),
              surfaceColor: String(theme.surfaceColor ?? '#f8f8ff'),
              primaryColor: String(theme.primaryColor ?? '#6D5DFB'),
              secondaryColor: String(theme.secondaryColor ?? ''),
              textColor: String(theme.textColor ?? '#261D55'),
              mutedTextColor: String(theme.mutedTextColor ?? ''),
              accentColor: String(theme.accentColor ?? ''),
              isDefault: Boolean(theme.isDefault),
              isActive: Boolean(theme.isActive ?? true),
            })),
        );
      }

      if (preferencesResult.status === 'fulfilled' && preferencesResult.value) {
        const preferences = preferencesResult.value as Record<string, unknown>;
        setActiveThemeId(
          preferences.themeId ? String(preferences.themeId) : null,
        );
      }
    });

    return () => {
      cancelled = true;
    };
  }, [copy.companionDefaultLabel, refreshKey]);

  return (
    <>
      <DashboardShell eyebrow={t('settings.eyebrow')} title={t('settings.title')}>
      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          icon={UserRound}
          label={t('settings.metric.profile')}
          note={settings.profile.email}
          value={settings.profile.displayName}
        />
        <MetricCard
          icon={Globe2}
          label="Timezone"
          tone="lilac"
          value={settings.preferences.timezone}
        />
        <MetricCard
          icon={MapPin}
          label={t('settings.metric.location')}
          tone="mint"
          value={settings.preferences.locationName}
        />
        <MetricCard
          icon={CreditCard}
          label={t('settings.metric.plan')}
          note={t('settings.metric.planRenewal', { date: settings.billing.renewal })}
          tone="sun"
          value={settings.billing.planName}
        />
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,0.9fr)_minmax(0,1.1fr)]">
        <Card>
          <SectionTitle
            title={t('settings.section.profile.title')}
            copy={t('settings.section.profile.copy')}
          />
          {/* Avatar uploader — direct Supabase upload via signed URL */}
          <div className="mt-5 rounded-lg border border-lilac/60 bg-white/60 p-4">
            <AvatarUploader
              currentAvatar={avatar}
              displayName={displayName}
              key={avatar ?? 'empty-avatar'}
              onUpdated={(publicUrl) => {
                const nextAvatar = publicUrl || null;
                setAvatarOverride(nextAvatar);
                setAccountProfile({
                  avatar: nextAvatar,
                  displayName,
                  email: settings.profile.email,
                });
                triggerRefresh();
              }}
            />
          </div>
          <div className="mt-5 grid gap-4">
            <Field
              label={t('settings.field.displayName')}
              value={displayName}
              onChange={(value) =>
                setProfileDraft((current) => ({
                  displayName: value,
                  birthday:
                    current?.birthday ??
                    normalizeBirthdayValue(settings.profile.birthday),
                }))
              }
            />
            <Field
              label={t('settings.field.birthday')}
              type="date"
              value={birthday}
              onChange={(value) =>
                setProfileDraft((current) => ({
                  displayName:
                    current?.displayName ?? settings.profile.displayName,
                  birthday: value,
                }))
              }
            />
            {(() => {
              // Compute zodiac client-side from the in-progress birthday
              // draft so the cards update the moment the user picks a new
              // date, without waiting for a PATCH round-trip. Falls back
              // to the server-rendered values when the draft is empty.
              const previewed = computeZodiac(birthday);
              const liveZodiac =
                zodiacLabel(previewed.zodiacSign, locale) !== '—'
                  ? zodiacLabel(previewed.zodiacSign, locale)
                  : settings.profile.zodiacSign;
              const liveChinese =
                chineseZodiacLabel(previewed.chineseZodiac, locale) !== '—'
                  ? chineseZodiacLabel(previewed.chineseZodiac, locale)
                  : settings.profile.chineseZodiac;
              return (
                <div className="grid gap-3 sm:grid-cols-2">
                  <DerivedCard
                    icon={WandSparkles}
                    label={t('settings.field.zodiacWestern')}
                    note={t('settings.zodiac.auto')}
                    value={liveZodiac}
                  />
                  <DerivedCard
                    icon={WandSparkles}
                    label={t('settings.field.zodiacChinese')}
                    note={t('settings.zodiac.chineseAuto')}
                    value={liveChinese}
                  />
                </div>
              );
            })()}
          </div>
          <Button
            className="mt-5"
            disabled={profileState === 'saving'}
            onClick={async () => {
              setProfileState('saving');
              try {
                await apiFetch('/user-profiles/me/profile', {
                  method: 'PATCH',
                  body: JSON.stringify({
                    displayName,
                    // Always send UTC midnight for the picked date so we
                    // don't shift back a day in negative timezones.
                    // (`new Date('YYYY-MM-DDT00:00:00')` is interpreted
                    // as LOCAL time → +07 lost a day in UTC.)
                    birthday: birthday
                      ? new Date(`${birthday}T00:00:00.000Z`).toISOString()
                      : null,
                  }),
                });
                setAccountProfile({
                  displayName,
                  name: displayName,
                  email: settings.profile.email,
                });
                setRefreshKey((current) => current + 1);
                triggerRefresh();
                setProfileDraft(null);
                pushToast({
                  tone: 'success',
                  title: t('settings.toast.profileSaved'),
                  message: t('settings.toast.profileSavedMessage'),
                });
              } catch {
                pushToast({
                  tone: 'error',
                  title: t('settings.toast.profileFailed'),
                  message: t('settings.toast.serverHint'),
                });
              } finally {
                setProfileState('idle');
              }
            }}
          >
            <Save className="h-4 w-4" />
            {profileState === 'saving' ? t('settings.btn.savingProfile') : t('settings.btn.saveProfile')}
          </Button>
        </Card>

        <Card>
          <SectionTitle
            title={t('settings.section.preferences.title')}
            copy={t('settings.section.preferences.copy')}
          />
          <div className="mt-5 grid gap-4">
            <div className="grid gap-4 sm:grid-cols-3">
              <Field
                label={t('settings.field.themeMode')}
                select
                value={themeMode}
                options={['SYSTEM', 'LIGHT', 'DARK']}
                onChange={(value) => {
                  const nextMode = value as ThemeMode;
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      current?.weatherEnabled ??
                      settings.preferences.weatherEnabled,
                    pushEnabled:
                      current?.pushEnabled ?? settings.preferences.pushEnabled,
                    soundEnabled:
                      current?.soundEnabled ??
                      settings.preferences.soundEnabled,
                    timezone:
                      current?.timezone ?? settings.preferences.timezone,
                    locationName:
                      current?.locationName ??
                      settings.preferences.locationName,
                    themeMode: nextMode,
                  }));
                  // Hot-apply immediately so the user sees the new mode
                  // without having to press "Lưu preferences" first.
                  const activePalette =
                    themeCatalog.find((t) => t.id === activeThemeId) ?? null;
                  dispatchDashboardTheme(nextMode, activePalette);
                  // Best-effort persist in the background.
                  void apiFetch('/user-preferences/me/preferences', {
                    method: 'PATCH',
                    body: JSON.stringify({ themeMode: nextMode }),
                  }).catch(() => {
                    /* surfaced via the Save button if it fails */
                  });
                }}
              />
              <Field
                label="Timezone"
                value={timezone}
                onChange={(value) =>
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      current?.weatherEnabled ??
                      settings.preferences.weatherEnabled,
                    pushEnabled:
                      current?.pushEnabled ?? settings.preferences.pushEnabled,
                    soundEnabled:
                      current?.soundEnabled ??
                      settings.preferences.soundEnabled,
                    timezone: value,
                    locationName:
                      current?.locationName ??
                      settings.preferences.locationName,
                    themeMode:
                      current?.themeMode ??
                      (settings.preferences.theme.toUpperCase() as ThemeMode),
                  }))
                }
              />
              <Field
                label={t('settings.metric.location')}
                value={locationName}
                onChange={(value) =>
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      current?.weatherEnabled ??
                      settings.preferences.weatherEnabled,
                    pushEnabled:
                      current?.pushEnabled ?? settings.preferences.pushEnabled,
                    soundEnabled:
                      current?.soundEnabled ??
                      settings.preferences.soundEnabled,
                    timezone:
                      current?.timezone ?? settings.preferences.timezone,
                    locationName: value,
                    themeMode:
                      current?.themeMode ??
                      (settings.preferences.theme.toUpperCase() as ThemeMode),
                  }))
                }
              />
            </div>

            <div className="grid gap-3 sm:grid-cols-3">
              <ToggleCard
                checked={weatherEnabled}
                icon={MapPin}
                label={t('settings.section.weather.title')}
                onClick={() =>
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      !(current?.weatherEnabled ??
                        settings.preferences.weatherEnabled),
                    pushEnabled:
                      current?.pushEnabled ?? settings.preferences.pushEnabled,
                    soundEnabled:
                      current?.soundEnabled ??
                      settings.preferences.soundEnabled,
                    timezone:
                      current?.timezone ?? settings.preferences.timezone,
                    locationName:
                      current?.locationName ??
                      settings.preferences.locationName,
                    themeMode:
                      current?.themeMode ??
                      (settings.preferences.theme.toUpperCase() as ThemeMode),
                  }))
                }
              />
              <ToggleCard
                checked={pushEnabled}
                icon={Bell}
                label={t('settings.field.notifyPush')}
                onClick={() =>
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      current?.weatherEnabled ??
                      settings.preferences.weatherEnabled,
                    pushEnabled:
                      !(current?.pushEnabled ??
                        settings.preferences.pushEnabled),
                    soundEnabled:
                      current?.soundEnabled ??
                      settings.preferences.soundEnabled,
                    timezone:
                      current?.timezone ?? settings.preferences.timezone,
                    locationName:
                      current?.locationName ??
                      settings.preferences.locationName,
                    themeMode:
                      current?.themeMode ??
                      (settings.preferences.theme.toUpperCase() as ThemeMode),
                  }))
                }
              />
              <ToggleCard
                checked={soundEnabled}
                icon={Moon}
                label={t('settings.field.notifySound')}
                onClick={() =>
                  setDraftPreferences((current) => ({
                    weatherEnabled:
                      current?.weatherEnabled ??
                      settings.preferences.weatherEnabled,
                    pushEnabled:
                      current?.pushEnabled ?? settings.preferences.pushEnabled,
                    soundEnabled:
                      !(current?.soundEnabled ??
                        settings.preferences.soundEnabled),
                    timezone:
                      current?.timezone ?? settings.preferences.timezone,
                    locationName:
                      current?.locationName ??
                      settings.preferences.locationName,
                    themeMode:
                      current?.themeMode ??
                      (settings.preferences.theme.toUpperCase() as ThemeMode),
                  }))
                }
              />
            </div>

            <div className="grid gap-3 sm:grid-cols-3">
              <StatusMiniCard
                note={t('settings.theme.systemNote')}
                title={t('settings.theme.current')}
                value={themeMode}
              />
              <StatusMiniCard
                note={weatherEnabled ? t('settings.weather.on') : t('settings.weather.off')}
                title={t('settings.weather.location')}
                value={locationName}
              />
              <StatusMiniCard
                note={t('settings.reminders.quickNote')}
                title={t('settings.reminders.dailyRhythm')}
                value={
                  settings.preferences.reminderTimes.length > 0
                    ? settings.preferences.reminderTimes.join(' • ')
                    : t('settings.reminders.empty.full')
                }
              />
            </div>
          </div>

          <div className="mt-5">
            <p className="mb-2 text-xs font-semibold uppercase tracking-[0.14em] text-[var(--app-muted,theme(colors.slate))]">
              {t('settings.reminders.quickAdd')}
            </p>
            <div className="flex flex-wrap items-center gap-2">
              {settings.preferences.reminderTimes.map((time) => (
                <span
                  className="inline-flex items-center gap-2 rounded-full border border-[var(--field-border)] bg-[var(--panel-bg)] px-3 py-1.5 text-sm font-bold"
                  key={time}
                >
                  <Repeat className="h-3.5 w-3.5 text-violet" />
                  {time}
                </span>
              ))}
              {settings.preferences.reminderTimes.length === 0 ? (
                <span className="text-xs font-semibold text-[var(--app-muted,theme(colors.slate))]">
                  {t('settings.reminders.quickEmpty')}
                </span>
              ) : null}
            </div>
            <QuickAddReminder
              defaultTitle={t('settings.reminders.defaultBreathing')}
              onCreated={() => {
                setRefreshKey((current) => current + 1);
                triggerRefresh();
              }}
            />
          </div>

          <div className="mt-5 flex flex-wrap gap-3">
            <Button
              disabled={saveState === 'saving'}
              onClick={async () => {
                setSaveState('saving');
                try {
                  await apiFetch('/user-preferences/me/preferences', {
                    method: 'PATCH',
                    body: JSON.stringify({
                      timezone,
                      locationName,
                      weatherEnabled,
                      enableSound: soundEnabled,
                      pushNotificationsEnabled: pushEnabled,
                      themeMode,
                    }),
                  });
                  setRefreshKey((current) => current + 1);
                  triggerRefresh();
                  setDraftPreferences(null);
                  pushToast({
                    tone: 'success',
                    title: t('settings.toast.preferencesSaved'),
                    message: t('settings.toast.preferencesSavedMessage'),
                  });
                } catch {
                  pushToast({
                    tone: 'error',
                    title: t('settings.toast.preferencesFailed'),
                    message: t('settings.toast.serverHint'),
                  });
                } finally {
                  setSaveState('idle');
                }
              }}
            >
              <Save className="h-4 w-4" />
              {saveState === 'saving' ? t('settings.btn.savingPreferences') : t('settings.btn.savePreferences')}
            </Button>
            <Button
              onClick={async () => {
                try {
                  const pos = await requestGeolocation();
                  await apiFetch('/weather/me/location', {
                    method: 'PATCH',
                    body: JSON.stringify({
                      latitude: pos.coords.latitude,
                      longitude: pos.coords.longitude,
                      weatherEnabled: true,
                    }),
                  });
                  setRefreshKey((current) => current + 1);
                  triggerRefresh();
                  pushToast({
                    tone: 'success',
                    title: t('weather.locateGranted'),
                    message: t('settings.toast.locationSavedMessage'),
                  });
                } catch (error) {
                  pushToast({
                    tone: 'error',
                    title: t('weather.locateFailed.title'),
                    message:
                      error instanceof Error ? error.message : 'Unknown',
                  });
                }
              }}
              variant="secondary"
            >
              <Navigation className="h-4 w-4" />
              {t('weather.locate')}
            </Button>
            <Button
              onClick={async () => {
                try {
                  await apiFetch('/notifications/me/test', {
                    method: 'POST',
                    body: JSON.stringify({
                      title: t('settings.notification.testTitle'),
                      message: t('settings.notification.testMessage'),
                      type: 'IN_APP',
                    }),
                  });
                  setRefreshKey((current) => current + 1);
                  triggerRefresh();
                  pushToast({
                    tone: 'info',
                    title: t('settings.toast.testNotificationCreated'),
                    message: t('settings.toast.testNotificationMessage'),
                  });
                } catch {
                  pushToast({
                    tone: 'error',
                    title: t('settings.toast.testNotificationFailed'),
                    message: t('settings.toast.serverHint'),
                  });
                }
              }}
              variant="secondary"
            >
              <Bell className="h-4 w-4" />
              {t('settings.btn.testNotification')}
            </Button>
          </div>
        </Card>
      </div>

      <Card>
        <SectionTitle
          title={t('settings.section.security.title')}
          copy={t('settings.section.security.copy')}
          action={<KeyRound className="h-5 w-5 text-violet" />}
        />
        <form
          className="mt-5 grid gap-4 lg:grid-cols-3"
          onSubmit={async (event) => {
            event.preventDefault();
            if (passwordDraft.newPassword !== passwordDraft.confirmPassword) {
              pushToast({
                tone: 'error',
                title: t('settings.toast.passwordMismatch'),
              });
              return;
            }
            if (!isStrongPassword(passwordDraft.newPassword)) {
              pushToast({
                tone: 'error',
                title: t('settings.toast.passwordTooShort'),
              });
              return;
            }

            setPasswordState('saving');
            try {
              await apiFetch('/auth/me/password', {
                method: 'PATCH',
                body: JSON.stringify({
                  currentPassword: passwordDraft.currentPassword,
                  newPassword: passwordDraft.newPassword,
                }),
              });
              setPasswordDraft({
                currentPassword: '',
                newPassword: '',
                confirmPassword: '',
              });
              pushToast({
                tone: 'success',
                title: t('settings.toast.passwordChanged'),
              });
            } catch {
              pushToast({
                tone: 'error',
                title: t('settings.password.changeFailed'),
                message: t('settings.toast.serverHint'),
              });
            } finally {
              setPasswordState('idle');
            }
          }}
        >
          <Field
            label={t('settings.field.currentPassword')}
            onChange={(value) =>
              setPasswordDraft((current) => ({
                ...current,
                currentPassword: value,
              }))
            }
            type="password"
            value={passwordDraft.currentPassword}
          />
          <Field
            label={t('settings.field.newPassword')}
            onChange={(value) =>
              setPasswordDraft((current) => ({
                ...current,
                newPassword: value,
              }))
            }
            type="password"
            value={passwordDraft.newPassword}
          />
          <Field
            label={t('settings.field.confirmPassword')}
            onChange={(value) =>
              setPasswordDraft((current) => ({
                ...current,
                confirmPassword: value,
              }))
            }
            type="password"
            value={passwordDraft.confirmPassword}
          />
          <p className="text-xs font-semibold text-slate lg:col-span-3">
            {t('settings.toast.passwordTooShort')}
          </p>
          <div className="lg:col-span-3">
            <Button
              disabled={
                passwordState === 'saving' ||
                !passwordDraft.currentPassword ||
                !passwordDraft.newPassword ||
                !passwordDraft.confirmPassword
              }
              type="submit"
            >
              <KeyRound className="h-4 w-4" />
              {passwordState === 'saving'
                ? t('settings.btn.changingPassword')
                : t('settings.btn.changePassword')}
            </Button>
          </div>
        </form>
      </Card>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.05fr)_minmax(0,0.95fr)]">
        <Card>
          <SectionTitle
            title={copy.companionTitle}
            copy={copy.companionCopy}
            action={<WandSparkles className="h-5 w-5 text-violet" />}
          />
          {companion ? (
            <div className="mt-5 space-y-5">
              <div className="grid gap-4 sm:grid-cols-[180px_minmax(0,1fr)]">
                <div
                  className="overflow-hidden rounded-2xl border border-lilac/70 bg-white/75"
                  style={{
                    background:
                      companion.asset?.secondaryColor || 'rgba(255,255,255,0.72)',
                  }}
                >
                  {companion.asset?.previewImageUrl ? (
                    <SafeCompanionImage
                      alt={companion.asset.name}
                      className="h-44 w-full object-cover"
                      src={companion.asset.previewImageUrl}
                    />
                  ) : (
                    <div className="flex h-44 items-center justify-center text-sm font-semibold text-slate">
                      {copy.noPreview}
                    </div>
                  )}
                </div>
                <div className="space-y-3">
                  <Field
                    label={copy.companionName}
                    value={companionNameDraft}
                    onChange={setCompanionNameDraft}
                  />
                  <div className="grid gap-3 sm:grid-cols-3">
                    <StatusMiniCard
                      note={copy.currentLevel}
                      title="Level"
                      value={String(companion.level)}
                    />
                    <StatusMiniCard
                      note={copy.affection}
                      title="Affection"
                      value={`${companion.affection}%`}
                    />
                    <StatusMiniCard
                      note={copy.energy}
                      title="Energy"
                      value={`${companion.energy}%`}
                    />
                  </div>
                  <div className="flex flex-wrap gap-2">
                    <Button
                      disabled={companionState === 'saving'}
                      onClick={async () => {
                        setCompanionState('saving');
                        try {
                          await apiFetch('/user-companions/me', {
                            method: 'PATCH',
                            body: JSON.stringify({ name: companionNameDraft }),
                          });
                          setRefreshKey((current) => current + 1);
                          triggerRefresh();
                          pushToast({
                            tone: 'success',
                            title: copy.renamedCompanion,
                          });
                        } catch {
                          pushToast({
                            tone: 'error',
                            title: copy.renameCompanionFailed,
                          });
                        } finally {
                          setCompanionState('idle');
                        }
                      }}
                    >
                      <Save className="h-4 w-4" />
                      {copy.saveName}
                    </Button>
                    {(['PET', 'FEED', 'PLAY'] as const).map((action) => (
                      <Button
                        key={action}
                        onClick={async () => {
                          try {
                            await apiFetch('/user-companions/me/interactions', {
                              method: 'POST',
                              body: JSON.stringify({ type: action }),
                            });
                            setRefreshKey((current) => current + 1);
                            triggerRefresh();
                            pushToast({
                              tone: 'success',
                              title:
                                action === 'PET'
                                  ? copy.petted
                                  : action === 'FEED'
                                    ? copy.fed
                                    : copy.played,
                            });
                          } catch {
                            pushToast({
                              tone: 'error',
                              title: copy.interactFailed,
                            });
                          }
                        }}
                        variant="secondary"
                      >
                        {action === 'PET'
                          ? copy.pet
                          : action === 'FEED'
                            ? copy.feed
                            : copy.play}
                      </Button>
                    ))}
                  </div>
                </div>
              </div>

              <div className="grid gap-3 sm:grid-cols-3">
                <StatusMiniCard
                  note={copy.currentMode}
                  title="Personalization"
                  value={modeLabel(companion.personalizationMode, copy)}
                />
                <StatusMiniCard
                  note={copy.currentMood}
                  title="Mood"
                  value={companion.mood}
                />
                <StatusMiniCard
                  note={copy.currentAction}
                  title="Action"
                  value={companion.action}
                />
              </div>

              <div className="space-y-3">
                {companionOptions.map((option) => (
                  <div
                    className="rounded-xl border border-lilac/70 bg-white/75 p-4"
                    key={option.mode}
                  >
                    <div className="flex flex-wrap items-start justify-between gap-3">
                      <div>
                        <p className="text-lg font-extrabold text-ink">
                          {companionOptionLabel(option, copy)}
                        </p>
                        <p className="mt-1 text-sm text-slate">
                          {option.key
                            ? copy.mappedBy(option.key)
                            : option.mode === 'CUSTOM'
                              ? copy.customMode
                              : copy.defaultMode}
                        </p>
                      </div>
                      <Button
                        disabled={!option.available || companionState === 'saving' || option.mode === 'CUSTOM'}
                        onClick={async () => {
                          setCompanionState('saving');
                          try {
                            await apiFetch('/user-companions/me/personalization-mode', {
                              method: 'PATCH',
                              body: JSON.stringify({
                                personalizationMode: option.mode,
                                preserveProgress: true,
                                resetVisualState: true,
                              }),
                            });
                            setRefreshKey((current) => current + 1);
                            triggerRefresh();
                            pushToast({
                              tone: 'success',
                              title: copy.changedMode(
                                companionOptionLabel(option, copy).toLowerCase(),
                              ),
                            });
                          } catch {
                            pushToast({
                              tone: 'error',
                              title: copy.changeModeFailed,
                            });
                          } finally {
                            setCompanionState('idle');
                          }
                        }}
                        variant={
                          companion.personalizationMode === option.mode &&
                          option.mode !== 'CUSTOM'
                            ? 'secondary'
                            : 'primary'
                        }
                      >
                        {option.mode === 'CUSTOM'
                          ? copy.selectAssetBelow
                          : companion.personalizationMode === option.mode
                            ? copy.inUse
                            : copy.apply}
                      </Button>
                    </div>

                    {option.assets.length > 0 ? (
                      <div className="mt-4 grid gap-3 sm:grid-cols-2">
                        {option.assets.slice(0, 2).map((asset) => (
                          <CompanionAssetCard
                            asset={asset}
                            key={asset.id}
                            onSelect={async () => {
                              setCompanionState('saving');
                              try {
                                await apiFetch('/user-companions/me/personalization-mode', {
                                  method: 'PATCH',
                                  body: JSON.stringify({
                                    personalizationMode: option.mode,
                                    preserveProgress: true,
                                    resetVisualState: true,
                                  }),
                                });
                                setRefreshKey((current) => current + 1);
                                triggerRefresh();
                                pushToast({
                                  tone: 'success',
                                  title: copy.syncedMode(
                                    companionOptionLabel(option, copy).toLowerCase(),
                                  ),
                                });
                              } catch {
                                pushToast({
                                  tone: 'error',
                                  title: copy.syncModeFailed,
                                });
                              } finally {
                                setCompanionState('idle');
                              }
                            }}
                            selected={companion.assetId === asset.id}
                          />
                        ))}
                      </div>
                    ) : null}
                  </div>
                ))}
              </div>

              <div className="rounded-xl border border-lilac/70 bg-white/75 p-4">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div>
                    <p className="text-lg font-extrabold text-ink">{copy.customLibrary}</p>
                    <p className="mt-1 text-sm text-slate">
                      {copy.customLibraryCopy}
                    </p>
                  </div>
                </div>
                <div className="mt-4 grid gap-3 sm:grid-cols-2">
                  {customAssets.map((asset) => (
                    <CompanionAssetCard
                      asset={asset}
                      key={asset.id}
                      onSelect={async () => {
                        setCompanionState('saving');
                        try {
                          await apiFetch('/user-companions/me/personalization-mode', {
                            method: 'PATCH',
                            body: JSON.stringify({
                              personalizationMode: 'CUSTOM',
                              assetId: asset.id,
                              preserveProgress: true,
                              resetVisualState: true,
                            }),
                          });
                          setRefreshKey((current) => current + 1);
                          triggerRefresh();
                          pushToast({
                            tone: 'success',
                            title: copy.loadedAsset(asset.name),
                          });
                        } catch {
                          pushToast({
                            tone: 'error',
                            title: copy.loadAssetFailed,
                          });
                        } finally {
                          setCompanionState('idle');
                        }
                      }}
                      selected={
                        companion.personalizationMode === 'CUSTOM' &&
                        companion.assetId === asset.id
                      }
                    />
                  ))}
                </div>
              </div>
            </div>
          ) : (
            <div className="mt-5 rounded-xl border border-dashed border-lilac bg-white/70 p-6 text-sm font-medium text-slate">
              {copy.companionLoading}
            </div>
          )}
        </Card>

        <Card>
          <SectionTitle
            title={copy.themeGalleryTitle}
            copy={copy.themeGalleryCopy}
            action={<Moon className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5 space-y-3">
            {themeCatalog.map((theme) => {
              const isActiveTheme = activeThemeId === theme.id;
              const statusLabel = isActiveTheme
                ? copy.inUse
                : themeState === theme.id
                  ? copy.applying
                  : copy.apply;
              // Auto-fix unreadable palettes (e.g. dark ink on a dark
              // surface). If the admin's textColor has enough contrast we
              // keep it; otherwise we fall back to white/near-black.
              const readableText = getReadableTextColor(
                theme.surfaceColor,
                theme.textColor,
              );
              const readableMuted = getReadableTextColor(
                theme.surfaceColor,
                theme.mutedTextColor || theme.textColor,
              );

              return (
                <button
                  className="w-full rounded-xl border p-4 text-left transition hover:-translate-y-0.5"
                  key={theme.id}
                  onClick={async () => {
                    setThemeState(theme.id);
                    dispatchDashboardTheme(theme.mode, theme);
                    try {
                      await apiFetch('/user-preferences/me/preferences', {
                        method: 'PATCH',
                        body: JSON.stringify({
                          themeId: theme.id,
                          themeMode: theme.mode,
                        }),
                      });
                      setActiveThemeId(theme.id);
                      setDraftPreferences((current) => ({
                        weatherEnabled:
                          current?.weatherEnabled ?? settings.preferences.weatherEnabled,
                        pushEnabled:
                          current?.pushEnabled ?? settings.preferences.pushEnabled,
                        soundEnabled:
                          current?.soundEnabled ?? settings.preferences.soundEnabled,
                        timezone: current?.timezone ?? settings.preferences.timezone,
                        locationName:
                          current?.locationName ?? settings.preferences.locationName,
                        themeMode: theme.mode,
                      }));
                      setRefreshKey((current) => current + 1);
                      triggerRefresh();
                      pushToast({
                        tone: 'success',
                        title: copy.themeApplied(theme.name),
                      });
                    } catch {
                      const currentTheme = themeCatalog.find(
                        (item) => item.id === activeThemeId,
                      );
                      dispatchDashboardTheme(
                        draftPreferences?.themeMode ??
                          (settings.preferences.theme.toUpperCase() as ThemeMode),
                        currentTheme ?? null,
                      );
                      pushToast({
                        tone: 'error',
                        title: copy.themeApplyFailed,
                      });
                    } finally {
                      setThemeState(null);
                    }
                  }}
                  style={{
                    backgroundColor: theme.surfaceColor,
                    borderColor: isActiveTheme
                      ? theme.primaryColor
                      : theme.secondaryColor || theme.primaryColor,
                    boxShadow: isActiveTheme
                      ? `0 0 0 1px ${theme.primaryColor}`
                      : 'none',
                    color: readableText,
                  }}
                  type="button"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p
                        className="text-lg font-extrabold"
                        style={{ color: readableText }}
                      >
                        {theme.name}
                      </p>
                      <p
                        className="mt-1 text-sm"
                        style={{ color: readableMuted }}
                      >
                        {theme.mode} {theme.isDefault ? copy.systemDefaultSuffix : ''}
                      </p>
                    </div>
                    <div
                      className="text-xs font-bold"
                      style={{
                        color: getReadableTextColor(
                          theme.surfaceColor,
                          theme.primaryColor,
                        ),
                      }}
                    >
                      {statusLabel}
                    </div>
                  </div>
                  <div className="mt-4 grid grid-cols-4 gap-2">
                    {[
                      theme.backgroundColor,
                      theme.surfaceColor,
                      theme.primaryColor,
                      theme.accentColor || theme.secondaryColor || theme.textColor,
                    ].map((color) => (
                      <div
                        className="h-12 rounded-lg border"
                        key={color}
                        style={{
                          backgroundColor: color,
                          borderColor: theme.mutedTextColor || 'rgba(0,0,0,0.08)',
                        }}
                      />
                    ))}
                  </div>
                </button>
              );
            })}
          </div>
        </Card>
      </div>

      <PermissionsPanel />

      <div className="grid gap-4 xl:grid-cols-2">
        <Card>
          <SectionTitle
            title={copy.sessionsTitle}
            copy={copy.sessionsCopy}
            action={<Laptop className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5">
            <DataTable
              columns={[
                t('sessions.field.device'),
                t('sessions.field.browser'),
                'IP',
                t('sessions.field.loginTime'),
                t('sessions.field.expires'),
                t('catalog.col.status'),
              ]}
              rows={settings.sessions
                .slice(
                  sessionsPage * sessionsPageSize,
                  (sessionsPage + 1) * sessionsPageSize,
                )
                .map((session) => [
                  <div
                    className="max-w-[220px]"
                    key={`${session.id}-device`}
                    title={session.device}
                  >
                    <p className="font-bold">{describeDevice(session.device, locale)}</p>
                  </div>,
                  <span
                    className="text-sm font-semibold"
                    key={`${session.id}-browser`}
                  >
                    {describeBrowser(session.device)}
                  </span>,
                  <code
                    className="rounded bg-[var(--field-bg)] px-2 py-1 text-xs"
                    key={`${session.id}-ip`}
                  >
                    {session.ipAddress || '—'}
                  </code>,
                  session.createdAt,
                  session.expiresAt,
                  session.current ? copy.currentSession : copy.savedSession,
                ])}
            />
            <SessionsPagination
              page={sessionsPage}
              pageSize={sessionsPageSize}
              setPage={setSessionsPage}
              setPageSize={setSessionsPageSize}
              total={settings.sessions.length}
            />
          </div>
          <p className="mt-4 text-sm text-[var(--app-muted,theme(colors.slate))]">
            {copy.sessionsNote}
          </p>
        </Card>

        <Card>
          <SectionTitle
            title={copy.pushDevicesTitle}
            copy={copy.pushDevicesCopy}
            action={<Smartphone className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5 flex flex-wrap gap-3">
            <Button
              disabled={deviceState === 'saving'}
              onClick={async () => {
                setDeviceState('saving');
                try {
                  await apiFetch('/notifications/me/devices', {
                    method: 'POST',
                    body: JSON.stringify({
                      token: `web-debug-${crypto.randomUUID()}`,
                      platform: 'WEB',
                      deviceName: 'Current browser',
                      timezone,
                      enabled: true,
                    }),
                  });
                  setRefreshKey((current) => current + 1);
                  triggerRefresh();
                  pushToast({
                    tone: 'success',
                    title: copy.pushDeviceAdded,
                    message: copy.pushDeviceAddedMessage,
                  });
                } catch {
                  pushToast({
                    tone: 'error',
                    title: copy.pushDeviceAddFailed,
                    message: t('settings.toast.serverHint'),
                  });
                } finally {
                  setDeviceState('idle');
                }
              }}
            >
              <Smartphone className="h-4 w-4" />
              {deviceState === 'saving' ? copy.adding : copy.registerCurrentBrowser}
            </Button>
          </div>
          <div className="mt-5">
            <DataTable
              columns={['Label', 'Platform', t('state.active'), t('catalog.col.actions')]}
              rows={settings.pushDevices.map((device) => [
                device.label,
                device.platform,
                device.active ? 'On' : 'Off',
                <Button
                  className="h-8 px-3 text-xs"
                  key={device.id}
                  onClick={async () => {
                    try {
                      await apiFetch(`/notifications/me/devices/${device.id}`, {
                        method: 'DELETE',
                      });
                      setRefreshKey((current) => current + 1);
                      triggerRefresh();
                      pushToast({
                        tone: 'success',
                        title: copy.pushDeviceRemoved,
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: copy.pushDeviceRemoveFailed,
                      });
                    }
                  }}
                  variant="secondary"
                >
                  {copy.remove}
                </Button>,
              ])}
            />
          </div>
        </Card>
      </div>

      <div className="grid gap-4 xl:grid-cols-[minmax(0,1.1fr)_minmax(0,0.9fr)_minmax(0,1.1fr)] mt-4">
        <Card>
          <SectionTitle
            title={copy.remindersTitle}
            copy={copy.remindersCopy}
            action={<Repeat className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5 grid gap-4">
            {/* Stack on mobile, 2-col on tablet, full single row only on
             *  ≥xl where there's actually room for label + input + button.
             *  Old md:grid-cols-[1fr_180px_220px_auto] squeezed the title
             *  field to 0px on intermediate widths. */}
            <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-[minmax(0,1fr)_180px_220px_auto]">
              <Field
                label={copy.titleLabel}
                value={reminderDraft.title}
                onChange={(value) =>
                  setReminderDraft((current) => ({ ...current, title: value }))
                }
              />
              <Field
                label={copy.typeLabel}
                select
                value={reminderDraft.type}
                options={['WATER', 'REST', 'BREATHING', 'JOURNAL', 'SLEEP', 'CUSTOM']}
                onChange={(value) =>
                  setReminderDraft((current) => ({
                    ...current,
                    type: value as ReminderDraft['type'],
                  }))
                }
              />
              <Field
                label={copy.datetimeLabel}
                type="datetime-local"
                value={reminderDraft.scheduledAt}
                onChange={(value) =>
                  setReminderDraft((current) => ({
                    ...current,
                    scheduledAt: value,
                  }))
                }
              />
              <div className="sm:col-span-2">
                <Button
                  className="w-full sm:w-auto"
                  disabled={reminderState === 'saving'}
                  onClick={async () => {
                    setReminderState('saving');
                    try {
                      await apiFetch('/reminders/me', {
                        method: 'POST',
                        body: JSON.stringify({
                          ...reminderDraft,
                          scheduledAt: new Date(
                            reminderDraft.scheduledAt,
                          ).toISOString(),
                          isActive: true,
                        }),
                      });
                      setRefreshKey((current) => current + 1);
                      triggerRefresh();
                      // KEEP the title + type + message so the user can
                      // quickly create another similar reminder. Only
                      // bump the scheduled time forward by an hour so
                      // they don't accidentally re-create the same slot.
                      setReminderDraft((current) => ({
                        ...current,
                        scheduledAt: nextLocalReminderTime(),
                      }));
                      pushToast({
                        tone: 'success',
                        title: copy.reminderCreated,
                        message: copy.reminderCreatedMessage(reminderDraft.title),
                      });
                    } catch {
                      pushToast({
                        tone: 'error',
                        title: copy.reminderCreateFailed,
                        message: t('settings.toast.serverHint'),
                      });
                    } finally {
                      setReminderState('idle');
                    }
                  }}
                >
                  <Save className="h-4 w-4" />
                  {reminderState === 'saving' ? copy.creating : copy.createReminder}
                </Button>
              </div>
            </div>
            <div className="mt-2 flex flex-wrap items-center justify-between gap-3">
              <p className="text-sm font-semibold text-[var(--app-muted,theme(colors.slate))]">
                {copy.savedReminderCount(settings.reminders.length)}
              </p>
              {settings.reminders.length > 0 ? (
                <Button
                  className="h-9 px-3 text-xs"
                  disabled={reminderState === 'saving'}
                  onClick={async () => {
                    const ok = window.confirm(
                      copy.confirmDeleteAllReminders(settings.reminders.length),
                    );
                    if (!ok) return;
                    setReminderState('saving');
                    try {
                      await Promise.all(
                        settings.reminders.map((reminder) =>
                          apiFetch(`/reminders/${reminder.id}`, {
                            method: 'DELETE',
                          }).catch(() => undefined),
                        ),
                      );
                      setRefreshKey((current) => current + 1);
                      triggerRefresh();
                      pushToast({
                        tone: 'success',
                        title: copy.deletedReminderCount(settings.reminders.length),
                      });
                    } finally {
                      setReminderState('idle');
                    }
                  }}
                  variant="secondary"
                >
                  <Trash2 className="h-3.5 w-3.5" />
                  {copy.deleteAll}
                </Button>
              ) : null}
            </div>
            <DataTable
              columns={[
                copy.typeLabel,
                copy.titleLabel,
                copy.scheduleLabel,
                t('catalog.col.status'),
                t('catalog.col.actions'),
              ]}
              rows={settings.reminders.map((reminder) => [
                <span
                  className="inline-flex rounded-full bg-violet/15 px-2 py-0.5 text-xs font-bold text-violet"
                  key={`${reminder.id}-type`}
                >
                  {reminder.type}
                </span>,
                reminder.title,
                reminder.schedule,
                reminder.active ? copy.on : copy.off,
                <div className="flex gap-2" key={reminder.id}>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={async () => {
                      try {
                        await apiFetch(`/reminders/${reminder.id}`, {
                          method: 'PATCH',
                          body: JSON.stringify({
                            isActive: !reminder.active,
                          }),
                        });
                        setRefreshKey((current) => current + 1);
                        triggerRefresh();
                        pushToast({
                          tone: 'success',
                          title: reminder.active
                            ? copy.reminderDisabled
                            : copy.reminderEnabled,
                        });
                      } catch {
                        pushToast({
                          tone: 'error',
                          title: copy.reminderStatusFailed,
                        });
                      }
                    }}
                    variant="secondary"
                  >
                    {reminder.active ? copy.disable : copy.enable}
                  </Button>
                  <Button
                    className="h-8 px-3 text-xs"
                    onClick={async () => {
                      try {
                        await apiFetch(`/reminders/${reminder.id}`, {
                          method: 'DELETE',
                        });
                        setRefreshKey((current) => current + 1);
                        triggerRefresh();
                        pushToast({
                          tone: 'success',
                          title: copy.reminderDeleted,
                        });
                      } catch {
                        pushToast({
                          tone: 'error',
                          title: copy.reminderDeleteFailed,
                        });
                      }
                    }}
                  >
                    {t('btn.delete')}
                  </Button>
                </div>,
              ])}
            />
          </div>
        </Card>

        <Card>
          <SectionTitle
            title={copy.billingTitle}
            copy={copy.billingCopy}
            action={<CreditCard className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5 rounded-lg border border-lilac/70 bg-white/75 p-4">
            <p className="text-xs font-semibold uppercase tracking-[0.14em] text-slate">
              {copy.currentPlan}
            </p>
            <p className="mt-2 text-2xl font-extrabold text-ink">
              {settings.billing.planName}
            </p>
            <p className="mt-1 text-sm font-medium text-plum">
              {copy.billingStatus(settings.billing.status, settings.billing.renewal)}
            </p>
          </div>
          <div className="mt-5 grid gap-3">
            {billingPlans.length > 0 ? billingPlans.map((plan) => (
              <div
                className="rounded-lg border border-lilac/70 bg-white/75 p-4"
                key={plan.name}
              >
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div>
                    <p className="text-lg font-extrabold text-ink">{plan.title}</p>
                    <p className="mt-1 text-sm font-semibold text-plum">
                      {formatPlanPrice(plan.price, plan.currency, locale)}
                    </p>
                  </div>
                  <Button
                    className="h-9 px-3 text-xs"
                    disabled={
                      billingState === plan.name ||
                      settings.billing.planName === plan.name
                    }
                    onClick={() => {
                      setCheckoutResult(null);
                      setCheckoutPlan(plan);
                    }}
                    variant={
                      settings.billing.planName === plan.name
                        ? 'secondary'
                        : 'primary'
                    }
                  >
                    {settings.billing.planName === plan.name
                      ? copy.inUse
                      : billingState === plan.name
                        ? copy.creating
                        : copy.choosePlan}
                  </Button>
                </div>
                {plan.features.length > 0 ? (
                  <div className="mt-3 flex flex-wrap gap-2">
                    {plan.features.slice(0, 4).map((feature) => (
                      <span
                        className="rounded-md bg-cloud px-2 py-1 text-xs font-bold text-ink"
                        key={feature}
                      >
                        {feature}
                      </span>
                    ))}
                  </div>
                ) : null}
              </div>
            )) : (
              <div className="rounded-lg border border-dashed border-lilac bg-white/70 p-5 text-sm font-medium text-slate">
                {copy.billingEmpty}
              </div>
            )}
          </div>
        </Card>

        <Card>
          <SectionTitle
            title={copy.historyTitle}
            copy={copy.historyCopy}
            action={<CreditCard className="h-5 w-5 text-violet" />}
          />
          <div className="mt-5">
            {settings.payments && settings.payments.length > 0 ? (
              <DataTable
                columns={[
                  copy.colPlan,
                  copy.colAmount,
                  copy.colOrderCode,
                  copy.colTxCode,
                  copy.colMethod,
                  copy.colDate,
                  copy.colStatus,
                ]}
                rows={settings.payments.map((payment) => {
                  let planTitle = payment.description || 'N/A';
                  if (planTitle.includes('Upgrade intent from dashboard to')) {
                    planTitle = planTitle.replace('Upgrade intent from dashboard to', '').trim();
                  } else if (planTitle.includes('Upgrade to')) {
                    planTitle = planTitle.replace('Upgrade to', '').trim();
                  }

                  let statusBadge = (
                    <span className="inline-flex rounded-full bg-slate-100 px-2 py-0.5 text-xs font-bold text-slate-600">
                      {payment.status}
                    </span>
                  );
                  if (payment.status === 'COMPLETED') {
                    statusBadge = (
                      <span className="inline-flex rounded-full bg-emerald-500/15 px-2 py-0.5 text-xs font-bold text-emerald-500">
                        {copy.statusSuccess}
                      </span>
                    );
                  } else if (payment.status === 'PENDING') {
                    statusBadge = (
                      <span className="inline-flex rounded-full bg-amber-500/15 px-2 py-0.5 text-xs font-bold text-amber-500 animate-pulse">
                        {copy.statusPending}
                      </span>
                    );
                  } else if (payment.status === 'FAILED') {
                    statusBadge = (
                      <span className="inline-flex rounded-full bg-red-500/15 px-2 py-0.5 text-xs font-bold text-red-500">
                        {copy.statusFailed}
                      </span>
                    );
                  }

                  return [
                    <span className="font-bold text-ink" key={`${payment.id}-plan`}>
                      {planTitle}
                    </span>,
                    <span className="font-semibold text-plum" key={`${payment.id}-amount`}>
                      {formatPlanPrice(payment.amount, payment.currency, locale)}
                    </span>,
                    <code className="text-xs text-slate-500" key={`${payment.id}-id`}>
                      {payment.id}
                    </code>,
                    <code className="text-xs text-violet font-bold" key={`${payment.id}-tx`}>
                      {payment.externalPaymentId || '—'}
                    </code>,
                    <span className="inline-flex rounded bg-violet/10 px-1.5 py-0.5 text-xs font-bold text-violet" key={`${payment.id}-provider`}>
                      {payment.provider}
                    </span>,
                    <span className="text-xs text-slate-500" key={`${payment.id}-date`}>
                      {payment.createdAt}
                    </span>,
                    <div key={`${payment.id}-status`}>{statusBadge}</div>,
                  ];
                })}
              />
            ) : (
              <div className="rounded-lg border border-dashed border-lilac bg-white/70 p-5 text-sm font-medium text-slate">
                {locale === 'en' ? 'No transactions found.' : 'Chưa có giao dịch nào được thực hiện.'}
              </div>
            )}
          </div>
        </Card>
      </div>
      </DashboardShell>
      {checkoutPlan ? (
        <CheckoutModal
          billingState={billingState}
          currentPlanName={settings.billing.planName}
          onClose={() => {
            setCheckoutPlan(null);
            setCheckoutResult(null);
          }}
          onConfirm={async () => {
            setBillingState(checkoutPlan.name);
            setCheckoutResult(null);
            try {
              const redirectOrigin = window.location.origin;
              const result = (await apiFetch('/billing/me/checkout-session', {
                method: 'POST',
                body: JSON.stringify({
                  planName: checkoutPlan.name,
                  provider: checkoutPlan.name === 'FREE' ? 'MANUAL' : 'SEPAY',
                  description: checkoutPlan.name === 'FREE' ? `Downgrade to ${checkoutPlan.title}` : `Upgrade intent from dashboard to ${checkoutPlan.title}`,
                  successUrl: `${redirectOrigin}/dashboard/settings?payment=success`,
                  errorUrl: `${redirectOrigin}/dashboard/settings?payment=error`,
                  cancelUrl: `${redirectOrigin}/dashboard/settings?payment=cancel`,
                }),
              })) as CheckoutResult;
              setCheckoutResult(result);

              // No external payment provider is wired yet, so settle the
              // pending payment through the manual confirmation endpoint to
              // actually activate the subscription instead of leaving it
              // PENDING forever.
              const paymentId = result.payment?.id;
              if ((!result.configured || checkoutPlan.name === 'FREE') && paymentId) {
                const activated = (await apiFetch(
                  `/billing/me/payments/${paymentId}/confirm`,
                  {
                    method: 'POST',
                    body: JSON.stringify({
                      planName: result.plan?.name ?? checkoutPlan.name,
                    }),
                  },
                )) as ConfirmResult;
                setCheckoutResult({
                  ...result,
                  payment: {
                    ...result.payment,
                    status: activated.payment?.status ?? result.payment?.status,
                  },
                  checkout: {
                    status: 'ACTIVATED',
                    note: copy.activatedNote(
                      activated.subscription?.planName ?? checkoutPlan.title,
                      activated.subscription?.status ?? 'ACTIVE',
                    ),
                  },
                });
                triggerRefresh();
                pushToast({
                  tone: 'success',
                  title: copy.activatedTitle(checkoutPlan.title),
                  message: copy.activatedMessage,
                });
              } else {
                triggerRefresh();
                pushToast({
                  tone: 'info',
                  title: copy.intentCreated(checkoutPlan.title),
                  message:
                    result.checkout?.note ??
                    copy.intentRecorded,
                });
              }
            } catch {
              pushToast({
                tone: 'error',
                title: copy.upgradeFailed,
                message: copy.upgradeFailedMessage,
              });
            } finally {
              setBillingState(null);
            }
          }}
          plan={checkoutPlan}
          result={checkoutResult}
        />
      ) : null}
    </>
  );
}

function SessionsPagination({
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

function QuickAddReminder({
  defaultTitle,
  onCreated,
}: {
  defaultTitle: string;
  onCreated: () => void;
}) {
  const pushToast = useUiStore((state) => state.pushToast);
  const { locale } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;
  const [time, setTime] = useState(() => {
    const d = new Date();
    d.setHours(d.getHours() + 1, 0, 0, 0);
    return `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
  });
  const [busy, setBusy] = useState(false);

  return (
    <div className="mt-3 flex flex-wrap items-end gap-3">
      <label className="flex-1 min-w-[120px]">
        <span className="text-xs font-semibold text-[var(--app-muted,theme(colors.slate))]">
          {copy.reminderTime}
        </span>
        <input
          className="mt-2 h-11 w-full rounded-lg border border-[var(--field-border)] bg-[var(--field-bg)] px-3 text-sm font-semibold text-[var(--app-text,theme(colors.ink))] outline-none"
          onChange={(event) => setTime(event.target.value)}
          type="time"
          value={time}
        />
      </label>
      <Button
        disabled={busy || !time}
        onClick={async () => {
          if (!time) return;
          setBusy(true);
          try {
            const [hh, mm] = time.split(':').map(Number);
            const scheduled = new Date();
            scheduled.setHours(hh ?? 9, mm ?? 0, 0, 0);
            if (scheduled.getTime() < Date.now()) {
              scheduled.setDate(scheduled.getDate() + 1);
            }
            await apiFetch('/reminders/me', {
              method: 'POST',
              body: JSON.stringify({
                title: defaultTitle,
                message: copy.quickAddMessage,
                type: 'BREATHING',
                scheduledAt: scheduled.toISOString(),
                isActive: true,
              }),
            });
            onCreated();
            pushToast({ tone: 'success', title: copy.quickAdded(time) });
          } catch {
            pushToast({ tone: 'error', title: copy.quickAddFailed });
          } finally {
            setBusy(false);
          }
        }}
        variant="secondary"
      >
        <Save className="h-4 w-4" />
        {busy ? copy.adding : copy.quickAdd}
      </Button>
    </div>
  );
}

function CheckoutModal({
  billingState,
  currentPlanName,
  onClose,
  onConfirm,
  plan,
  result,
}: {
  billingState: string | null;
  currentPlanName: string;
  onClose: () => void;
  onConfirm: () => Promise<void>;
  plan: BillingPlan;
  result: CheckoutResult | null;
}) {
  const { locale, t } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;
  const creating = billingState === plan.name;
  const currentPlan = currentPlanName === plan.name;
  const hasSepayCheckout =
    result?.provider === 'SEPAY' &&
    result?.checkout?.checkoutUrl &&
    result?.checkout?.checkoutFormfields;

  const isDowngradeToFree = currentPlanName !== 'FREE' && plan.name === 'FREE';

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-ink/55 p-4 backdrop-blur-sm sm:items-center">
      <div className="w-full max-w-xl rounded-2xl border border-[var(--panel-border)] bg-[var(--panel-strong)] p-5 text-[var(--app-text)] shadow-2xl">
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.18em] text-violet">
              {hasSepayCheckout ? '💳 SePay Payment' : 'Checkout intent'}
            </p>
            <h2 className="mt-2 text-2xl font-extrabold">{copy.checkoutTitle}</h2>
            <p className="mt-1 text-sm font-medium text-[var(--app-muted)]">
              {copy.checkoutCopy}
            </p>
          </div>
          <button
            aria-label={copy.closeCheckout}
            className="rounded-full border border-[var(--field-border)] p-2 text-[var(--app-text)] transition hover:bg-violet/10"
            onClick={onClose}
            type="button"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Plan summary card */}
        <div className="mt-5 rounded-xl border border-[var(--field-border)] bg-[var(--panel-bg)] p-4">
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <p className="text-xl font-extrabold">{plan.title}</p>
              <p className="mt-1 text-sm font-semibold text-violet">
                {formatPlanPrice(plan.price, plan.currency, locale)}
              </p>
            </div>
            <span className="rounded-full bg-cloud px-3 py-1 text-xs font-bold text-ink">
              {currentPlan ? copy.currentPlan : copy.upgradable}
            </span>
          </div>
          {plan.features.length > 0 ? (
            <div className="mt-4 flex flex-wrap gap-2">
              {plan.features.map((feature) => (
                <span
                  className="rounded-md border border-[var(--field-border)] px-2 py-1 text-xs font-bold"
                  key={feature}
                >
                  {feature}
                </span>
              ))}
            </div>
          ) : null}
        </div>

        {/* Downgrade warning */}
        {isDowngradeToFree && !result ? (
          <div className="mt-4 rounded-xl border border-coral/40 bg-coral/10 p-4">
            <div className="flex items-center gap-2">
              <div className="flex h-7 w-7 items-center justify-center rounded-full bg-coral/20">
                <span className="text-sm font-bold text-coral">⚠</span>
              </div>
              <p className="font-extrabold text-coral">
                {locale === 'en' ? 'Downgrade Plan Warning' : 'Cảnh báo hạ cấp gói cước'}
              </p>
            </div>
            <p className="mt-2 text-xs font-semibold leading-relaxed">
              {locale === 'en'
                ? 'Your account will be downgraded from your current paid plan to the Free plan. Advanced features (such as advanced analytics, custom companion, smart reminders) will be locked after downgrading.'
                : 'Tài khoản của anh sẽ bị hạ từ gói cước có trả phí hiện tại xuống gói Miễn phí. Các tính năng nâng cao (thống kê nâng cao, tùy chỉnh linh thú, reminder thông minh...) sẽ bị khóa sau khi hạ cấp.'}
            </p>
          </div>
        ) : null}

        {/* Result panel — with enhanced SePay checkout */}
        {result ? (
          <div className="mt-4 space-y-4">
            {/* Payment info summary */}
            <div className="rounded-xl border border-mint/40 bg-mint/10 p-4">
              <div className="flex items-center gap-2">
                <div className="flex h-7 w-7 items-center justify-center rounded-full bg-mint/20">
                  <span className="text-sm">✓</span>
                </div>
                <p className="font-extrabold text-mint">{copy.intentReady}</p>
              </div>
              <div className="mt-3 grid gap-2 text-sm font-semibold sm:grid-cols-2">
                <span className="flex items-center gap-1.5">
                  <span className="inline-block h-1.5 w-1.5 rounded-full bg-mint/60" />
                  Payment: <code className="text-xs">{result.payment?.id ? `${result.payment.id.slice(0, 12)}…` : '-'}</code>
                </span>
                <span className="flex items-center gap-1.5">
                  <span className={`inline-block h-1.5 w-1.5 rounded-full ${result.payment?.status === 'COMPLETED' ? 'bg-emerald-500' : result.payment?.status === 'PENDING' ? 'bg-amber-400 animate-pulse' : 'bg-slate'}`} />
                  Status: {result.payment?.status ?? '-'}
                </span>
                <span className="flex items-center gap-1.5">
                  <span className="inline-block h-1.5 w-1.5 rounded-full bg-violet/60" />
                  Provider: {result.provider ?? 'MANUAL'}
                </span>
                <span className="flex items-center gap-1.5">
                  <span className="inline-block h-1.5 w-1.5 rounded-full bg-violet/60" />
                  Amount:{' '}
                  {formatPlanPrice(
                    result.payment?.amount ?? plan.price,
                    result.payment?.currency ?? plan.currency,
                    locale,
                  )}
                </span>
              </div>
            </div>

            {/* SePay checkout form — prominent payment button */}
            {hasSepayCheckout ? (
              <div className="rounded-xl border-2 border-violet/30 bg-gradient-to-br from-violet/5 via-transparent to-violet/10 p-5">
                <div className="mb-4 text-center">
                  <p className="text-sm font-bold text-violet uppercase tracking-wider">Thanh toán an toàn qua SePay</p>
                  <p className="mt-2 text-3xl font-extrabold text-[var(--app-text)]">
                    {formatPlanPrice(
                      result.payment?.amount ?? plan.price,
                      result.payment?.currency ?? plan.currency,
                      locale,
                    )}
                  </p>
                  <p className="mt-1 text-xs font-medium text-[var(--app-muted)]">
                    Gói {plan.title} • Chuyển khoản ngân hàng
                  </p>
                </div>

                <form action={result.checkout!.checkoutUrl!} method="POST">
                  {Object.entries(result.checkout!.checkoutFormfields!).map(([key, value]) => (
                    <input key={key} type="hidden" name={key} value={value} />
                  ))}
                  <button
                    type="submit"
                    className="group relative w-full overflow-hidden rounded-xl bg-gradient-to-r from-violet to-plum px-6 py-4 text-white font-bold text-base shadow-lg transition-all duration-300 hover:shadow-xl hover:shadow-violet/25 hover:scale-[1.01] active:scale-[0.99]"
                  >
                    <span className="absolute inset-0 bg-white/10 opacity-0 transition-opacity group-hover:opacity-100" />
                    <span className="relative flex items-center justify-center gap-3">
                      <CreditCard className="h-5 w-5" />
                      <span>Thanh toán ngay qua SePay</span>
                      <span className="text-xs opacity-75">→</span>
                    </span>
                  </button>
                </form>

                <div className="mt-3 flex items-center justify-center gap-1.5 text-xs font-medium text-[var(--app-muted)]">
                  <svg className="h-3.5 w-3.5" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
                  </svg>
                  <span>Bảo mật bởi SePay Payment Gateway</span>
                </div>
              </div>
            ) : (
              <p className="text-sm font-medium text-[var(--app-muted)]">
                {result.checkout?.note ?? copy.paymentPendingNote}
              </p>
            )}
          </div>
        ) : null}

        <div className="mt-5 flex flex-wrap justify-end gap-3">
          <Button onClick={onClose} type="button" variant="secondary">
            {t('common.close')}
          </Button>
          {!hasSepayCheckout && (
            <Button
              disabled={creating || currentPlan}
              onClick={async () => {
                if (isDowngradeToFree) {
                  const msg = locale === 'en'
                    ? 'Are you sure you want to downgrade to the Free plan?'
                    : 'Anh có chắc chắn đồng ý hạ xuống gói cước Miễn phí không?';
                  const confirmed = window.confirm(msg);
                  if (!confirmed) {
                    return;
                  }
                }
                await onConfirm();
              }}
              type="button"
            >
              <CreditCard className="h-4 w-4" />
              {creating
                ? copy.creatingIntent
                : currentPlan
                  ? copy.inUse
                  : isDowngradeToFree
                    ? (locale === 'en' ? 'Confirm Downgrade' : 'Xác nhận hạ cấp')
                    : copy.createCheckout}
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}

function Field({
  label,
  value,
  type = 'text',
  onChange,
  select = false,
  options = [],
}: {
  label: string;
  value: string;
  type?: string;
  onChange?: (value: string) => void;
  select?: boolean;
  options?: string[];
}) {
  return (
    <label>
      <span className="text-sm font-semibold text-slate">{label}</span>
      {select ? (
        <select
          className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
          onChange={(event) => onChange?.(event.target.value)}
          value={value}
        >
          {options.map((option) => (
            <option key={option} value={option}>
              {option}
            </option>
          ))}
        </select>
      ) : (
        <input
          className="mt-2 h-11 w-full rounded-lg border border-lilac bg-white/85 px-3 text-sm font-semibold text-ink outline-none focus:border-violet"
          onChange={(event) => onChange?.(event.target.value)}
          readOnly={!onChange}
          type={type}
          value={value}
        />
      )}
    </label>
  );
}

function ToggleCard({
  checked,
  icon: Icon,
  label,
  onClick,
}: {
  checked: boolean;
  icon: LucideIcon;
  label: string;
  onClick: () => void;
}) {
  return (
    <button
      className={`rounded-lg border p-4 text-left transition ${
        checked
          ? 'border-violet bg-violet text-white'
          : 'border-lilac/70 bg-white/75 text-ink'
      }`}
      onClick={onClick}
      type="button"
    >
      <Icon className="h-5 w-5" />
      <p className="mt-4 font-bold">{label}</p>
      <p
        className={`mt-1 text-xs font-semibold ${
          checked ? 'text-white/70' : 'text-slate'
        }`}
      >
        {checked ? 'Enabled' : 'Disabled'}
      </p>
    </button>
  );
}

function DerivedCard({
  icon: Icon,
  label,
  note,
  value,
}: {
  icon: LucideIcon;
  label: string;
  note: string;
  value: string;
}) {
  return (
    <div className="rounded-lg border border-lilac/70 bg-white/75 p-4">
      <Icon className="h-5 w-5 text-violet" />
      <p className="mt-4 text-sm font-semibold text-slate">{label}</p>
      <p className="mt-1 text-xl font-extrabold text-ink">{value}</p>
      <p className="mt-1 text-xs font-medium text-plum">{note}</p>
    </div>
  );
}

function StatusMiniCard({
  title,
  value,
  note,
}: {
  title: string;
  value: string;
  note: string;
}) {
  return (
    <div className="rounded-lg border border-lilac/70 bg-white/75 p-4">
      <p className="text-xs font-semibold uppercase tracking-[0.14em] text-slate">
        {title}
      </p>
      <p className="mt-2 text-sm font-extrabold text-ink">{value}</p>
      <p className="mt-1 text-xs font-medium text-plum">{note}</p>
    </div>
  );
}

function CompanionAssetCard({
  asset,
  selected,
  onSelect,
}: {
  asset: CompanionAsset;
  selected: boolean;
  onSelect: () => void;
}) {
  const { locale } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;

  return (
    <button
      className={`overflow-hidden rounded-xl border text-left transition ${
        selected
          ? 'border-violet bg-violet/5 shadow-panel'
          : 'border-lilac/70 bg-white/75 hover:border-violet'
      }`}
      onClick={onSelect}
      type="button"
    >
      <div
        className="h-28 w-full"
        style={{ background: asset.secondaryColor || 'rgba(255,255,255,0.72)' }}
      >
        {asset.previewImageUrl ? (
          <SafeCompanionImage
            alt={asset.name}
            className="h-full w-full object-cover"
            src={asset.previewImageUrl}
          />
        ) : null}
      </div>
      <div className="p-4">
        <p className="font-extrabold text-ink">{asset.name}</p>
        <p className="mt-1 text-sm text-slate">
          {asset.description || copy.assetFallbackDescription}
        </p>
      </div>
    </button>
  );
}

function SafeCompanionImage({
  alt,
  className,
  src,
}: {
  alt: string;
  className: string;
  src: string;
}) {
  const { locale } = useTranslation();
  const copy = locale === 'en' ? EN_SETTINGS_COPY : VI_SETTINGS_COPY;
  const [failed, setFailed] = useState(false);

  if (failed) {
    return (
      <div
        className={`${className} flex items-center justify-center bg-violet/10 text-xs font-bold text-violet`}
      >
        {copy.previewLoadFailed}
      </div>
    );
  }

  return (
    // eslint-disable-next-line @next/next/no-img-element
    <img
      alt={alt}
      className={className}
      onError={() => setFailed(true)}
      referrerPolicy="no-referrer"
      src={src}
    />
  );
}

function normalizeBirthdayValue(value: string) {
  if (!value || value === '-') {
    return '';
  }

  // Already YYYY-MM-DD — accept as-is so the date input keeps it.
  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return value;
  }

  // vi-VN locale string "DD/MM/YYYY" — what live-dashboard.formatDate
  // happens to spit out. Parse the parts directly so we don't fall into
  // `new Date("10/3/2003")` which JS interprets as MM/DD/YYYY (US) and
  // would swap day↔month.
  const localeMatch = value.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (localeMatch) {
    const [, day, month, year] = localeMatch;
    return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
  }

  // ISO with time (e.g. "2003-03-10T00:00:00Z"). Use UTC parts so a VN
  // +07 browser doesn't roll back/forward a day.
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return '';
  }
  const year = parsed.getUTCFullYear();
  const month = String(parsed.getUTCMonth() + 1).padStart(2, '0');
  const day = String(parsed.getUTCDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function nextLocalReminderTime() {
  const date = new Date();
  date.setHours(date.getHours() + 1, 0, 0, 0);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hour = String(date.getHours()).padStart(2, '0');
  const minute = String(date.getMinutes()).padStart(2, '0');
  return `${year}-${month}-${day}T${hour}:${minute}`;
}

function formatPlanPrice(price: number, currency: string, locale: 'vi' | 'en') {
  if (price <= 0) {
    return locale === 'en' ? EN_SETTINGS_COPY.free : VI_SETTINGS_COPY.free;
  }

  const intlLocale = locale === 'en' ? 'en-US' : 'vi-VN';
  try {
    return new Intl.NumberFormat(intlLocale, {
      style: 'currency',
      currency,
      maximumFractionDigits: 0,
    }).format(price);
  } catch {
    return `${new Intl.NumberFormat(intlLocale, {
      maximumFractionDigits: 0,
    }).format(price)} ${currency}`;
  }
}

function toDashboardThemeMode(mode: ThemeMode): DashboardThemeMode {
  return mode.toLowerCase() as DashboardThemeMode;
}

function dispatchDashboardTheme(
  mode: ThemeMode,
  palette: DashboardThemePalette | null,
) {
  const dashboardMode = toDashboardThemeMode(mode);
  applyDashboardTheme(dashboardMode, palette);
  window.dispatchEvent(
    new CustomEvent(DASHBOARD_THEME_APPLIED_EVENT, {
      detail: {
        mode: dashboardMode,
        palette,
      },
    }),
  );
}

function modeLabel(mode: CompanionMode, copy: typeof VI_SETTINGS_COPY) {
  if (mode === 'ZODIAC') return copy.modeZodiac;
  if (mode === 'CHINESE_ZODIAC') return copy.modeChineseZodiac;
  if (mode === 'CUSTOM') return copy.modeCustom;
  return copy.modeDefault;
}

function companionOptionLabel(
  option: CompanionOptionGroup,
  copy: typeof VI_SETTINGS_COPY,
) {
  return modeLabel(option.mode, copy);
}
