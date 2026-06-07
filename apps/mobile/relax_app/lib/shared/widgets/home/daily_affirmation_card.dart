import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Hero card hiển thị 1 lời khẳng định cá nhân theo ngày.
///
/// 30 câu pastel rotated theo ngày của năm — user mở app vào 2 thời điểm
/// trong cùng 1 ngày sẽ thấy cùng 1 câu (consistency). Hôm sau câu khác.
class DailyAffirmationCard extends StatelessWidget {
  const DailyAffirmationCard({super.key, this.compact = false});

  /// `compact: true` → padding nhỏ hơn cho Home top.
  final bool compact;

  static const _affirmations = <_Affirmation>[
    _Affirmation('🌱', 'Hôm nay mình được phép chậm lại.'),
    _Affirmation('💜', 'Mình đang làm tốt hơn mình nghĩ.'),
    _Affirmation('🌸', 'Cảm xúc của mình xứng đáng được nghe.'),
    _Affirmation('🌿', 'Một ngày khó không có nghĩa cuộc đời khó.'),
    _Affirmation('☀️', 'Mình không phải hoàn hảo để được yêu.'),
    _Affirmation('🌙', 'Nghỉ ngơi không phải lười — đó là chăm sóc.'),
    _Affirmation('✨', 'Mỗi nhịp thở là một cơ hội bắt đầu lại.'),
    _Affirmation('🍃', 'Mình có quyền nói không với điều làm mình mệt.'),
    _Affirmation('🌺', 'Tiến độ nhỏ vẫn là tiến độ.'),
    _Affirmation('🦋', 'Mình đang trưởng thành theo nhịp của mình.'),
    _Affirmation('🌊', 'Cảm xúc đến rồi đi — như sóng biển.'),
    _Affirmation('🕊', 'Mình không cần giải thích cho mọi người.'),
    _Affirmation('🌻', 'Mình xứng đáng có những ngày dịu dàng.'),
    _Affirmation('🌷', 'Việc tự chăm bản thân không ích kỷ.'),
    _Affirmation('🍀', 'Mình có quyền thay đổi suy nghĩ.'),
    _Affirmation('🌼', 'Hôm qua đã qua. Hôm nay là trang mới.'),
    _Affirmation('🌵', 'Mạnh mẽ là khi mình dám yếu đuối một chút.'),
    _Affirmation('🌾', 'Mình đang ở đúng chỗ trong hành trình.'),
    _Affirmation('🌹', 'Yêu bản thân là kỹ năng — không phải sĩ diện.'),
    _Affirmation('🌟', 'Mình được phép vui mà không cảm thấy có lỗi.'),
    _Affirmation('🌈', 'Sau mưa là cầu vồng — kiên nhẫn nha ~'),
    _Affirmation('🌤', 'Một ngày tệ không định nghĩa con người mình.'),
    _Affirmation('🌝', 'Mình không nợ ai sự hạnh phúc của họ.'),
    _Affirmation('🐚', 'Lặng yên cũng là một dạng phản hồi.'),
    _Affirmation('🍂', 'Buông một số kỳ vọng là tự do.'),
    _Affirmation('🪐', 'Mình đủ — không cần thêm gì hôm nay.'),
    _Affirmation('🌌', 'Khoảnh khắc này, mình an toàn.'),
    _Affirmation('🦢', 'Mềm mại không có nghĩa yếu đuối.'),
    _Affirmation('🌬', 'Hơi thở của mình luôn là điểm tựa.'),
    _Affirmation('💫', 'Mình đang viết câu chuyện của mình — chậm cũng được.'),
  ];

  _Affirmation get _today {
    final now = DateTime.now();
    final dayOfYear = int.parse(
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
    );
    return _affirmations[dayOfYear % _affirmations.length];
  }

  @override
  Widget build(BuildContext context) {
    final affirmation = _today;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 12 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            RelaxTheme.purple.withValues(alpha: .12),
            RelaxTheme.lavender.withValues(alpha: .08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: RelaxTheme.lavender.withValues(alpha: .3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: RelaxTheme.lavender.withValues(alpha: .3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: Text(
                affirmation.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LỜI HÔM NAY',
                  style: TextStyle(
                    color: RelaxTheme.lavender,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  affirmation.text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                    fontSize: compact ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Affirmation {
  const _Affirmation(this.emoji, this.text);
  final String emoji;
  final String text;
}
