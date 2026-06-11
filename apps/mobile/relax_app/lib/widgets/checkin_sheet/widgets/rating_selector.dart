import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

// 5-option rating selector with emoji and label.
class RatingSelector extends StatelessWidget {
  const RatingSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  static const labels = ['Rất tệ', 'Tệ', 'Bình thường', 'Tốt', 'Rất tốt'];
  static const emojis = ['😿', '😾', '😐', '😺', '😻'];
  // Map rating -> mood for backend.
  static const moods = ['SAD', 'STRESSED', 'NEUTRAL', 'CALM', 'HAPPY'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        final sel = rating == i;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: sel
                  ? RelaxColors.violet.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel ? RelaxColors.violet : context.fieldBorder,
              ),
            ),
            child: Column(
              children: [
                Text(emojis[i], style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 2),
                Text(
                  context.t(labels[i]),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: context.appText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
