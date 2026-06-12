import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'device_registration.dart';
import 'secure_storage.dart';

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

  String? _activeSessionId;
  String? _activeActivityType;

  Map<String, dynamic>? get user => _user;
  bool get checking => _checking;
  bool get isLoggedIn => _user != null;
  bool get onboardingSeen => _onboardingSeen;
  String? get error => _error;
  String? get activeSessionId => _activeSessionId;
  String? get activeActivityType => _activeActivityType;

  /// Minimum thời gian giữ splash để brand "Thi Ái" hiển thị đủ lâu
  /// — không bị flash quá nhanh trên máy nhanh.
  static const _minSplashDuration = Duration(seconds: 3);

  Future<void> _bootstrap() async {
    final startedAt = DateTime.now();
    debugPrint('=== [BOOTSTRAP START] ===');
    
    // Đọc cờ đã xem onboarding chưa (key trùng với OnboardingScreen.seenKey).
    const storage = secureStorage;
    try {
      debugPrint('Bootstrap: Đọc cờ onboarding...');
      _onboardingSeen =
          (await storage.read(key: 'relax_onboarding_done')) == '1';
      debugPrint('Bootstrap: Cờ onboarding = $_onboardingSeen');
    } catch (e) {
      debugPrint('Bootstrap: Lỗi đọc cờ onboarding: $e');
    }

    String? token;
    try {
      debugPrint('Bootstrap: Đọc access token...');
      token = await RelaxApi.instance.accessToken;
      debugPrint('Bootstrap: Access token read = ${token != null && token.isNotEmpty ? "Có token" : "Không có token"}');
    } catch (e) {
      debugPrint('Bootstrap: Lỗi đọc access token: $e');
    }

    if (token == null || token.isEmpty) {
      debugPrint('Bootstrap: Không có token, chuyển sang màn hình Onboarding/Login sau khi giữ Splash...');
      await _enforceMinSplash(startedAt);
      _checking = false;
      debugPrint('Bootstrap: Hoàn thành bootstrap (No Token), notifyListeners().');
      notifyListeners();
      return;
    }

    try {
      debugPrint('Bootstrap: Có token, gọi API /users/me...');
      final res = await RelaxApi.instance.get('/users/me');
      debugPrint('Bootstrap: Kết quả API /users/me = ${res.statusCode}');
      if (res.statusCode == 200 && res.data is Map) {
        _user = Map<String, dynamic>.from(res.data as Map);
        debugPrint('Bootstrap: Đăng nhập tự động thành công cho user: ${_user?['email']}');
        await _mergeProfileName();
      } else {
        debugPrint('Bootstrap: Token không hợp lệ, tiến hành xóa token...');
        await RelaxApi.instance.clearTokens();
      }
    } catch (e) {
      debugPrint('Bootstrap: Lỗi gọi API /users/me hoặc lỗi kết nối: $e');
      await RelaxApi.instance.clearTokens();
    } finally {
      debugPrint('Bootstrap: Giữ Splash và hoàn tất...');
      await _enforceMinSplash(startedAt);
      _checking = false;
      debugPrint('Bootstrap: Hoàn thành bootstrap (With Token), notifyListeners().');
      notifyListeners();
    }
  }

  /// Nếu bootstrap quá nhanh (máy mạnh, token cached), delay cho đủ
  /// [_minSplashDuration] kể từ [startedAt] để brand splash hiển thị
  /// đủ lâu. Không kéo dài nếu đã chạy quá thời gian này.
  Future<void> _enforceMinSplash(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
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
    _activeSessionId = null;
    _activeActivityType = null;
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

  /// Cập nhật ảnh đại diện của user qua POST /storage/me/avatar.
  Future<bool> updateAvatar(String filePath) async {
    try {
      final file = await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      );
      final formData = FormData.fromMap({
        'file': file,
      });

      final res = await RelaxApi.instance.post(
        '/storage/me/avatar',
        body: formData,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final publicUrl = res.data?['publicUrl'] as String?;
        if (publicUrl != null && _user != null) {
          _user!['avatar'] = publicUrl;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('Update avatar failed: $e');
    }
    return false;
  }

  Future<void> refreshUser() async {
    try {
      final res = await RelaxApi.instance.get('/users/me');
      if (res.statusCode == 200 && res.data is Map) {
        _user = Map<String, dynamic>.from(res.data as Map);
        await _mergeProfileName();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> loginWithGoogle({required String idToken, String? accessToken}) async {
    debugPrint('AuthState.loginWithGoogle: Khởi chạy...');
    _error = null;
    notifyListeners();
    try {
      final body = <String, dynamic>{
        'idToken': idToken,
      };
      if (accessToken != null) {
        body['accessToken'] = accessToken;
      }

      debugPrint('AuthState.loginWithGoogle: Đang gửi POST /auth/google...');
      final res = await RelaxApi.instance.post('/auth/google', body: body);
      debugPrint('AuthState.loginWithGoogle: Backend phản hồi với HTTP Status = ${res.statusCode}');
      debugPrint('AuthState.loginWithGoogle: Body data = ${res.data}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final access = res.data?['accessToken'] as String?;
        final refresh = res.data?['refreshToken'] as String?;
        if (access != null) {
          debugPrint('AuthState.loginWithGoogle: Lưu tokens thành công!');
          debugPrint('  - Access Token: $access');
          debugPrint('  - Refresh Token: $refresh');
          await RelaxApi.instance.saveTokens(access: access, refresh: refresh);
          _user = res.data?['user'] is Map
              ? Map<String, dynamic>.from(res.data['user'] as Map)
              : null;
          unawaited(DeviceRegistration.register());
          await _mergeProfileName();
          notifyListeners();
          return true;
        }
      }
      _error = (res.data?['message'] as String?) ?? 'Đăng nhập Google thất bại';
      debugPrint('AuthState.loginWithGoogle: Thất bại. Lỗi: $_error');
    } catch (e) {
      _error = e.toString();
      debugPrint('AuthState.loginWithGoogle: Ngoại lệ xảy ra: $e');
    }
    notifyListeners();
    return false;
  }

  /// Start a relax session in the background
  Future<String?> startRelaxSession(String activityType, String title) async {
    try {
      final res = await RelaxApi.instance.post('/relax-activities/sessions/start', body: {
        'activityType': activityType,
        'title': title,
        'moodBefore': 'NEUTRAL',
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        final id = res.data?['id'] as String?;
        if (id != null) {
          _activeSessionId = id;
          _activeActivityType = activityType;
          notifyListeners();
          return id;
        }
      }
    } catch (e) {
      debugPrint('Start relax session failed: $e');
    }
    return null;
  }

  /// Finish an active relax session, post-checkin mood, and refresh user stats
  Future<bool> finishRelaxSession(
    String sessionId, {
    required String moodAfter,
    required int reliefLevel,
    String? note,
  }) async {
    try {
      final res = await RelaxApi.instance.post('/relax-activities/sessions/$sessionId/finish', body: {
        'moodAfter': moodAfter,
        'reliefLevel': reliefLevel,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (_activeSessionId == sessionId) {
          _activeSessionId = null;
          _activeActivityType = null;
        }
        notifyListeners();
        await refreshUser(); // refresh user stats & info
        return true;
      }
    } catch (e) {
      debugPrint('Finish relax session failed: $e');
    }
    return false;
  }
}
