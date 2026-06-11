import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme_controller.dart';

/// Chip màu để user đổi accent color cho toàn app — màu nhấn của nút, biểu
/// đồ, focus ring. Lưu vào ThemeController + secure storage, đổi ngay tức
/// thì nhờ MaterialApp.theme rebuild.
class AccentPickerCard extends StatelessWidget {
  const AccentPickerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeController>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('Màu nhấn'),
            style: TextStyle(
              color: context.appText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.t('Chọn tông gần với cảm xúc bạn đang muốn nuôi dưỡng'),
            style: TextStyle(color: context.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final p in ThemeController.palette)
                GestureDetector(
                  // ignore: deprecated_member_use
                  onTap: () => context.read<ThemeController>().setAccent(p.color),
                  child: Tooltip(
                    message: p.name,
                    child: Container(
                      // ignore: deprecated_member_use
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: p.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: t.accent.value == p.color.value
                              ? context.appText
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: p.color.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      // ignore: deprecated_member_use
                      child: t.accent.value == p.color.value
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
