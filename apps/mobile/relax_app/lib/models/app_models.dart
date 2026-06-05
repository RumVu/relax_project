part of 'package:relax_app/main.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.body,
    required this.scene,
  });

  final String title;
  final String body;
  final CatScene scene;
}

class Activity {
  const Activity(
    this.title,
    this.description,
    this.icon, {
    this.type = 'LOCAL',
    this.durationMinutes,
    this.reliefPercent,
    this.resources = const [],
  });

  final String title;
  final String description;
  final IconData icon;
  final String type;
  final int? durationMinutes;
  final int? reliefPercent;
  final List<BackendResource> resources;

  int get contentCount => resources.length;

  String get compactTitle => title.replaceFirst(RegExp(r'^\d+\.\s*'), '');

  factory Activity.fromBackend(BackendRelaxActivity activity) {
    final icon = switch (activity.type) {
      'MUSIC' => Icons.radio_rounded,
      'PODCAST' => Icons.mic_external_on_rounded,
      'JOURNAL' => Icons.menu_book_rounded,
      'BREATHING' => Icons.cloud_rounded,
      'MEDITATION' => Icons.self_improvement_rounded,
      'MYSTERY' => Icons.inventory_2_rounded,
      _ => Icons.spa_rounded,
    };

    return Activity(
      activity.title,
      activity.description.isNotEmpty
          ? activity.description
          : activity.subtitle,
      icon,
      type: activity.type,
      durationMinutes: activity.defaultDurationMinutes,
      reliefPercent: activity.resources.isEmpty ? 0 : 80,
      resources: activity.resources,
    );
  }
}

class MoodOption {
  const MoodOption(this.label, this.icon, this.percent);

  final String label;
  final IconData icon;
  final int percent;
}

class MethodOption {
  const MethodOption(this.label, this.icon);

  final String label;
  final IconData icon;
}

class NavItem {
  const NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum CatScene { window, laptop, sleep, wave }
