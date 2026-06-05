part of 'package:relax_app/main.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (activity.durationMinutes != null) '${activity.durationMinutes} phút',
      if (activity.reliefPercent != null) 'relief ${activity.reliefPercent}%',
      '${activity.contentCount} nội dung',
    ].join(' · ');

    return PixelPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          PixelIconBox(icon: activity.icon, size: 78),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  activity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: RelaxTheme.lavender),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              SmallActionButton(
                icon: Icons.play_arrow_rounded,
                label: 'Play',
                onTap: () => showPlayerSheet(context, activity),
              ),
              const SizedBox(height: 8),
              SmallActionButton(
                icon: Icons.flag_rounded,
                label: 'Finish',
                onTap: () => showFeedbackSheet(context, activity),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
