import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';
import 'widgets/wake_up_dialog.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  bool _isSleeping = false;
  DateTime? _sleepStartedAt;
  Timer? _timer;
  int _secondsSlept = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSleep() {
    _sleepStartedAt = DateTime.now();
    _secondsSlept = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _secondsSlept++;
      });
    });
    setState(() {
      _isSleeping = true;
    });
  }

  void _wakeUp() {
    _timer?.cancel();
    final started = _sleepStartedAt;
    final ended = DateTime.now();
    if (started == null) return;

    setState(() {
      _isSleeping = false;
    });

    // Open Wake Up Dialog to rate quality
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WakeUpDialog(
        startedAt: started,
        endedAt: ended,
        onLogged: () {
          if (mounted) {
            showSoftToast(context, message: context.t('Đã lưu dữ liệu giấc ngủ của bạn!'), tone: SoftToastTone.success);
          }
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Chế độ giấc ngủ'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Sleep Visuals
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _isSleeping
                          ? Colors.indigo.withValues(alpha: 0.3)
                          : Colors.amber.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  _isSleeping ? Icons.nights_stay : Icons.wb_twilight,
                  size: 96,
                  color: _isSleeping ? Colors.indigo[200] : Colors.amber[200],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _isSleeping ? context.t('Chúc ngủ ngon...') : context.t('Đã đến lúc nghỉ ngơi rồi'),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _isSleeping
                    ? context.t('Ứng dụng đang theo dõi thời lượng giấc ngủ của bạn.')
                    : context.t('Bật chế độ giấc ngủ để tắt màn hình giải tỏa căng thẳng.'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 32),
              if (_isSleeping)
                Text(
                  _formatDuration(_secondsSlept),
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSleeping ? Colors.redAccent : RelaxColors.violet,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (_isSleeping) {
                      _wakeUp();
                    } else {
                      _startSleep();
                    }
                  },
                  child: Text(
                    _isSleeping ? context.t('Thức dậy') : context.t('Bắt đầu giấc ngủ'),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
