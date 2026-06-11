import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../models/relax_activity.dart';

class PreActivitySheet extends StatelessWidget {
  const PreActivitySheet({
    super.key,
    required this.activity,
    required this.onConfirmed,
  });

  final RelaxActivity activity;
  final ValueChanged<String> onConfirmed;

  static const _moods = [
    {'mood': 'HAPPY', 'label': 'Vui', 'emoji': '😺'},
    {'mood': 'SAD', 'label': 'Buồn', 'emoji': '😿'},
    {'mood': 'STRESSED', 'label': 'Stress', 'emoji': '🙀'},
    {'mood': 'TIRED', 'label': 'Chán', 'emoji': '😾'},
    {'mood': 'ANXIOUS', 'label': 'Lo', 'emoji': '😼'},
    {'mood': 'NEUTRAL', 'label': 'Ổn', 'emoji': '😐'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.fieldBorder),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.fieldBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${context.t('Bắt đầu')} ${context.t(activity.title)} ✨',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('Hãy xác nhận cảm xúc lúc này của bạn nhé ~'),
            style: TextStyle(color: context.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: _moods.map((m) {
              final mood = m['mood']!;
              final label = context.t(m['label']!);
              final emoji = m['emoji']!;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onConfirmed(mood);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.fieldBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 6),
                      Text(
                        label,
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
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.t('Đóng'),
              style: TextStyle(color: context.mutedText, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
