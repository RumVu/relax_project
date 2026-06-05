import '../../core/api_client.dart';
import '../models/backend_models.dart';

class MobileContentSnapshot {
  const MobileContentSnapshot({
    this.moodOptions = const [],
    this.quote,
    this.companionMessage,
    this.companionAsset,
    this.appTheme,
    this.breathingExercises = const [],
    this.billingPlans = const [],
  });

  final List<BackendMoodOption> moodOptions;
  final BackendQuote? quote;
  final BackendCompanionMessage? companionMessage;
  final BackendCompanionAsset? companionAsset;
  final BackendAppTheme? appTheme;
  final List<BackendBreathingExercise> breathingExercises;
  final List<BackendBillingPlan> billingPlans;

  int get loadedSections {
    var count = 0;
    if (moodOptions.isNotEmpty) count++;
    if (quote != null) count++;
    if (companionMessage != null) count++;
    if (companionAsset != null) count++;
    if (appTheme != null) count++;
    if (breathingExercises.isNotEmpty) count++;
    if (billingPlans.isNotEmpty) count++;
    return count;
  }

  bool get hasData => loadedSections > 0;
}

abstract class MobileContentRepository {
  Future<MobileContentSnapshot> fetchSnapshot();
}

class MobileContentService implements MobileContentRepository {
  MobileContentService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<MobileContentSnapshot> fetchSnapshot() async {
    final results = await Future.wait<Object?>([
      _safeGet('/mood-checkins/options'),
      _safeGet('/cozy-quotes/random'),
      _safeGet('/companion-messages/random'),
      _safeGet('/companion-assets/default'),
      _safeGet('/app-themes/default'),
      _safeGet('/breathing-exercises?limit=8'),
      _safeGet('/billing/plans'),
    ]);

    final moods = _readItems(
      results[0],
    ).map(BackendMoodOption.fromJson).toList(growable: false);
    final quoteMap = _readMap(results[1]);
    final messageMap = _readMap(results[2]);
    final assetMap = _readMap(results[3]);
    final themeMap = _readMap(results[4]);
    final breathing = _readItems(
      results[5],
    ).map(BackendBreathingExercise.fromJson).toList(growable: false);
    final plans = _readItems(
      results[6],
    ).map(BackendBillingPlan.fromJson).toList(growable: false);

    return MobileContentSnapshot(
      moodOptions: moods,
      quote: quoteMap.isEmpty ? null : BackendQuote.fromJson(quoteMap),
      companionMessage: messageMap.isEmpty
          ? null
          : BackendCompanionMessage.fromJson(messageMap),
      companionAsset: assetMap.isEmpty
          ? null
          : BackendCompanionAsset.fromJson(assetMap),
      appTheme: themeMap.isEmpty ? null : BackendAppTheme.fromJson(themeMap),
      breathingExercises: breathing,
      billingPlans: plans,
    );
  }

  Future<Object?> _safeGet(String path) async {
    try {
      return await _apiClient.getJson(path);
    } catch (_) {
      return null;
    }
  }

  List<Map<String, Object?>> _readItems(Object? value) {
    if (value is List) return _readList(value);
    if (value is Map) {
      final items = value['items'];
      if (items is List) return _readList(items);
      final data = value['data'];
      if (data is List) return _readList(data);
    }
    return const [];
  }

  List<Map<String, Object?>> _readList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(key.toString(), value as Object?),
          ),
        )
        .toList(growable: false);
  }

  Map<String, Object?> _readMap(Object? value) {
    if (value is! Map) return const {};
    return value.map(
      (key, value) => MapEntry(key.toString(), value as Object?),
    );
  }
}

class StaticMobileContentRepository implements MobileContentRepository {
  const StaticMobileContentRepository(this.snapshot);

  final MobileContentSnapshot snapshot;

  @override
  Future<MobileContentSnapshot> fetchSnapshot() async => snapshot;
}
