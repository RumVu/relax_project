import 'package:flutter/material.dart';

import '../../../core/theme.dart';

// Mood emoji mapping for home screen.
String moodEmoji(String mood) {
  switch (mood) {
    case 'HAPPY':
      return '😺';
    case 'SAD':
      return '😿';
    case 'STRESSED':
      return '🙀';
    case 'TIRED':
      return '😾';
    case 'ANXIOUS':
      return '😼';
    case 'NEUTRAL':
      return '😐';
    case 'CALM':
      return '😌';
    case 'EXCITED':
      return '😸';
    case 'LONELY':
      return '🐱';
    case 'GRATEFUL':
      return '😻';
    case 'POOPING':
      return '💩';
    default:
      return '🐱';
  }
}

// Mood color mapping for tracking bars.
Color moodColor(String mood) {
  switch (mood) {
    case 'HAPPY':
    case 'GRATEFUL':
      return RelaxColors.sun;
    case 'STRESSED':
    case 'ANXIOUS':
      return RelaxColors.coral;
    case 'CALM':
    case 'EXCITED':
      return RelaxColors.mint;
    case 'POOPING':
      return const Color(0xFF8B4513);
    default:
      return RelaxColors.violet;
  }
}

// Weather icon mapping.
IconData weatherIcon(String? iconKey) {
  switch (iconKey) {
    case 'weather-sunny':
      return Icons.wb_sunny_outlined;
    case 'weather-night':
      return Icons.nightlight_round_outlined;
    case 'weather-rain':
      return Icons.umbrella_outlined;
    case 'weather-storm':
      return Icons.thunderstorm_outlined;
    case 'weather-cloudy':
      return Icons.cloud_outlined;
    default:
      return Icons.wb_sunny_outlined;
  }
}

// Weather icon color mapping.
Color weatherIconColor(String? iconKey) {
  switch (iconKey) {
    case 'weather-sunny':
      return RelaxColors.sun;
    case 'weather-night':
      return RelaxColors.lilac;
    case 'weather-rain':
    case 'weather-storm':
      return RelaxColors.violet;
    case 'weather-cloudy':
      return RelaxColors.slate;
    default:
      return RelaxColors.sun;
  }
}

// Dominant mood computation from counts map.
String dominantMood(Map<String, int> moodCounts) {
  if (moodCounts.isEmpty) return 'calm';
  final top = moodCounts.entries
      .reduce((a, b) => a.value >= b.value ? a : b)
      .key
      .toLowerCase();
  const map = {
    'happy': 'happy',
    'joyful': 'happy',
    'sad': 'sad',
    'down': 'sad',
    'angry': 'energetic',
    'anxious': 'energetic',
    'stressed': 'energetic',
    'calm': 'calm',
    'relaxed': 'calm',
    'neutral': 'neutral',
    'okay': 'neutral',
  };
  return map[top] ?? 'calm';
}
