import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

class IntensitySlider extends StatelessWidget {
  const IntensitySlider({super.key, required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.t('Cường độ'),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: context.appText,
              ),
            ),
            Text(
              '${value.round()}/5',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: RelaxColors.violet,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: RelaxColors.violet,
          inactiveColor: RelaxColors.lilac,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
