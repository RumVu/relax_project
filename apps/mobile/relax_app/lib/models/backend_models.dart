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

class BackendMoodOption {
  const BackendMoodOption({
    required this.mood,
    required this.label,
    required this.description,
    required this.companionLine,
    required this.iconKey,
    required this.recommendedActions,
  });

  final String mood;
  final String label;
  final String description;
  final String companionLine;
  final String iconKey;
  final List<String> recommendedActions;

  factory BackendMoodOption.fromJson(Map<String, Object?> json) {
    return BackendMoodOption(
      mood: _readString(json['mood'], fallback: 'NEUTRAL'),
      label: _readString(json['label'], fallback: 'Bình thường'),
      description: _readString(json['description']),
      companionLine: _readString(json['companionLine']),
      iconKey: _readString(json['iconKey']),
      recommendedActions:
          (json['recommendedActions'] is List
                  ? json['recommendedActions'] as List
                  : const [])
              .map((item) => item.toString())
              .toList(growable: false),
    );
  }
}

class BackendQuote {
  const BackendQuote({
    required this.content,
    required this.author,
    required this.mood,
  });

  final String content;
  final String? author;
  final String? mood;

  factory BackendQuote.fromJson(Map<String, Object?> json) {
    return BackendQuote(
      content: _readString(json['content']),
      author: _readNullableString(json['author']),
      mood: _readNullableString(json['mood']),
    );
  }
}

class BackendCompanionMessage {
  const BackendCompanionMessage({
    required this.content,
    required this.companionMood,
  });

  final String content;
  final String companionMood;

  factory BackendCompanionMessage.fromJson(Map<String, Object?> json) {
    return BackendCompanionMessage(
      content: _readString(json['content']),
      companionMood: _readString(json['companionMood'], fallback: 'CHILL'),
    );
  }
}

class BackendCompanionAsset {
  const BackendCompanionAsset({
    required this.name,
    required this.description,
    required this.previewImageUrl,
    required this.primaryColor,
    required this.accentColor,
  });

  final String name;
  final String description;
  final String? previewImageUrl;
  final String primaryColor;
  final String accentColor;

  factory BackendCompanionAsset.fromJson(Map<String, Object?> json) {
    return BackendCompanionAsset(
      name: _readString(json['name'], fallback: 'Thi Ai Companion'),
      description: _readString(json['description']),
      previewImageUrl: _readNullableString(json['previewImageUrl']),
      primaryColor: _readString(json['primaryColor'], fallback: '#6C4DE6'),
      accentColor: _readString(json['accentColor'], fallback: '#9C86FF'),
    );
  }
}

class BackendAppTheme {
  const BackendAppTheme({
    required this.name,
    required this.mode,
    required this.primaryColor,
    required this.accentColor,
  });

  final String name;
  final String mode;
  final String primaryColor;
  final String accentColor;

  factory BackendAppTheme.fromJson(Map<String, Object?> json) {
    return BackendAppTheme(
      name: _readString(json['name'], fallback: 'Default theme'),
      mode: _readString(json['mode'], fallback: 'SYSTEM'),
      primaryColor: _readString(json['primaryColor'], fallback: '#6C4DE6'),
      accentColor: _readString(json['accentColor'], fallback: '#9C86FF'),
    );
  }
}

class BackendBreathingExercise {
  const BackendBreathingExercise({
    required this.title,
    required this.description,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.cycles,
    required this.durationSeconds,
  });

  final String title;
  final String description;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int cycles;
  final int durationSeconds;

  factory BackendBreathingExercise.fromJson(Map<String, Object?> json) {
    return BackendBreathingExercise(
      title: _readString(json['title'], fallback: 'Bài thở'),
      description: _readString(json['description']),
      inhaleSeconds: _readInt(json['inhaleSeconds']),
      holdSeconds: _readInt(json['holdSeconds']),
      exhaleSeconds: _readInt(json['exhaleSeconds']),
      cycles: _readInt(json['cycles']),
      durationSeconds: _readInt(json['duration']),
    );
  }

  String get patternLabel => '$inhaleSeconds-$holdSeconds-$exhaleSeconds';
}

class BackendBillingPlan {
  const BackendBillingPlan({
    required this.name,
    required this.title,
    required this.description,
    required this.effectivePrice,
    required this.currency,
    required this.billingCycle,
  });

  final String name;
  final String title;
  final String description;
  final int effectivePrice;
  final String currency;
  final String billingCycle;

  factory BackendBillingPlan.fromJson(Map<String, Object?> json) {
    return BackendBillingPlan(
      name: _readString(json['name'], fallback: 'FREE'),
      title: _readString(json['title'], fallback: 'Free'),
      description: _readString(json['description']),
      effectivePrice: _readInt(json['effectivePrice']),
      currency: _readString(json['currency'], fallback: 'VND'),
      billingCycle: _readString(json['billingCycle'], fallback: 'MONTHLY'),
    );
  }

  String get priceLabel {
    if (effectivePrice <= 0) return 'Miễn phí';
    return '${effectivePrice ~/ 1000}k $currency/${billingCycle == 'ANNUAL' ? 'năm' : 'tháng'}';
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

Map<String, Object?> _readMap(Object? value) {
  if (value is! Map) return const {};
  return value.map((key, value) => MapEntry(key.toString(), value as Object?));
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

Color _colorFromHex(String value, Color fallback) {
  final sanitized = value.replaceFirst('#', '').trim();
  if (sanitized.length != 6) return fallback;
  final parsed = int.tryParse('FF$sanitized', radix: 16);
  if (parsed == null) return fallback;
  return Color(parsed);
}
