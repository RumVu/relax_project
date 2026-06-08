import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import 'journey_prompt.dart';

/// Phase của intro: 3 nhịp thở → chọn cảm xúc → gợi ý hoạt động.
enum _IntroPhase { breathing, moodPick, suggest }

/// Bảng cảm xúc cho intro — short list, mỗi chip có icon + label vi.
const _moods = <(String, String, IconData, Color)>[
  ('HAPPY', 'Vui', Icons.sentiment_very_satisfied, Color(0xFFFFC857)),
  ('CALM', 'Bình yên', Icons.spa, Color(0xFF9DD9D2)),
  ('STRESSED', 'Căng thẳng', Icons.bolt, Color(0xFFE48586)),
  ('SAD', 'Buồn', Icons.cloud, Color(0xFF8FA7DF)),
  ('TIRED', 'Mệt mỏi', Icons.bedtime, Color(0xFFB497BD)),
  ('ANXIOUS', 'Lo lắng', Icons.waves, Color(0xFFD8A0DF)),
];

/// Intro flow cho Khu Thư Giãn. Khi user vừa vào tab, dẫn dắt:
///   1. 3 nhịp thở dịu dàng (~18s, có thể skip)
///   2. Chọn cảm xúc hiện tại (mood quick-pick)
///   3. Show 2-3 gợi ý hoạt động phù hợp với mood
///
/// Sau khi xong, gọi [onDone] để parent dismiss intro overlay.
/// User có thể skip bất cứ lúc nào — không ép.
class RelaxIntro extends StatefulWidget {
  const RelaxIntro({super.key, required this.onDone, required this.onPick});

  /// Gọi khi user hoàn thành intro hoặc skip — parent ẩn intro.
  final VoidCallback onDone;

  /// Gọi khi user pick 1 gợi ý — parent push route đó.
  final void Function(String route) onPick;

  @override
  State<RelaxIntro> createState() => _RelaxIntroState();
}

class _RelaxIntroState extends State<RelaxIntro>
    with TickerProviderStateMixin {
  _IntroPhase _phase = _IntroPhase.breathing;
  late final AnimationController _breathCtrl;
  String? _selectedMood;
  Timer? _autoAdvance;
  int _breathCycle = 0;
  String _breathLabel = 'Hít vào…';

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.7,
      upperBound: 1.0,
    );
    _runBreathing();
    _prefetchLatestMood();
  }

  Future<void> _prefetchLatestMood() async {
    // Lấy mood mới nhất. Nếu trong 2h gần đây → dùng luôn, sẽ skip
    // thẳng từ breathing → suggest, bỏ qua bước mood pick.
    try {
      final res = await RelaxApi.instance
          .get('/mood-checkins/me', query: {'limit': 1});
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      if (items is List && items.isNotEmpty) {
        final latest = items.first as Map?;
        final mood = latest?['mood'] as String?;
        final createdAtStr = latest?['createdAt'] as String?;
        if (mood == null) return;
        DateTime? createdAt;
        if (createdAtStr != null) {
          createdAt = DateTime.tryParse(createdAtStr);
        }
        final isFresh = createdAt != null &&
            DateTime.now().difference(createdAt).inHours < 2;
        if (isFresh) {
          _selectedMood = mood;
        }
      }
    } catch (_) {
      // Không block intro — chỉ là gợi ý nice-to-have.
    }
  }

  /// 3 chu kỳ thở 4-2-4 = 30s. Mỗi giây cập nhật label + animate scale.
  Future<void> _runBreathing() async {
    for (int i = 0; i < 3; i++) {
      if (!mounted) return;
      setState(() {
        _breathCycle = i + 1;
        _breathLabel = 'Hít vào…';
      });
      await _breathCtrl.animateTo(1.0,
          duration: const Duration(seconds: 4), curve: Curves.easeInOut);
      if (!mounted) return;
      setState(() => _breathLabel = 'Giữ nhịp…');
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _breathLabel = 'Thở ra…');
      await _breathCtrl.animateTo(0.7,
          duration: const Duration(seconds: 4), curve: Curves.easeInOut);
    }
    if (!mounted) return;
    // Nếu prefetch đã tìm thấy mood mới ghi gần đây → bỏ qua step pick,
    // vào thẳng suggest. Hơn nữa thật, user không cần làm lại.
    setState(() => _phase = _selectedMood != null
        ? _IntroPhase.suggest
        : _IntroPhase.moodPick);
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _autoAdvance?.cancel();
    super.dispose();
  }

  void _selectMood(String mood) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMood = mood;
      _phase = _IntroPhase.suggest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.surface,
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_phase),
            child: _buildPhase(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPhase(BuildContext context) {
    switch (_phase) {
      case _IntroPhase.breathing:
        return _BreathingStep(
          controller: _breathCtrl,
          label: _breathLabel,
          cycle: _breathCycle,
          onSkip: () {
            // Skip → đi thẳng vào pick mood (hoặc gợi ý nếu đã có mood)
            setState(() => _phase = _selectedMood != null
                ? _IntroPhase.suggest
                : _IntroPhase.moodPick);
          },
        );
      case _IntroPhase.moodPick:
        return _MoodPickStep(
          onPick: _selectMood,
          onSkip: widget.onDone,
        );
      case _IntroPhase.suggest:
        final mood = _selectedMood ?? 'NEUTRAL';
        final suggestions = suggestionsForMood(mood);
        final moodLabel = _moodLabel(mood);
        return _SuggestStep(
          moodLabel: moodLabel,
          subtitle: subtitleForMood(mood),
          suggestions: suggestions,
          onPick: (route) {
            widget.onDone();
            widget.onPick(route);
          },
          onSeeAll: widget.onDone,
        );
    }
  }

  String _moodLabel(String code) {
    for (final m in _moods) {
      if (m.$1 == code) return m.$2;
    }
    return 'bình thường';
  }
}

class _BreathingStep extends StatelessWidget {
  const _BreathingStep({
    required this.controller,
    required this.label,
    required this.cycle,
    required this.onSkip,
  });
  final AnimationController controller;
  final String label;
  final int cycle;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Bỏ qua →',
                style: TextStyle(
                  color: context.appText.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Cùng thở một chút trước nha ✦',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhịp $cycle / 3',
            style: TextStyle(
              color: context.appText.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 36),
          AnimatedBuilder(
            animation: controller,
            builder: (_, _) => Transform.scale(
              scale: controller.value,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [RelaxColors.plum, RelaxColors.violet],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RelaxColors.violet.withValues(alpha: 0.35),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Theo nhịp tròn, mọi thứ đợi được mà.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText.withValues(alpha: 0.6),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MoodPickStep extends StatelessWidget {
  const _MoodPickStep({required this.onPick, required this.onSkip});
  final void Function(String mood) onPick;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Bỏ qua →',
                style: TextStyle(
                  color: context.appText.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Bây giờ bạn thấy thế nào?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn một cảm xúc gần nhất với bạn lúc này — để Thi Ái đề xuất hoạt động phù hợp.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText.withValues(alpha: 0.6),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.95,
              children: _moods
                  .map((m) => _MoodChip(
                        code: m.$1,
                        label: m.$2,
                        icon: m.$3,
                        color: m.$4,
                        onTap: () => onPick(m.$1),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatefulWidget {
  const _MoodChip({
    required this.code,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String code;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_MoodChip> createState() => _MoodChipState();
}

class _MoodChipState extends State<_MoodChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 30),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestStep extends StatelessWidget {
  const _SuggestStep({
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
            'Bạn đang $moodLabel 🌿',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
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
                child: _SuggestCard(
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
                'Xem tất cả hoạt động →',
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

class _SuggestCard extends StatelessWidget {
  const _SuggestCard({required this.suggestion, required this.onTap});
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
                  suggestion.label,
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
