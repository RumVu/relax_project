import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale_controller.dart';
import '../../../core/tour_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/cat_mascot.dart';

// Mascot speech bubble card with quote and companion link.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({
    super.key,
    required this.quote,
    required this.name,
  });

  final Map<String, dynamic>? quote;
  final String name;

  @override
  Widget build(BuildContext context) {
    final line = quote?['content'] != null
        ? context.t(quote!['content'] as String)
        : context.t(
            'Stress quá mới tìm đến toi hở? {name} nói cho toi nghe đi nè!',
            {'name': name},
          );
    return Container(
      key: TourController.instance.targetKeys[2],
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: RelaxColors.violet
                  .withValues(alpha: context.isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              line,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.push('/companion'),
            child: const CatMascot(size: 130, emoji: '😺'),
          ),
          const SizedBox(height: 4),
          Text(
            context.t('Chạm vào mèo để thăm linh thú ✦'),
            style: TextStyle(
              color: context.mutedText,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
