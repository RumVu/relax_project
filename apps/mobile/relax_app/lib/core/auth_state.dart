import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

/// State giữ thông tin user đăng nhập + giúp các màn hình
/// gọi login/register/logout mà không phải tự call API trực tiếp.
class AuthState extends ChangeNotifier {
  AuthState() {
    _bootstrap();
  }

  Map<String, dynamic>? _user;
  bool _checking = true;
  bool _onboardingSeen = true;
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
    try {
      await RelaxApi.instance.post('/auth/logout');
    } catch (_) {
      // best-effort
    }
    await RelaxApi.instance.clearTokens();
    _user = null;
    notifyListeners();
  }
}
