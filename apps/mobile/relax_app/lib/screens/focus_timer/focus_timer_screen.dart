import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';


enum _Phase { work, shortBreak, longBreak }

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  int _workMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  final int _cyclesBeforeLong = 4;

  _Phase _phase = _Phase.work;
  int _currentCycle = 1;
  int _completedCycles = 0;
  int _secondsLeft = 25 * 60;
  bool _running = false;
  Timer? _timer;

  int get _totalSeconds {
    switch (_phase) {
      case _Phase.work:
        return _workMinutes * 60;
      case _Phase.shortBreak:
        return _shortBreakMinutes * 60;
      case _Phase.longBreak:
        return _longBreakMinutes * 60;
    }
  }

  double get _progress {
    final total = _totalSeconds;
    if (total == 0) return 0;
    return 1.0 - (_secondsLeft / total);
  }

  Color get _phaseColor {
    switch (_phase) {
      case _Phase.work:
        return RelaxColors.violet;
      case _Phase.shortBreak:
        return RelaxColors.mint;
      case _Phase.longBreak:
        return const Color(0xFF2563EB);
    }
  }

  String get _phaseLabel {
    switch (_phase) {
      case _Phase.work:
        return 'Tập trung';
      case _Phase.shortBreak:
        return 'Nghỉ ngắn';
      case _Phase.longBreak:
        return 'Nghỉ dài';
    }
  }

  IconData get _phaseIcon {
    switch (_phase) {
      case _Phase.work:
        return Icons.bolt;
      case _Phase.shortBreak:
        return Icons.coffee;
      case _Phase.longBreak:
        return Icons.self_improvement;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) {
        _onPhaseComplete();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _phase = _Phase.work;
      _currentCycle = 1;
      _completedCycles = 0;
      _secondsLeft = _workMinutes * 60;
    });
  }

  void _onPhaseComplete() {
    HapticFeedback.heavyImpact();
    _timer?.cancel();

    if (_phase == _Phase.work) {
      _completedCycles++;
      _logSession();
      if (_completedCycles % _cyclesBeforeLong == 0) {
        setState(() {
          _phase = _Phase.longBreak;
          _secondsLeft = _longBreakMinutes * 60;
          _running = false;
        });
      } else {
        setState(() {
          _phase = _Phase.shortBreak;
          _secondsLeft = _shortBreakMinutes * 60;
          _running = false;
        });
      }
    } else {
      setState(() {
        _phase = _Phase.work;
        _currentCycle++;
        _secondsLeft = _workMinutes * 60;
        _running = false;
      });
    }
  }

  Future<void> _logSession() async {
    try {
      await RelaxApi.instance.post('/relax-sessions/me', body: {
        'activitySlug': 'focus-timer',
        'durationSeconds': _workMinutes * 60,
        'tags': ['pomodoro', 'cycle-$_completedCycles'],
      });
    } catch (_) {}
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Focus Timer'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: context.mutedText),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Phase indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _phaseColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_phaseIcon, color: _phaseColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    context.t(_phaseLabel),
                    style: TextStyle(
                      color: _phaseColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timer circle
            SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 8,
                      backgroundColor: context.fieldBorder,
                      color: _phaseColor,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_secondsLeft),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: context.appText,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '${context.t('Vòng')} $_currentCycle',
                        style: TextStyle(
                          color: context.mutedText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Completed cycles
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_cyclesBeforeLong, (i) {
                final done = i < (_completedCycles % _cyclesBeforeLong);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? _phaseColor : context.fieldBorder,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              '${context.t('Hoàn thành:')} $_completedCycles ${context.t('vòng')}',
              style: TextStyle(color: context.mutedText, fontSize: 12, fontWeight: FontWeight.w600),
            ),

            const Spacer(),

            // Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset
                  IconButton(
                    onPressed: _reset,
                    icon: Icon(Icons.refresh, color: context.mutedText, size: 28),
                  ),
                  // Play / Pause
                  GestureDetector(
                    onTap: _running ? _pause : _start,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _phaseColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _phaseColor.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _running ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  // Skip
                  IconButton(
                    onPressed: _onPhaseComplete,
                    icon: Icon(Icons.skip_next, color: context.mutedText, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('Cài đặt Timer'),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: context.appText,
              ),
            ),
            const SizedBox(height: 20),
            _SettingSlider(
              label: context.t('Tập trung (phút)'),
              value: _workMinutes,
              min: 5,
              max: 60,
              color: RelaxColors.violet,
              onChanged: (v) {
                setState(() {
                  _workMinutes = v;
                  if (_phase == _Phase.work && !_running) _secondsLeft = v * 60;
                });
              },
            ),
            _SettingSlider(
              label: context.t('Nghỉ ngắn (phút)'),
              value: _shortBreakMinutes,
              min: 1,
              max: 15,
              color: RelaxColors.mint,
              onChanged: (v) {
                setState(() {
                  _shortBreakMinutes = v;
                  if (_phase == _Phase.shortBreak && !_running) _secondsLeft = v * 60;
                });
              },
            ),
            _SettingSlider(
              label: context.t('Nghỉ dài (phút)'),
              value: _longBreakMinutes,
              min: 5,
              max: 30,
              color: const Color(0xFF2563EB),
              onChanged: (v) {
                setState(() {
                  _longBreakMinutes = v;
                  if (_phase == _Phase.longBreak && !_running) _secondsLeft = v * 60;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final Color color;
  final ValueChanged<int> onChanged;

  const _SettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      color: context.appText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              Text('$value',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            activeColor: color,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}
