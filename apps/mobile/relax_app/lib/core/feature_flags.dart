import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'api_client.dart';

class FeatureFlags extends ChangeNotifier {
  FeatureFlags._();
  static final instance = FeatureFlags._();

  Map<String, bool> _flags = {};
  bool _loaded = false;

  bool get loaded => _loaded;

  bool isEnabled(String key) => _flags[key] ?? true;

  Future<void> load() async {
    // Load from cache first
    try {
      final box = await Hive.openBox('feature_flags');
      final cached = box.get('flags');
      if (cached is Map) {
        _flags = Map<String, bool>.from(cached);
        _loaded = true;
        notifyListeners();
      }
    } catch (_) {}

    // Then fetch from server
    try {
      final res = await RelaxApi.instance.get('/feature-flags');
      final data = res.data;
      if (data is Map && data['items'] is List) {
        final items = data['items'] as List;
        final newFlags = <String, bool>{};
        for (final item in items) {
          if (item is Map) {
            final key = item['key'] as String?;
            final enabled = item['enabled'] as bool?;
            if (key != null) newFlags[key] = enabled ?? false;
          }
        }
        _flags = newFlags;
        _loaded = true;

        // Cache
        final box = await Hive.openBox('feature_flags');
        await box.put('flags', _flags);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('FeatureFlags load error: $e');
    }
  }
}
