import 'package:flutter/material.dart';
import '../../../../../../../app/theme.dart';
import '../../../../app/theme.dart';

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: index == active ? 12 : 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: index == active ? RelaxTheme.purple : context.relax.border,
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }
}
