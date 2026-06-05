part of 'package:relax_app/main.dart';

class MoodLineChart extends StatelessWidget {
  const MoodLineChart({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 118 : 178,
      child: CustomPaint(
        painter: MoodLinePainter(
          dark: context.dark,
          border: context.relax.border,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class MoodLinePainter extends CustomPainter {
  const MoodLinePainter({required this.dark, required this.border});

  final bool dark;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = border.withValues(alpha: .55)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    const values = [.22, .32, .58, .38, .30, .62, .84];
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      points.add(
        Offset(
          size.width * i / (values.length - 1),
          size.height * (1 - values[i]),
        ),
      );
    }

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
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

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final middle = Offset(
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
      path.quadraticBezierTo(previous.dx, previous.dy, middle.dx, middle.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = RelaxTheme.lavender
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final dot = Paint()
      ..color = dark ? const Color(0xFFEFE9FF) : RelaxTheme.purple;
    for (final point in points) {
      canvas.drawCircle(point, 4, dot);
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = RelaxTheme.purple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MoodLinePainter oldDelegate) {
    return oldDelegate.dark != dark || oldDelegate.border != border;
  }
}
