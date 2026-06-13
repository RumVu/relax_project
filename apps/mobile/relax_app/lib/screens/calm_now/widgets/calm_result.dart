import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';

/// Step cuối: hỏi user "đỡ hơn chưa?" + chọn mood after.
/// Không phán xét, chỉ ghi nhận.
class CalmResult extends StatefulWidget {
  const CalmResult({
    super.key,
    required this.moodBefore,
    required this.onSubmit,
  });

  final String moodBefore;
  final void Function(String moodAfter, int reliefLevel) onSubmit;

  @override
  State<CalmResult> createState() => _CalmResultState();
}

class _CalmResultState extends State<CalmResult> {
  String? _selectedMood;
  int _relief = 3;
  bool _submitting = false;

  static const _moodOptions = <_AfterMood>[
    _AfterMood('CALM', 'Bình tĩnh hơn', '😌', Color(0xFF81c784)),
    _AfterMood('NEUTRAL', 'Bình thường', '😐', Color(0xFF90caf9)),
    _AfterMood('TIRED', 'Vẫn mệt', '😪', Color(0xFFffcc80)),
    _AfterMood('SAD', 'Vẫn buồn', '😢', Color(0xFF64b5f6)),
    _AfterMood('STRESSED', 'Vẫn căng', '😰', Color(0xFFe57373)),
  ];

  void _submit() async {
    if (_selectedMood == null) return;
    HapticFeedback.lightImpact();
    setState(() => _submitting = true);
    widget.onSubmit(_selectedMood!, _relief);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Celebration.
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: Text('🌿', style: TextStyle(fontSize: 42)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.t('Đỡ hơn chưa?'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t('Không cần hoàn hảo — chỉ cần thật với mình.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          // Mood options.
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _moodOptions.map((m) {
              final selected = _selectedMood == m.code;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedMood = m.code);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? m.color.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? m.color.withValues(alpha: 0.6)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        context.t(m.label),
                        style: TextStyle(
                          color: selected ? m.color : Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          // Relief level slider.
          Text(
            context.t('Mức nhẹ nhõm'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final level = i + 1;
              final active = level <= _relief;
              return GestureDetector(
                onTap: () => setState(() => _relief = level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.06),
                  ),
                  child: Center(
                    child: Text(
                      _reliefEmoji(level),
                      style: TextStyle(
                          fontSize: active ? 22 : 18,
                          color: active ? null : Colors.white24),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _reliefLabel(_relief),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          // Submit button.
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed:
                  (_selectedMood != null && !_submitting) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.06),
                disabledForegroundColor: Colors.white30,
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
                      context.t('Ghi nhận & đóng'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _reliefEmoji(int level) {
    switch (level) {
      case 1:
        return '😞';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😊';
      default:
        return '😐';
    }
  }

  String _reliefLabel(int level) {
    switch (level) {
      case 1:
        return context.t('Chưa đỡ mấy');
      case 2:
        return context.t('Đỡ một chút');
      case 3:
        return context.t('Tạm ổn');
      case 4:
        return context.t('Nhẹ nhõm hơn');
      case 5:
        return context.t('Tốt hơn nhiều');
      default:
        return '';
    }
  }
}

class _AfterMood {
  const _AfterMood(this.code, this.label, this.emoji, this.color);
  final String code;
  final String label;
  final String emoji;
  final Color color;
}
