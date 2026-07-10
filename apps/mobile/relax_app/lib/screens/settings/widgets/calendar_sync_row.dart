import 'package:flutter/material.dart';

import '../../../core/calendar_integration_service.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';
import 'settings_shared.dart';

class CalendarSyncToggleRow extends StatefulWidget {
  const CalendarSyncToggleRow({super.key});

  @override
  State<CalendarSyncToggleRow> createState() => _CalendarSyncToggleRowState();
}

class _CalendarSyncToggleRowState extends State<CalendarSyncToggleRow> {
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final service = CalendarIntegrationService.instance;
    return SettingsRow(
      icon: Icons.calendar_today_outlined,
      title: context.t('Đồng bộ Lịch cá nhân'),
      subtitle: service.isSynced
          ? context.t('Đã đồng bộ. Gợi ý wellness sẽ cập nhật theo lịch làm việc.')
          : context.t('Đồng bộ Google/Apple Calendar để tự động gợi ý bài tập'),
      trailing: _syncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: RelaxColors.violet),
            )
          : Switch.adaptive(
              value: service.isSynced,
              activeTrackColor: RelaxColors.violet,
              onChanged: (val) async {
                setState(() => _syncing = true);
                await service.toggleSync();
                setState(() => _syncing = false);
                if (!mounted) return;
                showSoftToast(
                  // ignore: use_build_context_synchronously
                  context,
                  message: service.isSynced
                      // ignore: use_build_context_synchronously
                      ? context.t('Đã đồng bộ lịch thành công 📅')
                      // ignore: use_build_context_synchronously
                      : context.t('Đã tắt đồng bộ lịch'),
                  tone: SoftToastTone.success,
                );
              },
            ),
      onTap: () {},
    );
  }
}
