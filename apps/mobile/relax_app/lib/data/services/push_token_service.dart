import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/api_client.dart';

/// Đăng ký push token thiết bị với backend (`POST /v1/notifications/me/devices`).
///
/// Flow:
///   1. Sau khi user login thành công (hoặc khi Shell khởi động và isLoggedIn),
///      shell gọi `PushTokenService.registerIfNeeded(accessToken)`.
///   2. Service lấy FCM/APNs token từ Firebase (nếu có) hoặc dùng fallback
///      `device_id` đơn giản cho local testing.
///   3. Gọi backend với `{token, platform, deviceId, deviceName, appVersion, timezone}`.
///   4. Nếu backend trả lỗi → log và bỏ qua (không crash app).
///
/// Lưu ý: Firebase Messaging package (`firebase_messaging`) CHƯA được thêm vào
/// pubspec.yaml. Hiện tại service dùng `"PLACEHOLDER_FCM_TOKEN"` cho local
/// testing. Khi project thêm FCM/APNs → thay thế [_getDeviceToken] bằng
/// `FirebaseMessaging.instance.getToken()`.
class PushTokenService {
  PushTokenService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// Đăng ký device push token với backend nếu chưa đăng ký trong phiên này.
  ///
  /// Idempotent — backend upsert theo `deviceId`, gọi nhiều lần không sao.
  Future<void> registerIfNeeded({required String accessToken}) async {
    try {
      final token = await _getDeviceToken();
      if (token == null || token.isEmpty) return;

      final platform = _platformString();
      if (platform == null) return; // web hoặc desktop → bỏ qua

      final packageInfo = await PackageInfo.fromPlatform();
      final deviceId = await _getDeviceId();
      final timezone = DateTime.now().timeZoneName;

      await _client.postJson(
        '/notifications/me/devices',
        <String, Object?>{
          'token': token,
          'platform': platform,
          if (deviceId != null) 'deviceId': deviceId,
          'appVersion': packageInfo.version,
          'timezone': timezone,
          'enabled': true,
        },
        accessToken: accessToken,
      );
    } catch (e) {
      // Lỗi register push token KHÔNG nên crash app — chỉ log.
      debugPrint('[PushTokenService] register failed (non-critical): $e');
    }
  }

  /// Lấy FCM/APNs token.
  ///
  /// TODO: Khi thêm `firebase_messaging` vào pubspec, thay thế bằng:
  ///   ```dart
  ///   final msg = FirebaseMessaging.instance;
  ///   await msg.requestPermission();
  ///   return await msg.getToken();
  ///   ```
  ///
  /// Hiện tại trả `null` trên tất cả platform vì Firebase chưa được setup →
  /// service sẽ bỏ qua gracefully. Khi Firebase được cấu hình đúng, uncommment
  /// block bên dưới.
  Future<String?> _getDeviceToken() async {
    // ── Uncommment khi thêm firebase_messaging ────────────────────────────────
    // import 'package:firebase_messaging/firebase_messaging.dart';
    // final messaging = FirebaseMessaging.instance;
    // final settings = await messaging.requestPermission(provisional: true);
    // if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
    // return await messaging.getToken();
    // ─────────────────────────────────────────────────────────────────────────

    // Trả null → registerIfNeeded sẽ return sớm, không gọi API.
    // (Bật lại khi Firebase được cài đặt)
    return null;
  }

  /// Lấy device ID ổn định để backend upsert (không tạo row duplicate).
  ///
  /// Trả null nếu không có — backend sẽ dùng token làm unique key thay thế.
  Future<String?> _getDeviceId() async {
    // TODO: Dùng device_info_plus để lấy androidId / identifierForVendor
    // kết hợp với SecureStorage để persist qua reinstall trên iOS.
    return null;
  }

  /// Chuyển Flutter platform → chuỗi backend expect (`IOS` / `ANDROID`).
  /// Trả null nếu không phải mobile (web, desktop) → bỏ qua.
  String? _platformString() {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'IOS';
      case TargetPlatform.android:
        return 'ANDROID';
      default:
        return null;
    }
  }
}
