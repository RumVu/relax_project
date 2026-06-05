part of 'package:relax_app/main.dart';

abstract class RelaxCatalogRepository {
  Future<List<BackendRelaxActivity>> fetchActivities();
}

class RelaxCatalogService implements RelaxCatalogRepository {
  RelaxCatalogService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<List<BackendRelaxActivity>> fetchActivities() async {
    final raw = await _apiClient.getJson('/relax-activities');
    final items = raw is List
        ? raw
        : raw is Map
        ? _itemsFromMap(raw)
        : const [];

    return items
        .whereType<Map>()
        .map(
          (item) => BackendRelaxActivity.fromJson(
            item.map(
              (key, value) => MapEntry(key.toString(), value as Object?),
            ),
          ),
        )
        .toList(growable: false);
  }

  List<Object?> _itemsFromMap(Map<dynamic, dynamic> raw) {
    final items = raw['items'];
    if (items is List) return items.cast<Object?>();
    final data = raw['data'];
    if (data is List) return data.cast<Object?>();
    return const [];
  }
}

class StaticRelaxCatalogRepository implements RelaxCatalogRepository {
  const StaticRelaxCatalogRepository(this.activities);

  final List<BackendRelaxActivity> activities;

  @override
  Future<List<BackendRelaxActivity>> fetchActivities() async => activities;
}
