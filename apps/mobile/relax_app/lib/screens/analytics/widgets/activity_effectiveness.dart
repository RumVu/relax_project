import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

/// Hiển thị effectiveness từng loại activity — so sánh mood before vs after.
/// Data từ /relax-sessions/me/stats → favoriteActivities + relief.
class ActivityEffectiveness extends StatelessWidget {
  const ActivityEffectiveness({
    super.key,
    required this.activities,
    required this.averageRelief,
  });

  /// List of {activityType, count, avgRelief?, label}
  final List<Map<String, dynamic>> activities;
  final int averageRelief;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          context.t('Hoàn thành vài hoạt động để xem hiệu quả.'),
          style: TextStyle(color: context.mutedText, fontSize: 12),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Average relief header.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: RelaxColors.violet.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Mức nhẹ nhõm trung bình'),
                      style: TextStyle(
                        color: context.mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$averageRelief%',
                      style: const TextStyle(
                        color: RelaxColors.violet,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              // Stars.
              Row(
                children: List.generate(5, (i) {
                  final filled = (averageRelief / 20).round();
                  return Icon(
                    i < filled
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i < filled
                        ? RelaxColors.violet
                        : context.fieldBorder,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Per-activity bars.
        ...activities.map((a) => _ActivityBar(activity: a)),
      ],
    );
  }
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({required this.activity});
  final Map<String, dynamic> activity;

  static const _activityEmoji = {
    'BREATHING': '🌬️',
    'MEDITATION': '🧘',
    'MUSIC': '🎵',
    'PODCAST': '🎙️',
    'JOURNAL': '✍️',
    'MYSTERY': '🎲',
  };

  static const _activityLabel = {
    'BREATHING': 'Hít thở',
    'MEDITATION': 'Thiền',
    'MUSIC': 'Nhạc',
    'PODCAST': 'Podcast',
    'JOURNAL': 'Nhật ký',
    'MYSTERY': 'Khám phá',
  };

  @override
  Widget build(BuildContext context) {
    final type = activity['activityType'] as String? ?? 'MYSTERY';
    final count = (activity['count'] as num?)?.toInt() ?? 0;
    final avgRelief = (activity['avgRelief'] as num?)?.toDouble() ?? 0;
    final emoji = _activityEmoji[type] ?? '🌿';
    final label = _activityLabel[type] ?? type;
    final barValue = (avgRelief / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.t(label),
                      style: TextStyle(
                        color: context.appText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${avgRelief.round()}% · $count ${context.t('lần')}',
                      style: TextStyle(
                        color: context.mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: barValue,
                    backgroundColor: context.fieldBorder,
                    color: _barColor(avgRelief),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _barColor(double relief) {
    if (relief >= 70) return const Color(0xFF4caf50);
    if (relief >= 40) return const Color(0xFFff9800);
    return const Color(0xFFe57373);
  }
}
