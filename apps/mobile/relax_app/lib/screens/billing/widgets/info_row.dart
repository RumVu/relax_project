import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';

/// Dòng thông tin trong bottom sheet thanh toán.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.copyValue,
  });
  final String label;
  final String value;
  final String? copyValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: context.mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: context.appText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (copyValue != null)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: copyValue!));
                showSoftToast(
                  context,
                  message: context.t('Đã sao chép {label}', {'label': label}),
                  tone: SoftToastTone.success,
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: RelaxColors.violet,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
