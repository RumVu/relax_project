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
