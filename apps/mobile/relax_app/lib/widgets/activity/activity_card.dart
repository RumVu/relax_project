part of 'package:relax_app/main.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      child: Row(
        children: [
          PixelIconBox(icon: activity.icon, size: 74),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodyMedium,
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
