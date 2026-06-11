import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

class MoodErrorBox extends StatelessWidget {
  const MoodErrorBox({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RelaxColors.coral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RelaxColors.coral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('Không tải được dữ liệu'),
            style: const TextStyle(fontWeight: FontWeight.w800, color: RelaxColors.coral),
          ),
          const SizedBox(height: 4),
          Text(message,
              style: const TextStyle(color: RelaxColors.coral, fontSize: 12)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.t('Thử lại')),
          ),
        ],
      ),
    );
  }
}
