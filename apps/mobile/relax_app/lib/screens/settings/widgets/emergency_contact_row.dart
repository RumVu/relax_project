import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import 'settings_shared.dart';

class EmergencyContactRow extends StatefulWidget {
  const EmergencyContactRow({super.key});

  @override
  State<EmergencyContactRow> createState() => _EmergencyContactRowState();
}

class _EmergencyContactRowState extends State<EmergencyContactRow> {
  String _contact = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox('emergency_contact');
    if (mounted) {
      setState(() {
        _contact = box.get('contact', defaultValue: '') as String;
        _loaded = true;
      });
    }
  }

  Future<void> _edit() async {
    final ctrl = TextEditingController(text: _contact);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t('Liên hệ khẩn cấp')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t('Số điện thoại người thân tin tưởng. Sẽ hiện khi phát hiện dấu hiệu cần hỗ trợ.'),
              style: TextStyle(color: context.mutedText, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: context.t('Số điện thoại'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t('Hủy')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(context.t('Lưu')),
          ),
        ],
      ),
    );
    if (result != null) {
      final box = await Hive.openBox('emergency_contact');
      await box.put('contact', result);
      if (mounted) setState(() => _contact = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return SettingsRow(
      icon: Icons.contact_phone_outlined,
      title: context.t('Liên hệ khẩn cấp'),
      subtitle: _contact.isEmpty
          ? context.t('Thêm số người thân tin tưởng')
          : _contact,
      onTap: _edit,
    );
  }
}
