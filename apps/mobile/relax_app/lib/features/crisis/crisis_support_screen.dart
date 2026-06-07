import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';

/// Trang hỗ trợ khẩn cấp — quan trọng cho wellness app.
///
/// Cung cấp:
///   - Cảnh báo + grounding ngắn (5-4-3-2-1 senses)
///   - Hotlines Việt Nam đã verified
///   - Lời nhắc tìm con người thực sự (gia đình, bạn, chuyên gia)
///   - KHÔNG hứa hẹn thay thế professional help
///
/// Reach-out methods sẵn (callable Number copy to clipboard, không tự dial
/// để tránh accidental call).
class CrisisSupportScreen extends StatelessWidget {
  const CrisisSupportScreen({super.key});

  static const _hotlines = [
    _Hotline(
      name: 'Cấp cứu y tế (24/7)',
      number: '115',
      desc: 'Khi có nguy hiểm tức thì về thể chất hoặc tinh thần.',
      isEmergency: true,
    ),
    _Hotline(
      name: 'Công an',
      number: '113',
      desc: 'Khi cảm thấy không an toàn — bị đe doạ, theo dõi, bạo lực.',
      isEmergency: true,
    ),
    _Hotline(
      name: 'Tổng đài Quốc gia Bảo vệ Trẻ em',
      number: '111',
      desc: 'Miễn phí 24/7 — dành cho trẻ em & người lớn bảo vệ trẻ.',
    ),
    _Hotline(
      name: 'Ngày Mai Project',
      number: '096 306 1414',
      desc: 'Phòng chống tự tử — hoạt động qua điện thoại + Facebook.',
    ),
    _Hotline(
      name: 'Heart 2 Heart',
      number: '1900 599 962',
      desc: 'Tư vấn tâm lý qua điện thoại, có phí.',
    ),
  ];

  void _copyNumber(BuildContext context, String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã copy $number — paste vào điện thoại để gọi 💜'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Hỗ trợ khẩn cấp'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Hero: warmth + reassurance
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE85A6A).withValues(alpha: .08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE85A6A).withValues(alpha: .3),
              ),
            ),
            child: Column(
              children: [
                const CatAvatar(size: 80),
                const SizedBox(height: 12),
                Text(
                  'Bạn không một mình 💜',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Khi mọi thứ quá nặng, có những người được đào tạo để giúp '
                  'bạn — và họ thực sự muốn nghe. Phía dưới là các đường '
                  'dây hotline + một bài grounding ngắn nếu bạn cần dịu '
                  'lại ngay lúc này.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Grounding 5-4-3-2-1
          PixelPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.spa_rounded,
                      color: RelaxTheme.lavender,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Grounding 5-4-3-2-1',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Khi bị áp đảo bởi cảm xúc, thử kéo mình về hiện tại bằng '
                  '5 giác quan. Đọc chậm thôi nha ~',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                _GroundingStep(
                  n: 5,
                  emoji: '👀',
                  text: 'thứ bạn THẤY xung quanh',
                ),
                _GroundingStep(
                  n: 4,
                  emoji: '✋',
                  text: 'thứ bạn SỜ được (áo, ghế, không khí trên da)',
                ),
                _GroundingStep(
                  n: 3,
                  emoji: '👂',
                  text: 'âm thanh bạn NGHE thấy (xa hoặc gần)',
                ),
                _GroundingStep(
                  n: 2,
                  emoji: '👃',
                  text: 'mùi bạn NGỬI được (hoặc tưởng tượng nếu khó tìm)',
                ),
                _GroundingStep(
                  n: 1,
                  emoji: '👅',
                  text: 'vị trong miệng bạn (cốc nước, kẹo, hay không khí)',
                ),
                const SizedBox(height: 4),
                Text(
                  'Khi xong, hít thật sâu 1 lần. Bạn đang ở đây. Bạn an toàn '
                  'trong khoảnh khắc này.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: RelaxTheme.lavender,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.phone_rounded, color: RelaxTheme.lavender),
              const SizedBox(width: 8),
              Text(
                'Đường dây hỗ trợ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tap để copy số. App KHÔNG tự gọi — bạn chủ động paste vào '
            'phone app để xác nhận trước khi gọi.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11.5,
              color: context.relax.muted,
            ),
          ),
          const SizedBox(height: 12),
          for (final h in _hotlines)
            _HotlineCard(
              hotline: h,
              onTap: () => _copyNumber(context, h.number),
            ),
          const SizedBox(height: 18),
          PixelPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Một người thực sự gần bạn 💜',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Nếu được, hãy nói với 1 người thực sự — gia đình, bạn '
                  'thân, đồng nghiệp tin tưởng. Bạn không cần phải nói '
                  'mọi thứ, chỉ cần nói "Mình đang không ổn, ngồi với '
                  'mình một chút được không?"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Và nếu bạn cảm thấy có hại với bản thân — hãy gọi 115 '
                  'NGAY. Bạn xứng đáng được sống, và những người chuyên '
                  'môn sẽ giúp bạn vượt qua đêm này.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              '✦ Mình ở đây với bạn — nhưng bạn đáng được nhiều hơn ✦',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: RelaxTheme.lavender,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hotline {
  const _Hotline({
    required this.name,
    required this.number,
    required this.desc,
    this.isEmergency = false,
  });
  final String name;
  final String number;
  final String desc;
  final bool isEmergency;
}

class _HotlineCard extends StatelessWidget {
  const _HotlineCard({required this.hotline, required this.onTap});
  final _Hotline hotline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: hotline.isEmergency
            ? const Color(0xFFE85A6A).withValues(alpha: .08)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hotline.isEmergency
              ? const Color(0xFFE85A6A).withValues(alpha: .35)
              : context.relax.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  decoration: BoxDecoration(
                    color: hotline.isEmergency
                        ? const Color(0xFFE85A6A)
                        : RelaxTheme.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      hotline.number.split(' ').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              hotline.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                          if (hotline.isEmergency) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE85A6A),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'KHẨN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hotline.desc,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hotline.number,
                        style: TextStyle(
                          color: RelaxTheme.lavender,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.content_copy_rounded,
                  size: 18,
                  color: RelaxTheme.lavender,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroundingStep extends StatelessWidget {
  const _GroundingStep({
    required this.n,
    required this.emoji,
    required this.text,
  });
  final int n;
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: RelaxTheme.lavender.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$n',
                style: TextStyle(
                  color: RelaxTheme.lavender,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
