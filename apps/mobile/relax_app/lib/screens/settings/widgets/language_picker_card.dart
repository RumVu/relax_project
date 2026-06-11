import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../core/locale_controller.dart';

/// Hai chip Tiếng Việt / English — đổi locale toàn app ngay tại chỗ.
class LanguagePickerCard extends StatelessWidget {
  const LanguagePickerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    Widget chip(String code, String label, String flag) {
      final selected = loc.code == code;
      return Expanded(
        child: GestureDetector(
          onTap: () => context.read<LocaleController>().set(code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 14),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : context.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : context.fieldBorder,
              ),
            ),
            child: Column(
              children: [
                Text(flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : context.appText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          chip('vi', 'Tiếng Việt', '🇻🇳'),
          chip('en', 'English', '🇬🇧'),
        ],
      ),
    );
  }
}
