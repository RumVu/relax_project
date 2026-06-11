import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/locale_controller.dart';
import '../journey_prompt/journey_prompt.dart';

import 'models/intro_phase.dart';
import 'helpers/intro_helpers.dart';
import 'widgets/breathing_step.dart';
import 'widgets/mood_pick_step.dart';
import 'widgets/suggest_step.dart';

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
  IntroPhase _phase = IntroPhase.breathing;
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
    _doPrefetch();
  }

  Future<void> _doPrefetch() async {
    final mood = await prefetchLatestMood();
    if (mood != null) {
      _selectedMood = mood;
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
        ? IntroPhase.suggest
        : IntroPhase.moodPick);
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
      _phase = IntroPhase.suggest;
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
      case IntroPhase.breathing:
        return BreathingStep(
          controller: _breathCtrl,
          label: context.t(_breathLabel),
          cycle: _breathCycle,
          onSkip: () {
            // Skip → đi thẳng vào pick mood (hoặc gợi ý nếu đã có mood)
            setState(() => _phase = _selectedMood != null
                ? IntroPhase.suggest
                : IntroPhase.moodPick);
          },
        );
      case IntroPhase.moodPick:
        return MoodPickStep(
          onPick: _selectMood,
          onSkip: widget.onDone,
        );
      case IntroPhase.suggest:
        final mood = _selectedMood ?? 'NEUTRAL';
        final suggestions = suggestionsForMood(mood);
        final label = moodLabel(mood);
        return SuggestStep(
          moodLabel: context.t(label),
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
}
