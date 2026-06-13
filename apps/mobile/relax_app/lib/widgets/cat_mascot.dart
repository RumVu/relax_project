import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../core/auth_state.dart';
import '../screens/companion/helpers/companion_helpers.dart';

/// Placeholder linh thú mèo. Mockup dùng pixel-art thật; khi có file ảnh
/// (assets/cat_*.png) chỉ cần thay phần child bằng Image.asset là khớp.
/// Hiện dùng emoji trong khung bo tròn gradient nhẹ để giữ đúng bố cục.
class CatMascot extends StatelessWidget {
  const CatMascot({
    super.key,
    this.size = 120,
    this.emoji = '🐱',
    this.glow = true,
  });

  final double size;
  final String emoji;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    String resolvedEmoji = emoji;

    if (resolvedEmoji == '🐱' ||
        resolvedEmoji == '😺' ||
        resolvedEmoji == '🐈' ||
        resolvedEmoji == '😻') {
      try {
        final auth = context.watch<AuthState>();
        final user = auth.user;
        if (user != null) {
          final companion = user['companion'] as Map?;
          if (companion != null) {
            final asset = companion['asset'] as Map?;
            final key = asset?['key'] as String?;
            final type = companion['type'] as String?;
            final chZodiac = asset?['chineseZodiac'] as String?;
            final zSign = asset?['zodiacSign'] as String?;
            final dynamicEmoji = fallbackEmoji(
              type,
              assetKey: key,
              chineseZodiac: chZodiac ?? zSign,
            );
            if (dynamicEmoji != '🐾') {
              resolvedEmoji = dynamicEmoji;
            }
          } else {
            final profile = user['profile'] as Map?;
            final chZodiac = profile?['chineseZodiac'] as String?;
            final zSign = profile?['zodiacSign'] as String?;
            final dynamicEmoji = fallbackEmoji(
              'CUSTOM',
              chineseZodiac: chZodiac ?? zSign,
            );
            if (dynamicEmoji != '🐾') {
              resolvedEmoji = dynamicEmoji;
            }
          }
        }
      } catch (_) {
        // Fallback silently if AuthState is not in context (e.g. in some isolated widget test)
      }
    }

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            RelaxColors.violet.withValues(alpha: context.isDark ? 0.28 : 0.16),
            RelaxColors.lilac.withValues(alpha: context.isDark ? 0.12 : 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
      child: Text(resolvedEmoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}
