import 'package:flutter/material.dart';
import '../../../../../app/theme.dart';

class FavoriteActivity extends StatelessWidget {
  const FavoriteActivity({
    super.key,
    required this.label,
    required this.value,
    required this.amount,
  });

  final String label;
  final String value;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: amount,
                minHeight: 8,
                backgroundColor: context.relax.surfaceSoft,
                valueColor: const AlwaysStoppedAnimation(RelaxTheme.lavender),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
