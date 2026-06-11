import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../helpers/notification_helpers.dart';

/// A single notification row inside the notification bottom sheet.
class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = item['isRead'] == true;
    final title = context.t((item['title'] as String?) ?? 'Thông báo');
    final message = context.t((item['message'] as String?) ?? '');
    final date = formatNotificationDate(context, item['createdAt'] as String?);
    final type = item['type'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? context.surfaceAlt.withValues(alpha: 0.4)
              : context.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? Colors.transparent
                : context.fieldBorder.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isRead
                    ? context.surface.withValues(alpha: 0.5)
                    : RelaxColors.violet.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notificationIcon(type),
                color: isRead ? context.mutedText : RelaxColors.violet,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.w800,
                            fontSize: 14,
                            color: isRead ? context.mutedText : context.appText,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: RelaxColors.coral,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      color: isRead
                          ? context.mutedText.withValues(alpha: 0.7)
                          : context.mutedText,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 10,
                      color: context.mutedText.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
