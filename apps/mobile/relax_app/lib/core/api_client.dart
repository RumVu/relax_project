import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

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
/// Callback do SessionState đăng ký để client tự gia hạn token khi 401.
/// Trả về token mới nếu refresh ok, null nếu thất bại → call site bắn lỗi.
typedef TokenRefresher = Future<String?> Function();

class ApiClient {
  ApiClient({
    http.Client? client,
    String baseUrl = Env.apiUrl,
    this.timeout = const Duration(seconds: 10),
    this.onRefreshNeeded,
  }) : _client = client ?? http.Client(),
       baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl;

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  /// Khi gặp 401 và có accessToken, gọi callback để xin token mới rồi
  /// retry 1 lần. Null = không retry.
  final TokenRefresher? onRefreshNeeded;

  Uri _resolve(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$p');
  }

  Map<String, String> _headers({
    String? accessToken,
    bool sendingJson = false,
  }) {
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

  /// Common 401-retry wrapper. Nếu request đầu trả 401 và caller có
  /// `accessToken` + ApiClient có `onRefreshNeeded`, thử refresh 1 lần
  /// rồi gọi lại request với token mới.
  Future<http.Response> _send(
    Future<http.Response> Function(String? token) doRequest, {
    String? accessToken,
  }) async {
    final res = await doRequest(accessToken).timeout(timeout);
    if (res.statusCode != 401 ||
        accessToken == null ||
        onRefreshNeeded == null) {
      return res;
    }
    // Lần retry: xin token mới rồi resend
    final newToken = await onRefreshNeeded!();
    if (newToken == null) return res; // refresh fail → caller throw 401
    return doRequest(newToken).timeout(timeout);
  }

  Future<Object?> getJson(String path, {String? accessToken}) async {
    final uri = _resolve(path);
    final res = await _send(
      (token) => _client.get(uri, headers: _headers(accessToken: token)),
      accessToken: accessToken,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) _throwFor(res, uri);
    return _decode(res);
  }

  Future<Object?> postJson(
    String path,
    Object? body, {
    String? accessToken,
  }) async {
    final uri = _resolve(path);
    final encoded = body == null ? null : jsonEncode(body);
    final res = await _send(
      (token) => _client.post(
        uri,
        headers: _headers(accessToken: token, sendingJson: true),
        body: encoded,
      ),
      accessToken: accessToken,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) _throwFor(res, uri);
    return _decode(res);
  }

  Future<Object?> patchJson(
    String path,
    Object? body, {
    String? accessToken,
  }) async {
    final uri = _resolve(path);
    final encoded = body == null ? null : jsonEncode(body);
    final res = await _send(
      (token) => _client.patch(
        uri,
        headers: _headers(accessToken: token, sendingJson: true),
        body: encoded,
      ),
      accessToken: accessToken,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) _throwFor(res, uri);
    return _decode(res);
  }

  Future<void> delete(String path, {String? accessToken}) async {
    final uri = _resolve(path);
    final res = await _send(
      (token) => _client.delete(uri, headers: _headers(accessToken: token)),
      accessToken: accessToken,
    );
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
