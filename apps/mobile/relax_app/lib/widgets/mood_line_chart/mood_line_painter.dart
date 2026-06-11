import 'package:flutter/material.dart';

// CustomPainter for the 7-day mood line chart.
class MoodLinePainter extends CustomPainter {
  MoodLinePainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
  });

  final List<double?> values;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 4 horizontal grid lines.
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;
    final n = values.length;
    final dx = n > 1 ? size.width / (n - 1) : size.width;

    Offset pointAt(int i, double v) {
      final x = dx * i;
      final y = 8 + (size.height - 16) * (1 - v.clamp(0, 1));
      return Offset(x, y);
    }

    final path = Path();
    final fill = Path();
    var started = false;
    final dots = <Offset>[];
    for (var i = 0; i < n; i++) {
      final v = values[i];
      if (v == null) continue;
      final p = pointAt(i, v);
      dots.add(p);
      if (!started) {
        path.moveTo(p.dx, p.dy);
        fill.moveTo(p.dx, size.height);
        fill.lineTo(p.dx, p.dy);
        started = true;
      } else {
        path.lineTo(p.dx, p.dy);
        fill.lineTo(p.dx, p.dy);
      }
    }
    if (dots.isNotEmpty) {
      fill.lineTo(dots.last.dx, size.height);
      fill.close();
    }

    // Gradient fill under the line.
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fill, fillPaint);

    // Main line.
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Dots.
    final dotFill = Paint()..color = lineColor;
    final dotRing = Paint()..color = Colors.white;
    for (final d in dots) {
      canvas.drawCircle(d, 4.5, dotRing);
      canvas.drawCircle(d, 3, dotFill);
    }
  }

  @override
  bool shouldRepaint(covariant MoodLinePainter old) =>
      old.values != values || old.lineColor != lineColor;
}
