import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/local_notifications.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';

/// Focus Break Scheduler — Pomodoro-style work/break timer with notifications.
class FocusBreakScreen extends StatefulWidget {
  const FocusBreakScreen({super.key});

  @override
  State<FocusBreakScreen> createState() => _FocusBreakScreenState();
}

class _FocusBreakScreenState extends State<FocusBreakScreen> {
  static const _boxName = 'focus_break';

  int _workMinutes = 25;
  int _breakMinutes = 5;
  int _sessionsGoal = 4;
  int _completedSessions = 0;

  bool _isRunning = false;
  bool _isBreak = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox(_boxName);
    setState(() {
      _workMinutes = box.get('workMinutes', defaultValue: 25) as int;
      _breakMinutes = box.get('breakMinutes', defaultValue: 5) as int;
      _sessionsGoal = box.get('sessionsGoal', defaultValue: 4) as int;
    });
  }

  Future<void> _saveSettings() async {
    final box = await Hive.openBox(_boxName);
    await box.put('workMinutes', _workMinutes);
    await box.put('breakMinutes', _breakMinutes);
    await box.put('sessionsGoal', _sessionsGoal);
  }

  void _start() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = true;
      _isBreak = false;
      _remainingSeconds = _workMinutes * 60;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _onPhaseComplete();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _onPhaseComplete() {
    HapticFeedback.heavyImpact();
    if (_isBreak) {
      setState(() {
        _isBreak = false;
        _remainingSeconds = _workMinutes * 60;
      });
      _startTimer();
      LocalNotifications.showInstant(
        title: 'Hết giờ nghỉ! 💪',
        body: 'Quay lại tập trung nào!',
      );
    } else {
      setState(() {
        _completedSessions++;
        if (_completedSessions >= _sessionsGoal) {
          _isRunning = false;
          _remainingSeconds = 0;
          _timer?.cancel();
        } else {
          _isBreak = true;
          _remainingSeconds = _breakMinutes * 60;
          _startTimer();
        }
      });
      if (_completedSessions >= _sessionsGoal) {
        LocalNotifications.showInstant(
          title: 'Hoàn thành! 🎉',
          body: 'Bạn đã hoàn thành $_sessionsGoal phiên tập trung!',
        );
      } else {
        LocalNotifications.showInstant(
          title: 'Nghỉ giải lao! ☕',
          body: 'Đã xong 1 phiên. Nghỉ $_breakMinutes phút nhé!',
        );
      }
    }
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _remainingSeconds = 0;
      _completedSessions = 0;
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resume() {
    setState(() => _isRunning = true);
    _startTimer();
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _isRunning || _remainingSeconds > 0
        ? 1.0 -
            (_remainingSeconds /
                ((_isBreak ? _breakMinutes : _workMinutes) * 60))
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          context.t('Focus Break'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Timer circle
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor: context.fieldBorder,
                      color: _isBreak
                          ? RelaxColors.mint
                          : RelaxColors.violet,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isRunning || _remainingSeconds > 0
                            ? _formatTime(_remainingSeconds)
                            : _formatTime(_workMinutes * 60),
                        style: TextStyle(
                          color: context.appText,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          fontFeatures: const [
                            FontFeature.tabularFigures()
                          ],
                        ),
                      ),
                      Text(
                        _isBreak
                            ? context.t('Nghỉ giải lao')
                            : context.t('Tập trung'),
                        style: TextStyle(
                          color: _isBreak
                              ? RelaxColors.mint
                              : RelaxColors.violet,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Session progress
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_sessionsGoal, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < _completedSessions
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: i < _completedSessions
                        ? RelaxColors.mint
                        : context.fieldBorder,
                    size: 24,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '$_completedSessions / $_sessionsGoal ${context.t('phiên')}',
              style: TextStyle(
                color: context.mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Controls
          if (!_isRunning && _remainingSeconds == 0)
            _buildButton(
              context.t('Bắt đầu'),
              RelaxColors.violet,
              _start,
            )
          else if (_isRunning)
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    context.t('Tạm dừng'),
                    RelaxColors.coral,
                    _pause,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildButton(
                    context.t('Dừng hẳn'),
                    context.mutedText,
                    _stop,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    context.t('Tiếp tục'),
                    RelaxColors.violet,
                    _resume,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildButton(
                    context.t('Dừng hẳn'),
                    context.mutedText,
                    _stop,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 32),
          // Settings
          if (!_isRunning && _remainingSeconds == 0) ...[
            Text(
              context.t('Cài đặt'),
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            _SettingRow(
              label: context.t('Phiên tập trung'),
              value: '$_workMinutes ${context.t('phút')}',
              onDecrease: () {
                if (_workMinutes > 5) {
                  setState(() => _workMinutes -= 5);
                  _saveSettings();
                }
              },
              onIncrease: () {
                if (_workMinutes < 60) {
                  setState(() => _workMinutes += 5);
                  _saveSettings();
                }
              },
            ),
            _SettingRow(
              label: context.t('Thời gian nghỉ'),
              value: '$_breakMinutes ${context.t('phút')}',
              onDecrease: () {
                if (_breakMinutes > 1) {
                  setState(() => _breakMinutes -= 1);
                  _saveSettings();
                }
              },
              onIncrease: () {
                if (_breakMinutes < 30) {
                  setState(() => _breakMinutes += 1);
                  _saveSettings();
                }
              },
            ),
            _SettingRow(
              label: context.t('Số phiên mục tiêu'),
              value: '$_sessionsGoal',
              onDecrease: () {
                if (_sessionsGoal > 1) {
                  setState(() => _sessionsGoal -= 1);
                  _saveSettings();
                }
              },
              onIncrease: () {
                if (_sessionsGoal < 12) {
                  setState(() => _sessionsGoal += 1);
                  _saveSettings();
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });
  final String label;
  final String value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 22),
            color: context.mutedText,
            onPressed: onDecrease,
          ),
          Text(
            value,
            style: TextStyle(
              color: RelaxColors.violet,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22),
            color: context.mutedText,
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}
