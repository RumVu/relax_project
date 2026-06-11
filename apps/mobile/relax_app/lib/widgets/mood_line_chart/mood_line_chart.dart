import 'package:flutter/material.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import 'mood_line_painter.dart';

// Bieu do duong cam xuc 7 ngay — tu ve bang CustomPainter, khong can
// package ngoai. `values` la 7 diem 0..1 (null = ngay chua co du lieu).
class MoodLineChart extends StatelessWidget {
  const MoodLineChart({
    super.key,
    required this.values,
    this.labels = const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
    this.height = 130,
  });

  final List<double?> values;
  final List<String> labels;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: MoodLinePainter(
              values: values,
              lineColor: RelaxColors.violet,
              gridColor: context.fieldBorder,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: labels
              .map((l) => Text(
                    context.t(l),
                    style: TextStyle(fontSize: 10, color: context.mutedText),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
