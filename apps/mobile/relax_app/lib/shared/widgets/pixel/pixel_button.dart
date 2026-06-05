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
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: filled ? RelaxTheme.purple : Colors.transparent,
          foregroundColor: filled ? Colors.white : RelaxTheme.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: filled ? RelaxTheme.purple : context.relax.border,
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
