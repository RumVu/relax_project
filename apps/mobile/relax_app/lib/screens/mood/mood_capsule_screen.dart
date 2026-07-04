import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

class MoodCapsuleScreen extends StatefulWidget {
  const MoodCapsuleScreen({super.key});

  @override
  State<MoodCapsuleScreen> createState() => _MoodCapsuleScreenState();
}

class _MoodCapsuleScreenState extends State<MoodCapsuleScreen> {
  late Box<String> _capsuleBox;
  bool _loading = true;
  List<Map<String, dynamic>> _capsules = [];

  // Form states
  String _selectedMood = 'CALM';
  final _noteCtrl = TextEditingController();
  String _activity = 'Đang nghỉ ngơi';
  String _location = 'Ở nhà';
  final String _sound = 'Rain & Thunder';
  final String _quote = 'Hôm nay là một ngày tốt lành để hít thở sâu.';

  final List<(String, String, Color)> _moods = [
    ('HAPPY', '😊', RelaxColors.mint),
    ('CALM', '😌', const Color(0xFF10B981)),
    ('STRESSED', '😫', RelaxColors.plum),
    ('ANXIOUS', '😰', RelaxColors.violet),
    ('SAD', '😢', const Color(0xFF3B82F6)),
    ('TIRED', '🥱', const Color(0xFF6B7280)),
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _capsuleBox = await Hive.openBox<String>('mood_capsules');
    _loadCapsules();
  }

  void _loadCapsules() {
    final List<Map<String, dynamic>> list = [];
    for (var key in _capsuleBox.keys) {
      final val = _capsuleBox.get(key);
      if (val != null) {
        try {
          final decoded = jsonDecode(val) as Map<String, dynamic>;
          list.add({'key': key, ...decoded});
        } catch (_) {}
      }
    }
    list.sort((a, b) => (b['createdAt'] as String? ?? '').compareTo(a['createdAt'] as String? ?? ''));
    setState(() {
      _capsules = list;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_noteCtrl.text.trim().isEmpty) {
      showSoftToast(context, message: context.t('Vui lòng viết vài dòng cảm nhận'), tone: SoftToastTone.error);
      return;
    }

    final entry = {
      'mood': _selectedMood,
      'note': _noteCtrl.text.trim(),
      'activity': _activity,
      'location': _location,
      'sound': _sound,
      'quote': _quote,
      'createdAt': DateTime.now().toIso8601String(),
    };

    HapticFeedback.mediumImpact();
    await _capsuleBox.add(jsonEncode(entry));
    _noteCtrl.clear();
    _loadCapsules();

    if (mounted) {
      showSoftToast(context, message: context.t('Khoảnh khắc đã được cất giữ 🔒'), tone: SoftToastTone.success);
    }
  }

  Future<void> _delete(dynamic key) async {
    await _capsuleBox.delete(key);
    _loadCapsules();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
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
          context.t('Mood Capsule 🫙'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  _buildIntroCard(),
                  const SizedBox(height: 20),
                  _buildCreatorCard(),
                  const SizedBox(height: 24),
                  if (_capsules.isNotEmpty) ...[
                    Text(
                      context.t('Timeline Hộp ký ức'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.appText),
                    ),
                    const SizedBox(height: 12),
                    ..._capsules.map((c) => _buildCapsuleCard(c)),
                  ]
                ],
              ),
            ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RelaxColors.plum.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RelaxColors.plum.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Text('🫙', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.t('Hộp ký ức giúp bạn gom tất cả các yếu tố giác quan (nhạc đang nghe, quote đang đọc, note cảm xúc) thành một viên nang thời gian đẹp đẽ.'),
              style: TextStyle(color: context.appText, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorCard() {
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
              context.t('Đóng gói hộp ký ức hôm nay'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.appText),
            ),
            const SizedBox(height: 16),
            // Mood Selector
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _moods.length,
                itemBuilder: (ctx, idx) {
                  final m = _moods[idx];
                  final selected = _selectedMood == m.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = m.$1),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: selected ? m.$3.withValues(alpha: 0.15) : context.fieldBorder.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? m.$3 : context.fieldBorder, width: selected ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Text(m.$2, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            context.t(m.$1),
                            style: TextStyle(
                              color: selected ? m.$3 : context.appText,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: context.t('Đôi dòng cảm nhận hoặc khoảnh khắc lúc này...'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _activity,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: context.t('Hoạt động')),
                    items: ['Đang nghỉ ngơi', 'Làm việc', 'Đi bộ', 'Chuẩn bị ngủ']
                        .map((a) => DropdownMenuItem(value: a, child: Text(context.t(a), overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _activity = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _location,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: context.t('Địa điểm')),
                    items: ['Ở nhà', 'Công ty', 'Quán cafe', 'Ngoài trời']
                        .map((l) => DropdownMenuItem(value: l, child: Text(context.t(l), overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _location = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.archive_outlined, color: Colors.white),
                label: Text(
                  context.t('Cất giữ hộp ký ức'),
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

  Widget _buildCapsuleCard(Map<String, dynamic> item) {
    final date = DateTime.tryParse(item['createdAt'] ?? '')?.toLocal();
    final dateStr = date != null ? '${date.day}/${date.month}/${date.year}' : '';
    final moodTuple = _moods.firstWhere((m) => m.$1 == item['mood'], orElse: () => ('NEUTRAL', '😌', Colors.grey));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(moodTuple.$2, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    context.t(item['mood'] ?? ''),
                    style: TextStyle(fontWeight: FontWeight.bold, color: moodTuple.$3, fontSize: 15),
                  )
                ],
              ),
              Row(
                children: [
                  Text(dateStr, style: TextStyle(color: context.mutedText, fontSize: 12)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _delete(item['key']),
                    child: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item['note'] ?? '',
            style: TextStyle(fontSize: 14, color: context.appText, height: 1.4),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMetaIcon(Icons.location_on_outlined, item['location'] ?? ''),
              _buildMetaIcon(Icons.directions_run_outlined, item['activity'] ?? ''),
              _buildMetaIcon(Icons.music_note_outlined, item['sound'] ?? ''),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('“', style: TextStyle(fontSize: 22, color: RelaxColors.violet, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item['quote'] ?? '',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: context.mutedText),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetaIcon(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: context.mutedText),
        const SizedBox(width: 4),
        Text(context.t(text), style: TextStyle(color: context.mutedText, fontSize: 11)),
      ],
    );
  }
}
