import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

/// A single row card for one day of weather forecast.
class ForecastDayCard extends StatelessWidget {
  const ForecastDayCard({super.key, required this.day});

  final Map<String, dynamic> day;

  @override
  Widget build(BuildContext context) {
    final date = (day['date'] as String?) ?? '';
    final max = (day['temperatureMax'] as num?)?.round();
    final min = (day['temperatureMin'] as num?)?.round();
    final rain = (day['precipitationProbability'] as num?)?.round();
    final title = (day['title'] as String?) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.appText,
                ),
              ),
              if (title.isNotEmpty)
                Text(
                  context.t(title),
                  style: const TextStyle(
                      color: RelaxColors.slate, fontSize: 11),
                ),
            ],
          ),
          const Spacer(),
          if (rain != null) ...[
            const Icon(Icons.water_drop,
                size: 14, color: RelaxColors.violet),
            const SizedBox(width: 2),
            Text(
              '$rain%',
              style: const TextStyle(
                color: RelaxColors.violet,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 14),
          ],
          Text(
            '${min ?? '—'}° / ${max ?? '—'}°',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: context.appText,
            ),
          ),
        ],
      ),
    );
  }
}
