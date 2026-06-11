import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

// Card displaying suggested relaxation methods.
class MethodsCard extends StatelessWidget {
  const MethodsCard({super.key, required this.name});

  final String name;

  static const _methods = [
    ('Thiền định', Icons.self_improvement, '/meditation'),
    ('Hít thở', Icons.air, '/breathing'),
    ('Nhật ký', Icons.edit_note, '/journal'),
    ('Nhạc', Icons.headphones, '/sounds'),
    ('Podcast', Icons.mic_none, '/podcast'),
  ];

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
          Text(
            '${context.t('Phương thức phù hợp cho')} $name',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: _methods.map((m) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push(m.$3);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: context.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.fieldBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(m.$2, color: RelaxColors.violet),
                        const SizedBox(height: 6),
                        Text(
                          context.t(m.$1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: context.appText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
