import '../../relax_intro/models/intro_phase.dart';
import '../../../core/api_client.dart';

/// Lấy mood mới nhất. Nếu trong 2h gần đây → dùng luôn, sẽ skip
/// thẳng từ breathing → suggest, bỏ qua bước mood pick.
Future<String?> prefetchLatestMood() async {
  try {
    final res = await RelaxApi.instance
        .get('/mood-checkins/me', query: {'limit': 1});
    final data = res.data;
    final items = data is Map ? data['items'] : data;
    if (items is List && items.isNotEmpty) {
      final latest = items.first as Map?;
      final mood = latest?['mood'] as String?;
      final createdAtStr = latest?['createdAt'] as String?;
      if (mood == null) return null;
      DateTime? createdAt;
      if (createdAtStr != null) {
        createdAt = DateTime.tryParse(createdAtStr);
      }
      final isFresh = createdAt != null &&
          DateTime.now().difference(createdAt).inHours < 2;
      if (isFresh) {
        return mood;
      }
    }
  } catch (_) {
    // Không block intro — chỉ là gợi ý nice-to-have.
  }
  return null;
}

/// Tra cứu label tiếng Việt từ mood code.
String moodLabel(String code) {
  for (final m in moods) {
    if (m.$1 == code) return m.$2;
  }
  return 'bình thường';
}
