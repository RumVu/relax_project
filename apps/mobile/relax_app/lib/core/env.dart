/// Cấu hình môi trường runtime — đọc từ `--dart-define` lúc build/run.
///
/// Chạy local:
///   flutter run --dart-define=API_BASE=http://localhost:6823/v1
///
/// Chạy LAN emulator:
///   flutter run --dart-define=API_BASE=http://192.168.x.x:6823/v1
///
/// Production (mặc định nếu không truyền gì):
///   flutter run
///   → dùng https://backend-production-b8a5f.up.railway.app/v1
class Env {
  Env._();

  /// API base URL — override bằng `--dart-define=API_BASE=...`
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://backend-production-b8a5f.up.railway.app/v1',
  );

  /// Google Server Client ID (Web Client ID) for Google Sign-In
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '884741112800-aq6rsskn13eiv1r3f3e5qbttlj82skcs.apps.googleusercontent.com',
  );
}
