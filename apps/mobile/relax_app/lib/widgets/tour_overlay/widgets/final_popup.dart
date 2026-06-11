import 'package:flutter/material.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import 'glass_popup.dart';

/// Popup shown at the end of the tour, offering to finish or restart.
class FinalPopup extends StatelessWidget {
  const FinalPopup({
    super.key,
    required this.onFinish,
    required this.onRestart,
  });

  final VoidCallback onFinish;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPopup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, color: RelaxColors.mint, size: 48),
            const SizedBox(height: 16),
            Text(
              context.t('Tour Kết Thúc 🎉'),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.t('tour du lịch tới đây đã hết tiền dồiii ~, trải nghiệm tốt nha'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RelaxColors.violet,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onFinish,
                    child: Text(
                      context.t('Đã hiểu rùi nè ~'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onRestart,
                    child: Text(
                      context.t('đi lại lần nữa'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
