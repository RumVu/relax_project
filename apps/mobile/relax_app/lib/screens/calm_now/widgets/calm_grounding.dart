import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';

/// Bài tập grounding 5-4-3-2-1 (dùng 5 giác quan để neo bản thân
/// vào hiện tại). Khoảng 2–3 phút tùy tốc độ user bấm.
///
/// Mỗi bước hiện câu hỏi + số lượng, user bấm "Tiếp" khi đã tìm đủ.
/// Sau 5 bước → done.
class CalmGrounding extends StatefulWidget {
  const CalmGrounding({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<CalmGrounding> createState() => _CalmGroundingState();
}

class _CalmGroundingState extends State<CalmGrounding>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0→4 (5 bước)
  late final AnimationController _fadeCtrl;

  static const _steps = <_GroundStep>[
    _GroundStep(
      count: 5,
      sense: 'nhìn thấy',
      emoji: '👀',
      instruction: 'Nhìn xung quanh — tìm 5 thứ bạn nhìn thấy.',
      color: Color(0xFF90caf9),
    ),
    _GroundStep(
      count: 4,
      sense: 'chạm vào',
      emoji: '🤲',
      instruction: 'Chạm vào 4 thứ gần bạn — cảm nhận bề mặt.',
      color: Color(0xFFa5d6a7),
    ),
    _GroundStep(
      count: 3,
      sense: 'nghe thấy',
      emoji: '👂',
      instruction: 'Lắng nghe — bạn nghe được 3 âm thanh nào?',
      color: Color(0xFFffcc80),
    ),
    _GroundStep(
      count: 2,
      sense: 'ngửi thấy',
      emoji: '👃',
      instruction: 'Hít nhẹ — 2 mùi bạn cảm nhận được.',
      color: Color(0xFFce93d8),
    ),
    _GroundStep(
      count: 1,
      sense: 'nếm được',
      emoji: '👅',
      instruction: '1 vị — uống ngụm nước hoặc cảm nhận vị trong miệng.',
      color: Color(0xFFef9a9a),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    HapticFeedback.mediumImpact();
    await _fadeCtrl.animateTo(0.0,
        duration: const Duration(milliseconds: 150));
    if (!mounted) return;
    if (_step >= _steps.length - 1) {
      widget.onDone();
      return;
    }
    setState(() => _step++);
    await _fadeCtrl.animateTo(1.0,
        duration: const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    final progress = (_step + 1) / _steps.length;

    return FadeTransition(
      opacity: _fadeCtrl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              context.t('Bài tập grounding 5-4-3-2-1'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${context.t('Bước')} ${_step + 1} / ${_steps.length}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
            const Spacer(),
            // Emoji lớn.
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step.color.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(step.emoji, style: const TextStyle(fontSize: 52)),
              ),
            ),
            const SizedBox(height: 28),
            // Số lượng.
            Text(
              '${step.count}',
              style: TextStyle(
                color: step.color,
                fontSize: 56,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.t('thứ bạn ${step.sense}'),
              style: TextStyle(
                color: step.color.withValues(alpha: 0.8),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.t(step.instruction),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            const Spacer(),
            // Next button.
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: step.color.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _step < _steps.length - 1
                      ? context.t('Xong — tiếp theo')
                      : context.t('Hoàn thành'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Progress bar.
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                color: step.color.withValues(alpha: 0.6),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onDone,
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
      ),
    );
  }
}

class _GroundStep {
  const _GroundStep({
    required this.count,
    required this.sense,
    required this.emoji,
    required this.instruction,
    required this.color,
  });
  final int count;
  final String sense;
  final String emoji;
  final String instruction;
  final Color color;
}
