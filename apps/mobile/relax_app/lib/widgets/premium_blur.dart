import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/locale_controller.dart';
import '../core/premium_gate.dart';
import '../core/theme.dart';

/// Blur overlay cho nội dung premium — hiển thị khi user FREE.
///
/// Wrap bất kỳ widget nào cần gate:
/// ```dart
/// PremiumBlur(
///   child: MoodLineChart(values: _daily),
/// )
/// ```
class PremiumBlur extends StatelessWidget {
  const PremiumBlur({super.key, required this.child, this.message});

  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (PremiumGate.isPremium(context)) return child;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          IgnorePointer(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Opacity(opacity: 0.45, child: child),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    RelaxColors.violet.withValues(alpha: 0.25),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: RelaxColors.violet.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: RelaxColors.violet.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded,
                            color: RelaxColors.violet, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.t('Đặc quyền meow thủ 🐱'),
                        style: TextStyle(
                          color: RelaxColors.violet,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message ?? context.t('Khu vực dành cho các meow thủ'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.appText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.t(
                            'Nâng cấp lên gói hội viên để mở khoá ngay!'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.mutedText,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RelaxColors.violet,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => context.push('/billing'),
                          icon: const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 18),
                          label: Text(
                            context.t('Nâng cấp ngay'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
