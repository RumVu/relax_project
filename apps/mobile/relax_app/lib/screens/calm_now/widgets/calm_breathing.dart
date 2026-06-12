import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';

/// Hít thở nhanh 60 giây — 6 chu kỳ 4-2-4 (tự nhiên, nhẹ nhàng).
/// Không cần chọn pattern, không cần bấm start — chạy ngay lập tức.
/// Haptic mỗi khi chuyển pha.
class CalmBreathing extends StatefulWidget {
  const CalmBreathing({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<CalmBreathing> createState() => _CalmBreathingState();
}

class _CalmBreathingState extends State<CalmBreathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  Timer? _ticker;

  // 4-2-4 × 6 cycles = 60s.
  static const _inhale = 4;
  static const _hold = 2;
  static const _exhale = 4;
  static const _totalCycles = 6;

  String _phaseLabel = 'Hít vào…';
  int _remaining = _inhale;
  int _cyclesDone = 0;
  int _totalSeconds = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      upperBound: 1.0,
      value: 0.5,
    );
    // Bắt đầu ngay — không cần user bấm.
    _startPhase('inhale');
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _startPhase(String phase) {
    HapticFeedback.selectionClick();
    switch (phase) {
      case 'inhale':
        _phaseLabel = 'Hít vào…';
        _remaining = _inhale;
        _scaleCtrl.animateTo(1.0,
            duration: Duration(seconds: _inhale), curve: Curves.easeInOut);
        break;
      case 'hold':
        _phaseLabel = 'Giữ nhịp…';
        _remaining = _hold;
        break;
      case 'exhale':
        _phaseLabel = 'Thở ra…';
        _remaining = _exhale;
        _scaleCtrl.animateTo(0.5,
            duration: Duration(seconds: _exhale), curve: Curves.easeInOut);
        break;
    }
    if (mounted) setState(() {});
  }

  void _tick() {
    if (_finished) return;
    _totalSeconds++;
    _remaining--;

    if (_remaining <= 0) {
      // Chuyển phase.
      if (_phaseLabel.startsWith('Hít')) {
        _startPhase('hold');
      } else if (_phaseLabel.startsWith('Giữ')) {
        _startPhase('exhale');
      } else {
        // Xong 1 chu kỳ.
        _cyclesDone++;
        if (_cyclesDone >= _totalCycles) {
          _finish();
          return;
        }
        _startPhase('inhale');
      }
    } else {
      if (mounted) setState(() {});
    }
  }

  void _finish() {
    _ticker?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _finished = true;
      _phaseLabel = 'Xong rồi ✦';
    });
    _scaleCtrl.animateTo(0.7,
        duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds / (_totalCycles * (_inhale + _hold + _exhale));
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            context.t('Thở cùng mình nhé'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${context.t('Chu kỳ')} $_cyclesDone / $_totalCycles',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          // Animated breathing circle.
          AnimatedBuilder(
            animation: _scaleCtrl,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring.
                  Container(
                    height: 260,
                    width: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  // Middle ring.
                  Container(
                    height: 220,
                    width: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Main circle.
                  Transform.scale(
                    scale: _scaleCtrl.value,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.t(_phaseLabel),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!_finished)
                            Text(
                              '$_remaining',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          else
                            const Text(
                              '✓',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48,
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
          const Spacer(),
          // Progress bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              color: Colors.white.withValues(alpha: 0.5),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 16),
          // Skip button.
          if (!_finished)
            TextButton(
              onPressed: () {
                _ticker?.cancel();
                widget.onDone();
              },
              child: Text(
                context.t('Bỏ qua'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
