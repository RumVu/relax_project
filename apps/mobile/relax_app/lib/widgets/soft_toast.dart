import 'package:flutter/material.dart';

import '../core/theme.dart';

enum SoftToastTone { success, error, info }

/// Toast mềm thay default SnackBar — bo tròn, floating, không full-width
/// trên tablet, gradient nhẹ + icon. Dùng thay cho ScaffoldMessenger
/// showSnackBar ở các màn để giữ tone đầm thắm.
void showSoftToast(
  BuildContext context, {
  required String message,
  SoftToastTone tone = SoftToastTone.success,
  Duration duration = const Duration(milliseconds: 2400),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final (color, icon) = _styleFor(tone);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      duration: duration,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

(Color, IconData) _styleFor(SoftToastTone tone) {
  switch (tone) {
    case SoftToastTone.success:
      return (RelaxColors.mint, Icons.check_circle_outline);
    case SoftToastTone.error:
      return (RelaxColors.coral, Icons.error_outline);
    case SoftToastTone.info:
      return (RelaxColors.violet, Icons.info_outline);
  }
}
