import 'package:flutter/material.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import 'weather_chart_painter.dart';

// Bieu do xu huong nhiet do 7 ngay (Cao nhat / Thap nhat).
// Tu ve bang CustomPainter, tich hop hien thi chi so truc tiep len cham do thi.
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
          context.t('Xu hướng nhiệt độ 7 ngày 📊'),
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
                  painter: WeatherChartPainter(
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
                    context.t('Cao nhất'),
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
                    context.t('Thấp nhất'),
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
