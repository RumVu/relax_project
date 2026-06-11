import 'package:flutter/material.dart';

class SpotlightPainter extends CustomPainter {
  SpotlightPainter({required this.offset, required this.size});
  final Offset offset;
  final Size size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.75);

    if (size == Size.zero) {
      canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), paint);
      return;
    }

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    const padding = 6.0;
    final holeRect = Rect.fromLTWH(
      offset.dx - padding,
      offset.dy - padding,
      size.width + padding * 2,
      size.height + padding * 2,
    );
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(holeRect, const Radius.circular(14)));

    final path = Path.combine(PathOperation.difference, backgroundPath, holePath);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.size != size;
  }
}
