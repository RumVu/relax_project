import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';

/// Demo walkthrough — 6-item guided checklist that tracks progress in Hive.
class DemoChecklistScreen extends StatefulWidget {
  const DemoChecklistScreen({super.key});

  @override
  State<DemoChecklistScreen> createState() => _DemoChecklistScreenState();
}

class _DemoChecklistScreenState extends State<DemoChecklistScreen> {
  static const _boxName = 'demo_progress';

  late final List<_ChecklistItem> _items;
  Box? _box;
  final Set<int> _completed = {};

  @override
  void initState() {
    super.initState();
    _items = [
      _ChecklistItem(
        icon: Icons.mood,
        emoji: '😊',
        title: 'Check mood hôm nay',
        subtitle: 'Ghi nhận cảm xúc hiện tại của bạn',
        route: '/mood',
      ),
      _ChecklistItem(
        icon: Icons.spa,
        emoji: '🧘',
        title: 'Thử Calm Now',
        subtitle: 'Trải nghiệm bài tập thư giãn nhanh',
        route: '/calm-now',
      ),
      _ChecklistItem(
        icon: Icons.air,
        emoji: '🌬️',
        title: 'Hoàn thành 1 session',
        subtitle: 'Thử bài hít thở để giảm stress',
        route: '/breathing',
      ),
      _ChecklistItem(
        icon: Icons.bar_chart,
        emoji: '📊',
        title: 'Xem Weekly Report',
        subtitle: 'Xem báo cáo tuần về cảm xúc',
        route: '/weekly-report',
      ),
      _ChecklistItem(
        icon: Icons.lightbulb_outline,
        emoji: '💡',
        title: 'Xem Gợi ý thông minh',
        subtitle: 'Nhận gợi ý phù hợp với trạng thái',
        route: '/recommendations',
      ),
      _ChecklistItem(
        icon: Icons.admin_panel_settings,
        emoji: '🔧',
        title: 'Mở Admin Dashboard',
        subtitle: 'Truy cập web admin tại /admin',
        route: null, // Shows note instead of navigating.
      ),
    ];
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _box = await Hive.openBox(_boxName);
    final saved = _box?.get('completed');
    if (saved is List) {
      _completed.addAll(saved.cast<int>());
    }
    if (mounted) setState(() {});
  }

  Future<void> _markCompleted(int index) async {
    _completed.add(index);
    await _box?.put('completed', _completed.toList());
    if (mounted) setState(() {});
  }

  void _onItemTap(int index) {
    final item = _items[index];
    if (item.route == null) {
      // Admin dashboard — show info dialog.
      _markCompleted(index);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Text('🔧', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(context.t('Admin Dashboard')),
            ],
          ),
          content: Text(
            context.t(
                'Truy cập web admin tại /admin trên trình duyệt để quản lý nội dung, người dùng và cấu hình.'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.t('Đã hiểu'),
                  style: const TextStyle(color: RelaxColors.violet)),
            ),
          ],
        ),
      );
      return;
    }

    _markCompleted(index);
    context.push(item.route!);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completed.length;
    final progress = completedCount / _items.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.t('Demo Guide'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: context.appText),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  // Title section.
                  Text(
                    context.t('Demo Walkthrough'),
                    style: TextStyle(
                      color: context.appText,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.t('Khám phá các tính năng của Thi Ái'),
                    style: TextStyle(
                      color: context.mutedText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress bar.
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: RelaxColors.violet.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.t('Tiến trình'),
                              style: TextStyle(
                                color: context.appText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '$completedCount/${_items.length}',
                              style: const TextStyle(
                                color: RelaxColors.violet,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: context.fieldBorder,
                            color: RelaxColors.violet,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Checklist items.
                  for (int i = 0; i < _items.length; i++) ...[
                    _buildItem(context, i),
                    if (i < _items.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),

            // Skip button at bottom.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.fieldBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => context.go('/home'),
                  child: Text(
                    context.t('Bỏ qua'),
                    style: TextStyle(
                      color: context.mutedText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _items[index];
    final done = _completed.contains(index);

    return Container(
      decoration: BoxDecoration(
        color: done
            ? RelaxColors.violet.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done ? RelaxColors.violet.withValues(alpha: 0.3) : context.fieldBorder,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: done
                ? RelaxColors.violet.withValues(alpha: 0.15)
                : RelaxColors.violet.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check_circle, color: RelaxColors.violet, size: 22)
                : Text(item.emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          context.t(item.title),
          style: TextStyle(
            color: context.appText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            decoration: done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          context.t(item.subtitle),
          style: TextStyle(
            color: context.mutedText,
            fontSize: 11,
          ),
        ),
        trailing: done
            ? null
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: RelaxColors.violet,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.t('Go'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
        onTap: () => _onItemTap(index),
      ),
    );
  }
}

class _ChecklistItem {
  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  final String? route;

  const _ChecklistItem({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}
