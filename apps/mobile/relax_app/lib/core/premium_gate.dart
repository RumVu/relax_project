import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'auth_state.dart';
import 'locale_controller.dart';
import 'theme.dart';

/// Premium feature gate — kiểm tra subscription và hiện upgrade prompt.
///
/// Free features: mood checkin, basic breathing, 3 sounds, journal (5/day).
/// Premium: unlimited AI chat, advanced analytics, custom sounds, voice journal,
/// wellness plan, weekly report details.
class PremiumGate {
  PremiumGate._();

  static bool isPremium(BuildContext context) {
    final user = context.read<AuthState>().user;
    final subs = user?['subscriptions'] as List?;
    if (subs == null || subs.isEmpty) return false;
    final sub = subs.first as Map?;
    final plan = (sub?['planName'] as String?)?.toUpperCase() ?? 'FREE';
    final status = (sub?['status'] as String?)?.toUpperCase() ?? '';
    return plan != 'FREE' && status == 'ACTIVE';
  }

  static void showUpgradeSheet(BuildContext context, {String? feature}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: ctx.fieldBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text('✨', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              ctx.t('Nâng cấp Premium'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: ctx.appText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature != null
                  ? ctx.t('Tính năng "{feature}" cần gói Premium.', {'feature': feature})
                  : ctx.t('Mở khóa tất cả tính năng nâng cao.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: ctx.mutedText, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            _featureRow(ctx, '🤖', ctx.t('AI Chat không giới hạn')),
            _featureRow(ctx, '📊', ctx.t('Phân tích nâng cao')),
            _featureRow(ctx, '🎵', ctx.t('Toàn bộ âm thanh & podcast')),
            _featureRow(ctx, '📋', ctx.t('Kế hoạch wellness cá nhân')),
            _featureRow(ctx, '🎙️', ctx.t('Voice journal')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RelaxColors.violet,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/billing');
                },
                child: Text(
                  ctx.t('Xem gói Premium'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                ctx.t('Để sau'),
                style: TextStyle(
                  color: ctx.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _featureRow(BuildContext ctx, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: ctx.appText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.check, color: RelaxColors.mint, size: 18),
        ],
      ),
    );
  }
}
