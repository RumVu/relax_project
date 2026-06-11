import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'mood_painter.dart';

// Nen gradient dong — hai vong tron mo troi rat cham, doi tong theo cam xuc
// chu dao. Dat ben duoi moi noi dung cua Home de tao cam giac "tho" cung
// trang thai user, khong gay phan tam.
//
// `mood`: 'calm' | 'happy' | 'sad' | 'energetic' | 'neutral'.
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
        return Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: base)),
            Positioned.fill(
              child: CustomPaint(
                painter: MoodPainter(
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
