import 'package:flutter/widgets.dart';

import '../../../core/locale_controller.dart';

/// Format a price value as VND string with dot separators.
String formatPrice(BuildContext context, dynamic price) {
  if (price == null) return context.t('Miễn phí');
  final n = (price is num) ? price.toInt() : int.tryParse('$price') ?? 0;
  if (n == 0) return context.t('Miễn phí');
  // Format VND with dot separator
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${buf.toString()}đ';
}

/// Return a human-readable display name for a subscription tier slug.
String tierDisplayName(BuildContext context, String? tier) {
  switch (tier?.toUpperCase()) {
    case 'CHILL_PLUS':
      return 'Chill+';
    case 'CHILL_PLUS_ANNUAL':
      return context.t('Chill+ Năm');
    case 'PREMIUM':
      return 'Premium';
    case 'FREE':
      return context.t('Miễn phí');
    default:
      return tier ?? context.t('Miễn phí');
  }
}

/// Check whether [plan] matches the user's current subscription tier.
bool isCurrentPlan(Map<String, dynamic> plan, Map<String, dynamic>? subscription) {
  final planTier = (plan['slug'] ?? plan['name'] ?? '') as String;
  final subObj = subscription?['subscription'] as Map?;
  final currentTier = (subObj?['planName'] ?? subObj?['plan'] ?? subObj?['tier'] ?? subscription?['tier'] ?? subscription?['plan'] ?? 'FREE') as String;
  return planTier.toUpperCase() == currentTier.toUpperCase();
}
