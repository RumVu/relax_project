part of 'package:relax_app/main.dart';

class MoodProgress extends StatelessWidget {
  const MoodProgress({super.key, required this.mood});

  final MoodOption mood;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(mood.icon, size: 18, color: context.relax.muted),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: Text(
              mood.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: mood.percent / 100,
                minHeight: 8,
                backgroundColor: context.relax.surfaceSoft,
                valueColor: AlwaysStoppedAnimation(
                  mood.label == 'Stress'
                      ? const Color(0xFFE971E5)
                      : RelaxTheme.lavender,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${mood.percent}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
