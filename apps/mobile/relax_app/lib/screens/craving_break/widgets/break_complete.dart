import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';

/// Kết thúc break: "Bạn đã vượt qua 1 break 🌿"
/// Hiện thời gian break + hỏi mood after + relief level.
class BreakComplete extends StatefulWidget {
  const BreakComplete({
    super.key,
    required this.reason,
    required this.duration,
    required this.onSubmit,
  });

  final String reason;
  final Duration duration;
  final void Function(String moodAfter, int relief) onSubmit;

  @override
  State<BreakComplete> createState() => _BreakCompleteState();
}

class _BreakCompleteState extends State<BreakComplete> {
  String? _mood;
  int _relief = 3;
  bool _submitting = false;

  static const _moods = <_M>[
    _M('CALM', 'Bình tĩnh hơn', '😌'),
    _M('NEUTRAL', 'Tạm ổn', '😐'),
    _M('HAPPY', 'Vui hơn', '😊'),
    _M('TIRED', 'Vẫn mệt', '😪'),
    _M('STRESSED', 'Vẫn căng', '😰'),
  ];

  void _submit() {
    if (_mood == null) return;
    HapticFeedback.lightImpact();
    setState(() => _submitting = true);
    widget.onSubmit(_mood!, _relief);
  }

  @override
  Widget build(BuildContext context) {
    final mins = widget.duration.inMinutes;
    final secs = widget.duration.inSeconds % 60;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Celebration.
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2d6a4f).withValues(alpha: 0.3),
            ),
            child: const Center(
              child: Text('🌿', style: TextStyle(fontSize: 46)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.t('Break hoàn thành!'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$mins ${context.t('phút')} $secs ${context.t('giây')} — ${context.t('bạn đã làm được!')}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.t('Giờ bạn cảm thấy sao?'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          // Mood chips.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _moods.map((m) {
              final sel = _mood == m.code;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _mood = m.code);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        context.t(m.label),
                        style: TextStyle(
                          color: sel ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Relief stars.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final level = i + 1;
              final active = level <= _relief;
              return GestureDetector(
                onTap: () => setState(() => _relief = level),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    active ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: active
                        ? const Color(0xFF81c784)
                        : Colors.white.withValues(alpha: 0.15),
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            context.t('Mức nhẹ nhõm'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  (_mood != null && !_submitting) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2d6a4f),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.04),
                disabledForegroundColor: Colors.white24,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      context.t('Ghi nhận & quay lại'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _M {
  const _M(this.code, this.label, this.emoji);
  final String code;
  final String label;
  final String emoji;
}
