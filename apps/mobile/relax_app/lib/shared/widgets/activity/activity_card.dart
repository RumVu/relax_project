import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../data/models/app_models.dart';
import '../pixel/pixel_panel.dart';

/// Card 1 hoạt động trong Khu thư giãn.
///
/// Tap toàn bộ card → [onStart] (push JourneyScreen). Không còn dual
/// Play/Finish buttons gây nhầm lẫn — user vào Journey, hành trình
/// 5 chương sẽ dẫn dắt qua từng bước.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.chapterIndex,
    required this.onStart,
  });

  final Activity activity;

  /// Số thứ tự chương 1-based — hiển thị "Chương 01", "Chương 02"...
  final int chapterIndex;

  /// Khi user tap card → bắt đầu hành trình cho activity này.
  final ValueChanged<Activity> onStart;

  @override
  Widget build(BuildContext context) {
    final meta = <String>[
      if (activity.durationMinutes != null) '${activity.durationMinutes} phút',
      if (activity.reliefPercent != null) 'relief ${activity.reliefPercent}%',
      '${activity.contentCount} nội dung',
    ];
    final chapterLabel = 'Chương ${chapterIndex.toString().padLeft(2, '0')}';

    return PixelPanel(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onStart(activity),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PixelIconBox(icon: activity.icon, size: 76),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapterLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: RelaxTheme.lavender,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity.compactTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final item in meta)
                            _ActivityMetaChip(label: item),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StartHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RelaxTheme.purple, RelaxTheme.lavender],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: RelaxTheme.purple.withValues(alpha: .3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _ActivityMetaChip extends StatelessWidget {
  const _ActivityMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: RelaxTheme.purple,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
