import 'package:flutter/material.dart';

/// Bảng màu khớp với web dashboard — copy từ `apps/web/tailwind.config.ts`
/// nên app + web có cùng "tông Relax".
class RelaxColors {
  static const violet = Color(0xFF7357F6);
  static const lilac = Color(0xFFDCD6FF);
  static const mint = Color(0xFF40C9A2);
  static const coral = Color(0xFFEF767A);
  static const sun = Color(0xFFF7C948);
  static const ink = Color(0xFF14122E);
  static const night = Color(0xFF1F1736);
  static const plum = Color(0xFF4B3360);
  static const mist = Color(0xFFEEEAF6);
  static const slate = Color(0xFF94A3B8);

  static const bgLight = Color(0xFFF5F3FF);
}

/// Theme dùng chung cho cả app. Material 3 + custom seed color
/// + text theme nghiêng về sans-serif đậm để hợp tone "calm but bold"
/// của web.
ThemeData buildRelaxTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RelaxColors.violet,
      brightness: Brightness.light,
      primary: RelaxColors.violet,
      secondary: RelaxColors.mint,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: RelaxColors.bgLight,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: RelaxColors.ink,
      displayColor: RelaxColors.ink,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RelaxColors.lilac),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RelaxColors.lilac),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RelaxColors.violet, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RelaxColors.coral),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RelaxColors.violet,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RelaxColors.violet,
        side: const BorderSide(color: RelaxColors.violet),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: RelaxColors.lilac),
      ),
    ),
  );
}
