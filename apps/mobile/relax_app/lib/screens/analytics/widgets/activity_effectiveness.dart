import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

/// Hiển thị effectiveness từng loại activity — bảng chi tiết per-activity.
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
        // Average relief header with stars.
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
        const SizedBox(height: 16),

        // "What helps you most?" subtitle.
        Text(
          context.t('Hoạt động nào giúp bạn nhất?'),
          style: TextStyle(
            color: context.appText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.t('Bảng chi tiết hiệu quả từng hoạt động'),
          style: TextStyle(
            color: context.mutedText,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 12),

        // Table header.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: RelaxColors.violet.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  context.t('Hoạt động'),
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  context.t('Số lần'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  context.t('Relief TB'),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table rows.
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: context.fieldBorder),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < activities.length; i++)
                _ActivityRow(
                  activity: activities[i],
                  isLast: i == activities.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity, required this.isLast});
  final Map<String, dynamic> activity;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final type = activity['activityType'] as String? ?? 'MYSTERY';
    final count = (activity['count'] as num?)?.toInt() ?? 0;
    final avgRelief = (activity['avgRelief'] as num?)?.toDouble() ?? 0;
    final emoji =
        ActivityEffectiveness._activityEmoji[type] ?? '🌿';
    final label =
        ActivityEffectiveness._activityLabel[type] ?? type;

    final reliefColor = avgRelief >= 70
        ? const Color(0xFF4caf50)
        : avgRelief >= 40
            ? const Color(0xFFff9800)
            : const Color(0xFFe57373);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.fieldBorder, width: 0.5),
              ),
            ),
      child: Row(
        children: [
          // Activity name with emoji.
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    context.t(label),
                    style: TextStyle(
                      color: context.appText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Session count.
          Expanded(
            flex: 2,
            child: Text(
              '$count ${context.t('lần')}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Relief percentage with colored indicator.
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: reliefColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '+${avgRelief.round()}%',
                  style: TextStyle(
                    color: reliefColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
