import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Một CustomTransitionPage mềm mại, dùng chung cho mọi GoRoute để app
/// có cảm giác đầm thắm, dịu dàng — không bị slide cứng như Material
/// default. Fade + slight rise + subtle scale, easeOutCubic 360ms.
CustomTransitionPage<T> softPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      final eased = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: eased,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(eased),
          child: child,
        ),
      );
    },
  );
}
