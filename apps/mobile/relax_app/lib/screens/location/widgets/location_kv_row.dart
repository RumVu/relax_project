import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

// Key-value row for location info display.
class LocationKvRow extends StatelessWidget {
  const LocationKvRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(context.t(label),
              style: TextStyle(color: context.mutedText, fontSize: 12)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: context.appText, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
