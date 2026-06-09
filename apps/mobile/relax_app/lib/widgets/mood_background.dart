import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Nền gradient động — hai vòng tròn mờ trôi rất chậm, đổi tông theo cảm xúc
/// chủ đạo. Đặt bên dưới mọi nội dung của Home để tạo cảm giác "thở" cùng
/// trạng thái user, không gây phân tâm.
///
/// `mood`: 'calm' | 'happy' | 'sad' | 'energetic' | 'neutral'.
class MoodBackground extends StatefulWidget {
  const MoodBackground({
    super.key,
    this.mood = 'calm',
    required this.child,
  });

  final String mood;
  final Widget child;

  @override
  State<MoodBackground> createState() => _MoodBackgroundState();
}

class _MoodBackgroundState extends State<MoodBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // Mỗi mood = 2 màu nền dịu — lerp giữa chúng tạo "hơi thở" rất chậm.
  ({Color a, Color b}) get _palette {
    switch (widget.mood) {
      case 'happy':
        return (a: const Color(0xFFFFD8A8), b: const Color(0xFFFFB199));
      case 'sad':
        return (a: const Color(0xFFA0B8E0), b: const Color(0xFF8E9EBE));
      case 'energetic':
        return (a: const Color(0xFFFFB199), b: const Color(0xFF7357F6));
      case 'neutral':
        return (a: const Color(0xFFDCD6FF), b: const Color(0xFFB6E5D8));
      case 'calm':
      default:
        return (a: const Color(0xFFB6C9E5), b: const Color(0xFFDCD6FF));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? RelaxColors.bgDark : RelaxColors.bgLight;
    final pal = _palette;
    return AnimatedBuilder(
      animation: _c,
      builder: (ctx, _) {
        final t = _c.value * 2 * math.pi;
        // Hai blob di chuyển vòng tròn rất chậm.
        return Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: base)),
            Positioned.fill(
              child: CustomPaint(
                painter: _MoodPainter(
                  t: t,
                  colorA: pal.a.withValues(alpha: dark ? 0.18 : 0.32),
                  colorB: pal.b.withValues(alpha: dark ? 0.18 : 0.32),
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

class _MoodPainter extends CustomPainter {
  _MoodPainter({required this.t, required this.colorA, required this.colorB});
  final double t;
  final Color colorA;
  final Color colorB;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w * 0.55;

    final cx1 = w * 0.3 + math.cos(t) * w * 0.15;
    final cy1 = h * 0.25 + math.sin(t) * h * 0.08;
    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [colorA, colorA.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: Offset(cx1, cy1), radius: r));
    canvas.drawCircle(Offset(cx1, cy1), r, p1);

    final cx2 = w * 0.75 + math.cos(t + math.pi) * w * 0.12;
    final cy2 = h * 0.75 + math.sin(t + math.pi) * h * 0.1;
    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [colorB, colorB.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: Offset(cx2, cy2), radius: r));
    canvas.drawCircle(Offset(cx2, cy2), r, p2);
  }

  @override
  bool shouldRepaint(covariant _MoodPainter old) =>
      old.t != t || old.colorA != colorA || old.colorB != colorB;
}
