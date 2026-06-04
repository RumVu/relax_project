import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Placeholder linh thú mèo. Mockup dùng pixel-art thật; khi có file ảnh
/// (assets/cat_*.png) chỉ cần thay phần child bằng Image.asset là khớp.
/// Hiện dùng emoji trong khung bo tròn gradient nhẹ để giữ đúng bố cục.
class CatMascot extends StatelessWidget {
  const CatMascot({
    super.key,
    this.size = 120,
    this.emoji = '🐱',
    this.glow = true,
  });

  final double size;
  final String emoji;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            RelaxColors.violet.withValues(alpha: context.isDark ? 0.28 : 0.16),
            RelaxColors.lilac.withValues(alpha: context.isDark ? 0.12 : 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: RelaxColors.violet.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}
