import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';

/// Ritual 3 phút: 4 steps tự động chạy — breathing → quote → ambient →
/// mini journal prompt. Mỗi step ~45s. Tổng ~3 phút.
///
/// Mô phỏng "đi hút thuốc" nhưng thay vì thuốc là self-care:
/// hít thở (thay hút), đọc quote (thay nhìn trời), journal (thay suy nghĩ).
class BreakRitual extends StatefulWidget {
  const BreakRitual({super.key, required this.reason, required this.onDone});
  final String reason;
  final VoidCallback onDone;

  @override
  State<BreakRitual> createState() => _BreakRitualState();
}

class _BreakRitualState extends State<BreakRitual>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0=breathing, 1=quote, 2=ambient, 3=journal
  int _stepSeconds = 0;
  int _totalSeconds = 0;
  Timer? _ticker;
  late final AnimationController _breathCtrl;

  // Breathing state.
  String _breathLabel = 'Hít vào…';
  int _breathRemaining = 4;

  static const _totalDuration = 180; // 3 phút

  // Step durations.
  static const _stepDurations = [50, 40, 45, 45]; // breathing, quote, ambient, journal

  static const _quotes = [
    'Không cần hoàn hảo. Chỉ cần cho phép mình nghỉ.',
    'Bạn đang làm tốt hơn bạn nghĩ rất nhiều.',
    'Mỗi nhịp thở là một lần bắt đầu lại.',
    'Không ai đánh giá bạn vì nghỉ ngơi. Trừ deadline, nhưng deadline không biết đọc.',
    'Thở đi. Mọi thứ đang đợi. Và đợi được.',
    'Bạn không phải máy. Ngay cả máy còn phải restart.',
    'Đây là khoảnh khắc của bạn. Không notification nào quan trọng hơn bạn.',
  ];

  static const _journalPrompts = [
    'Điều gì đang chiếm nhiều tâm trí bạn nhất lúc này?',
    'Nếu được bỏ 1 thứ khỏi hôm nay, bạn chọn gì?',
    'Bạn muốn nói gì với bản thân 5 phút trước?',
    'Một điều nhỏ khiến bạn biết ơn hôm nay?',
    'Nếu cảm xúc lúc này là thời tiết, nó là gì?',
  ];

  late final String _quote;
  late final String _journalPrompt;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _quote = _quotes[rng.nextInt(_quotes.length)];
    _journalPrompt = _journalPrompts[rng.nextInt(_journalPrompts.length)];

    _breathCtrl = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      upperBound: 1.0,
      value: 0.5,
    );

    _startBreathing();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _breathCtrl.dispose();
    super.dispose();
  }

  void _startBreathing() {
    _breathLabel = 'Hít vào…';
    _breathRemaining = 4;
    _breathCtrl.animateTo(1.0,
        duration: const Duration(seconds: 4), curve: Curves.easeInOut);
  }

  void _tick() {
    _totalSeconds++;
    _stepSeconds++;

    // Breathing animation khi ở step 0.
    if (_step == 0) {
      _breathRemaining--;
      if (_breathRemaining <= 0) {
        if (_breathLabel.startsWith('Hít')) {
          _breathLabel = 'Giữ…';
          _breathRemaining = 2;
        } else if (_breathLabel.startsWith('Giữ')) {
          _breathLabel = 'Thở ra…';
          _breathRemaining = 4;
          _breathCtrl.animateTo(0.5,
              duration: const Duration(seconds: 4), curve: Curves.easeInOut);
        } else {
          _breathLabel = 'Hít vào…';
          _breathRemaining = 4;
          _breathCtrl.animateTo(1.0,
              duration: const Duration(seconds: 4), curve: Curves.easeInOut);
        }
        HapticFeedback.selectionClick();
      }
    }

    // Check step transition.
    if (_stepSeconds >= _stepDurations[_step] && _step < 3) {
      HapticFeedback.mediumImpact();
      setState(() {
        _step++;
        _stepSeconds = 0;
      });
    }

    // Done.
    if (_totalSeconds >= _totalDuration) {
      _ticker?.cancel();
      HapticFeedback.heavyImpact();
      widget.onDone();
      return;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds / _totalDuration;
    final stepProgress = _stepSeconds / _stepDurations[_step];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(
        children: [
          // Step indicator.
          Row(
            children: List.generate(4, (i) {
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: i < _step
                        ? Colors.white.withValues(alpha: 0.5)
                        : i == _step
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.08),
                  ),
                  child: i == _step
                      ? FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: stepProgress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            context.t(_stepLabel),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Step content.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: _buildStep(),
            ),
          ),
          const Spacer(),
          // Timer.
          Text(
            '${(_totalDuration - _totalSeconds) ~/ 60}:${((_totalDuration - _totalSeconds) % 60).toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              color: Colors.white.withValues(alpha: 0.3),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _ticker?.cancel();
              widget.onDone();
            },
            child: Text(
              context.t('Xong sớm'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _stepLabel {
    switch (_step) {
      case 0:
        return '1/4 · Hít thở';
      case 1:
        return '2/4 · Đọc & suy nghĩ';
      case 2:
        return '3/4 · Lắng nghe';
      case 3:
        return '4/4 · Ghi lại';
      default:
        return '';
    }
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildBreathing();
      case 1:
        return _buildQuote();
      case 2:
        return _buildAmbient();
      case 3:
        return _buildJournal();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBreathing() {
    return AnimatedBuilder(
      animation: _breathCtrl,
      builder: (context, _) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: _breathCtrl.value,
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.05),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.t(_breathLabel),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_breathRemaining',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              context.t('Hít thở như đang hút một điếu bình yên.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Text('📖', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 24),
          Text(
            context.t(_quote),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.t('Để câu này ngấm một chút…'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbient() {
    return Column(
      children: [
        const Text('🎧', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 24),
        Text(
          context.t('Nhắm mắt. Lắng nghe.'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.t('Tưởng tượng mình đang ở nơi yên tĩnh nhất bạn biết.'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        // Visualizer giả — mấy thanh nhảy nhẹ.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (i) {
            final height = 20.0 + (sin((_totalSeconds + i) * 0.8) * 15);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 4,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white
                    .withValues(alpha: 0.15 + (i % 3) * 0.05),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildJournal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const Text('✍️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 20),
          Text(
            context.t(_journalPrompt),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.t('Không cần viết ra. Chỉ cần nghĩ về nó.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
