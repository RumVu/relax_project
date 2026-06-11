import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../helpers/home_ui_helpers.dart';

// Card showing mood distribution bars for each mood option.
class MoodTrackingCard extends StatelessWidget {
  const MoodTrackingCard({
    super.key,
    required this.name,
    required this.moodOptions,
    required this.moodCounts,
    required this.moodTotal,
  });

  final String name;
  final List<Map<String, dynamic>> moodOptions;
  final Map<String, int> moodCounts;
  final int moodTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${context.t('Theo dõi cảm xúc của')} $name',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: context.appText,
                  ),
                ),
              ),
              const Icon(Icons.bar_chart, color: RelaxColors.violet, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          if (moodOptions.isEmpty)
            Text(context.t('Chưa có dữ liệu cảm xúc.'),
                style: TextStyle(color: context.mutedText, fontSize: 12))
          else
            ...moodOptions.map((o) {
              final mood = o['mood'] as String;
              final label = (o['label'] as String?) ?? mood;
              final pct =
                  moodTotal == 0 ? 0.0 : (moodCounts[mood] ?? 0) / moodTotal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        context.t(label),
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(moodColor(mood)),
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
            }),
        ],
      ),
    );
  }
}
