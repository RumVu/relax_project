import '../../../core/api_client.dart';

/// Holds the parsed results from the home screen's parallel API calls.
class HomeData {
  final Map<String, dynamic>? greeting;
  final Map<String, dynamic>? quote;
  final List<Map<String, dynamic>> moodOptions;
  final Map<String, int> moodCounts;
  final int moodTotal;
  final int unreadCount;

  const HomeData({
    required this.greeting,
    required this.quote,
    required this.moodOptions,
    required this.moodCounts,
    required this.moodTotal,
    required this.unreadCount,
  });
}

/// Loads and parses all data required by the home screen.
class HomeDataLoader {
  const HomeDataLoader._();

  /// Fetch greeting, quote, mood options, mood history, and unread count
  /// in parallel, then parse them into a [HomeData] bundle.
  static Future<HomeData> loadAll(String lang) async {
    final results = await Future.wait([
      RelaxApi.instance.get('/weather/me/current'),
      RelaxApi.instance.get('/cozy-quotes/random', query: {'lang': lang}),
      RelaxApi.instance.get('/mood-checkins/options'),
      RelaxApi.instance.get('/mood-checkins/me', query: {'limit': 60}),
      RelaxApi.instance.get('/notifications/me/unread-count'),
    ]);

    // -- greeting --
    final w = results[0].data;
    final greeting = (w is Map && w['greeting'] is Map)
        ? Map<String, dynamic>.from(w['greeting'])
        : null;

    // -- quote --
    final quote = results[1].data is Map
        ? Map<String, dynamic>.from(results[1].data)
        : null;

    // -- mood options (max 7) --
    final opts = results[2].data;
    final moodOptions = (opts is List)
        ? opts
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .take(7)
            .toList()
        : <Map<String, dynamic>>[];

    // -- mood history → counts --
    final hist = results[3].data;
    final items = hist is Map ? hist['items'] : hist;
    final moodCounts = <String, int>{};
    int moodTotal = 0;
    if (items is List) {
      for (final it in items.whereType<Map>()) {
        final m = it['mood'] as String?;
        if (m == null) continue;
        moodCounts[m] = (moodCounts[m] ?? 0) + 1;
        moodTotal++;
      }
    }

    // -- unread notification count --
    final unreadRes = results[4].data;
    final unreadCount = (unreadRes is Map && unreadRes['count'] is num)
        ? (unreadRes['count'] as num).toInt()
        : 0;

    return HomeData(
      greeting: greeting,
      quote: quote,
      moodOptions: moodOptions,
      moodCounts: moodCounts,
      moodTotal: moodTotal,
      unreadCount: unreadCount,
    );
  }

  /// Fetch only the unread notification count.
  static Future<int> fetchUnreadCount() async {
    final res = await RelaxApi.instance.get('/notifications/me/unread-count');
    final data = res.data;
    return (data is Map && data['count'] is num)
        ? (data['count'] as num).toInt()
        : 0;
  }
}
