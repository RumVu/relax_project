import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../models/breathing_pattern.dart';

// Horizontal chip selector for breathing patterns.
class PatternPicker extends StatelessWidget {
  const PatternPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(breathingPatterns.length, (i) {
        final sel = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? RelaxColors.violet : context.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sel ? RelaxColors.violet : context.fieldBorder,
              ),
            ),
            child: Text(
              context.t(breathingPatterns[i].label),
              style: TextStyle(
                color: sel ? Colors.white : context.appText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
    );
  }
}
