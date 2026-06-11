import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/checkin_sheet/checkin_sheet.dart';
import '../../widgets/journey_prompt/journey_prompt.dart';
import 'models/breathing_pattern.dart';
import 'models/breathing_phase.dart';

/// Vòng tròn hít thở hoạt họa: phình to khi hít vào, thu nhỏ khi thở ra,
/// giữ nguyên khi nín thở; có bộ đếm ngược giây + đếm chu kỳ. Dùng
/// AnimationController điều khiển scale theo độ dài từng pha.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  int _patternIdx = 0;
  BreathingPhase _phase = BreathingPhase.idle;
  int _cyclesDone = 0;
  int _phaseRemaining = 0;
  bool _running = false;
  Timer? _ticker;

  BreathingPattern get _pattern => breathingPatterns[_patternIdx];

  @override
  void initState() {
    super.initState();
    // Min scale 0.55 → 1.0 (giống web). Value của controller = scale.
    _scaleCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.55,
      upperBound: 1.0,
      value: 0.55,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthState>();
      if (auth.activeSessionId == null) {
        auth.startRelaxSession('BREATHING', context.t('Hít thở không khí'));
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scaleCtrl.dispose();
    super.dispose();
  }

  int _phaseLength(BreathingPhase p) {
    switch (p) {
      case BreathingPhase.inhale:
        return _pattern.inhale;
      case BreathingPhase.hold:
        return _pattern.hold;
      case BreathingPhase.exhale:
        return _pattern.exhale;
      case BreathingPhase.holdAfter:
        return _pattern.holdAfter;
      default:
        return 0;
    }
  }

  BreathingPhase _nextPhase(BreathingPhase current) {
    const order = [BreathingPhase.inhale, BreathingPhase.hold, BreathingPhase.exhale, BreathingPhase.holdAfter];
    final idx = order.indexOf(current);
    for (var step = 1; step <= order.length; step++) {
      final candidate = order[(idx + step) % order.length];
      if (_phaseLength(candidate) > 0) return candidate;
    }
    return BreathingPhase.inhale;
  }

  void _applyPhaseAnimation(BreathingPhase p) {
    final secs = _phaseLength(p);
    if (p == BreathingPhase.inhale) {
      _scaleCtrl.animateTo(1.0, duration: Duration(seconds: secs == 0 ? 1 : secs));
    } else if (p == BreathingPhase.exhale) {
      _scaleCtrl.animateTo(0.55, duration: Duration(seconds: secs == 0 ? 1 : secs));
    }
    // hold / holdAfter: giữ nguyên scale hiện tại.
  }

  void _start() {
    const order = [BreathingPhase.inhale, BreathingPhase.hold, BreathingPhase.exhale, BreathingPhase.holdAfter];
    final first = order.firstWhere((p) => _phaseLength(p) > 0,
        orElse: () => BreathingPhase.inhale);
    setState(() {
      _phase = first;
      _phaseRemaining = _phaseLength(first);
      _cyclesDone = 0;
      _running = true;
    });
    _applyPhaseAnimation(first);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!_running) return;
    setState(() {
      _phaseRemaining -= 1;
      if (_phaseRemaining > 0) return;
      final next = _nextPhase(_phase);
      if (next == BreathingPhase.inhale) {
        _cyclesDone += 1;
        if (_cyclesDone >= _pattern.cycles) {
          _running = false;
          _phase = BreathingPhase.finished;
          _ticker?.cancel();
          _scaleCtrl.animateTo(0.7, duration: const Duration(milliseconds: 600));
          // Haptic nhẹ báo hoàn thành — không rung mạnh.
          HapticFeedback.lightImpact();
          // Đợi 600ms cho animation kết thúc rồi mời tiếp. Primary CTA
          // là "Tập 1 vòng nữa" → restart ngay tại chỗ, không phải hỏi
          // user pick lại pattern.
          Future.delayed(const Duration(milliseconds: 700), () {
            if (!mounted) return;
            final auth = context.read<AuthState>();
            final activeId = auth.activeSessionId;
            showCheckInSheet(context, context.t('Hít thở không khí'), sessionId: activeId).then((_) {
              if (!mounted) return;
              showJourneyPrompt(
                context,
                title: context.t('Đã hít thở xong 🌬️'),
                subtitle:
                    context.t('Nhẹ nhõm hơn rồi nhỉ? Muốn tập thêm 1 vòng nữa, hay đi tiếp một bước êm?'),
                suggestions: [
                  JourneySuggestion(
                    icon: Icons.refresh,
                    label: context.t('Tập thêm 1 vòng nữa'),
                    onTap: () {
                      if (!mounted) return;
                      // Reset state + bắt đầu lại session ngay tức thì.
                      setState(() {
                        _cyclesDone = 0;
                        _phase = BreathingPhase.idle;
                        _phaseRemaining = 0;
                        _running = false;
                      });
                      final authNew = context.read<AuthState>();
                      if (authNew.activeSessionId == null) {
                        authNew.startRelaxSession('BREATHING', context.t('Hít thở không khí'));
                      }
                      _start();
                    },
                  ),
                  JourneySuggestion(
                    icon: Icons.mood,
                    label: context.t('Ghi lại cảm xúc bây giờ'),
                    route: '/mood',
                  ),
                  JourneySuggestion(
                    icon: Icons.edit_note,
                    label: context.t('Viết vào nhật ký'),
                    route: '/journal',
                  ),
                  JourneySuggestion(
                    icon: Icons.headphones,
                    label: context.t('Nghe nhạc êm'),
                    route: '/sounds',
                  ),
                ],
              );
            });
          });
          return;
        }
      }
      _phase = next;
      _phaseRemaining = _phaseLength(next);
      _applyPhaseAnimation(next);
    });
  }

  void _pause() {
    setState(() => _running = false);
    _ticker?.cancel();
    _scaleCtrl.stop();
  }

  void _resume() {
    setState(() => _running = true);
    _applyPhaseAnimation(_phase);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _phase = BreathingPhase.idle;
      _phaseRemaining = 0;
      _cyclesDone = 0;
    });
    _scaleCtrl.animateTo(0.55, duration: const Duration(milliseconds: 400));
  }

  String get _phaseLabel {
    switch (_phase) {
      case BreathingPhase.inhale:
        return 'Hít vào';
      case BreathingPhase.hold:
        return 'Giữ';
      case BreathingPhase.exhale:
        return 'Thở ra';
      case BreathingPhase.holdAfter:
        return 'Nghỉ';
      case BreathingPhase.finished:
        return 'Hoàn thành';
      default:
        return 'Sẵn sàng';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.t('Hít thở cùng nhau'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.t('Chọn nhịp thở rồi để vòng tròn dẫn bạn.'),
                style: const TextStyle(color: RelaxColors.slate),
              ),
            ),
            const SizedBox(height: 16),
            // Pattern picker
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(breathingPatterns.length, (i) {
                final sel = i == _patternIdx;
                return GestureDetector(
                  onTap: () {
                    setState(() => _patternIdx = i);
                    _reset();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? RelaxColors.violet : context.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? RelaxColors.violet : context.fieldBorder,
                      ),
                    ),
                    child: Text(
                      context.t(breathingPatterns[i].label),
                      style: TextStyle(
                        color: sel ? Colors.white : context.appText,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 36),
            // The breathing circle
            SizedBox(
              height: 280,
              child: Center(
                child: AnimatedBuilder(
                  animation: _scaleCtrl,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        _ring(260),
                        _ring(220),
                        _ring(180),
                        Transform.scale(
                          scale: _scaleCtrl.value,
                          child: Container(
                            height: 220,
                            width: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [RelaxColors.violet, RelaxColors.plum],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      RelaxColors.violet.withValues(alpha: 0.45),
                                  blurRadius: 50,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.t(_phaseLabel).toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _phase == BreathingPhase.idle
                                      ? '·'
                                      : _phase == BreathingPhase.finished
                                          ? '✓'
                                          : '$_phaseRemaining',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 44,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.t('Chu kỳ {done} / {total}', {'done': '$_cyclesDone', 'total': '${_pattern.cycles}'}),
              style: const TextStyle(
                color: RelaxColors.slate,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${context.t('Nhịp')} ${_pattern.inhale}-${_pattern.hold}-${_pattern.exhale}-${_pattern.holdAfter} × ${_pattern.cycles} ${context.t('chu kỳ')}',
              style: const TextStyle(color: RelaxColors.slate, fontSize: 12),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_phase == BreathingPhase.idle || _phase == BreathingPhase.finished)
                  ElevatedButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      _phase == BreathingPhase.finished ? context.t('Tập lại') : context.t('Bắt đầu'),
                    ),
                  )
                else if (_running)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RelaxColors.lilac,
                      foregroundColor: RelaxColors.plum,
                    ),
                    onPressed: _pause,
                    icon: const Icon(Icons.pause),
                    label: Text(context.t('Tạm dừng')),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _resume,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(context.t('Tiếp tục')),
                  ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.t('Đặt lại')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ring(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: RelaxColors.violet.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}
