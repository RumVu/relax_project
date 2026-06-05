import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

/// Biểu đồ đường cảm xúc 7 ngày — KHÔNG còn hardcode bất kỳ giá trị nào.
///
/// [data] — list double [0,1], index 0 = ngày xa nhất (T2), index 6 = hôm nay.
///   • null  → skeleton (đang load)
///   • [] / all-zero → empty state "Chưa có dữ liệu"
///   • [v1..v7] → vẽ đường thật từ API
class MoodLineChart extends StatelessWidget {
  const MoodLineChart({
    super.key,
    this.compact = false,
    this.data,
    this.dayLabels = const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
  });

  final bool compact;
  final List<double>? data;
  final List<String> dayLabels;

  bool get _hasData =>
      data != null && data!.isNotEmpty && data!.any((v) => v > 0);

  @override
  Widget build(BuildContext context) {
    final chartH = compact ? 118.0 : 178.0;

    if (data == null) {
      return SizedBox(
        height: chartH,
        child: Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: RelaxTheme.lavender.withValues(alpha: .5),
            ),
          ),
        ),
      );
    }

    if (!_hasData) {
      return SizedBox(
        height: compact ? 72 : 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_rounded,
                color: context.relax.muted.withValues(alpha: .4), size: 26),
            const SizedBox(height: 6),
            Text(
              'Chưa có dữ liệu — bắt đầu check-in cảm xúc nhé ✦',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.relax.muted, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: chartH,
          child: CustomPaint(
            painter: MoodLinePainter(
              dark: context.dark,
              border: context.relax.border,
              values: data!,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        if (compact && dayLabels.length == 7) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayLabels
                .map((l) => Text(l,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 10, color: context.relax.muted)))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class MoodLinePainter extends CustomPainter {
  const MoodLinePainter(
      {required this.dark, required this.border, required this.values});

  final bool dark;
  final Color border;
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = border.withValues(alpha: .55)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (values.isEmpty) return;

    final n = values.length;
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          n == 1 ? size.width / 2 : size.width * i / (n - 1),
          size.height * (1 - values[i].clamp(0.0, 1.0)),
        ),
    ];

    // gradient fill
    final fill = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) fill.lineTo(p.dx, p.dy);
    fill.lineTo(pts.last.dx, size.height);
    fill.close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            RelaxTheme.purple.withValues(alpha: .24),
            RelaxTheme.purple.withValues(alpha: .02),
          ],
        ).createShader(Offset.zero & size),
    );

    // bezier line
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final mid = Offset(
          (pts[i - 1].dx + pts[i].dx) / 2, (pts[i - 1].dy + pts[i].dy) / 2);
      line.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, mid.dx, mid.dy);
    }
    line.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(
      line,
      Paint()
        ..color = RelaxTheme.lavender
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // dots
    final dotFill = Paint()
      ..color = dark ? const Color(0xFFEFE9FF) : RelaxTheme.purple;
    final dotRing = Paint()
      ..color = RelaxTheme.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final p in pts) {
      canvas.drawCircle(p, 4, dotFill);
      canvas.drawCircle(p, 6, dotRing);
    }
  }

  @override
  bool shouldRepaint(covariant MoodLinePainter old) =>
      old.dark != dark ||
      old.values.length != values.length ||
      old.values.toString() != values.toString();
}
