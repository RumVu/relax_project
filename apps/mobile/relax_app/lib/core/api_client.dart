part of 'package:relax_app/main.dart';

/// Cấu hình base URL backend. Source-of-truth thật là [Env.apiUrl] —
/// `BackendConfig.defaultBaseUrl` chỉ là alias để code cũ vẫn compile.
class BackendConfig {
  const BackendConfig._();

  /// @Deprecated — dùng [Env.apiUrl] thay vì hằng số này.
  static const defaultBaseUrl = Env.apiUrl;
}

/// HTTP client thin — bọc `package:http` với:
/// - tự gắn `Accept: application/json`
/// - tự decode UTF-8 + JSON
/// - hỗ trợ `Authorization: Bearer <token>` khi có
/// - timeout cứng để UI không treo
/// - phân biệt 401 vs 4xx khác để [SessionState] có thể refresh
class ApiClient {
  ApiClient({
    http.Client? client,
    String baseUrl = Env.apiUrl,
    this.timeout = const Duration(seconds: 10),
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Uri _resolve(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$p');
  }

  Map<String, String> _headers({String? accessToken, bool sendingJson = false}) {
    return <String, String>{
      'Accept': 'application/json',
      if (sendingJson) 'Content-Type': 'application/json; charset=utf-8',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  Object? _decode(http.Response res) {
    if (res.body.trim().isEmpty) return null;
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Never _throwFor(http.Response res, Uri uri) {
    final code = res.statusCode;
    String message;
    try {
      final decoded = _decode(res);
      if (decoded is Map && decoded['message'] != null) {
        final raw = decoded['message'];
        message = raw is List ? raw.join(', ') : raw.toString();
      } else {
        message = 'Backend trả $code khi gọi ${uri.path}';
      }
    } catch (_) {
      message = 'Backend trả $code khi gọi ${uri.path}';
    }
    if (code == 401) throw UnauthorizedException(message);
    throw ApiException(message, statusCode: code);
  }

  Future<Object?> getJson(String path, {String? accessToken}) async {
    final uri = _resolve(path);
    final res = await _client
        .get(uri, headers: _headers(accessToken: accessToken))
        .timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) _throwFor(res, uri);
    return _decode(res);
  }

  Future<Object?> postJson(
    String path,
    Object? body, {
    String? accessToken,
  }) async {
    final uri = _resolve(path);
    final res = await _client
        .post(
          uri,
          headers: _headers(accessToken: accessToken, sendingJson: true),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) _throwFor(res, uri);
    return _decode(res);
  }

  Future<Object?> patchJson(
    String path,
    Object? body, {
    String? accessToken,
  }) async {
    final uri = _resolve(path);
    final res = await _client
        .patch(
          uri,
          headers: _headers(accessToken: accessToken, sendingJson: true),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) _throwFor(res, uri);
    return _decode(res);
  }

  Future<void> delete(String path, {String? accessToken}) async {
    final uri = _resolve(path);
    final res = await _client
        .delete(uri, headers: _headers(accessToken: accessToken))
        .timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) _throwFor(res, uri);
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// 401 — gọi riêng để [SessionState.tryRefresh] biết khi nào nên gia hạn.
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message) : super(statusCode: 401);
}
