import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';

/// Step 1: "Bạn đang muốn nghỉ vì gì?" — 6 lý do phổ biến.
class BreakReasonPicker extends StatelessWidget {
  const BreakReasonPicker({super.key, required this.onSelect});

  final void Function(String reason) onSelect;

  static const _reasons = <_Reason>[
    _Reason('STRESS', 'Căng thẳng', '😤', 'Đầu nặng, vai cứng, muốn hét.'),
    _Reason('SLEEPY', 'Buồn ngủ', '😴', 'Mắt díp, đầu gật, caffeine hết tác dụng.'),
    _Reason('BORED', 'Chán việc', '🥱', 'Không muốn nhìn màn hình thêm 1 giây.'),
    _Reason('OVERTHINKING', 'Nghĩ quá nhiều', '🌀', 'Não chạy 47 tab cùng lúc.'),
    _Reason('CRAVING', 'Thèm (thuốc/đồ ăn/...)', '🍬', 'Cơ thể đòi gì đó ngay lập tức.'),
    _Reason('SOCIAL_ESCAPE', 'Né xã hội 5 phút', '🫥', 'Muốn biến mất một lúc.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Icon.
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            child: const Center(
              child: Text('🚬', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t('→ nhưng lành mạnh hơn.'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.t('Bạn đang muốn nghỉ vì gì?'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _reasons.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final r = _reasons[i];
                return _ReasonTile(reason: r, onTap: () => onSelect(r.code));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Reason {
  const _Reason(this.code, this.label, this.emoji, this.subtitle);
  final String code;
  final String label;
  final String emoji;
  final String subtitle;
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({required this.reason, required this.onTap});
  final _Reason reason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(reason.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t(reason.label),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.t(reason.subtitle),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
