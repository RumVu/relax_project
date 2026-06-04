import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Một nhịp thở: bao nhiêu giây cho từng pha + số chu kỳ.
class _Pattern {
  const _Pattern({
    required this.code,
    required this.label,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.holdAfter,
    required this.cycles,
  });

  final String code;
  final String label;
  final int inhale;
  final int hold;
  final int exhale;
  final int holdAfter;
  final int cycles;
}

const _patterns = <_Pattern>[
  _Pattern(
    code: 'box',
    label: 'Box 4-4-4-4 · cân bằng',
    inhale: 4,
    hold: 4,
    exhale: 4,
    holdAfter: 4,
    cycles: 6,
  ),
  _Pattern(
    code: 'relax',
    label: '4-7-8 · ngủ ngon',
    inhale: 4,
    hold: 7,
    exhale: 8,
    holdAfter: 0,
    cycles: 5,
  ),
  _Pattern(
    code: 'natural',
    label: '4-0-4-0 · tự nhiên',
    inhale: 4,
    hold: 0,
    exhale: 4,
    holdAfter: 0,
    cycles: 8,
  ),
];

enum _Phase { idle, inhale, hold, exhale, holdAfter, finished }

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
  _Phase _phase = _Phase.idle;
  int _cyclesDone = 0;
  int _phaseRemaining = 0;
  bool _running = false;
  Timer? _ticker;

  _Pattern get _pattern => _patterns[_patternIdx];

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
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scaleCtrl.dispose();
    super.dispose();
  }

  int _phaseLength(_Phase p) {
    switch (p) {
      case _Phase.inhale:
        return _pattern.inhale;
      case _Phase.hold:
        return _pattern.hold;
      case _Phase.exhale:
        return _pattern.exhale;
      case _Phase.holdAfter:
        return _pattern.holdAfter;
      default:
        return 0;
    }
  }

  _Phase _nextPhase(_Phase current) {
    const order = [_Phase.inhale, _Phase.hold, _Phase.exhale, _Phase.holdAfter];
    final idx = order.indexOf(current);
    for (var step = 1; step <= order.length; step++) {
      final candidate = order[(idx + step) % order.length];
      if (_phaseLength(candidate) > 0) return candidate;
    }
    return _Phase.inhale;
  }

  void _applyPhaseAnimation(_Phase p) {
    final secs = _phaseLength(p);
    if (p == _Phase.inhale) {
      _scaleCtrl.animateTo(1.0, duration: Duration(seconds: secs == 0 ? 1 : secs));
    } else if (p == _Phase.exhale) {
      _scaleCtrl.animateTo(0.55, duration: Duration(seconds: secs == 0 ? 1 : secs));
    }
    // hold / holdAfter: giữ nguyên scale hiện tại.
  }

  void _start() {
    const order = [_Phase.inhale, _Phase.hold, _Phase.exhale, _Phase.holdAfter];
    final first = order.firstWhere((p) => _phaseLength(p) > 0,
        orElse: () => _Phase.inhale);
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
      if (next == _Phase.inhale) {
        _cyclesDone += 1;
        if (_cyclesDone >= _pattern.cycles) {
          _running = false;
          _phase = _Phase.finished;
          _ticker?.cancel();
          _scaleCtrl.animateTo(0.7, duration: const Duration(milliseconds: 600));
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
      _phase = _Phase.idle;
      _phaseRemaining = 0;
      _cyclesDone = 0;
    });
    _scaleCtrl.animateTo(0.55, duration: const Duration(milliseconds: 400));
  }

  String get _phaseLabel {
    switch (_phase) {
      case _Phase.inhale:
        return 'Hít vào';
      case _Phase.hold:
        return 'Giữ';
      case _Phase.exhale:
        return 'Thở ra';
      case _Phase.holdAfter:
        return 'Nghỉ';
      case _Phase.finished:
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hít thở cùng nhau',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chọn nhịp thở rồi để vòng tròn dẫn bạn.',
                style: TextStyle(color: RelaxColors.slate),
              ),
            ),
            const SizedBox(height: 16),
            // Pattern picker
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_patterns.length, (i) {
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
                      _patterns[i].label,
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
                                  _phaseLabel.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _phase == _Phase.idle
                                      ? '·'
                                      : _phase == _Phase.finished
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
              'Chu kỳ $_cyclesDone / ${_pattern.cycles}',
              style: const TextStyle(
                color: RelaxColors.slate,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Nhịp ${_pattern.inhale}-${_pattern.hold}-${_pattern.exhale}-${_pattern.holdAfter} × ${_pattern.cycles} chu kỳ',
              style: const TextStyle(color: RelaxColors.slate, fontSize: 12),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_phase == _Phase.idle || _phase == _Phase.finished)
                  ElevatedButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      _phase == _Phase.finished ? 'Tập lại' : 'Bắt đầu',
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
                    label: const Text('Tạm dừng'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _resume,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Tiếp tục'),
                  ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Đặt lại'),
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
