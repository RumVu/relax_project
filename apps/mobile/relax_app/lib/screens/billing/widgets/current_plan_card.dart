import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

/// Card hiển thị gói hiện tại.
class CurrentPlanCard extends StatelessWidget {
  const CurrentPlanCard({
    super.key,
    required this.subscription,
    required this.tierName,
  });
  final Map<String, dynamic>? subscription;
  final String Function(String?) tierName;

  @override
  Widget build(BuildContext context) {
    final subObj = subscription?['subscription'] as Map?;
    final tier = (subObj?['planName'] ??
        subObj?['plan'] ??
        subObj?['tier'] ??
        subscription?['tier'] ??
        subscription?['plan'] ??
        'FREE') as String;
    final isFree = tier.toUpperCase() == 'FREE';
    final expiresAt = (subObj?['endDate'] ??
        subObj?['expiresAt'] ??
        subscription?['expiresAt'] ??
        subscription?['endDate']) as String?;
    final expDate = expiresAt != null ? DateTime.tryParse(expiresAt) : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFree
              ? [RelaxColors.slate, const Color(0xFF5a6072)]
              : [RelaxColors.violet, RelaxColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isFree ? RelaxColors.slate : RelaxColors.violet)
                .withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFree ? Icons.person_outline : Icons.workspace_premium,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                context.t('Gói hiện tại'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tierName(tier),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          if (expDate != null) ...[
            const SizedBox(height: 6),
            Text(
              '${context.t('Hết hạn:')} ${expDate.day}/${expDate.month}/${expDate.year}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
          if (isFree) ...[
            const SizedBox(height: 10),
            Text(
              context.t('Nâng cấp để mở khóa toàn bộ tính năng!'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
