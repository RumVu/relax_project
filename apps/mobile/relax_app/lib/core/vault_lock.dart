import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'locale_controller.dart';
import 'theme.dart';

/// Private Vault — PIN lock for journal entries.
/// Uses Hive to store hashed PIN locally. No biometric for simplicity,
/// can add local_auth later.
class VaultLock {
  VaultLock._();
  static final VaultLock instance = VaultLock._();

  static const _boxName = 'vault_lock';

  Future<Box<dynamic>> get _box async => Hive.openBox(_boxName);

  Future<bool> get isEnabled async {
    final box = await _box;
    return box.get('pin') != null;
  }

  Future<void> setPin(String pin) async {
    final box = await _box;
    await box.put('pin', pin.hashCode.toString());
  }

  Future<void> removePin() async {
    final box = await _box;
    await box.delete('pin');
  }

  Future<bool> verify(String pin) async {
    final box = await _box;
    final stored = box.get('pin') as String?;
    return stored == pin.hashCode.toString();
  }

  /// Show PIN entry dialog. Returns true if unlocked, false if cancelled.
  static Future<bool> unlock(BuildContext context) async {
    final enabled = await VaultLock.instance.isEnabled;
    if (!enabled) return true;

    final result = await showDialog<bool>(
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
