import 'package:flutter/material.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import 'widgets/primary_card.dart';
import 'widgets/secondary_chip.dart';

// Re-export helpers so callers can import from one file.
export 'helpers/mood_suggestions.dart';

/// Một "nhánh tiếp theo" cho user — gợi ý nhẹ nhàng sau khi vừa hoàn
/// thành một hành động (vd: vừa ghi cảm xúc xong → mời thử hít thở).
class JourneySuggestion {
  const JourneySuggestion({
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
  }) : assert(route != null || onTap != null,
            'Suggestion phải có route hoặc onTap');

  final IconData icon;
  final String label;

  /// GoRouter path, vd `/breathing`, `/journal`, `/sounds`, hoặc
  /// `/home?tab=2` để chuyển sang tab Insights.
  final String? route;

  /// Custom action thay vì navigation — vd "Tập 1 vòng nữa" restart
  /// session ngay tại chỗ, không pop sheet.
  final VoidCallback? onTap;
}

/// Hiển thị bottom sheet dẫn dắt sau khi hoàn thành một hành động.
/// Soft, dismissible — không ép user, chỉ mời tiếp tục hành trình.
Future<void> showJourneyPrompt(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<JourneySuggestion> suggestions,
  String dismissLabel = 'Để sau',
}) async {
  if (suggestions.isEmpty) return;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _JourneySheet(
      title: title,
      subtitle: subtitle,
      suggestions: suggestions,
      dismissLabel: dismissLabel,
    ),
  );
}

class _JourneySheet extends StatelessWidget {
  const _JourneySheet({
    required this.title,
    required this.subtitle,
    required this.suggestions,
    required this.dismissLabel,
  });

  final String title;
  final String subtitle;
  final List<JourneySuggestion> suggestions;
  final String dismissLabel;

  @override
  Widget build(BuildContext context) {
    final primary = suggestions.first;
    final rest = suggestions.skip(1).toList();
    final bg = context.surface;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 24),
          child: child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.appText.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              context.t(title),
              style: TextStyle(
                color: context.appText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.t(subtitle),
              style: TextStyle(
                color: context.appText.withValues(alpha: 0.72),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            PrimaryCard(suggestion: primary),
            if (rest.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rest
                    .map((s) => SecondaryChip(suggestion: s))
                    .toList(),
              ),
            ],
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.t(dismissLabel),
                  style: TextStyle(
                    color: context.appText.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
