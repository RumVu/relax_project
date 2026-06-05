import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class TimeChip extends StatelessWidget {
  const TimeChip({super.key, required this.time, required this.selected});

  final String time;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: selected ? RelaxTheme.purple : context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? RelaxTheme.purple : context.relax.border,
        ),
      ),
      child: Center(
        child: Text(
          time,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).textTheme.titleMedium?.color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
