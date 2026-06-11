import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/tour_controller.dart';
import '../../../core/theme.dart';
import '../helpers/home_ui_helpers.dart';

// Quick mood check-in grid for the home screen.
class HomeMoodGrid extends StatelessWidget {
  const HomeMoodGrid({
    super.key,
    required this.moodOptions,
    required this.savingMood,
    required this.onLogMood,
  });

  final List<Map<String, dynamic>> moodOptions;
  final String? savingMood;
  final void Function(String mood, String label) onLogMood;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      key: TourController.instance.targetKeys[1],
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: moodOptions.map((o) {
        final mood = o['mood'] as String;
        final label =
            (o['shortLabel'] as String?) ?? (o['label'] as String?) ?? mood;
        final saving = savingMood == mood;
        return GestureDetector(
          onTap: saving ? null : () => onLogMood(mood, label),
          child: Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.fieldBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(moodEmoji(mood), style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 6),
                saving
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: RelaxColors.violet),
                      )
                    : Text(
                        context.t(label),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: context.appText,
                        ),
                      ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
