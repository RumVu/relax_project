import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class PixelButton extends StatelessWidget {
  const PixelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;

  /// Null → button thực sự disabled (không nhận tap). Trước đây callers pass
  /// `() {}` để "fake disable" → user spam click vẫn fire → multiple requests.
  final VoidCallback? onPressed;

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: filled ? accent : Colors.transparent,
          foregroundColor: filled ? Colors.white : accent,
          disabledBackgroundColor:
              filled ? accent.withValues(alpha: .35) : Colors.transparent,
          disabledForegroundColor: context.relax.muted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: filled ? accent : context.relax.border,
              width: 1.2,
            ),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
