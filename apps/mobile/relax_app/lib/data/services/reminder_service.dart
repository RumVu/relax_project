import '../../core/api_client.dart';

/// Một nhắc nhở (reminder) — backend trả `time` dạng "HH:mm".
class Reminder {
  const Reminder({
    required this.id,
    required this.time,
    required this.enabled,
    this.label,
    this.type = 'COMPANION',
  });

  final String id;
  final String time; // "HH:mm"
  final bool enabled;
  final String? label;
  final String type;

  factory Reminder.fromJson(Map<String, dynamic> j) {
    return Reminder(
      id: (j['id'] ?? '').toString(),
      time: (j['time'] ?? j['scheduledAt'] ?? '21:00').toString(),
      enabled: (j['enabled'] as bool?) ?? true,
      label: j['label'] as String?,
      type: (j['type'] ?? 'COMPANION').toString(),
    );
  }
}

/// Gọi /v1/reminders/me — list/create/delete.
class ReminderService {
  ReminderService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<Reminder>> list({required String accessToken}) async {
    final raw = await _client.getJson(
      '/reminders/me',
      accessToken: accessToken,
    );
    final items = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : raw is List
        ? raw
        : const <Object?>[];
    return items
        .whereType<Map>()
        .map((e) => Reminder.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<Reminder> create({
    required String accessToken,
    required String time,
    String type = 'COMPANION',
    String? label,
  }) async {
    final payload = <String, Object?>{
      'time': time,
      'type': type,
      'enabled': true,
    };
    if (label != null) {
      payload['label'] = label;
    }
    final body = await _client.postJson(
      '/reminders/me',
      payload,
      accessToken: accessToken,
    );
    if (body is Map<String, dynamic>) return Reminder.fromJson(body);
    if (body is Map) return Reminder.fromJson(Map<String, dynamic>.from(body));
    throw const ApiException('Backend không trả reminder hợp lệ.');
  }

  Future<void> delete({required String accessToken, required String id}) async {
    await _client.delete('/reminders/me/$id', accessToken: accessToken);
  }
}
