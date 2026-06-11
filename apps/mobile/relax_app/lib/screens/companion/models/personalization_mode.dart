import 'package:flutter/material.dart';

/// A typed representation of a companion personalization mode entry.
class PersonalizationMode {
  const PersonalizationMode({
    required this.mode,
    required this.label,
    required this.icon,
  });

  /// The API mode key, e.g. 'DEFAULT', 'ZODIAC', 'CHINESE_ZODIAC', 'CUSTOM'.
  final String mode;

  /// The human-readable label (before translation).
  final String label;

  /// The icon displayed next to the mode.
  final IconData icon;
}

/// All available personalization modes.
const List<PersonalizationMode> personalizationModes = [
  PersonalizationMode(mode: 'DEFAULT', label: 'Mặc định', icon: Icons.pets),
  PersonalizationMode(mode: 'ZODIAC', label: 'Cung hoàng đạo', icon: Icons.star_border),
  PersonalizationMode(mode: 'CHINESE_ZODIAC', label: '12 con giáp', icon: Icons.calendar_month),
  PersonalizationMode(mode: 'CUSTOM', label: 'Tự chọn', icon: Icons.dashboard_customize),
];
