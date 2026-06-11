import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/locale_controller.dart';

class BreathingStep extends StatelessWidget {
  const BreathingStep({
    super.key,
    required this.controller,
    required this.label,
    required this.cycle,
    required this.onSkip,
  });
  final AnimationController controller;
  final String label;
  final int cycle;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                context.t('Bỏ qua →'),
                style: TextStyle(
                  color: context.appText.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            context.t('Cùng thở một chút trước nha ✦'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${context.t('Nhịp')} $cycle / 3',
            style: TextStyle(
              color: context.appText.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 36),
          AnimatedBuilder(
            animation: controller,
            builder: (_, _) => Transform.scale(
              scale: controller.value,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [RelaxColors.plum, RelaxColors.violet],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RelaxColors.violet.withValues(alpha: 0.35),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            context.t('Theo nhịp tròn, mọi thứ đợi được mà.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText.withValues(alpha: 0.6),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
