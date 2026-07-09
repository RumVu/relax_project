import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../core/vault_lock.dart';
import 'settings_shared.dart';

class PrivateAiToggleRow extends StatefulWidget {
  const PrivateAiToggleRow({super.key});

  @override
  State<PrivateAiToggleRow> createState() => _PrivateAiToggleRowState();
}

class _PrivateAiToggleRowState extends State<PrivateAiToggleRow> {
  bool _enabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final val = await VaultLock.getPrivateAiMode();
    if (mounted) setState(() { _enabled = val; _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return SettingsRow(
      icon: Icons.smart_toy_outlined,
      title: context.t('Chế độ AI riêng tư'),
      subtitle: _enabled
          ? context.t('Nhật ký sẽ KHÔNG được gửi cho AI phân tích')
          : context.t('AI có thể đọc nhật ký để gợi ý cảm xúc'),
      trailing: Switch.adaptive(
        value: _enabled,
        activeTrackColor: RelaxColors.violet,
        onChanged: (val) async {
          await VaultLock.setPrivateAiMode(val);
          setState(() => _enabled = val);
        },
      ),
      onTap: () {},
    );
  }
}
