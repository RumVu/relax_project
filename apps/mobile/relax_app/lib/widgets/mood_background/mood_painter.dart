import 'dart:math' as math;

import 'package:flutter/material.dart';

// CustomPainter for the two floating radial gradient blobs.
class MoodPainter extends CustomPainter {
  MoodPainter({required this.t, required this.colorA, required this.colorB});

  final double t;
  final Color colorA;
  final Color colorB;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w * 0.55;

    final cx1 = w * 0.3 + math.cos(t) * w * 0.15;
    final cy1 = h * 0.25 + math.sin(t) * h * 0.08;
    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [colorA, colorA.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: Offset(cx1, cy1), radius: r));
    canvas.drawCircle(Offset(cx1, cy1), r, p1);

    final cx2 = w * 0.75 + math.cos(t + math.pi) * w * 0.12;
    final cy2 = h * 0.75 + math.sin(t + math.pi) * h * 0.1;
    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [colorB, colorB.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: Offset(cx2, cy2), radius: r));
    canvas.drawCircle(Offset(cx2, cy2), r, p2);
  }

  @override
  bool shouldRepaint(covariant MoodPainter old) =>
      old.t != t || old.colorA != colorA || old.colorB != colorB;
}
