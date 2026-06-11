import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

class MoodGrid extends StatelessWidget {
  const MoodGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((o) {
        final mood = o['mood'] as String;
        final label = (o['label'] as String?) ?? mood;
        final isSel = selected == mood;
        return GestureDetector(
          onTap: () => onSelect(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSel ? RelaxColors.violet : context.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSel ? RelaxColors.violet : context.fieldBorder,
                width: isSel ? 2 : 1,
              ),
            ),
            child: Text(
              context.t(label),
              style: TextStyle(
                color: isSel ? Colors.white : context.appText,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
