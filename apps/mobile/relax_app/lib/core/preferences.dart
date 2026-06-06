import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/app_copy.dart';

/// Lưu trữ preferences đơn giản qua SharedPreferences.
/// Theme mode, language, và các cài đặt nhẹ khác.
class AppPreferences {
  AppPreferences._(this._prefs);

  static AppPreferences? _instance;

  static Future<AppPreferences> instance() async {
    _instance ??= AppPreferences._(await SharedPreferences.getInstance());
    return _instance!;
  }

  final SharedPreferences _prefs;

  static const _kThemeMode = 'theme_mode';
  static const _kLanguage = 'language';
  static const _kReminderTime = 'reminder_time';
  static const _kSoundChoice = 'sound_choice';
  static const _kOnboardingDone = 'onboarding_done';

  // ── Theme ──────────────────────────────────────────────────────────────
  ThemeMode get themeMode {
    final v = _prefs.getString(_kThemeMode);
    return switch (v) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(
      _kThemeMode,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }

  // ── Language ───────────────────────────────────────────────────────────
  AppLanguage get language {
    final v = _prefs.getString(_kLanguage);
    return v == 'en' ? AppLanguage.en : AppLanguage.vi;
  }

  Future<void> setLanguage(AppLanguage lang) async {
    await _prefs.setString(_kLanguage, lang == AppLanguage.en ? 'en' : 'vi');
  }

  // ── Reminder time ──────────────────────────────────────────────────────
  String get reminderTime => _prefs.getString(_kReminderTime) ?? '21:00';
  Future<void> setReminderTime(String time) async {
    await _prefs.setString(_kReminderTime, time);
  }

  // ── Sound choice ───────────────────────────────────────────────────────
  String get soundChoice =>
      _prefs.getString(_kSoundChoice) ?? 'Tiếng mèo con kêu';
  Future<void> setSoundChoice(String name) async {
    await _prefs.setString(_kSoundChoice, name);
  }

  // ── Onboarding done ────────────────────────────────────────────────────
  /// true sau lần đầu user hoàn thành onboarding (bấm "Bắt đầu" hoặc đăng nhập).
  /// Lần mở app sau, splash sẽ skip thẳng vào login/shell.
  bool get onboardingDone => _prefs.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool done) async {
    await _prefs.setBool(_kOnboardingDone, done);
  }
}
