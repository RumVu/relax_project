import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedule local notification cho reminder time chip.
///
/// Hoạt động hoàn toàn local — không cần backend push. Sau khi user
/// chọn "21:00" trong Setup, app sẽ tự tạo 1 daily reminder lúc 21:00.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _tzInitialized = false;

  static const _channelId = 'relax_reminders';
  static const _channelName = 'Nhắc nhở Thi Ái Chill';
  static const _channelDesc =
      'Nhắc bạn quay lại check-in cảm xúc + thư giãn mỗi ngày';

  Future<void> _ensureInit() async {
    if (_initialized) return;

    if (!_tzInitialized) {
      tz_data.initializeTimeZones();
      _tzInitialized = true;
    }

    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: init);
    _initialized = true;
  }

  /// Xin quyền hiện notification. Return true nếu được cấp.
  Future<bool> requestPermission() async {
    await _ensureInit();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final ok = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return ok ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final ok = await android?.requestNotificationsPermission();
      return ok ?? true;
    }
    return true;
  }

  /// Schedule 1 reminder lặp lại hàng ngày tại [time] ("HH:mm").
  /// [id] để overwrite reminder cũ cùng id. Trả notification id.
  Future<int> scheduleDaily({
    required String time,
    required int id,
    String title = 'Đến giờ chăm sóc bản thân ~',
    String body = 'Cùng mình hít thở một nhịp nhẹ nha ✦',
  }) async {
    await _ensureInit();
    final parts = time.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Time phải dạng "HH:mm", got: $time');
    }
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Cancel reminder cũ nếu có
    await _plugin.cancel(id: id);

    // Tính next fire time
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (when.isBefore(now)) {
      when = when.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // daily repeat
    );
    return id;
  }

  /// Hủy 1 reminder cụ thể.
  Future<void> cancel(int id) async {
    await _ensureInit();
    await _plugin.cancel(id: id);
  }

  /// Hủy hết.
  Future<void> cancelAll() async {
    await _ensureInit();
    await _plugin.cancelAll();
  }
}
