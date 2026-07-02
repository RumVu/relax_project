import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/locale_controller.dart';
import '../models/intro_phase.dart';

class MoodPickStep extends StatelessWidget {
  const MoodPickStep({super.key, required this.onPick, required this.onSkip});
  final void Function(String mood) onPick;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                context.t('Bỏ qua →'),
                style: TextStyle(
                  color: context.appText.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            context.t('Bây giờ bạn thấy thế nào?'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t('Chọn một cảm xúc gần nhất với bạn lúc này — để Relax Time đề xuất hoạt động phù hợp.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appText.withValues(alpha: 0.6),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.68,
              children: moods
                  .map((m) => MoodChip(
                        code: m.$1,
                        label: context.t(m.$2),
                        icon: m.$3,
                        iconColor: m.$4,
                        image: m.$5,
                        bgColor: m.$6,
                        onTap: () => onPick(m.$1),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MoodChip extends StatefulWidget {
  const MoodChip({
    super.key,
    required this.code,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.image,
    required this.bgColor,
    required this.onTap,
  });
  final String code;
  final String label;
  final IconData icon;
  final Color iconColor;
  final String image;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  State<MoodChip> createState() => _MoodChipState();
}

class _MoodChipState extends State<MoodChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.iconColor.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(widget.icon, color: widget.iconColor, size: 22),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Image.asset(
                    widget.image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 2),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Color(0xFF2D2D3A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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
