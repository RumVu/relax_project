import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../data/models/app_models.dart';

/// Chip phương thức (Thiền/Hít thở/Nhật ký/Nhạc) — compact để 4 chip vừa 1 hàng.
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(method.icon, color: RelaxTheme.lavender, size: 22),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  method.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
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
