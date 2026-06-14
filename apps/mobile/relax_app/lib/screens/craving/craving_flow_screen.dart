import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';

/// Craving break flow.
///
/// Steps:
///   1. Choose reason (CravingReason enum)
///   2. Timer (3 or 5 min) with breathing guidance
///   3. After timer: intensity slider + save
class CravingFlowScreen extends StatefulWidget {
  const CravingFlowScreen({super.key});

  @override
  State<CravingFlowScreen> createState() => _CravingFlowScreenState();
}

enum _FlowPhase { reason, timer, review }

class _CravingFlowScreenState extends State<CravingFlowScreen>
    with TickerProviderStateMixin {
  _FlowPhase _phase = _FlowPhase.reason;
  String? _reason;
  int _intensityBefore = 5;
  int _intensityAfter = 3;
  int _timerSeconds = 180; // default 3 min
  int _remaining = 180;
  Timer? _timer;
  bool _saving = false;

  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _transitionTo(_FlowPhase next) async {
    await _fadeCtrl.animateTo(0.0,
        duration: const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _phase = next);
    await _fadeCtrl.animateTo(1.0,
        duration: const Duration(milliseconds: 300));
  }

  void _onReasonSelected(String reason, int intensity) {
    HapticFeedback.mediumImpact();
    _reason = reason;
    _intensityBefore = intensity;
    _remaining = _timerSeconds;
    _startTimer();
    _transitionTo(_FlowPhase.timer);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          t.cancel();
          _transitionTo(_FlowPhase.review);
        }
      });
    });
  }

  void _skipTimer() {
    _timer?.cancel();
    _transitionTo(_FlowPhase.review);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await RelaxApi.instance.post('/craving/log', body: {
        'reason': _reason,
        'intensityBefore': _intensityBefore,
        'intensityAfter': _intensityAfter,
        'duration': _timerSeconds - _remaining,
        'activityUsed': 'breathing',
        'resisted': true,
      });
    } catch (_) {
      // Offline-queued via API client
    }
    if (!mounted) return;
    HapticFeedback.lightImpact();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1117),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.7)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Cắt cơn thèm thuốc'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0d1117), Color(0xFF161b22), Color(0xFF1a2332)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeCtrl,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_phase),
                child: _buildPhase(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case _FlowPhase.reason:
        return _ReasonPhase(
          onSelect: _onReasonSelected,
          timerSeconds: _timerSeconds,
          onTimerChanged: (v) => setState(() => _timerSeconds = v),
        );
      case _FlowPhase.timer:
        return _TimerPhase(
          remaining: _remaining,
          total: _timerSeconds,
          onSkip: _skipTimer,
        );
      case _FlowPhase.review:
        return _ReviewPhase(
          intensity: _intensityAfter,
          onChanged: (v) => setState(() => _intensityAfter = v),
          onSave: _save,
          saving: _saving,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Phase 1: Choose reason + intensity
// ---------------------------------------------------------------------------

class _ReasonPhase extends StatefulWidget {
  const _ReasonPhase({
    required this.onSelect,
    required this.timerSeconds,
    required this.onTimerChanged,
  });
  final void Function(String reason, int intensity) onSelect;
  final int timerSeconds;
  final ValueChanged<int> onTimerChanged;

  @override
  State<_ReasonPhase> createState() => _ReasonPhaseState();
}

class _ReasonPhaseState extends State<_ReasonPhase> {
  String? _selected;
  int _intensity = 5;

  static const _reasons = [
    ('SMOKE_CRAVING', 'Thèm thuốc', Icons.smoke_free),
    ('STRESS', 'Căng thẳng', Icons.psychology_alt),
    ('BOREDOM', 'Chán', Icons.sentiment_neutral),
    ('SLEEPY', 'Buồn ngủ', Icons.bedtime),
    ('OVERWHELMED', 'Quá tải', Icons.storm),
    ('LONELY', 'Cô đơn', Icons.person_off),
    ('HABIT', 'Thói quen', Icons.repeat),
    ('SOCIAL', 'Xã hội', Icons.groups),
    ('OTHER', 'Khác', Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            context.t('Bạn đang cảm thấy gì?'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _reasons.map((r) {
              final selected = _selected == r.$1;
              return GestureDetector(
                onTap: () => setState(() => _selected = r.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                     color: selected
                        ? RelaxColors.violet.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? RelaxColors.violet
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(r.$3,
                          size: 18,
                          color: selected
                              ? RelaxColors.violet
                              : Colors.white.withValues(alpha: 0.6)),
                      const SizedBox(width: 6),
                      Text(
                        context.t(r.$2),
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            '${context.t('Mức độ thèm thuốc')}: $_intensity/10',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _intensity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: RelaxColors.violet,
            inactiveColor: Colors.white.withValues(alpha: 0.15),
            onChanged: (v) => setState(() => _intensity = v.round()),
          ),
          const SizedBox(height: 16),
          Text(
            context.t('Thời gian break'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _TimerChip(
                label: '3 ${context.t("phút")}',
                selected: widget.timerSeconds == 180,
                onTap: () => widget.onTimerChanged(180),
              ),
              const SizedBox(width: 10),
              _TimerChip(
                label: '5 ${context.t("phút")}',
                selected: widget.timerSeconds == 300,
                onTap: () => widget.onTimerChanged(300),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _selected != null ? () => widget.onSelect(_selected!, _intensity) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: RelaxColors.violet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
              ),
              child: Text(
                context.t('Bắt đầu'),
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? RelaxColors.violet.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? RelaxColors.violet
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Phase 2: Timer with breathing cue
// ---------------------------------------------------------------------------

class _TimerPhase extends StatelessWidget {
  const _TimerPhase({
    required this.remaining,
    required this.total,
    required this.onSkip,
  });
  final int remaining;
  final int total;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    final progress = total > 0 ? 1.0 - (remaining / total) : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.t('Hít thở sâu...'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(RelaxColors.mint),
                ),
              ),
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          remaining > 0
              ? context.t('Cơn thèm sẽ qua...')
              : context.t('Bạn đã vượt qua!'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 48),
        TextButton(
          onPressed: onSkip,
          child: Text(
            context.t('Bỏ qua'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Phase 3: Review intensity after
// ---------------------------------------------------------------------------

class _ReviewPhase extends StatelessWidget {
  const _ReviewPhase({
    required this.intensity,
    required this.onChanged,
    required this.onSave,
    required this.saving,
  });
  final int intensity;
  final ValueChanged<int> onChanged;
  final VoidCallback onSave;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline,
              color: RelaxColors.mint, size: 64),
          const SizedBox(height: 24),
          Text(
            context.t('Bạn thấy đỡ hơn chưa?'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${context.t('Mức độ hiện tại')}: $intensity/10',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: intensity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: RelaxColors.mint,
            inactiveColor: Colors.white.withValues(alpha: 0.15),
            onChanged: (v) => onChanged(v.round()),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: RelaxColors.mint,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.t('Lưu & Hoàn thành'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
