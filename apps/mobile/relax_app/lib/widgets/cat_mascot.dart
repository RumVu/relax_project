import 'package:flutter/material.dart';

import '../core/theme.dart';

enum CatVariant { stand, sleep, right, left }

const _fileMap = <CatVariant, String>{
  CatVariant.stand: 'assets/mascot/meo-chat.gif',
  CatVariant.sleep: 'assets/mascot/meo-sleep.gif',
  CatVariant.right: 'assets/mascot/meo-right.gif',
  CatVariant.left: 'assets/mascot/meo-left.gif',
};

class CatMascot extends StatelessWidget {
  const CatMascot({
    super.key,
    this.variant = CatVariant.stand,
    this.size = 120,
    this.glow = true,
    this.opacity = 1.0,
  });

  final CatVariant variant;
  final double size;
  final bool glow;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
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
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          _fileMap[variant]!,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
