import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';

/// Help & FAQ — 8 câu hỏi thường gặp + tips dùng app.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  static const _faqs = [
    _Faq(
      'Khi nào nên check-in cảm xúc?',
      'Bất cứ lúc nào bạn nhận ra mình "đang cảm gì đó". Sáng sau khi '
          'thức, trước khi đi ngủ, hoặc khi cảm xúc trào lên đột ngột. '
          'Mỗi lần check-in giúp bạn biết bản thân hơn ~',
    ),
    _Faq(
      'Quick Relief khác Journey thế nào?',
      'Quick Relief là 60 giây SOS khi stress đột ngột. Journey là '
          'hành trình 5 chương ~ 10-15 phút, dẫn dắt bạn qua từng bước. '
          'Quick Relief cho lúc cấp tốc; Journey cho khi có thời gian.',
    ),
    _Faq(
      'Có nên trả lời mọi notification?',
      'Không cần. Mỗi notification chỉ là gợi ý nhẹ — không có "phạt" '
          'gì nếu bỏ qua. Đánh dấu đã đọc nếu muốn dọn, hoặc cứ kệ.',
    ),
    _Faq(
      'Dữ liệu của tôi có an toàn không?',
      'Token đăng nhập lưu trong Keychain (iOS) hoặc Keystore (Android) '
          'của thiết bị. Mood, nhật ký, phiên thư giãn được mã hoá khi '
          'truyền. Không bán cho ai. Setup → Xóa tài khoản → xóa vĩnh viễn.',
    ),
    _Faq(
      'Tôi quên mật khẩu phải làm sao?',
      'Login screen → "Quên mật khẩu?" → nhập email → mở email kiểm tra. '
          'Nhớ check folder Spam. Link reset có hiệu lực 1 giờ.',
    ),
    _Faq(
      'Thi Ái có phải AI thật không?',
      'KHÔNG. Companion chat dùng phản hồi được curate sẵn — không có '
          'LLM xử lý input. Mục đích: cho bạn cảm giác được nghe + acknowledge, '
          'nhưng KHÔNG thay thế trò chuyện với người thực sự.',
    ),
    _Faq(
      'Tôi đang khủng hoảng, app có giúp được không?',
      'Setup → Hỗ trợ khẩn cấp có hotline 115 + grounding 5-4-3-2-1. '
          'Nhưng nếu có nguy hiểm tức thì — gọi 115 NGAY. App là người '
          'bạn nhỏ, không phải bác sĩ.',
    ),
    _Faq(
      'Streak của tôi reset rồi, có cách phục hồi không?',
      'Hiện tại chưa có "streak freeze" — sẽ thêm trong update sau. '
          'Quan trọng nhất là: 1 ngày miss không phá hỏng hành trình. '
          'Quay lại ngay hôm nay, streak mới bắt đầu ✦',
    ),
  ];

  final _expanded = <int>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Trợ giúp & FAQ'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [RelaxTheme.purple, RelaxTheme.lavender],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CatAvatar(size: 60),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cần giúp gì? ✦',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '8 câu hỏi thường gặp + 1 chỗ liên hệ ở cuối.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .9),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < _faqs.length; i++)
            _FaqTile(
              faq: _faqs[i],
              expanded: _expanded.contains(i),
              onToggle: () => setState(() {
                if (_expanded.contains(i)) {
                  _expanded.remove(i);
                } else {
                  _expanded.add(i);
                }
              }),
            ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.relax.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.mail_outline_rounded,
                      size: 16,
                      color: RelaxTheme.lavender,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Còn câu hỏi khác?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Email: hello@thiai-chill.app\n'
                  'Mình đọc tất cả feedback và phản hồi trong 1-2 ngày 💜',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
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

class _Faq {
  const _Faq(this.q, this.a);
  final String q;
  final String a;
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.faq,
    required this.expanded,
    required this.onToggle,
  });
  final _Faq faq;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: expanded
              ? RelaxTheme.lavender.withValues(alpha: .5)
              : context.relax.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        faq.q,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: expanded ? .5 : 0,
                      child: const Icon(
                        Icons.expand_more_rounded,
                        color: RelaxTheme.lavender,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            faq.a,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(height: 1.55, fontSize: 12.5),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
