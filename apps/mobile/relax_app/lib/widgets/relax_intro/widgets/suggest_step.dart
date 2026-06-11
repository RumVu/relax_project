import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/locale_controller.dart';
import '../../journey_prompt/journey_prompt.dart';

class SuggestStep extends StatelessWidget {
  const SuggestStep({
    super.key,
    required this.moodLabel,
    required this.subtitle,
    required this.suggestions,
    required this.onPick,
    required this.onSeeAll,
  });
  final String moodLabel;
  final String subtitle;
  final List<JourneySuggestion> suggestions;
  final void Function(String route) onPick;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            '${context.t('Bạn đang')} $moodLabel 🌿',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t(subtitle),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText.withValues(alpha: 0.65),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SuggestCard(
                  suggestion: s,
                  // Mood-based suggestions luôn có route (không onTap).
                  onTap: () => onPick(s.route ?? '/sounds'),
                ),
              )),
          const Spacer(),
          Center(
            child: TextButton(
              onPressed: onSeeAll,
              child: Text(
                context.t('Xem tất cả hoạt động →'),
                style: TextStyle(
                  color: context.appText.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestCard extends StatelessWidget {
  const SuggestCard({super.key, required this.suggestion, required this.onTap});
  final JourneySuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [RelaxColors.violet, RelaxColors.plum],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(suggestion.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.t(suggestion.label),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
