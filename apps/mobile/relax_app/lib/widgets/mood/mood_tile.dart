part of 'package:relax_app/main.dart';

class MoodTile extends StatelessWidget {
  const MoodTile({super.key, required this.mood, required this.selected});

  final MoodOption mood;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.all(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? RelaxTheme.purple.withValues(alpha: .12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mood.icon,
              size: 34,
              color: selected ? RelaxTheme.purple : context.relax.muted,
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                mood.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
