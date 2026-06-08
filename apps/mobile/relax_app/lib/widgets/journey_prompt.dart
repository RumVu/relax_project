import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

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
///
/// [title] thường là feedback ngắn cho việc vừa làm ("Đã ghi cảm xúc 🌸").
/// [subtitle] là nhịp dẫn ("Hơi căng thẳng nhỉ? Thử 3 phút hít thở để
/// dịu lại nha ✦").
/// [suggestions] tối đa 3 — render thành card lớn (primary) + chip nhỏ.
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
              title,
              style: TextStyle(
                color: context.appText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                color: context.appText.withValues(alpha: 0.72),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            _PrimaryCard(suggestion: primary),
            if (rest.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rest.map((s) => _SecondaryChip(suggestion: s)).toList(),
              ),
            ],
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  dismissLabel,
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

class _PrimaryCard extends StatelessWidget {
  const _PrimaryCard({required this.suggestion});
  final JourneySuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.pop(context);
          if (suggestion.onTap != null) {
            suggestion.onTap!();
          } else if (suggestion.route != null) {
            context.push(suggestion.route!);
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [RelaxColors.violet, RelaxColors.plum],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(suggestion.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  suggestion.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryChip extends StatelessWidget {
  const _SecondaryChip({required this.suggestion});
  final JourneySuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.pop(context);
          if (suggestion.onTap != null) {
            suggestion.onTap!();
          } else if (suggestion.route != null) {
            context.push(suggestion.route!);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: RelaxColors.violet.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: RelaxColors.violet.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(suggestion.icon, color: RelaxColors.violet, size: 18),
              const SizedBox(width: 8),
              Text(
                suggestion.label,
                style: const TextStyle(
                  color: RelaxColors.violet,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Map từ mood code → gợi ý nhánh tiếp theo phù hợp.
List<JourneySuggestion> suggestionsForMood(String mood) {
  switch (mood.toUpperCase()) {
    case 'HAPPY':
    case 'EXCITED':
    case 'GRATEFUL':
      return const [
        JourneySuggestion(
          icon: Icons.edit_note,
          label: 'Ghi lại khoảnh khắc này',
          route: '/journal',
        ),
        JourneySuggestion(
          icon: Icons.headphones,
          label: 'Nghe nhạc',
          route: '/sounds',
        ),
      ];
    case 'STRESSED':
    case 'ANXIOUS':
      return const [
        JourneySuggestion(
          icon: Icons.air,
          label: 'Hít thở 3 phút để dịu lại',
          route: '/breathing',
        ),
        JourneySuggestion(
          icon: Icons.self_improvement,
          label: 'Thiền dẫn dắt',
          route: '/meditation',
        ),
        JourneySuggestion(
          icon: Icons.edit_note,
          label: 'Viết ra để trút bỏ',
          route: '/journal',
        ),
      ];
    case 'SAD':
    case 'LONELY':
      return const [
        JourneySuggestion(
          icon: Icons.edit_note,
          label: 'Trút lòng vào nhật ký',
          route: '/journal',
        ),
        JourneySuggestion(
          icon: Icons.headphones,
          label: 'Một bản nhạc xoa dịu',
          route: '/sounds',
        ),
        JourneySuggestion(
          icon: Icons.air,
          label: 'Vài nhịp thở chậm',
          route: '/breathing',
        ),
      ];
    case 'TIRED':
      return const [
        JourneySuggestion(
          icon: Icons.headphones,
          label: 'Âm thanh êm để nghỉ ngơi',
          route: '/sounds',
        ),
        JourneySuggestion(
          icon: Icons.self_improvement,
          label: 'Thiền thư giãn',
          route: '/meditation',
        ),
      ];
    case 'CALM':
    case 'NEUTRAL':
    default:
      return const [
        JourneySuggestion(
          icon: Icons.self_improvement,
          label: 'Thiền 5 phút',
          route: '/meditation',
        ),
        JourneySuggestion(
          icon: Icons.edit_note,
          label: 'Viết một dòng cho hôm nay',
          route: '/journal',
        ),
        JourneySuggestion(
          icon: Icons.insights,
          label: 'Xem nhịp cảm xúc tuần này',
          route: '/home?tab=2',
        ),
      ];
  }
}

/// Câu phụ đề mềm theo mood — short, soothing.
String subtitleForMood(String mood) {
  switch (mood.toUpperCase()) {
    case 'HAPPY':
    case 'EXCITED':
    case 'GRATEFUL':
      return 'Niềm vui nho nhỏ này đáng được giữ lại nha ✦';
    case 'STRESSED':
    case 'ANXIOUS':
      return 'Hơi căng nhỉ. Để Thi Ái cùng bạn hạ nhịp lại một chút.';
    case 'SAD':
    case 'LONELY':
      return 'Buồn cũng được. Mình ngồi lại với cảm xúc một chút nha.';
    case 'TIRED':
      return 'Mệt rồi đó. Nghỉ một nhịp đã, mọi thứ đợi được mà.';
    case 'CALM':
    case 'NEUTRAL':
    default:
      return 'Giữ nhịp bình yên này, mình đi tiếp một bước nhẹ nhé.';
  }
}
