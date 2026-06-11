import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

// Gradient card explaining why location is needed.
class LocationWhyCard extends StatelessWidget {
  const LocationWhyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RelaxColors.violet, RelaxColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_outlined, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(context.t('Vì sao cần vị trí?'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.t(
                'Để gợi ý thời tiết, quán cà phê yên tĩnh và phòng tập thiền gần bạn. Chúng tôi chỉ lưu toạ độ, không theo dõi di chuyển.'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
