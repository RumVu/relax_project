import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../shared/painters/pixel_scene_painter.dart';
import 'backend_models.dart';

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
  const MoodOption(this.label, this.icon, this.percent, {this.code});

  final String label;
  final IconData icon;
  final int percent;

  /// Mã backend (HAPPY / SAD / STRESSED…). Cần để POST `/mood-checkins/me`.
  /// `null` cho các mood mẫu trong [AppCopy] khi backend chưa trả gì.
  final String? code;

  factory MoodOption.fromBackend(BackendMoodOption option, int index) {
    final icon = switch (option.mood) {
      'HAPPY' => Icons.sentiment_very_satisfied_rounded,
      'SAD' => Icons.sentiment_dissatisfied_rounded,
      'STRESSED' => Icons.psychology_alt_rounded,
      'TIRED' => Icons.cloudy_snowing,
      'ANXIOUS' => Icons.battery_1_bar_rounded,
      'CALM' => Icons.spa_rounded,
      'EXCITED' => Icons.local_fire_department_rounded,
      'LONELY' => Icons.nights_stay_rounded,
      'GRATEFUL' => Icons.favorite_rounded,
      _ => Icons.sentiment_neutral_rounded,
    };

    return MoodOption(
      option.label,
      icon,
      math.max(12, 82 - index * 6),
      code: option.mood,
    );
  }
}

class MethodOption {
  const MethodOption(this.label, this.icon);

  final String label;
  final IconData icon;

  factory MethodOption.fromAction(String action) {
    return switch (action) {
      'MEDITATION' => const MethodOption(
        'Thiền định',
        Icons.self_improvement_rounded,
      ),
      'BREATHING' => const MethodOption('Hít thở', Icons.cloud_queue_rounded),
      'JOURNAL' => const MethodOption('Viết nhật kí', Icons.edit_note_rounded),
      'MUSIC' => const MethodOption('Nghe nhạc', Icons.headphones_rounded),
      _ => MethodOption(action, Icons.spa_rounded),
    };
  }
}

class NavItem {
  const NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum CatScene { window, laptop, sleep, wave }
