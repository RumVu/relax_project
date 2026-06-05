import '../../core/api_client.dart';

/// Một phiên thư giãn (relax session). UI cần `id` để gọi finish sau.
class RelaxSession {
  const RelaxSession({
    required this.id,
    required this.activityCode,
    required this.startedAt,
    this.finishedAt,
    this.stressDelta,
  });

  final String id;
  final String activityCode;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int? stressDelta;

  factory RelaxSession.fromJson(Map<String, dynamic> j) {
    return RelaxSession(
      id: (j['id'] ?? '').toString(),
      activityCode: (j['activityCode'] ?? j['code'] ?? '').toString(),
      startedAt:
          DateTime.tryParse((j['startedAt'] ?? '').toString()) ??
          DateTime.now(),
      finishedAt: j['finishedAt'] == null
          ? null
          : DateTime.tryParse(j['finishedAt'].toString()),
      stressDelta: (j['stressDelta'] as num?)?.toInt(),
    );
  }
}

/// Bắt đầu / kết thúc một phiên thư giãn. Cần access token.
///
/// Khớp với contract backend:
/// - POST `/v1/relax-sessions/start` body `{activityType, resourceId?, title?,
///   moodBefore?}`.
/// - POST `/v1/relax-sessions/:id/finish` body `{moodAfter?, reliefLevel 1..5,
///   note?}`.
class RelaxSessionService {
  RelaxSessionService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// Bắt đầu phiên ngay khi user bấm "Play" — backend trả `id` để chốt sau.
  Future<RelaxSession> start({
    required String accessToken,
    required String activityType,
    String? resourceId,
    String? title,
    String? moodBefore,
  }) async {
    final body = await _client
        .postJson('/relax-sessions/start', <String, Object?>{
          'activityType': activityType,
          'resourceId': ?resourceId,
          'title': ?title,
          'moodBefore': ?moodBefore,
        }, accessToken: accessToken);
    return _asSession(body);
  }

  /// Kết thúc khi user bấm "Finish" — `reliefLevel` 1..5 + note tự do.
  Future<RelaxSession> finish({
    required String accessToken,
    required String sessionId,
    required int reliefLevel,
    String? note,
    String? moodAfter,
  }) async {
    final trimmed = note?.trim();
    final body = await _client
        .postJson('/relax-sessions/$sessionId/finish', <String, Object?>{
          'reliefLevel': reliefLevel.clamp(1, 5),
          'moodAfter': ?moodAfter,
          if (trimmed != null && trimmed.isNotEmpty) 'note': trimmed,
        }, accessToken: accessToken);
    return _asSession(body);
  }

  /// Lịch sử để dựng popup thống kê (streak, total time, etc.).
  Future<List<RelaxSession>> recent({
    required String accessToken,
    int limit = 30,
  }) async {
    final raw = await _client.getJson(
      '/relax-sessions/me?limit=$limit',
      accessToken: accessToken,
    );
    final items = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : raw is List
        ? raw
        : const <Object?>[];
    return items
        .whereType<Map>()
        .map((e) => RelaxSession.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  RelaxSession _asSession(Object? body) {
    if (body is Map<String, dynamic>) return RelaxSession.fromJson(body);
    if (body is Map) {
      return RelaxSession.fromJson(Map<String, dynamic>.from(body));
    }
    throw const ApiException('Backend không trả relax-session hợp lệ.');
  }
}
