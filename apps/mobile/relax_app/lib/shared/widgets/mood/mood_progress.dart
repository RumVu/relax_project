import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../data/models/app_models.dart';

/// Một dòng trong bảng theo dõi cảm xúc.
///
/// [realPercent] — % thật từ lịch sử checkin (0-100). Nếu null → hiện loading.
/// Không bao giờ dùng giá trị hardcode từ MoodOption.percent nữa.
class MoodProgress extends StatelessWidget {
  const MoodProgress({
    super.key,
    required this.mood,
    this.realPercent, // null = loading, 0-100 = real data
  });

  final MoodOption mood;
  final int? realPercent;

  @override
  Widget build(BuildContext context) {
    final isLoading = realPercent == null;
    final pct = realPercent ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(mood.icon, size: 18, color: context.relax.muted),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              mood.label,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isLoading
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      backgroundColor: context.relax.surfaceSoft,
                      valueColor: AlwaysStoppedAnimation(
                        context.relax.surfaceSoft,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      widthFactor: 1.0,
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        minHeight: 8,
                        backgroundColor: context.relax.surfaceSoft,
                        valueColor: AlwaysStoppedAnimation(
                          mood.code == 'STRESS'
                              ? const Color(0xFFE971E5)
                              : RelaxTheme.lavender,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(
              isLoading ? '…' : '$pct%',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
