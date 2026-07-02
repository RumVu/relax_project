import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/tour_controller.dart';
import '../../../core/theme.dart';
import '../helpers/home_ui_helpers.dart';

class HomeMoodGrid extends StatefulWidget {
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
  State<HomeMoodGrid> createState() => _HomeMoodGridState();
}

class _HomeMoodGridState extends State<HomeMoodGrid> {
  String? _pressedMood;

  void _handleTap(String mood, String label) {
    if (_pressedMood != null || widget.savingMood != null) return;
    setState(() => _pressedMood = mood);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      widget.onLogMood(mood, label);
      setState(() => _pressedMood = null);
    });
  }

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
      children: widget.moodOptions.map((o) {
        final mood = o['mood'] as String;
        final label =
            (o['shortLabel'] as String?) ?? (o['label'] as String?) ?? mood;
        final saving = widget.savingMood == mood;
        final pressed = _pressedMood == mood;
        final busy = _pressedMood != null || widget.savingMood != null;
        final imagePath =
            pressed ? moodImageAfter(mood) : moodImageBefore(mood);

        return GestureDetector(
          onTap: busy ? null : () => _handleTap(mood, label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: pressed
                  ? RelaxColors.violet.withValues(alpha: 0.08)
                  : context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: pressed ? RelaxColors.violet : context.fieldBorder,
                width: pressed ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Image.asset(
                      imagePath,
                      key: ValueKey(imagePath),
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                saving || pressed
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
