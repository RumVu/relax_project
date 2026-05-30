/**
 * Tiếng Việt là ngôn ngữ mặc định (KHÔNG viết tắt, KHÔNG chêm tiếng Anh).
 * English là ngôn ngữ thứ hai.
 *
 * Quy ước key: namespace.path.in.dot (ví dụ `nav.overview`,
 * `accountMenu.logout`). Một key mới phải có cả 2 ngôn ngữ — TypeScript
 * sẽ chặn build nếu thiếu (xem type `Locale` & `Dictionary`).
 *
 * Placeholder {{name}} được hỗ trợ qua hàm `t(key, { name })`.
 */

export type Locale = 'vi' | 'en';
export const LOCALES: Locale[] = ['vi', 'en'];
export const DEFAULT_LOCALE: Locale = 'vi';

export const LOCALE_LABELS: Record<Locale, string> = {
  vi: 'Tiếng Việt',
  en: 'English',
};

export const LOCALE_SHORT: Record<Locale, string> = {
  vi: 'VI',
  en: 'EN',
};

const vi = {
  // ===== Common =====
  'common.loading': 'Đang tải…',
  'common.refresh': 'Làm mới',
  'common.close': 'Đóng',
  'common.cancel': 'Huỷ',
  'common.confirm': 'Xác nhận',
  'common.save': 'Lưu',
  'common.copy': 'Sao chép',
  'common.copied': 'Đã sao chép {{label}}',
  'common.unknown': 'Không xác định',
  'common.you': 'bạn',
  'common.notSupported': 'Trình duyệt không hỗ trợ',

  // ===== Navigation =====
  'nav.overview': 'Tổng quan',
  'nav.mood': 'Cảm xúc',
  'nav.breaks': 'Nghỉ ngơi',
  'nav.journal': 'Nhật ký',
  'nav.analytics': 'Phân tích',
  'nav.weather': 'Thời tiết',
  'nav.settings': 'Cài đặt',
  'nav.adminHome': 'Trang quản trị',
  'nav.users': 'Người dùng',
  'nav.search': 'Tìm kiếm',
  'nav.logs': 'Nhật ký hệ thống',
  'nav.quotes': 'Câu trích dẫn',
  'nav.sounds': 'Âm thanh',
  'nav.exercises': 'Bài tập hít thở',
  'nav.themes': 'Giao diện',
  'nav.onboarding': 'Hướng dẫn ban đầu',
  'nav.companionAssets': 'Tài nguyên người bạn đồng hành',
  'nav.companionMessages': 'Tin nhắn người bạn đồng hành',

  // ===== Brand / Shell =====
  'brand.cozyControl': 'Bảng điều khiển thư giãn',
  'brand.adminConsole': 'Bảng điều khiển quản trị',
  'brand.tagline': 'Nghỉ thư giãn',
  'shell.openMenu': 'Mở thực đơn',
  'shell.closeMenu': 'Đóng thực đơn',
  'shell.notifications.count': '{{count}} thông báo',
  'shell.notifications.recent': 'Thông báo gần đây',
  'shell.notifications.unread': '{{count}} chưa đọc',
  'shell.notifications.readAll': 'Đánh dấu đã đọc',
  'shell.notifications.empty': 'Chưa có thông báo mới.',
  'shell.notifications.markedRead': 'Đã đánh dấu đã đọc',
  'shell.notifications.markFailed': 'Không đánh dấu được thông báo',
  'shell.notifications.openFailed': 'Không mở được thông báo',
  'shell.realtime.connected': 'Trực tuyến đã kết nối',
  'shell.realtime.disconnected': 'Trực tuyến mất kết nối',
  'shell.refresh.title': 'Đang làm mới dữ liệu',
  'shell.refresh.message': 'Bảng điều khiển sẽ tải lại dữ liệu trực tuyến.',
  'shell.focus.on': 'Đã bật chế độ tập trung',
  'shell.focus.off': 'Đã tắt chế độ tập trung',
  'shell.focus.onMessage': 'Giảm xao nhãng để tập trung thư giãn.',
  'shell.focus.offMessage': 'Giao diện đã trở lại bình thường.',
  'shell.focus.label': 'Tập trung',
  'shell.reminder.fallbackLabel': 'Nhắc nhở buổi tối',

  // ===== Account menu =====
  'account.profile': 'Quản lý hồ sơ',
  'account.profile.hint': 'Tên, ảnh đại diện, mật khẩu',
  'account.sessions': 'Lịch sử đăng nhập',
  'account.sessions.hint': 'Thiết bị, địa chỉ IP, trình duyệt',
  'account.adminConsole': 'Vào trang quản trị',
  'account.adminConsole.hint': 'Quản trị hệ thống',
  'account.language': 'Ngôn ngữ',
  'account.language.hint': 'Tiếng Việt / Tiếng Anh',
  'account.logout': 'Đăng xuất',
  'account.logout.hint': 'Kết thúc phiên này',
  'account.loggingOut': 'Đang đăng xuất…',
  'account.loggedOut': 'Đã đăng xuất',
  'account.role.admin': 'Quản trị viên',
  'account.role.user': 'Người dùng',
  'account.you': 'Bạn',

  // ===== Sessions modal =====
  'sessions.title': 'Lịch sử đăng nhập',
  'sessions.description': 'Thiết bị hiện tại và các phiên đã đăng nhập vào tài khoản của bạn.',
  'sessions.current.heading': 'Thiết bị hiện tại',
  'sessions.list.heading': 'Tất cả phiên đăng nhập',
  'sessions.list.empty': 'Chưa có phiên nào.',
  'sessions.loading': 'Đang tải…',
  'sessions.loadFailed': 'Không tải được phiên đăng nhập.',
  'sessions.currentBadge': 'Phiên này',
  'sessions.loginAt': 'Đăng nhập lúc {{when}}',
  'sessions.field.device': 'Thiết bị',
  'sessions.field.os': 'Hệ điều hành',
  'sessions.field.browser': 'Trình duyệt',
  'sessions.field.clientHints': 'Gợi ý từ trình duyệt',
  'sessions.field.ip': 'Địa chỉ IP',
  'sessions.field.loginTime': 'Đăng nhập',
  'sessions.field.expires': 'Hết hạn',
  'sessions.userAgent': 'Chuỗi nhận dạng trình duyệt',
  'sessions.copyUserAgent': 'Sao chép chuỗi trình duyệt',
  'sessions.copy.label': 'chuỗi nhận dạng trình duyệt',
  'sessions.clipboard.denied': 'Trình duyệt từ chối quyền sao chép',
  'sessions.deviceType.desktop': 'Máy tính để bàn',
  'sessions.deviceType.mobile': 'Điện thoại',
  'sessions.deviceType.tablet': 'Máy tính bảng',
  'sessions.deviceType.other': 'Thiết bị khác',
  'sessions.runningOn': 'Đang chạy trên',

  // ===== Auth =====
  'auth.welcomeBack': 'Chào mừng trở lại',
  'auth.signIn.title': 'Đăng nhập bảng điều khiển',
  'auth.signUp.title': 'Tạo tài khoản mới',
  'auth.signUp.subtitle': 'Bắt đầu hành trình thư giãn của bạn.',
  'auth.email': 'Địa chỉ thư điện tử',
  'auth.password': 'Mật khẩu',
  'auth.login': 'Đăng nhập',
  'auth.register': 'Đăng ký',
  'auth.or': 'Hoặc',
  'auth.noAccount': 'Chưa có tài khoản?',
  'auth.haveAccount': 'Đã có tài khoản?',
  'auth.createOne': 'Tạo tài khoản',
  'auth.signIn': 'Đăng nhập tại đây',
  'auth.google.notConfigured': 'Đăng nhập bằng Google chưa được bật. Cần đặt {{key}} rồi xây dựng lại trang web.',
  'auth.google.success': 'Đã đăng nhập bằng Google',
  'auth.google.failed': 'Đăng nhập bằng Google không thành công',
  'auth.google.serverDenied': 'Máy chủ không chấp nhận mã thông báo của Google.',
  'auth.signingIn': 'Đang đăng nhập…',

  // ===== Roles =====
  'role.admin': 'Quản trị viên',
  'role.user': 'Người dùng',
} as const;

const en: Record<keyof typeof vi, string> = {
  // ===== Common =====
  'common.loading': 'Loading…',
  'common.refresh': 'Refresh',
  'common.close': 'Close',
  'common.cancel': 'Cancel',
  'common.confirm': 'Confirm',
  'common.save': 'Save',
  'common.copy': 'Copy',
  'common.copied': 'Copied {{label}}',
  'common.unknown': 'Unknown',
  'common.you': 'you',
  'common.notSupported': 'Browser not supported',

  // ===== Navigation =====
  'nav.overview': 'Overview',
  'nav.mood': 'Mood',
  'nav.breaks': 'Breaks',
  'nav.journal': 'Journal',
  'nav.analytics': 'Analytics',
  'nav.weather': 'Weather',
  'nav.settings': 'Settings',
  'nav.adminHome': 'Admin Home',
  'nav.users': 'Users',
  'nav.search': 'Search',
  'nav.logs': 'Logs',
  'nav.quotes': 'Quotes',
  'nav.sounds': 'Sounds',
  'nav.exercises': 'Breathing exercises',
  'nav.themes': 'Themes',
  'nav.onboarding': 'Onboarding',
  'nav.companionAssets': 'Companion assets',
  'nav.companionMessages': 'Companion messages',

  // ===== Brand / Shell =====
  'brand.cozyControl': 'Cozy Control',
  'brand.adminConsole': 'Admin Console',
  'brand.tagline': 'Digital Break',
  'shell.openMenu': 'Open menu',
  'shell.closeMenu': 'Close menu',
  'shell.notifications.count': '{{count}} notifications',
  'shell.notifications.recent': 'Recent notifications',
  'shell.notifications.unread': '{{count}} unread',
  'shell.notifications.readAll': 'Mark all read',
  'shell.notifications.empty': 'No new notifications.',
  'shell.notifications.markedRead': 'Marked as read',
  'shell.notifications.markFailed': 'Could not mark notifications',
  'shell.notifications.openFailed': 'Could not open notification',
  'shell.realtime.connected': 'Realtime connected',
  'shell.realtime.disconnected': 'Realtime disconnected',
  'shell.refresh.title': 'Refreshing data',
  'shell.refresh.message': 'Dashboard will refetch live data.',
  'shell.focus.on': 'Focus mode on',
  'shell.focus.off': 'Focus mode off',
  'shell.focus.onMessage': 'Distractions dimmed so you can unwind.',
  'shell.focus.offMessage': 'Back to the normal layout.',
  'shell.focus.label': 'Focus',
  'shell.reminder.fallbackLabel': 'Evening reminder',

  // ===== Account menu =====
  'account.profile': 'Manage profile',
  'account.profile.hint': 'Name, avatar, password',
  'account.sessions': 'Login history',
  'account.sessions.hint': 'Devices, IP, browser',
  'account.adminConsole': 'Open admin console',
  'account.adminConsole.hint': 'System administration',
  'account.language': 'Language',
  'account.language.hint': 'Vietnamese / English',
  'account.logout': 'Sign out',
  'account.logout.hint': 'End this session',
  'account.loggingOut': 'Signing out…',
  'account.loggedOut': 'Signed out',
  'account.role.admin': 'Admin',
  'account.role.user': 'User',
  'account.you': 'You',

  // ===== Sessions modal =====
  'sessions.title': 'Login history',
  'sessions.description': 'The current device and all sessions signed in to your account.',
  'sessions.current.heading': 'Current device',
  'sessions.list.heading': 'All sessions',
  'sessions.list.empty': 'No sessions yet.',
  'sessions.loading': 'Loading…',
  'sessions.loadFailed': 'Could not load sessions.',
  'sessions.currentBadge': 'This session',
  'sessions.loginAt': 'Signed in at {{when}}',
  'sessions.field.device': 'Device',
  'sessions.field.os': 'Operating system',
  'sessions.field.browser': 'Browser',
  'sessions.field.clientHints': 'Client hints',
  'sessions.field.ip': 'IP address',
  'sessions.field.loginTime': 'Signed in',
  'sessions.field.expires': 'Expires',
  'sessions.userAgent': 'User-Agent string',
  'sessions.copyUserAgent': 'Copy user agent',
  'sessions.copy.label': 'user agent',
  'sessions.clipboard.denied': 'Browser refused clipboard access',
  'sessions.deviceType.desktop': 'Desktop',
  'sessions.deviceType.mobile': 'Mobile',
  'sessions.deviceType.tablet': 'Tablet',
  'sessions.deviceType.other': 'Other device',
  'sessions.runningOn': 'Running on',

  // ===== Auth =====
  'auth.welcomeBack': 'Welcome back',
  'auth.signIn.title': 'Sign in to the recovery dashboard',
  'auth.signUp.title': 'Create a new account',
  'auth.signUp.subtitle': 'Start your relaxation journey.',
  'auth.email': 'Email',
  'auth.password': 'Password',
  'auth.login': 'Sign in',
  'auth.register': 'Sign up',
  'auth.or': 'or',
  'auth.noAccount': 'No account yet?',
  'auth.haveAccount': 'Already have an account?',
  'auth.createOne': 'Create one',
  'auth.signIn': 'Sign in here',
  'auth.google.notConfigured': 'Google sign-in is disabled. Set {{key}} and rebuild the web app.',
  'auth.google.success': 'Signed in with Google',
  'auth.google.failed': 'Google sign-in failed',
  'auth.google.serverDenied': 'Server did not accept the Google token.',
  'auth.signingIn': 'Signing in…',

  // ===== Roles =====
  'role.admin': 'Admin',
  'role.user': 'User',
};

export type TranslationKey = keyof typeof vi;
export type Dictionary = Record<TranslationKey, string>;

export const DICTIONARIES: Record<Locale, Dictionary> = {
  vi,
  en,
};
