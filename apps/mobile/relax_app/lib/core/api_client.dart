import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'env.dart';
import 'offline_store.dart';
import 'secure_storage.dart';

/// API base URL — lấy từ [Env.apiBase] (hỗ trợ `--dart-define=API_BASE=...`).
/// Mặc định: production Tailscale Funnel URL.
final String kApiBase = Env.apiBase;

/// Singleton Dio instance — gắn sẵn:
///   - baseUrl + 15s timeout.
///   - Interceptor tự đính kèm Bearer token vào mỗi request.
///   - Interceptor tự refresh khi 401 (1 lần) rồi retry.
class RelaxApi {
  RelaxApi._() {
    _dio = Dio(BaseOptions(
      baseUrl: kApiBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ));
    _dio.interceptors.add(_authInterceptor());
  }

  static final RelaxApi instance = RelaxApi._();
  static void Function(String message)? onRateLimitExceeded;
  late final Dio _dio;
  final FlutterSecureStorage _storage = secureStorage;

  static const _accessKey = 'relax_access_token';
  static const _refreshKey = 'relax_refresh_token';

  Future<String?> get accessToken => _storage.read(key: _accessKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshKey);

  Future<void> saveTokens({required String access, String? refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    if (refresh != null) {
      await _storage.write(key: _refreshKey, value: refresh);
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  /// GET wrapper — tries network first, falls back to offline cache.
  Future<Response<dynamic>> get(String path,
      {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      if (res.statusCode != null && res.statusCode! < 400) {
        OfflineStore.instance.cacheResponse(path, query, res.data);
      }
      return res;
    } catch (e) {
      final cached = OfflineStore.instance.readCache(path, query: query);
      if (cached != null) {
        return Response(
          requestOptions: RequestOptions(path: path),
          data: cached,
          statusCode: 200,
        );
      }
      rethrow;
    }
  }

  static bool _isSensitivePath(String path) =>
      path.startsWith('/auth') || path.contains('delete-account');

  /// POST wrapper — queues offline if no connectivity (except sensitive paths).
  Future<Response<dynamic>> post(String path, {dynamic body}) async {
    try {
      return await _dio.post(path, data: body);
    } catch (e) {
      if (!_isSensitivePath(path) && await _isNetworkError(e)) {
        await OfflineStore.instance.enqueue(method: 'POST', path: path, body: body);
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {'queued': true},
          statusCode: 202,
        );
      }
      rethrow;
    }
  }

  Future<Response<dynamic>> patch(String path, {dynamic body}) async {
    try {
      return await _dio.patch(path, data: body);
    } catch (e) {
      if (!_isSensitivePath(path) && await _isNetworkError(e)) {
        await OfflineStore.instance.enqueue(method: 'PATCH', path: path, body: body);
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {'queued': true},
          statusCode: 202,
        );
      }
      rethrow;
    }
  }

  Future<Response<dynamic>> delete(String path, {dynamic body}) async {
    try {
      return await _dio.delete(path, data: body);
    } catch (e) {
      if (!_isSensitivePath(path) && await _isNetworkError(e)) {
        await OfflineStore.instance.enqueue(method: 'DELETE', path: path, body: body);
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {'queued': true},
          statusCode: 202,
        );
      }
      rethrow;
    }
  }

  Future<bool> _isNetworkError(dynamic e) async {
    if (e is DioException &&
        (e.type == DioExceptionType.connectionError ||
         e.type == DioExceptionType.connectionTimeout ||
         e.type == DioExceptionType.sendTimeout)) {
      return true;
    }
    return !await OfflineStore.instance.isOnline;
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Login + register không cần token; gắn vào không sao nhưng tránh tốn IO.
        if (options.path.contains('/auth/login') ||
            options.path.contains('/auth/register')) {
          return handler.next(options);
        }
        final token = await accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) async {
        // Backend trả 401 với envelope `{success:false, code:'AUTH_*', ...}`
        // do `validateStatus` cho qua. Nếu là 401 + chưa retry → refresh +
        // gọi lại.
        if (response.statusCode == 429) {
          onRateLimitExceeded?.call('Bạn đang thao tác quá nhanh, vui lòng nghỉ ngơi một chút! (HTTP 429)');
        }
        if (response.statusCode == 401 &&
            response.requestOptions.extra['relax_retry'] != true) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            response.requestOptions.extra['relax_retry'] = true;
            response.requestOptions.headers['Authorization'] =
                'Bearer ${await accessToken}';
            try {
              final retry = await _dio.fetch(response.requestOptions);
              return handler.resolve(retry);
            } catch (e) {
              return handler.next(response);
            }
          }
        }
        handler.next(response);
      },
    );
  }

  /// Đổi refresh token lấy access mới. Trả `true` khi thành công.
  Future<bool> _tryRefresh() async {
    final refresh = await refreshToken;
    if (refresh == null) return false;
    try {
      final res = await Dio(BaseOptions(baseUrl: kApiBase)).post(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final access = res.data?['accessToken'] as String?;
      final newRefresh = res.data?['refreshToken'] as String?;
      if (access != null) {
        await saveTokens(access: access, refresh: newRefresh);
        return true;
      }
    } catch (_) {
      await clearTokens();
    }
    return false;
  }
}
