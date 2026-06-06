import '../../core/api_client.dart';

/// Kết quả thành công từ /auth/login | /auth/register | /auth/refresh.
class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final Map<String, dynamic> user;

  factory AuthResult.fromJson(Map<String, dynamic> j) {
    return AuthResult(
      accessToken: (j['accessToken'] ?? j['access_token']) as String,
      refreshToken: (j['refreshToken'] ?? j['refresh_token']) as String,
      user: Map<String, dynamic>.from(j['user'] as Map),
    );
  }
}

/// Gọi các endpoint /v1/auth/* của backend.
class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final body = await _client.postJson('/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthResult.fromJson(_asMap(body));
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final body = await _client.postJson('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
    });
    return AuthResult.fromJson(_asMap(body));
  }

  Future<AuthResult> refresh(String refreshToken) async {
    final body = await _client.postJson('/auth/refresh', {
      'refreshToken': refreshToken,
    });
    return AuthResult.fromJson(_asMap(body));
  }

  /// Đăng nhập qua Google — gửi idToken lên backend /auth/google
  /// Backend verify với Google và trả về JWT access/refresh token.
  Future<AuthResult> googleLogin({required String idToken}) async {
    final body = await _client.postJson('/auth/google', {'idToken': idToken});
    return AuthResult.fromJson(_asMap(body));
  }

  Future<Map<String, dynamic>> fetchMe(String accessToken) async {
    final body = await _client.getJson('/users/me', accessToken: accessToken);
    return _asMap(body);
  }

  Map<String, dynamic> _asMap(Object? v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    throw const ApiException('Backend không trả JSON object cho auth.');
  }
}
