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
        children: [
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
