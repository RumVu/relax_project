import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../data/models/app_models.dart';
import '../../../features/relax/sheets/relax_sheets.dart';
import '../buttons/small_action_button.dart';
import '../pixel/pixel_panel.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final meta = <String>[
      if (activity.durationMinutes != null) '${activity.durationMinutes} phút',
      if (activity.reliefPercent != null) 'relief ${activity.reliefPercent}%',
      '${activity.contentCount} nội dung',
    ];

    return PixelPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PixelIconBox(icon: activity.icon, size: 86),
          const SizedBox(width: 14),
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in meta) _ActivityMetaChip(label: item),
                  ],
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
