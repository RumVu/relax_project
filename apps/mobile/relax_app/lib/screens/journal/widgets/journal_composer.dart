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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        children: [
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
