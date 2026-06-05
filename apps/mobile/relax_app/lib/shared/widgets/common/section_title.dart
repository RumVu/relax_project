import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: RelaxTheme.lavender, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}
