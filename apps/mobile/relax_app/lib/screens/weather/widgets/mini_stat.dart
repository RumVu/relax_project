import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// A compact weather stat card (e.g. humidity, wind speed).
class MiniStat extends StatelessWidget {
  const MiniStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: RelaxColors.violet, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: RelaxColors.slate, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: context.appText,
            ),
          ),
        ],
      ),
    );
  }
}
