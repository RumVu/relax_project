import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale_controller.dart';
import '../../../core/tour_controller.dart';
import '../../../core/theme.dart';
import '../helpers/home_ui_helpers.dart';

// Top header with weather icon, greeting, and notification bell.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    required this.greeting,
    required this.unreadCount,
    required this.onNotifications,
  });

  final String name;
  final Map<String, dynamic>? greeting;
  final int unreadCount;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final template = (greeting?['titleTemplate'] as String?) ??
        (greeting?['title'] as String?) ??
        'Đã trở lại rồi nè ~';
    final cleanTemplate = template.replaceAll('{{name}}', '{name}');
    final title = context.t(cleanTemplate, {'name': name});
    final subtitle = context.t(
        (greeting?['subtitle'] as String?) ?? 'Chúc bạn một ngày nhẹ nhàng.');
    return Row(
      key: TourController.instance.targetKeys[0],
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/weather'),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(
                  weatherIcon(greeting?['iconKey']),
                  color: weatherIconColor(greeting?['iconKey']),
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: context.appText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style:
                            TextStyle(color: context.mutedText, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Stack(
          children: [
            IconButton(
              onPressed: onNotifications,
              icon:
                  Icon(Icons.notifications_outlined, color: context.appText),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: RelaxColors.coral,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
