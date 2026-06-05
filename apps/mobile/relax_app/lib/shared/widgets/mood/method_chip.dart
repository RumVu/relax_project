import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../data/models/app_models.dart';

class MethodChip extends StatelessWidget {
  const MethodChip({super.key, required this.method, this.onTap});

  final MethodOption method;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 90,
          decoration: BoxDecoration(
            color: context.relax.surfaceSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onTap != null
                  ? RelaxTheme.purple.withValues(alpha: .3)
                  : context.relax.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(method.icon, color: RelaxTheme.lavender, size: 28),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  method.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
