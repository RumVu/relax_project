import 'package:flutter/material.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import 'glass_popup.dart';

/// Popup shown between screen transitions asking the user
/// whether they want to continue the tour.
class TransitionPopup extends StatelessWidget {
  const TransitionPopup({
    super.key,
    required this.onSkip,
    required this.onContinue,
  });

  final VoidCallback onSkip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPopup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_run_outlined, color: RelaxColors.violet, size: 48),
            const SizedBox(height: 16),
            Text(
              context.t('Tiếp tục tour chứ?'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.t('Chúng ta sẽ chuyển sang trang tiếp theo để khám phá thêm nhiều chức năng thú vị nha ~'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onSkip,
                    child: Text(
                      context.t('Bỏ qua'),
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RelaxColors.violet,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onContinue,
                    child: Text(
                      context.t('Cho tui đi tiếp cái tour này đi'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
