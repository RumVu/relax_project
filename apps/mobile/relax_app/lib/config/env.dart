part of 'package:relax_app/main.dart';

/// Cấu hình build-time đọc qua `String.fromEnvironment` — giá trị truyền vào
/// khi build/run bằng `--dart-define=KEY=VALUE` hoặc `--dart-define-from-file=.env`.
///
/// Xem file `.env.example` ở root mobile app để biết danh sách biến.
///
/// Quy ước: không hardcode secret thật ở đây. Default chỉ để dev local boot
/// được — production phải truyền qua CI/CD.
class Env {
  const Env._();

  /// Backend Nest URL (đã có `/v1`). Không kèm trailing slash.
  static const String apiUrl = String.fromEnvironment(
    'RELAX_API_URL',
    defaultValue: 'https://relax-backend.tail3e0c74.ts.net/v1',
  );

  /// Supabase project URL — dùng cho direct file upload (avatar, journal media).
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anon public key.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// SePay redirect base — backend sẽ thêm `?status=success|cancel|error`.
  static const String sepayReturnUrl = String.fromEnvironment(
    'SEPAY_RETURN_URL',
    defaultValue: 'https://app.relax.dev/billing',
  );

  /// Flavor: 'dev' | 'staging' | 'prod' — để log + ẩn/hiện banner debug.
  static const String flavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'dev',
  );

  /// True khi build dev → bật banner trên cùng + log verbose.
  static bool get isDev => flavor != 'prod';

  /// True khi đã cấu hình Supabase đủ (URL + anon key).
  static bool get supabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Một map gọn để dump ra log khi debug — không in secret nguyên dạng.
  static Map<String, String> summary() => {
        'apiUrl': apiUrl,
        'supabaseUrl': supabaseUrl.isEmpty ? '<unset>' : supabaseUrl,
        'supabaseAnonKey': supabaseAnonKey.isEmpty
            ? '<unset>'
            : '${supabaseAnonKey.substring(0, 6)}…',
        'sepayReturnUrl': sepayReturnUrl,
        'flavor': flavor,
      };
}
