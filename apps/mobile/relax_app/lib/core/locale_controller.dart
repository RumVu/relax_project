import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Quản lý ngôn ngữ hiển thị của app (Tiếng Việt / English), lưu vào secure
/// storage và phát ChangeNotifier khi đổi.
class LocaleController extends ChangeNotifier {
  LocaleController() {
    _restore();
  }

  static const _key = 'relax_locale';
  final _storage = const FlutterSecureStorage();

  String _code = 'vi';
  String get code => _code;
  Locale get locale => Locale(_code);

  Future<void> _restore() async {
    final saved = await _storage.read(key: _key);
    if (saved == 'en' || saved == 'vi') {
      _code = saved!;
      notifyListeners();
    }
  }

  Future<void> set(String code) async {
    if (code != 'vi' && code != 'en') return;
    _code = code;
    notifyListeners();
    await _storage.write(key: _key, value: code);
  }
}

/// Bảng dịch toàn cục — load từ JSON asset thay vì hardcode.
/// Cách dùng: `context.t('Đăng nhập')` ở bất kỳ widget nào có context.
class Translations {
  static Map<String, String> _en = {};

  /// Gọi 1 lần khi app khởi động (trước runApp).
  static Future<void> load() async {
    final raw = await rootBundle.loadString('assets/lang/en.json');
    _en = Map<String, String>.from(json.decode(raw) as Map);
  }

  static String t(String key, String lang) {
    if (lang == 'en') return _en[key] ?? key;
    return key; // vi là nguồn → trả nguyên
  }
}

extension TranslateX on BuildContext {
  String t(String key, [Map<String, String>? args]) {
    // Tránh import provider ở mọi file — dùng InheritedNotifier qua lookup
    // bằng cách đọc element tree. Caller phải watch LocaleController ở
    // build() nếu muốn rebuild khi đổi ngôn ngữ.
    String val = Translations.t(key, _LocaleScope.of(this));
    if (args != null) {
      args.forEach((k, v) {
        val = val.replaceAll('{$k}', v);
      });
    }
    return val;
  }
}

/// InheritedWidget mỏng để truyền lang code xuống dưới mà không cần Provider
/// import — đặt ở gốc cây bởi `LocaleScope`.
class LocaleScope extends InheritedWidget {
  const LocaleScope({super.key, required this.lang, required super.child});
  final String lang;

  static String of(BuildContext c) {
    final s = c.dependOnInheritedWidgetOfExactType<LocaleScope>();
    return s?.lang ?? 'vi';
  }

  @override
  bool updateShouldNotify(LocaleScope old) => old.lang != lang;
}

class _LocaleScope {
  static String of(BuildContext c) => LocaleScope.of(c);
}
