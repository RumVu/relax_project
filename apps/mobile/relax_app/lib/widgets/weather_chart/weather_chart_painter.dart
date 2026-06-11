import 'package:flutter/material.dart';

// CustomPainter for the 7-day temperature trend chart.
class WeatherChartPainter extends CustomPainter {
  WeatherChartPainter({
    required this.forecast,
    required this.highColor,
    required this.lowColor,
    required this.gridColor,
    required this.textColor,
    required this.mutedTextColor,
  });

  final List<Map<String, dynamic>> forecast;
  final Color highColor;
  final Color lowColor;
  final Color gridColor;
  final Color textColor;
  final Color mutedTextColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (forecast.isEmpty) return;

    final highs =
        forecast.map((d) => (d['temperatureMax'] as num?)?.toDouble()).toList();
    final lows =
        forecast.map((d) => (d['temperatureMin'] as num?)?.toDouble()).toList();

    double? globalMin;
    double? globalMax;

    for (final val in highs) {
      if (val != null) {
        if (globalMax == null || val > globalMax) globalMax = val;
      }
    }
    for (final val in lows) {
      if (val != null) {
        if (globalMin == null || val < globalMin) globalMin = val;
      }
    }

    globalMin ??= 15.0;
    globalMax ??= 35.0;

    if (globalMax == globalMin) {
      globalMax += 2;
      globalMin -= 2;
    } else {
      final diff = globalMax - globalMin;
      globalMax += diff * 0.2;
      globalMin -= diff * 0.2;
    }

    final double minVal = globalMin;
    final double maxVal = globalMax;

    final n = forecast.length;
    final dx = n > 1 ? size.width / (n - 1) : size.width;

    Offset getPoint(int i, double temp) {
      final x = dx * i;
      final ratio = (temp - minVal) / (maxVal - minVal);
      final y = 22 + (size.height - 44) * (1 - ratio);
      return Offset(x, y);
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = 22 + (size.height - 44) * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final highPath = Path();
    final lowPath = Path();
    final highFill = Path();
    final lowFill = Path();

    final highDots = <Offset>[];
    final lowDots = <Offset>[];

    var highStarted = false;
    var lowStarted = false;

    for (var i = 0; i < n; i++) {
      final h = highs[i];
      final l = lows[i];

      if (h != null) {
        final p = getPoint(i, h);
        highDots.add(p);
        if (!highStarted) {
          highPath.moveTo(p.dx, p.dy);
          highFill.moveTo(p.dx, size.height);
          highFill.lineTo(p.dx, p.dy);
          highStarted = true;
        } else {
          highPath.lineTo(p.dx, p.dy);
          highFill.lineTo(p.dx, p.dy);
        }
      }

      if (l != null) {
        final p = getPoint(i, l);
        lowDots.add(p);
        if (!lowStarted) {
          lowPath.moveTo(p.dx, p.dy);
          lowFill.moveTo(p.dx, size.height);
          lowFill.lineTo(p.dx, p.dy);
          lowStarted = true;
        } else {
          lowPath.lineTo(p.dx, p.dy);
          lowFill.lineTo(p.dx, p.dy);
        }
      }
    }

    // High gradient fill
    if (highDots.isNotEmpty) {
      highFill.lineTo(highDots.last.dx, size.height);
      highFill.close();
      final highFillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            highColor.withValues(alpha: 0.15),
            highColor.withValues(alpha: 0.05),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(highFill, highFillPaint);
    }

    // Low gradient fill
    if (lowDots.isNotEmpty) {
      lowFill.lineTo(lowDots.last.dx, size.height);
      lowFill.close();
      final lowFillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lowColor.withValues(alpha: 0.12),
            lowColor.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(lowFill, lowFillPaint);
    }

    // Line strokes
    final linePaint = Paint()
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (highStarted) {
      canvas.drawPath(highPath, linePaint..color = highColor);
    }
    if (lowStarted) {
      canvas.drawPath(lowPath, linePaint..color = lowColor);
    }

    // Dots and temperature labels
    final dotFill = Paint();
    final dotRing = Paint()..color = Colors.white;

    void drawDotsAndLabels(
        List<Offset> dots, List<double?> temps, Color color, bool isHigh) {
      for (var i = 0; i < dots.length; i++) {
        final p = dots[i];
        final t = temps[i];
        if (t == null) continue;

        canvas.drawCircle(p, 4.5, dotRing);
        canvas.drawCircle(p, 3.0, dotFill..color = color);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${t.round()}°',
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final textOffset = Offset(
          p.dx - textPainter.width / 2,
          isHigh ? p.dy - 16 : p.dy + 6,
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    drawDotsAndLabels(highDots, highs, highColor, true);
    drawDotsAndLabels(lowDots, lows, lowColor, false);
  }

  @override
  bool shouldRepaint(covariant WeatherChartPainter old) =>
      old.forecast != forecast;
}
