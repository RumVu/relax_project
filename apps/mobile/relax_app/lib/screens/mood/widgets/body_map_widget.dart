import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

class BodyZone {
  final String id;
  final String label;
  final Offset center;
  final double radius;

  const BodyZone(this.id, this.label, this.center, this.radius);
}

class BodyMapWidget extends StatelessWidget {
  final Set<String> selectedZones;
  final ValueChanged<String> onToggle;

  const BodyMapWidget({
    super.key,
    required this.selectedZones,
    required this.onToggle,
  });

  static const _zones = [
    BodyZone('HEAD', 'Đầu', Offset(0.5, 0.08), 0.07),
    BodyZone('NECK', 'Cổ/Vai', Offset(0.5, 0.18), 0.06),
    BodyZone('CHEST', 'Ngực', Offset(0.5, 0.28), 0.08),
    BodyZone('STOMACH', 'Bụng', Offset(0.5, 0.40), 0.07),
    BodyZone('LEFT_ARM', 'Tay trái', Offset(0.25, 0.32), 0.05),
    BodyZone('RIGHT_ARM', 'Tay phải', Offset(0.75, 0.32), 0.05),
    BodyZone('LOWER_BACK', 'Lưng dưới', Offset(0.5, 0.52), 0.07),
    BodyZone('LEFT_LEG', 'Chân trái', Offset(0.38, 0.72), 0.06),
    BodyZone('RIGHT_LEG', 'Chân phải', Offset(0.62, 0.72), 0.06),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = w * 1.1;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              // Body silhouette
              Center(
                child: CustomPaint(
                  size: Size(w * 0.5, h * 0.9),
                  painter: _BodyOutlinePainter(
                    color: ctx.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              // Touch zones
              ..._zones.map((zone) {
                final selected = selectedZones.contains(zone.id);
                final x = zone.center.dx * w;
                final y = zone.center.dy * h;
                final r = zone.radius * w;

                return Positioned(
                  left: x - r,
                  top: y - r,
                  child: GestureDetector(
                    onTap: () => onToggle(zone.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: r * 2,
                      height: r * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? RelaxColors.coral.withValues(alpha: 0.35)
                            : ctx.isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.04),
                        border: Border.all(
                          color: selected
                              ? RelaxColors.coral
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ctx.t(zone.label),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                            color: selected
                                ? RelaxColors.coral
                                : ctx.mutedText,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _BodyOutlinePainter extends CustomPainter {
  final Color color;

  _BodyOutlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Head
    canvas.drawCircle(Offset(w * 0.5, h * 0.06), w * 0.12, paint);

    // Torso
    final torso = Path()
      ..moveTo(w * 0.3, h * 0.14)
      ..quadraticBezierTo(w * 0.5, h * 0.12, w * 0.7, h * 0.14)
      ..lineTo(w * 0.72, h * 0.45)
      ..quadraticBezierTo(w * 0.5, h * 0.5, w * 0.28, h * 0.45)
      ..close();
    canvas.drawPath(torso, paint);

    // Arms
    final leftArm = Path()
      ..moveTo(w * 0.28, h * 0.16)
      ..quadraticBezierTo(w * 0.08, h * 0.28, w * 0.1, h * 0.42)
      ..lineTo(w * 0.18, h * 0.42)
      ..quadraticBezierTo(w * 0.16, h * 0.3, w * 0.3, h * 0.2)
      ..close();
    canvas.drawPath(leftArm, paint);

    final rightArm = Path()
      ..moveTo(w * 0.72, h * 0.16)
      ..quadraticBezierTo(w * 0.92, h * 0.28, w * 0.9, h * 0.42)
      ..lineTo(w * 0.82, h * 0.42)
      ..quadraticBezierTo(w * 0.84, h * 0.3, w * 0.7, h * 0.2)
      ..close();
    canvas.drawPath(rightArm, paint);

    // Legs
    final leftLeg = Path()
      ..moveTo(w * 0.3, h * 0.45)
      ..lineTo(w * 0.28, h * 0.85)
      ..lineTo(w * 0.42, h * 0.85)
      ..lineTo(w * 0.46, h * 0.45)
      ..close();
    canvas.drawPath(leftLeg, paint);

    final rightLeg = Path()
      ..moveTo(w * 0.54, h * 0.45)
      ..lineTo(w * 0.58, h * 0.85)
      ..lineTo(w * 0.72, h * 0.85)
      ..lineTo(w * 0.7, h * 0.45)
      ..close();
    canvas.drawPath(rightLeg, paint);

    // Feet
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.24, h * 0.85, w * 0.22, h * 0.06),
        Radius.circular(w * 0.04),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.54, h * 0.85, w * 0.22, h * 0.06),
        Radius.circular(w * 0.04),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BodyOutlinePainter old) => old.color != color;
}
