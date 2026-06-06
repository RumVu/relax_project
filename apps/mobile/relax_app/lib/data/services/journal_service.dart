import '../../core/api_client.dart';

/// Một entry nhật ký trả về từ /v1/journals/me.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.content,
    required this.createdAt,
    this.title,
    this.mood,
    this.tags = const [],
    this.isFavorite = false,
  });

  final String id;
  final String content;
  final DateTime createdAt;
  final String? title;
  final String? mood;
  final List<String> tags;
  final bool isFavorite;

  factory JournalEntry.fromJson(Map<String, dynamic> j) {
    final tagsRaw = j['tags'];
    return JournalEntry(
      id: (j['id'] ?? '').toString(),
      title: j['title'] as String?,
      content: (j['content'] ?? '').toString(),
      mood: j['mood'] as String?,
      tags: tagsRaw is List
          ? tagsRaw.whereType<String>().toList(growable: false)
          : const [],
      isFavorite: (j['isFavorite'] as bool?) ?? false,
      createdAt:
          DateTime.tryParse((j['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

/// Gọi /v1/journals/me — list + create + favorite.
class JournalService {
  JournalService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<JournalEntry>> list({
    required String accessToken,
    int limit = 30,
  }) async {
    final raw = await _client.getJson(
      '/journals/me?limit=$limit',
      accessToken: accessToken,
    );
    final items = raw is Map && raw['items'] is List
        ? raw['items'] as List
        : raw is List
            ? raw
            : const <Object?>[];
    return items
        .whereType<Map>()
        .map((e) => JournalEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<JournalEntry> create({
    required String accessToken,
    required String content,
    String? title,
    String? mood,
    List<String> tags = const [],
    bool isPrivate = true,
    bool isFavorite = false,
  }) async {
    final payload = <String, Object?>{
      'content': content,
      'isPrivate': isPrivate,
      'isFavorite': isFavorite,
      if (title != null && title.isNotEmpty) 'title': title,
      if (mood != null && mood.isNotEmpty) 'mood': mood,
      if (tags.isNotEmpty) 'tags': tags,
    };
    final body = await _client.postJson(
      '/journals/me',
      payload,
      accessToken: accessToken,
    );
    if (body is Map<String, dynamic>) return JournalEntry.fromJson(body);
    if (body is Map) return JournalEntry.fromJson(Map<String, dynamic>.from(body));
    throw const ApiException('Backend không trả journal hợp lệ.');
  }
}
