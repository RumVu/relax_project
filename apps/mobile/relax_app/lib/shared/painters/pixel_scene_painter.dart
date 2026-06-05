part of 'package:relax_app/main.dart';

class PixelScenePainter extends CustomPainter {
  const PixelScenePainter({required this.scene, required this.dark});

  final CatScene scene;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final floor = Paint()
      ..color = const Color(0xFF7E67E8).withValues(alpha: dark ? .34 : .22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .14,
          size.height * .72,
          size.width * .72,
          size.height * .12,
        ),
        const Radius.circular(20),
      ),
      floor,
    );

    _stars(canvas, size);
    if (scene == CatScene.window || scene == CatScene.wave) {
      _window(canvas, size);
    }
    if (scene == CatScene.laptop) {
      _laptop(canvas, size);
    }
    if (scene == CatScene.sleep) {
      _sleepBubble(canvas, size);
    }

    final catRect = Rect.fromCenter(
      center: Offset(size.width * .5, size.height * .56),
      width: size.width * .48,
      height: size.height * .50,
    );
    PixelCatPainter(
      dark: dark,
      waving: scene == CatScene.wave,
      sleeping: scene == CatScene.sleep,
    ).paint(canvas, catRect.size, offset: catRect.topLeft);

    _plant(canvas, size);
  }

  void _stars(Canvas canvas, Size size) {
    final star = Paint()
      ..color = dark ? const Color(0xFFFFC96E) : RelaxTheme.purple;
    for (final point in [
      Offset(size.width * .2, size.height * .26),
      Offset(size.width * .78, size.height * .24),
      Offset(size.width * .68, size.height * .38),
      Offset(size.width * .26, size.height * .44),
    ]) {
      canvas.drawCircle(point, 2.5, star);
      canvas.drawLine(
        point.translate(-6, 0),
        point.translate(6, 0),
        star..strokeWidth = 1.4,
      );
      canvas.drawLine(point.translate(0, -6), point.translate(0, 6), star);
    }
  }

  void _window(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * .12, size.height * .18, 70, 78);
    final frame = Paint()..color = const Color(0xFF5D4DD2);
    final glass = Paint()
      ..color = dark ? const Color(0xFF222747) : const Color(0xFFE6E2FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      frame,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(6), const Radius.circular(5)),
      glass,
    );
    canvas.drawCircle(
      Offset(rect.left + 28, rect.top + 30),
      9,
      Paint()..color = const Color(0xFFFFD26B),
    );
  }

  void _laptop(Canvas canvas, Size size) {
    final body = Paint()
      ..color = dark ? const Color(0xFFC7C9D9) : const Color(0xFFB4B7C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .25,
          size.height * .60,
          size.width * .5,
          size.height * .08,
        ),
        const Radius.circular(6),
      ),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .30,
          size.height * .40,
          size.width * .4,
          size.height * .22,
        ),
        const Radius.circular(8),
      ),
      body,
    );
  }

  void _sleepBubble(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dark ? const Color(0xFF242A44) : Colors.white
      ..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(size.width * .58, size.height * .2, 70, 46);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = RelaxTheme.lavender
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Zzz',
        style: TextStyle(
          color: RelaxTheme.lavender,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _plant(Canvas canvas, Size size) {
    final pot = Paint()..color = const Color(0xFF7358D6);
    final leaf = Paint()..color = const Color(0xFF8BCB96);
    final x = size.width * .74;
    final y = size.height * .66;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 28, 30),
        const Radius.circular(5),
      ),
      pot,
    );
    canvas.drawOval(Rect.fromLTWH(x + 5, y - 18, 10, 22), leaf);
    canvas.drawOval(Rect.fromLTWH(x + 15, y - 20, 10, 24), leaf);
  }

  @override
  bool shouldRepaint(covariant PixelScenePainter oldDelegate) {
    return oldDelegate.scene != scene || oldDelegate.dark != dark;
  }
}

class PixelCatPainter extends CustomPainter {
  const PixelCatPainter({
    this.dark = false,
    this.waving = false,
    this.sleeping = false,
  });

  final bool dark;
  final bool waving;
  final bool sleeping;

  @override
  void paint(Canvas canvas, Size size, {Offset offset = Offset.zero}) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final fur = Paint()..color = const Color(0xFFC2A08B);
    final stripe = Paint()..color = const Color(0xFF776151);
    final cream = Paint()..color = const Color(0xFFF7EEE7);
    final outline = Paint()
      ..color = dark ? const Color(0xFF090C18) : const Color(0xFF3C3159)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, size.shortestSide * .018);
    final blush = Paint()..color = const Color(0xFFFF8A9A);

    final body = Rect.fromLTWH(
      size.width * .22,
      size.height * .40,
      size.width * .56,
      size.height * .42,
    );
    canvas.drawOval(body, fur);
    canvas.drawOval(body, outline);

    final tailPath = Path()
      ..moveTo(size.width * .72, size.height * .62)
      ..quadraticBezierTo(
        size.width * .96,
        size.height * .50,
        size.width * .82,
        size.height * .30,
      );
    canvas.drawPath(
      tailPath,
      Paint()
        ..color = fur.color
        ..strokeWidth = size.width * .13
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      tailPath,
      outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, size.width * .018),
    );

    final head = Rect.fromLTWH(
      size.width * .18,
      size.height * .08,
      size.width * .64,
      size.height * .48,
    );
    final leftEar = Path()
      ..moveTo(size.width * .28, size.height * .15)
      ..lineTo(size.width * .18, size.height * .02)
      ..lineTo(size.width * .40, size.height * .08)
      ..close();
    final rightEar = Path()
      ..moveTo(size.width * .60, size.height * .08)
      ..lineTo(size.width * .82, size.height * .02)
      ..lineTo(size.width * .72, size.height * .15)
      ..close();
    canvas.drawPath(leftEar, fur);
    canvas.drawPath(rightEar, fur);
    canvas.drawPath(leftEar, outline);
    canvas.drawPath(rightEar, outline);
    canvas.drawOval(head, fur);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .29,
        size.height * .30,
        size.width * .42,
        size.height * .26,
      ),
      cream,
    );
    canvas.drawOval(head, outline);

    for (final x in [.35, .50, .65]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * .12),
        Offset(size.width * (x - .06), size.height * .25),
        stripe
          ..strokeWidth = size.width * .025
          ..strokeCap = StrokeCap.round,
      );
    }

    if (sleeping) {
      final eyePaint = Paint()
        ..color = const Color(0xFF2E253E)
        ..strokeWidth = size.width * .018
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromLTWH(size.width * .33, size.height * .30, 16, 10),
        0,
        math.pi,
        false,
        eyePaint,
      );
      canvas.drawArc(
        Rect.fromLTWH(size.width * .58, size.height * .30, 16, 10),
        0,
        math.pi,
        false,
        eyePaint,
      );
    } else {
      canvas.drawCircle(
        Offset(size.width * .38, size.height * .33),
        size.width * .045,
        Paint()..color = const Color(0xFF221D2D),
      );
      canvas.drawCircle(
        Offset(size.width * .62, size.height * .33),
        size.width * .045,
        Paint()..color = const Color(0xFF221D2D),
      );
      canvas.drawCircle(
        Offset(size.width * .395, size.height * .315),
        size.width * .012,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(size.width * .635, size.height * .315),
        size.width * .012,
        Paint()..color = Colors.white,
      );
    }

    canvas.drawCircle(
      Offset(size.width * .50, size.height * .40),
      size.width * .018,
      Paint()..color = const Color(0xFF6D4B54),
    );
    canvas.drawCircle(
      Offset(size.width * .31, size.height * .42),
      size.width * .018,
      blush,
    );
    canvas.drawCircle(
      Offset(size.width * .69, size.height * .42),
      size.width * .018,
      blush,
    );

    final pawY = size.height * (waving ? .49 : .72);
    canvas.drawCircle(Offset(size.width * .31, pawY), size.width * .07, fur);
    canvas.drawCircle(
      Offset(size.width * .69, size.height * .72),
      size.width * .07,
      fur,
    );
    canvas.drawCircle(
      Offset(size.width * .31, pawY),
      size.width * .07,
      outline,
    );
    canvas.drawCircle(
      Offset(size.width * .69, size.height * .72),
      size.width * .07,
      outline,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PixelCatPainter oldDelegate) {
    return oldDelegate.dark != dark ||
        oldDelegate.waving != waving ||
        oldDelegate.sleeping != sleeping;
  }
}
