import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../journey_prompt.dart';

/// A compact chip for secondary suggestions (after the primary card).
class SecondaryChip extends StatelessWidget {
  const SecondaryChip({super.key, required this.suggestion});
  final JourneySuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.pop(context);
          if (suggestion.onTap != null) {
            suggestion.onTap!();
          } else if (suggestion.route != null) {
            context.push(suggestion.route!);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: RelaxColors.violet.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: RelaxColors.violet.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(suggestion.icon, color: RelaxColors.violet, size: 18),
              const SizedBox(width: 8),
              Text(
                context.t(suggestion.label),
                style: const TextStyle(
                  color: RelaxColors.violet,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
