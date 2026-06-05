part of 'package:relax_app/main.dart';

/// Một dòng mood check-in trả về từ /mood-checkins/me.
class MoodCheckin {
  const MoodCheckin({
    required this.id,
    required this.mood,
    required this.intensity,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String mood;
  final int intensity;
  final DateTime createdAt;
  final String? note;

  factory MoodCheckin.fromJson(Map<String, dynamic> j) {
    return MoodCheckin(
      id: (j['id'] ?? '').toString(),
      mood: (j['mood'] ?? '').toString(),
      intensity: (j['intensity'] as num?)?.toInt() ?? 3,
      createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      note: j['note'] as String?,
    );
  }
}

/// POST + GET cho /mood-checkins. Cần access token.
class MoodService {
  MoodService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// Ghi nhanh một cảm xúc — intensity mặc định 3 ở UI, ngấm nét nhất.
  Future<MoodCheckin> log({
    required String accessToken,
    required String mood,
    int intensity = 3,
    String? note,
    List<String> tags = const ['home'],
  }) async {
    final body = await _client.postJson(
      '/mood-checkins/me',
      {
        'mood': mood,
        'intensity': intensity,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        'tags': tags,
      },
      accessToken: accessToken,
    );
    if (body is Map<String, dynamic>) return MoodCheckin.fromJson(body);
    if (body is Map) {
      return MoodCheckin.fromJson(Map<String, dynamic>.from(body));
    }
    throw const ApiException('Backend không trả mood-checkin sau khi tạo.');
  }

  /// Lịch sử gần đây — UI dùng để vẽ progress bar + chọn mood chủ đạo.
  Future<List<MoodCheckin>> history({
    required String accessToken,
    int limit = 60,
  }) async {
    final raw = await _client.getJson(
      '/mood-checkins/me?limit=$limit',
      accessToken: accessToken,
    );
    final items = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : raw is List
            ? raw
            : const <Object?>[];
    return items
        .whereType<Map>()
        .map((e) => MoodCheckin.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }
}
