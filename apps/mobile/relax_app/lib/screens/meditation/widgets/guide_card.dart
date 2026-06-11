import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

/// A card displaying a single meditation guide with title, description,
/// instructor, focus area, duration, and a "Start" button.
class GuideCard extends StatelessWidget {
  const GuideCard({
    super.key,
    required this.guide,
    required this.onStart,
  });

  final Map<String, dynamic> guide;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final title = guide['title'] as String? ?? '';
    final desc = guide['description'] as String? ?? '';
    final minutes = guide['duration'] as num? ?? 10;
    final instructor = guide['instructor'] as String? ?? 'Chưa rõ';
    final area = guide['focusArea'] as String? ?? 'Mindfulness';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: context.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: context.fieldBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: RelaxColors.violet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.spa, color: RelaxColors.violet),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.mutedText, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.t('Instructor:')} $instructor · $area · $minutes ${context.t('phút')}',
                    style: TextStyle(
                      color: context.mutedText,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: RelaxColors.violet,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                onStart();
              },
              child: Text(
                context.t('Bắt đầu'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
