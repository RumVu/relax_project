import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/services/auth_service.dart';

/// Lưu access/refresh token + user profile vào Keychain (iOS) / Keystore
/// (Android). Mọi đọc/ghi đều async vì secure storage là plug-in native.
///
/// Bao bọc bởi [SessionState] (ChangeNotifier) để UI rebuild khi đăng nhập /
/// đăng xuất / refresh.
class SecureSession {
  SecureSession({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessKey = 'relax_access_token';
  static const _refreshKey = 'relax_refresh_token';
  static const _userKey = 'relax_user_json';

  Future<String?> readAccess() => _storage.read(key: _accessKey);
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);

  Future<void> writeTokens({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // corrupted JSON → bỏ qua, coi như chưa login.
    }
    return null;
  }

  Future<void> writeUser(Map<String, dynamic> user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userKey);
  }
}

/// InheritedWidget mỏng để widget bất kỳ đọc [SessionState] qua
/// `context.session` mà không cần Provider/Riverpod.
class SessionScope extends InheritedNotifier<SessionState> {
  const SessionScope({
    super.key,
    required SessionState session,
    required super.child,
  }) : super(notifier: session);

  static SessionState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SessionScope>()?.notifier;

  static SessionState of(BuildContext context) {
    final session = maybeOf(context);
    assert(session != null, 'SessionScope chưa được mount ở trên cây widget.');
    return session!;
  }
}

extension SessionContextX on BuildContext {
  SessionState get session => SessionScope.of(this);
  SessionState? get sessionOrNull => SessionScope.maybeOf(this);
}

/// State global cho phiên đăng nhập — UI watch để rebuild khi user đổi.
/// Không dùng provider/riverpod để giữ codebase thuần stdlib.
class SessionState extends ChangeNotifier {
  SessionState({SecureSession? storage, AuthService? auth})
    : _storage = storage ?? SecureSession(),
      _auth = auth ?? AuthService() {
    _bootstrap();
  }

  final SecureSession _storage;
  final AuthService _auth;

  Map<String, dynamic>? _user;
  String? _access;
  String? _refresh;
  bool _booting = true;

  Map<String, dynamic>? get user => _user;
  String? get accessToken => _access;
  bool get isLoggedIn => _access != null && _user != null;
  bool get isBooting => _booting;

  /// Đọc token đã lưu lúc app khởi động — nếu còn token thì gọi /me xác minh.
  Future<void> _bootstrap() async {
    try {
      _access = await _storage.readAccess();
      _refresh = await _storage.readRefresh();
      _user = await _storage.readUser();
      if (_access != null) {
        // Best-effort refresh user — nếu lỗi, vẫn giữ cache cũ để app boot
        // được offline.
        try {
          final fresh = await _auth.fetchMe(_access!);
          _user = fresh;
          await _storage.writeUser(fresh);
        } catch (_) {
          // ignore — sẽ retry lúc gọi API thật.
        }
      }
    } finally {
      _booting = false;
      notifyListeners();
    }
  }

  /// Lưu kết quả sau login/register thành công.
  Future<void> apply({
    required String access,
    required String refresh,
    required Map<String, dynamic> user,
  }) async {
    _access = access;
    _refresh = refresh;
    _user = user;
    await _storage.writeTokens(access: access, refresh: refresh);
    await _storage.writeUser(user);
    notifyListeners();
  }

  Future<void> updateCachedUser(Map<String, dynamic> patch) async {
    final current = _user ?? <String, dynamic>{};
    final next = {...current, ...patch};
    _user = next;
    await _storage.writeUser(next);
    notifyListeners();
  }

  /// Quay lại trạng thái chưa đăng nhập.
  Future<void> logout() async {
    _access = null;
    _refresh = null;
    _user = null;
    await _storage.clear();
    notifyListeners();
  }

  /// Gọi refresh token endpoint khi 401. Trả `true` nếu refresh ok.
  Future<bool> tryRefresh() async {
    final r = _refresh;
    if (r == null) return false;
    try {
      final result = await _auth.refresh(r);
      _access = result.accessToken;
      _refresh = result.refreshToken;
      await _storage.writeTokens(
        access: result.accessToken,
        refresh: result.refreshToken,
      );
      notifyListeners();
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }
}
