import 'package:flutter/material.dart';
import '../../../../../../../app/theme.dart';
import '../../../../app/theme.dart';
import '../../../data/models/app_models.dart';

class MethodChip extends StatelessWidget {
  const MethodChip({super.key, required this.method});

  final MethodOption method;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.relax.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(method.icon, color: RelaxTheme.purple),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              method.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
