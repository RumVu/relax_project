// Helper utilities for the notification sheet.

import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';

/// Format a raw ISO date string into a relative time label.
String formatNotificationDate(BuildContext context, String? dateStr) {
  if (dateStr == null) return '';
  try {
    final dt = DateTime.parse(dateStr).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 30) {
      return context.t('Vừa xong');
    } else if (diff.inMinutes < 60) {
      return context.t('{count} phút trước', {'count': '${diff.inMinutes}'});
    } else if (diff.inHours < 24) {
      return context.t('{count} giờ trước', {'count': '${diff.inHours}'});
    } else {
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute $day/$month';
    }
  } catch (_) {
    return '';
  }
}

/// Return an appropriate icon for the notification [type].
IconData notificationIcon(String? type) {
  switch (type) {
    case 'EMAIL':
      return Icons.mail_outline;
    case 'SMS':
      return Icons.sms_outlined;
    case 'PUSH':
      return Icons.cell_tower_outlined;
    default:
      return Icons.notifications_none_outlined;
  }
}
