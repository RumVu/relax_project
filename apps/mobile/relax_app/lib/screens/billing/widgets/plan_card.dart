import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

/// Card gói đăng ký.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.isCurrent,
    required this.features,
    required this.onTap,
  });
  final String name;
  final String description;
  final String price;
  final bool isCurrent;
  final List<String> features;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? RelaxColors.violet : context.fieldBorder,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: context.appText,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: RelaxColors.violet.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    context.t('Đang dùng'),
                    style: const TextStyle(
                      color: RelaxColors.violet,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(description,
                style: TextStyle(color: context.mutedText, fontSize: 13)),
          ],
          const SizedBox(height: 12),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: context.appText,
            ),
          ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: RelaxColors.mint),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(f,
                            style: TextStyle(
                                color: context.appText, fontSize: 13)),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCurrent ? context.surfaceAlt : RelaxColors.violet,
                foregroundColor: isCurrent ? context.mutedText : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onTap,
              child: Text(
                isCurrent
                    ? context.t('Gói hiện tại')
                    : context.t('Chọn gói này'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
