import 'package:flutter/material.dart';

import 'locale_controller.dart';
import 'theme.dart';

/// Detect self-harm / crisis keywords in text.
/// Non-blocking, supportive approach — show SOS resources.
class SafetyDetector {
  SafetyDetector._();

  static const _keywords = [
    'tự tử', 'tự sát', 'muốn chết', 'không muốn sống',
    'tự hại', 'tự cắt', 'cắt tay', 'rạch tay',
    'kết thúc cuộc đời', 'chấm dứt tất cả',
    'suicide', 'kill myself', 'self harm', 'end it all',
    'want to die', 'cut myself',
    'không còn lý do', 'vô vọng', 'tuyệt vọng',
  ];

  static bool containsCrisisKeywords(String text) {
    final lower = text.toLowerCase();
    return _keywords.any((kw) => lower.contains(kw));
  }

  static void showSafetyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.favorite, color: RelaxColors.coral, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ctx.t('Bạn ổn không?'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: ctx.appText,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.t('Relax Time nhận thấy bạn có thể đang trải qua giai đoạn khó khăn. Bạn không đơn độc.'),
              style: TextStyle(color: ctx.mutedText, height: 1.5),
            ),
            const SizedBox(height: 16),
            _hotline(ctx, '🇻🇳', '1800 599 920', ctx.t('Đường dây nóng VN (24/7, miễn phí)')),
            const SizedBox(height: 8),
            _hotline(ctx, '📞', '111', ctx.t('Tổng đài bảo vệ trẻ em')),
            const SizedBox(height: 8),
            _hotline(ctx, '🚑', '115', ctx.t('Cấp cứu y tế')),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RelaxColors.violet.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ctx.t('Chia sẻ với người bạn tin tưởng. Đó là dũng cảm, không phải yếu đuối. 💜'),
                style: TextStyle(
                  color: ctx.appText,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              ctx.t('Cảm ơn, tôi ổn'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _hotline(
      BuildContext ctx, String emoji, String number, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(number,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: RelaxColors.coral,
                      fontSize: 15)),
              Text(label,
                  style: TextStyle(color: ctx.mutedText, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
