import 'package:flutter/material.dart';
import 'secure_storage.dart';

import 'theme.dart';

/// Giữ chế độ giao diện (sáng / tối / theo hệ thống) + màu nhấn (accent) và
/// lưu lựa chọn của người dùng vào secure storage để lần mở app sau vẫn nhớ.
class ThemeController extends ChangeNotifier {
  ThemeController() {
    _restore();
  }

  static const _modeKey = 'relax_theme_mode';
  static const _accentKey = 'relax_accent_color';
  final _storage = secureStorage;

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Bảng màu nhấn cho user chọn — tên gọi gợi cảm xúc, không kỹ thuật.
  static const palette = <({String name, Color color})>[
    (name: 'Tím Relax', color: RelaxColors.violet),
    (name: 'Bạc hà', color: RelaxColors.mint),
    (name: 'San hô', color: RelaxColors.coral),
    (name: 'Nắng vàng', color: RelaxColors.sun),
    (name: 'Hoa cà', color: Color(0xFFB084EE)),
    (name: 'Biển sâu', color: Color(0xFF3A7BD5)),
  ];

  Color _accent = RelaxColors.violet;
  Color get accent => _accent;

  Future<void> _restore() async {
    final savedMode = await _storage.read(key: _modeKey);
    switch (savedMode) {
      case 'light':
        _mode = ThemeMode.light;
        break;
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      default:
        _mode = ThemeMode.system;
    }
    final savedAccent = await _storage.read(key: _accentKey);
    if (savedAccent != null) {
      final v = int.tryParse(savedAccent);
      if (v != null) _accent = Color(v);
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await _storage.write(
      key: _modeKey,
      value: switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }

  Future<void> setAccent(Color color) async {
    _accent = color;
    notifyListeners();
    // ignore: deprecated_member_use
    await _storage.write(key: _accentKey, value: color.value.toString());
  }
}
