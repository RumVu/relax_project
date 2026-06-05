part of 'package:relax_app/main.dart';

class BackendRelaxActivity {
  const BackendRelaxActivity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.defaultDurationMinutes,
    required this.resources,
  });

  final String type;
  final String title;
  final String subtitle;
  final String description;
  final int defaultDurationMinutes;
  final List<BackendResource> resources;

  factory BackendRelaxActivity.fromJson(Map<String, Object?> json) {
    final resources = _readList(json['resources'])
        .map(BackendResource.fromJson)
        .where((resource) => resource.title.isNotEmpty)
        .toList(growable: false);

    return BackendRelaxActivity(
      type: _readString(json['type'], fallback: 'MUSIC'),
      title: _readString(json['title'], fallback: 'Thư giãn'),
      subtitle: _readString(json['subtitle']),
      description: _readString(json['description']),
      defaultDurationMinutes: _readInt(json['defaultDurationMinutes']),
      resources: resources,
    );
  }
}

class BackendResource {
  const BackendResource({
    required this.id,
    required this.title,
    required this.category,
    required this.durationSeconds,
    required this.soundUrl,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String category;
  final int durationSeconds;
  final String? soundUrl;
  final String? imageUrl;

  factory BackendResource.fromJson(Map<String, Object?> json) {
    return BackendResource(
      id: _readString(json['id']),
      title: _readString(json['title'], fallback: 'Nội dung thư giãn'),
      category: _readString(json['category'], fallback: 'CONTENT'),
      durationSeconds: _readInt(json['duration']),
      soundUrl: _readNullableString(json['soundUrl']),
      imageUrl: _readNullableString(json['imageUrl']),
    );
  }

  String get durationLabel {
    if (durationSeconds <= 0) return '--:--';
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
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

String _readString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String? _readNullableString(Object? value) {
  final text = _readString(value);
  return text.isEmpty ? null : text;
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
