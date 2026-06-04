import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Giữ chế độ giao diện (sáng / tối / theo hệ thống) và lưu lựa chọn của
/// người dùng vào secure storage để lần mở app sau vẫn nhớ.
class ThemeController extends ChangeNotifier {
  ThemeController() {
    _restore();
  }

  static const _key = 'relax_theme_mode';
  final _storage = const FlutterSecureStorage();

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> _restore() async {
    final saved = await _storage.read(key: _key);
    switch (saved) {
      case 'light':
        _mode = ThemeMode.light;
        break;
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      default:
        _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await _storage.write(
      key: _key,
      value: switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }
}
