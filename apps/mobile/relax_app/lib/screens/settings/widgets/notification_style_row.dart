import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';
import 'settings_shared.dart';

class NotificationStyleRow extends StatefulWidget {
  const NotificationStyleRow({super.key});

  @override
  State<NotificationStyleRow> createState() => _NotificationStyleRowState();
}

class _NotificationStyleRowState extends State<NotificationStyleRow> {
  String _style = 'Gentle';

  final Map<String, String> _previews = {
    'Gentle': '"Nghỉ một chút nha bạn ơi."',
    'Funny': '"Não bạn đang quá tải rồi, cho nó thở đi thôi!"',
    'Minimal': '"2-minute break."',
    'Companion': '"Linh thú: Meow! Hãy dừng lại hít thở một tẹo nào."',
    'Silent': 'Chỉ hiện huy hiệu ứng dụng (Silent)',
  };

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: Icons.notifications_active_outlined,
      title: context.t('Phong cách thông báo'),
      subtitle: '${context.t("Đang chọn")}: $_style',
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showStyleChooser(context),
    );
  }

  void _showStyleChooser(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.t('Phong cách Thông báo (Lab) 🧪'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.t('Chọn phong cách nhắc nhở thư giãn phù hợp nhất với bạn.'),
                    style: TextStyle(fontSize: 12, color: context.mutedText),
                  ),
                  const SizedBox(height: 16),
                  ..._previews.keys.map((style) {
                    final selected = _style == style;
                    return InkWell(
                      onTap: () {
                        setState(() => _style = style);
                        setModalState(() {});
                        showSoftToast(
                          context,
                          message: '${context.t("Đã chuyển sang phong cách:")} $style 🔔',
                          tone: SoftToastTone.success,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: selected ? RelaxColors.violet.withValues(alpha: 0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: selected ? RelaxColors.violet : context.mutedText,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.t(style),
                                    style: TextStyle(
                                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                      color: context.appText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.t(_previews[style]!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: context.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
