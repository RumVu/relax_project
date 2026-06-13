import 'package:hive_flutter/hive_flutter.dart';

import 'local_notifications.dart';

/// Smart push reminders — lên lịch nhắc nhở thông minh dựa trên thói quen.
///
/// IDs:
///   100 = Morning mood check-in
///   101 = Afternoon break reminder
///   102 = Evening journal/wind-down
///   103 = Custom breathing reminder
class SmartReminders {
  SmartReminders._();
  static final SmartReminders instance = SmartReminders._();

  static const _boxName = 'smart_reminders';
  Box<dynamic>? _box;

  Future<Box<dynamic>> get _prefs async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  // ─── Preset schedules ──────────────────────────────────

  static const _defaultSchedules = <String, _ReminderConfig>{
    'morning_mood': _ReminderConfig(
      id: 100,
      hour: 9,
      minute: 0,
      title: 'Chào buổi sáng 🌤️',
      body: 'Hôm nay bạn đang cảm thấy sao? Ghi lại cảm xúc nhé!',
    ),
    'afternoon_break': _ReminderConfig(
      id: 101,
      hour: 14,
      minute: 30,
      title: 'Nghỉ giải lao ☕',
      body: 'Đã đến lúc nghỉ 3 phút. Hít thở hoặc nghe nhạc nhẹ nhé!',
    ),
    'evening_journal': _ReminderConfig(
      id: 102,
      hour: 21,
      minute: 0,
      title: 'Thời gian cho bạn 🌙',
      body: 'Viết vài dòng nhật ký hoặc nghe nhạc thư giãn trước khi ngủ.',
    ),
    'breathing': _ReminderConfig(
      id: 103,
      hour: 16,
      minute: 0,
      title: 'Hít thở sâu 🌬️',
      body: 'Dành 1 phút hít thở. Cơ thể bạn sẽ cảm ơn!',
    ),
  };

  /// Enable a specific reminder.
  Future<void> enable(String key, {int? hour, int? minute}) async {
    final config = _defaultSchedules[key];
    if (config == null) return;

    final h = hour ?? config.hour;
    final m = minute ?? config.minute;

    await LocalNotifications.scheduleDaily(
      id: config.id,
      title: config.title,
      body: config.body,
      hour: h,
      minute: m,
    );

    final box = await _prefs;
    await box.put(key, {'enabled': true, 'hour': h, 'minute': m});
  }

  /// Disable a specific reminder.
  Future<void> disable(String key) async {
    final config = _defaultSchedules[key];
    if (config == null) return;
    await LocalNotifications.cancel(config.id);

    final box = await _prefs;
    await box.put(key, {'enabled': false});
  }

  /// Check if a reminder is enabled.
  Future<bool> isEnabled(String key) async {
    final box = await _prefs;
    final data = box.get(key) as Map?;
    return data?['enabled'] == true;
  }

  /// Get saved time for a reminder.
  Future<({int hour, int minute})?> getTime(String key) async {
    final box = await _prefs;
    final data = box.get(key) as Map?;
    if (data == null || data['enabled'] != true) return null;
    return (
      hour: data['hour'] as int? ?? _defaultSchedules[key]!.hour,
      minute: data['minute'] as int? ?? _defaultSchedules[key]!.minute,
    );
  }

  /// Enable all default reminders (first-time setup).
  Future<void> enableDefaults() async {
    final box = await _prefs;
    if (box.get('_initialized') == true) return;

    for (final key in _defaultSchedules.keys) {
      await enable(key);
    }
    await box.put('_initialized', true);
  }

  /// Get all reminder keys and their states.
  Future<Map<String, ({bool enabled, int hour, int minute, String title})>>
      getAll() async {
    final box = await _prefs;
    final result =
        <String, ({bool enabled, int hour, int minute, String title})>{};

    for (final entry in _defaultSchedules.entries) {
      final data = box.get(entry.key) as Map?;
      final enabled = data?['enabled'] == true;
      result[entry.key] = (
        enabled: enabled,
        hour: data?['hour'] as int? ?? entry.value.hour,
        minute: data?['minute'] as int? ?? entry.value.minute,
        title: entry.value.title,
      );
    }
    return result;
  }

  static List<String> get availableKeys => _defaultSchedules.keys.toList();
}

class _ReminderConfig {
  const _ReminderConfig({
    required this.id,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
  });
  final int id;
  final int hour;
  final int minute;
  final String title;
  final String body;
}
