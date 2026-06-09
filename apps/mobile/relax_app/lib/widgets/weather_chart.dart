import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Biểu đồ xu hướng nhiệt độ 7 ngày (Cao nhất / Thấp nhất).
/// Tự vẽ bằng CustomPainter, tích hợp hiển thị chỉ số trực tiếp lên chấm đồ thị.
class WeatherForecastChart extends StatelessWidget {
  const WeatherForecastChart({
    super.key,
    required this.forecast,
    this.height = 140,
  });

  final List<Map<String, dynamic>> forecast;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    // Định dạng label ngày dưới trục hoành (vd: "08/06", "09/06")
    final labels = forecast.map((d) {
      final dateStr = d['date'] as String? ?? '';
      if (dateStr.length >= 10) {
        final parts = dateStr.split('-');
        if (parts.length >= 3) {
          return '${parts[2]}/${parts[1]}';
        }
      }
      return dateStr;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xu hướng nhiệt độ 7 ngày 📊',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: context.appText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.fieldBorder),
          ),
          child: Column(
            children: [
              SizedBox(
                height: height,
                width: double.infinity,
                child: CustomPaint(
                  painter: _WeatherChartPainter(
                    forecast: forecast,
                    highColor: RelaxColors.coral,
                    lowColor: RelaxColors.violet,
                    gridColor: context.fieldBorder,
                    textColor: context.appText,
                    mutedTextColor: context.mutedText,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: labels
                    .map((l) => Text(
                          l,
                          style: TextStyle(
                            fontSize: 10,
                            color: context.mutedText,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              // Legend ghi chú màu
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: RelaxColors.coral,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Cao nhất',
                    style: TextStyle(fontSize: 11, color: context.mutedText),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: RelaxColors.violet,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Thấp nhất',
                    style: TextStyle(fontSize: 11, color: context.mutedText),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _WeatherChartPainter extends CustomPainter {
  _WeatherChartPainter({
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

    final highs = forecast.map((d) => (d['temperatureMax'] as num?)?.toDouble()).toList();
    final lows = forecast.map((d) => (d['temperatureMin'] as num?)?.toDouble()).toList();

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

    // Chừa khoảng trống đệm ở biên
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

    // Vẽ lưới ngang
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

    // Tô gradient High
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

    // Tô gradient Low
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

    // Vẽ đường đồ thị
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

    // Vẽ các nút tròn và chữ chỉ số nhiệt độ
    final dotFill = Paint();
    final dotRing = Paint()..color = Colors.white;

    void drawDotsAndLabels(List<Offset> dots, List<double?> temps, Color color, bool isHigh) {
      for (var i = 0; i < dots.length; i++) {
        final p = dots[i];
        final t = temps[i];
        if (t == null) continue;

        // Vẽ dot
        canvas.drawCircle(p, 4.5, dotRing);
        canvas.drawCircle(p, 3.0, dotFill..color = color);

        // Vẽ text chỉ số nhiệt độ
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

        // High hiện phía trên dot, Low hiện phía dưới
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
  bool shouldRepaint(covariant _WeatherChartPainter old) =>
      old.forecast != forecast;
}
