import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

/// The text-input composer card for writing a new journal entry.
class JournalComposer extends StatelessWidget {
  const JournalComposer({
    super.key,
    required this.titleController,
    required this.bodyController,
    required this.saving,
    required this.onSave,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final bool saving;
  final VoidCallback onSave;

  static final _prompts = [
    'Điều gì khiến bạn mỉm cười hôm nay?',
    'Nếu cảm xúc lúc này là thời tiết, nó là gì?',
    'Một điều nhỏ bạn biết ơn hôm nay?',
    'Điều gì đang chiếm nhiều tâm trí bạn nhất?',
    'Nếu được bỏ 1 thứ khỏi hôm nay, bạn chọn gì?',
    'Bạn muốn nói gì với bản thân sáng nay?',
    'Ai khiến bạn cảm thấy an toàn nhất?',
    'Một kỷ niệm đẹp bạn muốn giữ lại?',
  ];

  static final _templates = [
    (
      'Brain dump 🤯',
      'Dành cho lúc đầu óc quá tải. Hãy viết ra tất cả những gì đang làm phiền bạn:\n- Có chuyện gì đang xảy ra?\n- Những suy nghĩ lộn xộn nào đang chạy qua?\n- Điều gì cần giải quyết ngay lập tức?\n- Những gì có thể bỏ qua lúc này?'
    ),
    (
      'Gratitude 🙏',
      'Dành cho lúc cần kéo mood lên. Hãy viết ra 3 điều tích cực:\n1. Hôm nay mình biết ơn điều gì?\n2. Ai đã làm điều tốt lành cho mình?\n3. Một việc nhỏ mình tự hào đã làm hôm nay?'
    ),
    (
      'Anger release 🤬',
      'Dành cho lúc tức giận. Trút bỏ năng lượng nóng nảy:\n- Ai hay điều gì khiến mình giận sôi người?\n- Thể chất mình đang có cảm giác gì (nóng mặt, nghiến răng...)?\n- Cách lành mạnh để xoa dịu ngọn lửa này là gì?'
    ),
    (
      'Anxiety unpack 😰',
      'Dành cho lúc lo lắng, bồn chồn:\n- Nguồn gốc của nỗi lo sợ này là gì?\n- Tình huống xấu nhất có thể xảy ra là gì? Nó có thực sự có khả năng xảy ra?\n- Nếu nó xảy ra, mình sẽ xử lý như thế nào?'
    ),
    (
      'Sleep reflection 🌙',
      'Dành cho trước khi ngủ để thư giãn:\n- Hôm nay điều gì đã kết thúc tốt đẹp?\n- Mình cần buông bỏ điều gì trước khi nhắm mắt?\n- Mong ước một giấc ngủ ngon như thế nào?'
    ),
    (
      'Self-compassion 🌸',
      'Dành cho khi tự trách bản thân:\n- Mình đang tự phê phán bản thân về điều gì?\n- Nếu một người bạn thân gặp chuyện này, mình sẽ an ủi họ thế nào?\n- Lời dịu dàng mình gửi cho chính mình lúc này?'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final prompt = _prompts[Random().nextInt(_prompts.length)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Templates list
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: _templates.map((temp) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(context.t(temp.$1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    backgroundColor: context.surface,
                    side: BorderSide(color: context.fieldBorder),
                    onPressed: () {
                      bodyController.text = temp.$2;
                      bodyController.selection = TextSelection.collapsed(offset: temp.$2.length);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          // Mood-based journal prompt.
          GestureDetector(
            onTap: () {
              bodyController.text = '${context.t(prompt)}\n\n';
              bodyController.selection = TextSelection.collapsed(
                  offset: bodyController.text.length);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: RelaxColors.violet.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.t(prompt),
                      style: TextStyle(
                        color: context.mutedText,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Icon(Icons.add, color: context.mutedText, size: 16),
                ],
              ),
            ),
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: context.t('Tiêu đề (không bắt buộc)'),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const Divider(color: RelaxColors.lilac),
          TextField(
            controller: bodyController,
            maxLines: 4,
            maxLength: 600,
            decoration: InputDecoration(
              hintText: context.t('Hôm nay có gì đáng nhớ?'),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.edit, size: 18),
              label: Text(saving
                  ? context.t('Đang lưu…')
                  : context.t('Lưu nhật ký')),
            ),
          ),
        ],
      ),
    );
  }
}
