import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class SmallButton extends StatelessWidget {
  const SmallButton({
    super.key,
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? RelaxColors.violet;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: filled ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filled ? activeColor : context.fieldBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: filled ? Colors.white : context.appText,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : context.appText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
