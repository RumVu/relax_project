import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../helpers/breathing_labels.dart';
import '../models/breathing_phase.dart';

// Animated breathing circle with scale animation, rings, and phase display.
class BreathingCircle extends StatelessWidget {
  const BreathingCircle({
    super.key,
    required this.scaleCtrl,
    required this.phase,
    required this.phaseRemaining,
  });

  final AnimationController scaleCtrl;
  final BreathingPhase phase;
  final int phaseRemaining;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: AnimatedBuilder(
          animation: scaleCtrl,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                _ring(260),
                _ring(220),
                _ring(180),
                Transform.scale(
                  scale: scaleCtrl.value,
                  child: Container(
                    height: 220,
                    width: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [RelaxColors.violet, RelaxColors.plum],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: RelaxColors.violet.withValues(alpha: 0.45),
                          blurRadius: 50,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.t(phaseLabel(phase)).toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          phase == BreathingPhase.idle
                              ? '·'
                              : phase == BreathingPhase.finished
                                  ? '✓'
                                  : '$phaseRemaining',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _ring(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: RelaxColors.violet.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}
