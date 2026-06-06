import 'package:flutter/material.dart';
import 'app_copy.dart';

class RelaxTheme {
  static const purple = Color(0xFF6C4DE6);
  static const lavender = Color(0xFF9C86FF);
  static const ink = Color(0xFF28225B);
  static const night = Color(0xFF121728);
  static const nightCard = Color(0xFF1A2135);
  static const mist = Color(0xFFF7F5FF);
  static const line = Color(0xFFC9BFFF);

  static ThemeData light({Color? accent}) {
    return _base(
      brightness: Brightness.light,
      scaffold: const Color(0xFFF8F6FF),
      surface: Colors.white,
      surfaceSoft: const Color(0xFFF0ECFF),
      text: ink,
      muted: const Color(0xFF746D9B),
      accent: accent ?? purple,
    );
  }

  static ThemeData dark({Color? accent}) {
    return _base(
      brightness: Brightness.dark,
      scaffold: night,
      surface: nightCard,
      surfaceSoft: const Color(0xFF222945),
      text: const Color(0xFFEDE8FF),
      muted: const Color(0xFFA8A2CA),
      accent: accent ?? purple,
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color surfaceSoft,
    required Color text,
    required Color muted,
    required Color accent,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      primary: accent,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: colorScheme,
      fontFamily: 'monospace',
      extensions: [
        RelaxColors(
          surfaceSoft: surfaceSoft,
          border: brightness == Brightness.dark
              ? const Color(0xFF343B63)
              : line,
          muted: muted,
          glow: brightness == Brightness.dark
              ? const Color(0xFF8E7BFF)
              : const Color(0xFFDED6FF),
          danger: const Color(0xFFE85A6A),
        ),
      ],
      textTheme: TextTheme(
        displaySmall: TextStyle(
          color: text,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          height: 1.05,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          height: 1.05,
        ),
        headlineSmall: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          height: 1.12,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(color: text, fontSize: 15, height: 1.45),
        bodyMedium: TextStyle(color: muted, fontSize: 13, height: 1.45),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class RelaxColors extends ThemeExtension<RelaxColors> {
  const RelaxColors({
    required this.surfaceSoft,
    required this.border,
    required this.muted,
    required this.glow,
    required this.danger,
  });

  final Color surfaceSoft;
  final Color border;
  final Color muted;
  final Color glow;
  final Color danger;

  @override
  RelaxColors copyWith({
    Color? surfaceSoft,
    Color? border,
    Color? muted,
    Color? glow,
    Color? danger,
  }) {
    return RelaxColors(
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      border: border ?? this.border,
      muted: muted ?? this.muted,
      glow: glow ?? this.glow,
      danger: danger ?? this.danger,
    );
  }

  @override
  RelaxColors lerp(ThemeExtension<RelaxColors>? other, double t) {
    if (other is! RelaxColors) return this;
    return RelaxColors(
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      border: Color.lerp(border, other.border, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension RelaxContext on BuildContext {
  RelaxColors get relax => Theme.of(this).extension<RelaxColors>()!;
  bool get dark => Theme.of(this).brightness == Brightness.dark;
  AppCopy get copy => AppCopyScope.of(this);
}
