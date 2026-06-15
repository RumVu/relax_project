import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_client.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

class MoodGoalsWidget extends StatefulWidget {
  const MoodGoalsWidget({super.key});

  @override
  State<MoodGoalsWidget> createState() => _MoodGoalsWidgetState();
}

class _MoodGoalsWidgetState extends State<MoodGoalsWidget> {
  List<Map<String, dynamic>> _goals = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await RelaxApi.instance.get('/mood-goals/me/progress');
      if (res.data is List && mounted) {
        setState(() {
          _goals = (res.data as List).cast<Map<String, dynamic>>();
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push('/mood-goals'),
          child: Row(
            children: [
              Icon(Icons.flag, color: RelaxColors.violet, size: 18),
              const SizedBox(width: 6),
              Text(
                context.t('Mục tiêu cảm xúc'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: context.appText,
                ),
              ),
              const Spacer(),
              Text(
                context.t('Xem tất cả ›'),
                style: const TextStyle(
                  color: RelaxColors.violet,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (_goals.isEmpty)
          GestureDetector(
            onTap: () => context.push('/mood-goals'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.fieldBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline,
                      color: RelaxColors.violet, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.t('Đặt mục tiêu cảm xúc đầu tiên!'),
                      style: TextStyle(
                        color: context.mutedText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._goals.take(2).map((g) => _buildMiniGoal(context, g)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMiniGoal(BuildContext context, Map<String, dynamic> goal) {
    final title = goal['title'] as String? ?? '';
    final progress = goal['progress'] as Map<String, dynamic>?;
    final percentage = (progress?['percentage'] ?? 0) as int;

    return GestureDetector(
      onTap: () => context.push('/mood-goals'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.fieldBorder),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 3,
                    backgroundColor: context.fieldBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        RelaxColors.violet),
                  ),
                  Center(
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: context.appText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
