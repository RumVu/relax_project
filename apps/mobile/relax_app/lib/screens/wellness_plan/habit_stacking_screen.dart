import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

class HabitStackingScreen extends StatefulWidget {
  const HabitStackingScreen({super.key});

  @override
  State<HabitStackingScreen> createState() => _HabitStackingScreenState();
}

class _HabitStackingScreenState extends State<HabitStackingScreen> {
  late Box<String> _habitBox;
  bool _loading = true;
  List<Map<String, dynamic>> _habits = [];

  final _cueCtrl = TextEditingController();
  final _routineCtrl = TextEditingController();

  final List<(String, String)> _defaultPresets = [
    ('thức dậy', 'mood check-in 20s'),
    ('ăn trưa', '2 phút breathing'),
    ('tan làm', 'soundscape 5 phút'),
    ('lên giường', 'sleep reflection'),
    ('stress', 'calm now'),
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _habitBox = await Hive.openBox<String>('habit_stacking');
    if (_habitBox.isEmpty) {
      // Seed default stackings
      for (var p in _defaultPresets) {
        final entry = {
          'cue': p.$1,
          'routine': p.$2,
          'completedToday': false,
          'lastCompletedDate': '',
        };
        await _habitBox.add(jsonEncode(entry));
      }
    }
    _loadHabits();
  }

  void _loadHabits() {
    final List<Map<String, dynamic>> list = [];
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    for (var key in _habitBox.keys) {
      final val = _habitBox.get(key);
      if (val != null) {
        try {
          final decoded = jsonDecode(val) as Map<String, dynamic>;
          final lastDate = decoded['lastCompletedDate'] as String? ?? '';
          final completed = lastDate == todayStr;
          list.add({
            'key': key,
            ...decoded,
            'completedToday': completed,
          });
        } catch (_) {}
      }
    }
    setState(() {
      _habits = list;
      _loading = false;
    });
  }

  Future<void> _toggleComplete(Map<String, dynamic> item) async {
    HapticFeedback.lightImpact();
    final key = item['key'];
    final completed = !item['completedToday'];
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    final updated = {
      'cue': item['cue'],
      'routine': item['routine'],
      'lastCompletedDate': completed ? todayStr : '',
    };

    await _habitBox.put(key, jsonEncode(updated));
    _loadHabits();

    if (completed) {
      try {
        final budgetBox = await Hive.openBox('mood_budget');
        final currentEnergy = budgetBox.get('energy', defaultValue: 70) as int;
        final currentStress = budgetBox.get('stress', defaultValue: 45) as int;
        await budgetBox.put('energy', (currentEnergy + 10).clamp(0, 100));
        await budgetBox.put('stress', (currentStress - 10).clamp(0, 100));
      } catch (_) {}
    }

    if (completed && mounted) {
      showSoftToast(
        context,
        message: context.t('Tuyệt vời! +10 Năng lượng cảm xúc 🔋'),
        tone: SoftToastTone.success,
      );
      // We can also trigger a reward notification here
    }
  }

  Future<void> _addCustom() async {
    if (_cueCtrl.text.trim().isEmpty || _routineCtrl.text.trim().isEmpty) {
      showSoftToast(context, message: context.t('Vui lòng điền đủ cả hai ô'), tone: SoftToastTone.error);
      return;
    }

    final entry = {
      'cue': _cueCtrl.text.trim(),
      'routine': _routineCtrl.text.trim(),
      'lastCompletedDate': '',
    };

    await _habitBox.add(jsonEncode(entry));
    _cueCtrl.clear();
    _routineCtrl.clear();
    _loadHabits();

    if (mounted) {
      showSoftToast(context, message: context.t('Đã thêm Habit Stacking mới!'), tone: SoftToastTone.success);
    }
  }

  Future<void> _delete(dynamic key) async {
    await _habitBox.delete(key);
    _loadHabits();
  }

  @override
  void dispose() {
    _cueCtrl.dispose();
    _routineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? const Color(0xFF0d1117) : RelaxColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Habit Stacking 🧱'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildIntroCard(),
                  const SizedBox(height: 20),
                  Text(
                    context.t('Thói quen chồng thói quen của bạn'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.appText),
                  ),
                  const SizedBox(height: 12),
                  ..._habits.map((h) => _buildHabitCard(h)),
                  const SizedBox(height: 24),
                  _buildAddForm(),
                ],
              ),
            ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RelaxColors.mint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RelaxColors.mint.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                context.t('Phương pháp Habit Stacking'),
                style: TextStyle(fontWeight: FontWeight.bold, color: context.appText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.t('Liên kết một thói quen tự nhiên có sẵn (ví dụ: ăn trưa) với một routine chăm sóc tinh thần mới. Giúp thói quen mới dễ bám rễ hơn mà không mất nhiều ý chí!'),
            style: TextStyle(color: context.appText, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> item) {
    final completed = item['completedToday'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? RelaxColors.mint.withValues(alpha: 0.04) : context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed ? RelaxColors.mint : context.fieldBorder,
          width: completed ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: completed,
            activeColor: RelaxColors.mint,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (_) => _toggleComplete(item),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: context.appText, fontSize: 14),
                children: [
                  TextSpan(text: '${context.t("Sau khi")} ', style: TextStyle(color: context.mutedText)),
                  TextSpan(text: item['cue'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' → ${context.t("mình sẽ")} ', style: TextStyle(color: context.mutedText)),
                  TextSpan(
                    text: item['routine'],
                    style: const TextStyle(fontWeight: FontWeight.bold, color: RelaxColors.violet),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _delete(item['key']),
            child: Icon(Icons.close, size: 18, color: context.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForm() {
    return Card(
      color: context.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('Thêm thói quen mới'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.appText),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cueCtrl,
              decoration: InputDecoration(
                labelText: context.t('Sau khi tôi... (Thói quen cũ)'),
                hintText: context.t('thức dậy, pha cafe, rửa mặt...'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _routineCtrl,
              decoration: InputDecoration(
                labelText: context.t('Tôi sẽ... (Routine mới)'),
                hintText: context.t('check-in 20s, thở 2 phút...'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _addCustom,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  context.t('Thêm thói quen'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RelaxColors.violet,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
