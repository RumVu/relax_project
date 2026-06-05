import 'package:flutter/material.dart';
import '../../../../../../../app/theme.dart';
import '../../../../app/theme.dart';
import '../pixel/pixel_panel.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onBellTap,
    this.bellHasBadge = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  /// Bấm chuông → callback (vd mở Stats sheet). Null = bell tĩnh.
  final VoidCallback? onBellTap;

  /// Hiện chấm đỏ nhỏ ở chuông.
  final bool bellHasBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PixelIconBox(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null)
          SizedBox(width: 86, height: 70, child: trailing)
        else
          IconButton(
            tooltip: 'Thống kê',
            onPressed: onBellTap,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: context.relax.muted,
                ),
                if (bellHasBadge)
                  Positioned(
                    right: 1,
                    top: 1,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE85A6A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
