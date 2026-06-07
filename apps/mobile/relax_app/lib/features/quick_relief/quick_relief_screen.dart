import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// Quick Relief — nút SOS 60 giây giúp user calm nhanh khi stress lên đột ngột.
///
/// Khác Journey (5 chương ~ 10-15 phút) — Quick Relief là single tap fastest:
///   1. Mở màn → countdown 60s ngay
///   2. Vòng tròn breath pulse 4-7-8 (inhale 4s, hold 7s, exhale 8s)
///   3. Lời nhắn xoay vòng "Bạn ổn", "Hít vào", "Bạn an toàn"
///   4. Haptic gentle mỗi nhịp đổi phase
///   5. Sau 60s → confirmation "Bạn vừa cho mình 60s. Đẹp lắm 💜"
///
/// Không cần auth, không POST API, không tracking. Just calm.
class QuickReliefScreen extends StatefulWidget {
  const QuickReliefScreen({super.key});

  @override
  State<QuickReliefScreen> createState() => _QuickReliefScreenState();
}

class _QuickReliefScreenState extends State<QuickReliefScreen>
    with TickerProviderStateMixin {
  static const _totalSec = 60;
  // 4-7-8 breathing: inhale 4s, hold 7s, exhale 8s = 19s/cycle → ~3 cycles in 60s
  static const _phases = [
    _Phase('Hít vào', 4, _PhaseKind.inhale),
    _Phase('Giữ hơi', 7, _PhaseKind.hold),
    _Phase('Thở ra', 8, _PhaseKind.exhale),
  ];

  late final AnimationController _circle = AnimationController(
    duration: const Duration(seconds: 4),
    vsync: this,
  );
  late Animation<double> _scale;

  Timer? _timer;
  int _elapsedSec = 0;
  int _phaseIdx = 0;
  int _phaseRemaining = _phases[0].seconds;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _setupScale();
    _circle.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _setupScale() {
    final phase = _phases[_phaseIdx];
    final begin = phase.kind == _PhaseKind.inhale ? .6 : 1.0;
    final end = switch (phase.kind) {
      _PhaseKind.inhale => 1.0,
      _PhaseKind.hold => 1.0,
      _PhaseKind.exhale => .6,
    };
    _scale = Tween(begin: begin, end: end).animate(
      CurvedAnimation(parent: _circle, curve: Curves.easeInOutCubic),
    );
    _circle.duration = Duration(seconds: phase.seconds);
    _circle.forward(from: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _circle.dispose();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    if (_done) return;
    if (_elapsedSec >= _totalSec) {
      _timer?.cancel();
      setState(() => _done = true);
      HapticFeedback.lightImpact();
      return;
    }
    setState(() {
      _elapsedSec++;
      _phaseRemaining--;
    });
    if (_phaseRemaining <= 0) {
      // Advance phase
      _phaseIdx = (_phaseIdx + 1) % _phases.length;
      _phaseRemaining = _phases[_phaseIdx].seconds;
      _setupScale();
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phases[_phaseIdx];
    final progress = _elapsedSec / _totalSec;
    return Scaffold(
      backgroundColor: const Color(0xFF1A2135),
      body: SafeArea(
        child: _done ? _buildDone() : _buildBreathing(phase, progress),
      ),
    );
  }

  Widget _buildBreathing(_Phase phase, double progress) {
    return Stack(
      children: [
        // Top bar
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'QUICK RELIEF',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_totalSec - _elapsedSec}s còn lại',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        // Center breath circle
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scale,
                builder: (_, __) => Container(
                  width: 220 * _scale.value,
                  height: 220 * _scale.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        RelaxTheme.lavender.withValues(alpha: .85),
                        RelaxTheme.purple.withValues(alpha: .45),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: RelaxTheme.lavender.withValues(alpha: .35),
                        blurRadius: 60,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          phase.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_phaseRemaining',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _calmText(_elapsedSec),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        // Bottom progress
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: .15),
                  valueColor:
                      AlwaysStoppedAnimation(RelaxTheme.lavender),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '4-7-8 nhịp thở · Theo vòng tròn',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _calmText(int sec) {
    final beats = [
      'Bạn đang ở đây ~',
      'Mỗi nhịp thở là một bước nhỏ',
      'Không có gì cần xử lý lúc này',
      'Bạn an toàn trong khoảnh khắc này',
      'Đẹp lắm — tiếp tục nha',
      'Cơ thể bạn đang dịu lại',
    ];
    return beats[(sec ~/ 10) % beats.length];
  }

  Widget _buildDone() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF48D3A8), Color(0xFF6BD4D4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF48D3A8).withValues(alpha: .5),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Bạn vừa cho mình 60 giây ✦',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Một hơi thở dài cũng đáng. Cơ thể đã ghi nhớ trạng thái dịu '
            'lại — bạn có thể quay lại khoảnh khắc này bất kỳ lúc nào.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .75),
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 36),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _done = false;
                _elapsedSec = 0;
                _phaseIdx = 0;
                _phaseRemaining = _phases[0].seconds;
              });
              _setupScale();
              _timer = Timer.periodic(
                const Duration(seconds: 1),
                (_) => _tick(),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: RelaxTheme.purple,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Một vòng nữa'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Đóng lại',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _Phase {
  const _Phase(this.label, this.seconds, this.kind);
  final String label;
  final int seconds;
  final _PhaseKind kind;
}

enum _PhaseKind { inhale, hold, exhale }
