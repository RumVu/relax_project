import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../models/mood_labels.dart';

/// Horizontal bar chart showing the distribution of moods by percentage.
class MoodDistribution extends StatelessWidget {
  const MoodDistribution({
    super.key,
    required this.distribution,
    required this.total,
  });

  final Map<String, int> distribution;
  final int total;

  @override
  Widget build(BuildContext context) {
    final sorted = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((e) {
        final pct = total == 0 ? 0.0 : e.value / total;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  context.t(kMoodLabels[e.key] ?? e.key),
                  style: TextStyle(fontSize: 12, color: context.appText),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: context.surfaceAlt,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        RelaxColors.violet),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 38,
                child: Text(
                  '${(pct * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.appText,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
