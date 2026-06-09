import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'secure_storage.dart';

/// Đăng ký thiết bị di động với backend qua `/notifications/me/devices`
/// để dashboard Settings → Push devices hiện đúng máy mà user đang dùng.
///
/// Token được sinh 1 lần và lưu trong SecureStorage — tái sử dụng giữa
/// các lần login để backend nhận diện đúng (upsert by unique token).
class DeviceRegistration {
  static const _storage = secureStorage;
  static const _kDeviceToken = 'relax_device_token';
  static const _kDeviceId = 'relax_device_id';

  /// Sinh token hoặc đọc lại từ SecureStorage. Token này là một string
  /// random 32 ký tự — không phải FCM/APNs token thật (chưa wire push),
  /// nhưng đủ để backend lưu unique và dashboard hiển thị.
  static Future<String> _getOrCreateToken() async {
    final existing = await _storage.read(key: _kDeviceToken);
    if (existing != null && existing.isNotEmpty) return existing;
    final rng = Random.secure();
    final bytes = List<int>.generate(24, (_) => rng.nextInt(256));
    final token = 'mobile-${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
    await _storage.write(key: _kDeviceToken, value: token);
    return token;
  }

  static Future<String> _getOrCreateDeviceId() async {
    final existing = await _storage.read(key: _kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final rng = Random.secure();
    final id = 'dev-${List.generate(8, (_) => rng.nextInt(36).toRadixString(36)).join()}';
    await _storage.write(key: _kDeviceId, value: id);
    return id;
  }

  static String _detectPlatform() {
    if (kIsWeb) return 'WEB';
    if (Platform.isIOS) return 'IOS';
    if (Platform.isAndroid) return 'ANDROID';
    if (Platform.isMacOS) return 'MACOS';
    if (Platform.isWindows) return 'WINDOWS';
    if (Platform.isLinux) return 'LINUX';
    return 'WEB';
  }

  static String _detectDeviceName() {
    if (kIsWeb) return 'Web browser';
    if (Platform.isIOS) return 'iPhone / iPad';
    if (Platform.isAndroid) return 'Android phone';
    if (Platform.isMacOS) return 'Mac';
    if (Platform.isWindows) return 'Windows PC';
    if (Platform.isLinux) return 'Linux PC';
    return 'Thi Ái app';
  }

  /// Gọi sau khi login/register thành công. Best-effort: nếu fail
  /// không throw để không chặn flow đăng nhập.
  static Future<void> register() async {
    try {
      final token = await _getOrCreateToken();
      final deviceId = await _getOrCreateDeviceId();
      final platform = _detectPlatform();
      final deviceName = _detectDeviceName();
      final timezone = DateTime.now().timeZoneName;
      await RelaxApi.instance.post(
        '/notifications/me/devices',
        body: {
          'token': token,
          'platform': platform,
          'provider': 'FCM',
          'deviceId': deviceId,
          'deviceName': deviceName,
          'appVersion': '1.0.0',
          'timezone': timezone,
          'enabled': true,
        },
      );
    } catch (e) {
      // Không chặn login — chỉ log debug.
      if (kDebugMode) {
        // ignore: avoid_print
        print('DeviceRegistration.register failed: $e');
      }
    }
  }

  /// Gỡ device khỏi backend khi logout. Best-effort — nếu fail vẫn
  /// cho logout tiếp tục. Backend lookup theo token (unique).
  static Future<void> unregister() async {
    try {
      final token = await _storage.read(key: _kDeviceToken);
      if (token == null || token.isEmpty) return;
      // Lấy list device để tìm id, vì endpoint DELETE cần id.
      final res = await RelaxApi.instance.get('/notifications/me/devices');
      final data = res.data;
      if (data is List) {
        for (final item in data) {
          if (item is Map && item['token'] == token) {
            final id = item['id'] as String?;
            if (id != null) {
              await RelaxApi.instance.delete('/notifications/me/devices/$id');
              break;
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('DeviceRegistration.unregister failed: $e');
      }
    }
  }
}
