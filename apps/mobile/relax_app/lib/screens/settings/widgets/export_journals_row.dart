import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/api_client.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../core/vault_lock.dart';
import '../../../widgets/soft_toast.dart';
import 'settings_shared.dart';

class ExportJournalsRow extends StatefulWidget {
  const ExportJournalsRow({super.key});

  @override
  State<ExportJournalsRow> createState() => _ExportJournalsRowState();
}

class _ExportJournalsRowState extends State<ExportJournalsRow> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final res = await RelaxApi.instance
          .get('/journals/me', query: {'limit': 999});
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      final journals = (items is List)
          ? items
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      if (journals.isEmpty) {
        if (mounted) {
          showSoftToast(context,
              message: context.t('Không có nhật ký nào để xuất'),
              tone: SoftToastTone.info);
        }
        return;
      }

      final text = await VaultLock.exportJournals(journals);

      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        showSoftToast(context,
            message: context.t('Đã sao chép {count} nhật ký vào clipboard', {
              'count': journals.length.toString(),
            }),
            tone: SoftToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: e.toString(), tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: Icons.download_outlined,
      title: context.t('Xuất nhật ký'),
      subtitle: context.t('Sao chép toàn bộ nhật ký dạng văn bản'),
      trailing: _exporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: RelaxColors.violet,
              ),
            )
          : const Icon(Icons.chevron_right, color: RelaxColors.slate),
      onTap: _exporting ? () {} : _export,
    );
  }
}
