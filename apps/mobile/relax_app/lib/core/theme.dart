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

  // Dark-mode surfaces — navy sâu giống mockup.
  static const bgDark = Color(0xFF0E0C1F);
  static const surfaceDark = Color(0xFF1A1733);
  static const surfaceDark2 = Color(0xFF221E3D);
  static const borderDark = Color(0xFF2E2A4A);
  static const textDark = Color(0xFFE8E4F6);
  static const mutedDark = Color(0xFF9A93BE);
}

InputDecorationTheme _inputTheme({
  required Color fill,
  required Color border,
}) {
  OutlineInputBorder ob(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecorationTheme(
    filled: true,
    fillColor: fill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: ob(border),
    enabledBorder: ob(border),
    focusedBorder: ob(RelaxColors.violet, 2),
    errorBorder: ob(RelaxColors.coral),
  );
}

ButtonStyle _elevatedStyle() => ElevatedButton.styleFrom(
      backgroundColor: RelaxColors.violet,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );

ButtonStyle _outlinedStyle() => OutlinedButton.styleFrom(
      foregroundColor: RelaxColors.violet,
      side: const BorderSide(color: RelaxColors.violet),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

/// Theme sáng.
ThemeData buildRelaxTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
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
    textTheme: base.textTheme
        .apply(bodyColor: RelaxColors.ink, displayColor: RelaxColors.ink),
    inputDecorationTheme:
        _inputTheme(fill: Colors.white, border: RelaxColors.lilac),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedStyle()),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedStyle()),
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

/// Theme tối — navy sâu khớp mockup dark mode.
ThemeData buildRelaxDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RelaxColors.violet,
      brightness: Brightness.dark,
      primary: RelaxColors.violet,
      secondary: RelaxColors.mint,
      surface: RelaxColors.surfaceDark,
    ),
    scaffoldBackgroundColor: RelaxColors.bgDark,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: RelaxColors.textDark,
      displayColor: RelaxColors.textDark,
    ),
    inputDecorationTheme: _inputTheme(
      fill: RelaxColors.surfaceDark2,
      border: RelaxColors.borderDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedStyle()),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedStyle()),
    cardTheme: CardThemeData(
      color: RelaxColors.surfaceDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: RelaxColors.borderDark),
      ),
    ),
  );
}

/// Helper đọc màu theo brightness hiện tại — để screen không phải hardcode
/// `Colors.white` / `RelaxColors.ink` rồi vỡ ở dark mode.
extension RelaxThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Nền của card / ô input.
  Color get surface => isDark ? RelaxColors.surfaceDark : Colors.white;

  /// Nền nổi hơn surface một chút (vd field bên trong card).
  Color get surfaceAlt =>
      isDark ? RelaxColors.surfaceDark2 : RelaxColors.bgLight;

  /// Chữ chính.
  Color get appText => isDark ? RelaxColors.textDark : RelaxColors.ink;

  /// Chữ phụ / mô tả.
  Color get mutedText => isDark ? RelaxColors.mutedDark : RelaxColors.slate;

  /// Viền nhẹ của card.
  Color get fieldBorder =>
      isDark ? RelaxColors.borderDark : RelaxColors.lilac;
}
