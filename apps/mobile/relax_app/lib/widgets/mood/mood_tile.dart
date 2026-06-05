part of 'package:relax_app/main.dart';

/// Ô cảm xúc trong lưới 3×2 ở HomeScreen. Bấm → callback `onTap` của parent
/// POST `/mood-checkins/me`. Trong lúc đang gửi, ô hiện loader + bị disable
/// để tránh double-tap.
class MoodTile extends StatelessWidget {
  const MoodTile({
    super.key,
    required this.mood,
    required this.selected,
    this.busy = false,
    this.onTap,
  });

  final MoodOption mood;
  final bool selected;

  /// True khi POST đang chạy cho ô này.
  final bool busy;

  /// `null` → không cho bấm (vd MoodOption chưa có `code` để map backend).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !busy;
    return PixelPanel(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: enabled ? onTap : null,
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
              if (busy)
                const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: RelaxTheme.purple,
                  ),
                )
              else
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
      ),
    );
  }
}
