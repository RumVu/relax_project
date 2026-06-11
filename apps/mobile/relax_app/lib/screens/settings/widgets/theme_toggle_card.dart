import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme_controller.dart';

/// Bộ chọn giao diện Sáng / Tối / Hệ thống — lưu ngay qua ThemeController.
class ThemeToggleCard extends StatelessWidget {
  const ThemeToggleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final mode = controller.mode;
    Widget option(ThemeMode m, IconData icon, String label) {
      final selected = mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            controller.setMode(m);
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? RelaxColors.violet : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : context.mutedText,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  context.t(label),
                  style: TextStyle(
                    color: selected ? Colors.white : context.mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          option(ThemeMode.light, Icons.light_mode_outlined, 'Sáng'),
          option(ThemeMode.dark, Icons.dark_mode_outlined, 'Tối'),
          option(ThemeMode.system, Icons.brightness_auto_outlined, 'Hệ thống'),
        ],
      ),
    );
  }
}
