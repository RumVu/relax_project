import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../core/locale_controller.dart';
import '../core/theme.dart';
import '../widgets/soft_toast.dart';

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
      builder: (ctx) => _WakeUpDialog(
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

class _WakeUpDialog extends StatefulWidget {
  const _WakeUpDialog({
    required this.startedAt,
    required this.endedAt,
    required this.onLogged,
  });

  final DateTime startedAt;
  final DateTime endedAt;
  final VoidCallback onLogged;

  @override
  State<_WakeUpDialog> createState() => _WakeUpDialogState();
}

class _WakeUpDialogState extends State<_WakeUpDialog> {
  double _quality = 7.0;
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await RelaxApi.instance.post(
        '/sleep/sessions',
        body: {
          'startedAt': widget.startedAt.toUtc().toIso8601String(),
          'endedAt': widget.endedAt.toUtc().toIso8601String(),
          'quality': _quality.toInt(),
          'note': _noteController.text.trim(),
        },
      );
      widget.onLogged();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showSoftToast(context, message: e.toString(), tone: SoftToastTone.error);
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t('Chào buổi sáng! ☀️')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t('Bạn đánh giá chất lượng giấc ngủ tối qua như thế nào?')),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_quality.toInt()} / 10',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            Slider(
              value: _quality,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              activeColor: RelaxColors.violet,
              onChanged: (v) => setState(() => _quality = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: context.t('Ghi chú (mơ thấy gì, có tỉnh giấc không...)'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_submitting)
          const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
        else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('Bỏ qua')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RelaxColors.violet),
            onPressed: _submit,
            child: Text(context.t('Lưu')),
          ),
        ]
      ],
    );
  }
}
