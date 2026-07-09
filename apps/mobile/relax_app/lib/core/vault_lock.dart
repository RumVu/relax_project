import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

import 'locale_controller.dart';
import 'theme.dart';

/// Private Vault — PIN lock + biometric + auto-lock + privacy controls
/// for journal entries. Uses Hive for all local storage.
class VaultLock {
  VaultLock._();
  static final VaultLock instance = VaultLock._();

  static const _boxName = 'vault_lock';
  static const _settingsBoxName = 'vault_settings';

  Future<Box<dynamic>> get _box async => Hive.openBox(_boxName);
  static Future<Box<dynamic>> get _settingsBox async =>
      Hive.openBox(_settingsBoxName);

  // ---------------------------------------------------------------------------
  // PIN management
  // ---------------------------------------------------------------------------

  Future<bool> get isEnabled async {
    final box = await _box;
    return box.get('pin') != null;
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  static String _hashPin(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  Future<void> setPin(String pin) async {
    final box = await _box;
    final salt = _generateSalt();
    await box.put('pin_salt', salt);
    await box.put('pin', _hashPin(pin, salt));
  }

  Future<void> removePin() async {
    final box = await _box;
    await box.delete('pin');
    await box.delete('pin_salt');
  }

  Future<bool> verify(String pin) async {
    final box = await _box;
    final stored = box.get('pin') as String?;
    if (stored == null) return false;
    final salt = box.get('pin_salt') as String?;
    if (salt == null) {
      // Legacy: migrate old hashCode-based PIN on next setPin
      return stored == pin.hashCode.toString();
    }
    return stored == _hashPin(pin, salt);
  }

  // ---------------------------------------------------------------------------
  // Biometric support
  // ---------------------------------------------------------------------------

  static final _localAuth = LocalAuthentication();

  static Future<bool> unlockBiometric(BuildContext context) async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheck && !isDeviceSupported) return false;

      // ignore: use_build_context_synchronously
      return await _localAuth.authenticate(
        localizedReason: context.t('Mở khóa nhật ký'),
        biometricOnly: true,
      );
    } on PlatformException {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Unlock — biometric first, then PIN fallback
  // ---------------------------------------------------------------------------

  /// Show PIN entry dialog. Tries biometric first, falls back to PIN.
  /// Returns true if unlocked, false if cancelled.
  static Future<bool> unlock(BuildContext context) async {
    final enabled = await VaultLock.instance.isEnabled;
    if (!enabled) return true;

    // Try biometric first
    // ignore: use_build_context_synchronously
    final biometricOk = await unlockBiometric(context);
    if (biometricOk) return true;

    // Fallback to PIN dialog
    final result = await showDialog<bool>(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _PinDialog(),
    );
    return result == true;
  }

  /// Show setup dialog to create or change PIN.
  static Future<bool> setupPin(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _SetupPinDialog(),
    );
    return result == true;
  }

  // ---------------------------------------------------------------------------
  // Auto-lock — lock after 60s in background
  // ---------------------------------------------------------------------------

  static const _autoLockDuration = Duration(seconds: 60);

  /// Check whether the app should auto-lock (was in background > 60s).
  static Future<bool> shouldAutoLock() async {
    final box = await Hive.openBox(_boxName);
    final lastActive = box.get('last_active_time') as int?;
    if (lastActive == null) return false;
    final elapsed =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastActive));
    return elapsed > _autoLockDuration;
  }

  /// Call when the app is active / in foreground to refresh the timer.
  static Future<void> markActive() async {
    final box = await Hive.openBox(_boxName);
    await box.put('last_active_time', DateTime.now().millisecondsSinceEpoch);
  }

  /// Call when the app goes to background to record the time.
  static Future<void> markInactive() async {
    final box = await Hive.openBox(_boxName);
    await box.put('last_active_time', DateTime.now().millisecondsSinceEpoch);
  }

  // ---------------------------------------------------------------------------
  // Hide preview — hide journal content in list
  // ---------------------------------------------------------------------------

  /// When true, journal list should show "Nội dung đã ẩn" instead of preview.
  static Future<bool> getHidePreview() async {
    final box = await _settingsBox;
    return box.get('hide_preview', defaultValue: false) as bool;
  }

  static bool get hidePreview {
    final box = Hive.box(_settingsBoxName);
    return box.get('hide_preview', defaultValue: false) as bool;
  }

  static Future<void> setHidePreview(bool value) async {
    final box = await _settingsBox;
    await box.put('hide_preview', value);
  }

  // ---------------------------------------------------------------------------
  // Private AI mode — prevent journal content from being sent to AI
  // ---------------------------------------------------------------------------

  /// When true, journal content should NOT be sent to AI companion.
  static Future<bool> getPrivateAiMode() async {
    final box = await _settingsBox;
    return box.get('private_ai_mode', defaultValue: false) as bool;
  }

  static bool get privateAiMode {
    final box = Hive.box(_settingsBoxName);
    return box.get('private_ai_mode', defaultValue: false) as bool;
  }

  static Future<void> setPrivateAiMode(bool value) async {
    final box = await _settingsBox;
    await box.put('private_ai_mode', value);
  }

  // ---------------------------------------------------------------------------
  // Export journals — formatted text output
  // ---------------------------------------------------------------------------

  static String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $h:$min';
  }

  /// Create a nicely formatted text export of all provided journals.
  /// Returns the full text content ready to be saved or shared.
  static Future<String> exportJournals(
      List<Map<String, dynamic>> journals) async {
    final buf = StringBuffer();
    buf.writeln('═══════════════════════════════════════');
    buf.writeln('  NHẬT KÝ CÁ NHÂN — Relax App');
    buf.writeln('  Xuất ngày: ${_formatDate(DateTime.now())}');
    buf.writeln('  Tổng số: ${journals.length} bài viết');
    buf.writeln('═══════════════════════════════════════');
    buf.writeln();

    for (var i = 0; i < journals.length; i++) {
      final j = journals[i];
      final title = (j['title'] as String?) ?? 'Không tiêu đề';
      final content = (j['content'] as String?) ?? '';
      final createdAt = j['createdAt'] as String?;
      final mood = (j['mood'] as String?) ?? '';
      final fav = j['isFavorite'] == true || j['favorite'] == true;

      String dateStr = '';
      if (createdAt != null) {
        try {
          final dt = DateTime.parse(createdAt);
          dateStr = _formatDate(dt);
        } catch (_) {
          dateStr = createdAt;
        }
      }

      buf.writeln('───────────────────────────────────────');
      buf.writeln('📝 #${i + 1}  ${fav ? '❤️ ' : ''}$title');
      if (dateStr.isNotEmpty) buf.writeln('📅 $dateStr');
      if (mood.isNotEmpty) buf.writeln('🎭 $mood');
      buf.writeln('');
      buf.writeln(content);
      buf.writeln();
    }

    buf.writeln('═══════════════════════════════════════');
    buf.writeln('  Hết.');
    buf.writeln('═══════════════════════════════════════');

    return buf.toString();
  }

  // ---------------------------------------------------------------------------
  // Ensure vault_settings box is opened (call during app init)
  // ---------------------------------------------------------------------------

  /// Open the vault_settings box. Call this during app startup so that
  /// synchronous getters (hidePreview, privateAiMode) work.
  static Future<void> ensureInitialized() async {
    await Hive.openBox(_settingsBoxName);
  }
}

class _PinDialog extends StatefulWidget {
  const _PinDialog();

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _ctrl = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _ctrl.text.trim();
    if (pin.isEmpty) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    final ok = await VaultLock.instance.verify(pin);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _checking = false;
        _error = context.t('Mã PIN không đúng');
        _ctrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('🔒 ', style: TextStyle(fontSize: 22)),
          Text(context.t('Nhật ký riêng tư')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.t('Nhập mã PIN để mở khóa nhật ký.'),
            style: TextStyle(color: context.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '••••',
              errorText: _error,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.t('Hủy')),
        ),
        ElevatedButton(
          onPressed: _checking ? null : _submit,
          child: _checking
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.t('Mở khóa')),
        ),
      ],
    );
  }
}

class _SetupPinDialog extends StatefulWidget {
  const _SetupPinDialog();

  @override
  State<_SetupPinDialog> createState() => _SetupPinDialogState();
}

class _SetupPinDialogState extends State<_SetupPinDialog> {
  final _pinCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _pinCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (pin.length < 4) {
      setState(() => _error = context.t('PIN phải có ít nhất 4 ký tự'));
      return;
    }
    if (pin != confirm) {
      setState(() => _error = context.t('PIN xác nhận không khớp'));
      return;
    }
    await VaultLock.instance.setPin(pin);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('🔐 ', style: TextStyle(fontSize: 22)),
          Text(context.t('Đặt mã PIN')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            autofocus: true,
            decoration: InputDecoration(
              labelText: context.t('Mã PIN mới'),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: context.t('Xác nhận PIN'),
              errorText: _error,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.t('Hủy')),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(context.t('Lưu')),
        ),
      ],
    );
  }
}
