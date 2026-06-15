import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

class MoodGoalsScreen extends StatefulWidget {
  const MoodGoalsScreen({super.key});

  @override
  State<MoodGoalsScreen> createState() => _MoodGoalsScreenState();
}

class _MoodGoalsScreenState extends State<MoodGoalsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _goals = [];
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/mood-goals/me/progress'),
        RelaxApi.instance.get('/mood-goals/me/summary'),
      ]);
      setState(() {
        _goals = (results[0].data as List?)?.cast<Map<String, dynamic>>() ?? [];
        _summary = results[1].data as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          context.isDark ? const Color(0xFF0d1117) : RelaxColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Mục tiêu cảm xúc 🎯'),
          style:
              TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: RelaxColors.violet),
            onPressed: () => _showCreateDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: RelaxColors.violet,
          onRefresh: _load,
          child: _loading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: RelaxColors.violet))
              : ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    if (_summary != null) _buildSummaryCard(context),
                    const SizedBox(height: 16),
                    Text(
                      context.t('Mục tiêu đang hoạt động'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.appText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_goals.isEmpty)
                      _buildEmptyState(context)
                    else
                      ..._goals.map((g) => _buildGoalCard(context, g)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final active = _summary?['active'] ?? 0;
    final completed = _summary?['completed'] ?? 0;
    final rate = ((_summary?['completionRate'] ?? 0) * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6c63ff), Color(0xFF9c27b0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(context.t('Đang theo'), '$active', Icons.flag),
          _summaryItem(context.t('Hoàn thành'), '$completed', Icons.check_circle),
          _summaryItem(context.t('Tỷ lệ'), '$rate%', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildGoalCard(BuildContext context, Map<String, dynamic> goal) {
    final title = goal['title'] as String? ?? '';
    final type = goal['type'] as String? ?? '';
    final progress = goal['progress'] as Map<String, dynamic>?;
    final current = progress?['current'] ?? 0;
    final target = progress?['target'] ?? 1;
    final percentage = (progress?['percentage'] ?? 0) as int;
    final milestones =
        (goal['milestones'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: RelaxColors.violet.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconForType(type),
                    color: RelaxColors.violet, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          color: context.appText,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        )),
                    const SizedBox(height: 2),
                    Text(_labelForType(type),
                        style:
                            TextStyle(color: context.mutedText, fontSize: 12)),
                  ],
                ),
              ),
              Text('$percentage%',
                  style: TextStyle(
                    color: RelaxColors.violet,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: context.fieldBorder,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(RelaxColors.violet),
            ),
          ),
          const SizedBox(height: 6),
          Text('$current / $target',
              style: TextStyle(color: context.mutedText, fontSize: 12)),
          if (milestones.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...milestones.map((ms) => _buildMilestoneRow(context, ms)),
          ],
        ],
      ),
    );
  }

  Widget _buildMilestoneRow(BuildContext context, Map<String, dynamic> ms) {
    final reached = ms['reached'] as bool? ?? false;
    final title = ms['title'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            reached ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: reached ? RelaxColors.mint : context.mutedText,
          ),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                color: reached ? context.appText : context.mutedText,
                fontSize: 13,
                decoration:
                    reached ? TextDecoration.lineThrough : TextDecoration.none,
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(context.t('Chưa có mục tiêu nào'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.appText,
              )),
          const SizedBox(height: 6),
          Text(context.t('Tạo mục tiêu để theo dõi hành trình cảm xúc!'),
              style: TextStyle(color: context.mutedText, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showCreateDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: Text(context.t('Tạo mục tiêu')),
            style: ElevatedButton.styleFrom(
              backgroundColor: RelaxColors.violet,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'TARGET_MOOD':
        return Icons.emoji_emotions;
      case 'REDUCE_MOOD':
        return Icons.remove_circle_outline;
      case 'STREAK':
        return Icons.local_fire_department;
      case 'CHECKIN_COUNT':
        return Icons.checklist;
      default:
        return Icons.flag;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'TARGET_MOOD':
        return 'Hướng tới cảm xúc';
      case 'REDUCE_MOOD':
        return 'Giảm thiểu cảm xúc';
      case 'STREAK':
        return 'Chuỗi ngày';
      case 'CHECKIN_COUNT':
        return 'Số lần ghi nhận';
      default:
        return type;
    }
  }

  void _showCreateDialog() {
    String title = '';
    String selectedType = 'CHECKIN_COUNT';
    int targetCount = 7;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: ctx.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ctx.fieldBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(ctx.t('Tạo mục tiêu mới'),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ctx.appText)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: ctx.t('Tên mục tiêu'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (v) => title = v,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: ctx.t('Loại mục tiêu'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: 'CHECKIN_COUNT',
                          child: Text(ctx.t('Số lần ghi nhận'))),
                      DropdownMenuItem(
                          value: 'TARGET_MOOD',
                          child: Text(ctx.t('Hướng tới cảm xúc'))),
                      DropdownMenuItem(
                          value: 'REDUCE_MOOD',
                          child: Text(ctx.t('Giảm thiểu cảm xúc'))),
                      DropdownMenuItem(
                          value: 'STREAK',
                          child: Text(ctx.t('Chuỗi ngày liên tục'))),
                    ],
                    onChanged: (v) {
                      setSheetState(() => selectedType = v ?? 'CHECKIN_COUNT');
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: ctx.t('Mục tiêu (số lần)'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        targetCount = int.tryParse(v) ?? 7,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (title.isEmpty) return;
                        Navigator.pop(ctx);
                        await _createGoal(title, selectedType, targetCount);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RelaxColors.violet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(ctx.t('Tạo mục tiêu'),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createGoal(
      String title, String type, int targetCount) async {
    HapticFeedback.lightImpact();
    try {
      await RelaxApi.instance.post('/mood-goals/me', body: {
        'title': title,
        'type': type,
        'targetCount': targetCount,
      });
      if (!mounted) return;
      showSoftToast(context,
          message: context.t('Đã tạo mục tiêu!'), tone: SoftToastTone.success);
      await _load();
    } catch (_) {
      if (mounted) {
        showSoftToast(context,
            message: context.t('Lỗi khi tạo mục tiêu'),
            tone: SoftToastTone.error);
      }
    }
  }
}
