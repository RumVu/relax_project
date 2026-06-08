import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';
import 'device_registration.dart';

/// State giữ thông tin user đăng nhập + giúp các màn hình
/// gọi login/register/logout mà không phải tự call API trực tiếp.
class AuthState extends ChangeNotifier {
  AuthState() {
    _bootstrap();
  }

  Map<String, dynamic>? _user;
  bool _checking = true;
  // Mặc định FALSE — đảm bảo user mới install (storage chưa có key)
  // sẽ được dẫn vào onboarding. Sau khi _bootstrap đọc storage, giá
  // trị này sẽ overwrite chính xác.
  bool _onboardingSeen = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get checking => _checking;
  bool get isLoggedIn => _user != null;
  bool get onboardingSeen => _onboardingSeen;
  String? get error => _error;

  Future<void> _bootstrap() async {
    // Đọc cờ đã xem onboarding chưa (key trùng với OnboardingScreen.seenKey).
    const storage = FlutterSecureStorage();
    _onboardingSeen =
        (await storage.read(key: 'relax_onboarding_done')) == '1';

    final token = await RelaxApi.instance.accessToken;
    if (token == null || token.isEmpty) {
      _checking = false;
      notifyListeners();
      return;
    }
    try {
      final res = await RelaxApi.instance.get('/users/me');
      if (res.statusCode == 200 && res.data is Map) {
        _user = Map<String, dynamic>.from(res.data as Map);
        await _mergeProfileName();
      } else {
        await RelaxApi.instance.clearTokens();
      }
    } catch (_) {
      await RelaxApi.instance.clearTokens();
    } finally {
      _checking = false;
      notifyListeners();
    }
  }

  /// displayName nằm trên UserProfile, không phải User.name — ưu tiên dùng
  /// displayName cho lời chào nếu có, để khi user đổi tên hồ sơ thì app
  /// hiển thị đúng.
  Future<void> _mergeProfileName() async {
    try {
      final p = await RelaxApi.instance.get('/user-profiles/me/profile');
      final dn = p.data is Map ? p.data['displayName'] as String? : null;
      if (dn != null && dn.trim().isNotEmpty && _user != null) {
        _user!['name'] = dn.trim();
      }
    } catch (_) {
      // profile chưa có — bỏ qua, dùng User.name.
    }
  }

  /// Cập nhật tên hiển thị qua PATCH /user-profiles/me/profile.
  Future<bool> updateDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    try {
      final res = await RelaxApi.instance.patch(
        '/user-profiles/me/profile',
        body: {'displayName': trimmed},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (_user != null) _user!['name'] = trimmed;
        notifyListeners();
        return true;
      }
    } catch (_) {
      // nuốt — caller hiển thị lỗi
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    notifyListeners();
    try {
      final res = await RelaxApi.instance.post('/auth/login', body: {
        'email': email.trim(),
        'password': password,
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        final access = res.data?['accessToken'] as String?;
        final refresh = res.data?['refreshToken'] as String?;
        if (access != null) {
          await RelaxApi.instance.saveTokens(access: access, refresh: refresh);
          _user = res.data?['user'] is Map
              ? Map<String, dynamic>.from(res.data['user'] as Map)
              : null;
          // Register device để dashboard Settings → Push devices hiện
          // máy này. Best-effort, không chặn login.
          unawaited(DeviceRegistration.register());
          notifyListeners();
          return true;
        }
      }
      _error = (res.data?['message'] as String?) ?? 'Đăng nhập thất bại';
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _error = null;
    notifyListeners();
    try {
      final res = await RelaxApi.instance.post('/auth/register', body: {
        'email': email.trim(),
        'password': password,
        'name': name.trim(),
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        final access = res.data?['accessToken'] as String?;
        final refresh = res.data?['refreshToken'] as String?;
        if (access != null) {
          await RelaxApi.instance.saveTokens(access: access, refresh: refresh);
          _user = res.data?['user'] is Map
              ? Map<String, dynamic>.from(res.data['user'] as Map)
              : null;
          unawaited(DeviceRegistration.register());
          notifyListeners();
          return true;
        }
      }
      _error = (res.data?['message'] as String?) ?? 'Đăng ký thất bại';
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    // Unregister device trước khi token bị clear — nếu không sẽ 401.
    await DeviceRegistration.unregister();
    try {
      await RelaxApi.instance.post('/auth/logout');
    } catch (_) {
      // best-effort
    }
    await RelaxApi.instance.clearTokens();
    _user = null;
    _onLogoutCleanup?.call();
    notifyListeners();
  }

  /// Callback đăng ký từ main.dart để reset các per-session state
  /// (vd RelaxScreen intro flag) khi user logout. Tránh dùng import
  /// chéo screens ↔ core.
  void Function()? _onLogoutCleanup;
  set onLogoutCleanup(void Function()? fn) => _onLogoutCleanup = fn;

  /// Đánh dấu user đã hoàn thành onboarding — cập nhật in-memory flag
  /// và notify router refreshListenable để redirect logic tính lại,
  /// tránh kẹt loop /onboarding khi storage đã ghi nhưng state chưa
  /// biết. Gọi từ OnboardingScreen._finish() sau khi write storage.
  void markOnboardingSeen() {
    if (_onboardingSeen) return;
    _onboardingSeen = true;
    notifyListeners();
  }
}
