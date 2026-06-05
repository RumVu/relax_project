import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Quản lý ngôn ngữ hiển thị của app (Tiếng Việt / English), lưu vào secure
/// storage và phát ChangeNotifier khi đổi.
class LocaleController extends ChangeNotifier {
  LocaleController() {
    _restore();
  }

  static const _key = 'relax_locale';
  final _storage = const FlutterSecureStorage();

  String _code = 'vi';
  String get code => _code;
  Locale get locale => Locale(_code);

  Future<void> _restore() async {
    final saved = await _storage.read(key: _key);
    if (saved == 'en' || saved == 'vi') {
      _code = saved!;
      notifyListeners();
    }
  }

  Future<void> set(String code) async {
    if (code != 'vi' && code != 'en') return;
    _code = code;
    notifyListeners();
    await _storage.write(key: _key, value: code);
  }
}

/// Bảng dịch toàn cục — key tiếng Việt → bản dịch theo locale.
/// Cách dùng: `context.t('Đăng nhập')` ở bất kỳ widget nào có context.
class Translations {
  static const _en = <String, String>{
    // Common
    'Đăng nhập': 'Log in',
    'Đăng ký': 'Sign up',
    'Đăng xuất': 'Log out',
    'Hủy': 'Cancel',
    'Hủy bỏ': 'Cancel',
    'Lưu': 'Save',
    'Tiếp tục': 'Continue',
    'Quay lại': 'Back',
    'Email': 'Email',
    'Mật khẩu': 'Password',
    'Tên hiển thị': 'Display name',

    // Settings sections
    'Setup ✨': 'Setup ✨',
    'Thông báo': 'Notifications',
    'Khám phá': 'Discover',
    'Thiết bị & vị trí': 'Device & location',
    'Quy định & sử dụng': 'Terms & usage',
    'Thống kê tình trạng': 'Wellness stats',
    'Giao diện': 'Appearance',
    'Nạp thẻ / Nâng cấp': 'Top-up / Upgrade',
    'Tài khoản': 'Account',
    'Ngôn ngữ': 'Language',

    // Settings rows
    'Phân tích cảm xúc': 'Mood analytics',
    'Biểu đồ & phân bố cảm xúc của bạn': 'Charts & mood distribution',
    'Thời tiết': 'Weather',
    'Theo dõi thời tiết & dự báo': 'Track weather & forecast',
    'Linh thú': 'Companion',
    'Nuôi và tương tác với bạn đồng hành': 'Raise and chat with your companion',
    'Vị trí của bạn': 'Your location',
    'Gợi ý thời tiết & địa điểm thư giãn gần bạn':
        'Weather & nearby relax spots suggestions',
    'Thông tin thiết bị': 'Device info',
    'Model, hệ điều hành, phiên bản app': 'Model, OS, app version',
    'Điều khoản, bản quyền & giấy phép': 'Terms, copyright & licenses',
    'Đọc trước khi sử dụng': 'Read before using',
    'Giới thiệu': 'About',
    'Phiên bản 1.0.0': 'Version 1.0.0',
    'Mở khóa tính năng nâng cao': 'Unlock advanced features',
    'Phân tích sâu, companion theo cung & con giáp':
        'Deep insights, zodiac-based companion',
    'Nạp ngay': 'Top up',
    'Xóa tài khoản': 'Delete account',
    'Xóa vĩnh viễn toàn bộ dữ liệu của bạn':
        'Permanently erase all your data',
    'Màu nhấn': 'Accent color',
    'Chọn tông gần với cảm xúc bạn đang muốn nuôi dưỡng':
        'Pick a tone close to how you want to feel',

    // Home
    'Đã trở lại rồi nè ~': 'Welcome back ~',
    'Chúc bạn một ngày nhẹ nhàng.': 'Wishing you a gentle day.',
    'bạn': 'friend',

    // Billing
    'Mở khóa Chill Plus 💜': 'Unlock Chill Plus 💜',
    'Đang dùng': 'Current',

    // Misc
    'Đang lấy vị trí…': 'Getting location…',
    'Lấy vị trí hiện tại': 'Get current location',
    'Lưu vào hồ sơ': 'Save to profile',
    'Vị trí của bạn — gần ngay đây':
        'Your location — right here',
  };

  static String t(String key, String lang) {
    if (lang == 'en') return _en[key] ?? key;
    return key; // vi là nguồn → trả nguyên
  }
}

/// Extension nhỏ để gọi `context.t('...')` gọn gàng.
/// Phải có `LocaleController` provider phía trên cây widget.
extension TranslateX on BuildContext {
  String t(String key) {
    // Tránh import provider ở mọi file — dùng InheritedNotifier qua lookup
    // bằng cách đọc element tree. Caller phải watch LocaleController ở
    // build() nếu muốn rebuild khi đổi ngôn ngữ.
    return Translations.t(key, _LocaleScope.of(this));
  }
}

/// InheritedWidget mỏng để truyền lang code xuống dưới mà không cần Provider
/// import — đặt ở gốc cây bởi `LocaleScope`.
class LocaleScope extends InheritedWidget {
  const LocaleScope({super.key, required this.lang, required super.child});
  final String lang;

  static String of(BuildContext c) {
    final s = c.dependOnInheritedWidgetOfExactType<LocaleScope>();
    return s?.lang ?? 'vi';
  }

  @override
  bool updateShouldNotify(LocaleScope old) => old.lang != lang;
}

class _LocaleScope {
  static String of(BuildContext c) => LocaleScope.of(c);
}
