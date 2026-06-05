import 'package:flutter/material.dart';
import '../../../../../../../app/theme.dart';
import '../../../../app/theme.dart';
import '../pixel/pixel_panel.dart';

class SettingAction extends StatelessWidget {
  const SettingAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? action;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = danger ? context.relax.danger : RelaxTheme.lavender;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: PixelPanel(
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: danger ? color : null,
                    ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (action != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: RelaxTheme.purple,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  action!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right_rounded, color: context.relax.muted),
          ],
        ),
      ),
    );
  }
}
