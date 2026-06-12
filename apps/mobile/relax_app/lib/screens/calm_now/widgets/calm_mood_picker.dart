import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';

/// Step 1: User chọn cảm xúc đang có. 6 lựa chọn phổ biến khi cần
/// "cứu" gấp — không hiện toàn bộ mood wheel để tránh cognitive load.
class CalmMoodPicker extends StatelessWidget {
  const CalmMoodPicker({super.key, required this.onSelect});

  final void Function(String mood) onSelect;

  static const _moods = <_MoodOption>[
    _MoodOption('STRESSED', 'Căng thẳng', '😰', Color(0xFFe57373)),
    _MoodOption('ANGRY', 'Tức giận', '😤', Color(0xFFef5350)),
    _MoodOption('SAD', 'Buồn', '😢', Color(0xFF64b5f6)),
    _MoodOption('TIRED', 'Kiệt sức', '😩', Color(0xFFffb74d)),
    _MoodOption('ANXIOUS', 'Lo lắng', '😟', Color(0xFFba68c8)),
    _MoodOption('OVERWHELMED', 'Quá tải', '🤯', Color(0xFFff8a65)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Biểu tượng lớn.
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: Text('🫂', style: TextStyle(fontSize: 42)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.t('Bạn đang cảm thấy gì?'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t('Chọn một — mình sẽ tìm cách giúp bạn ngay.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 2.2,
              physics: const NeverScrollableScrollPhysics(),
              children: _moods
                  .map((m) => _MoodTile(
                        option: m,
                        onTap: () => onSelect(m.code),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption(this.code, this.label, this.emoji, this.color);
  final String code;
  final String label;
  final String emoji;
  final Color color;
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({required this.option, required this.onTap});
  final _MoodOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: option.color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(option.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.t(option.label),
                  style: TextStyle(
                    color: option.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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
