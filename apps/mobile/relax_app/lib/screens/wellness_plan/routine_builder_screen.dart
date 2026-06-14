import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

class RoutineBuilderScreen extends StatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  State<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends State<RoutineBuilderScreen> {
  late Box<String> _box;
  bool _loading = true;
  List<Map<String, dynamic>> _routines = [];

  final List<Map<String, dynamic>> _presets = [
    {
      'id': 'morning_reset',
      'title': 'Morning Reset',
      'emoji': '🌤️',
      'description': 'Đón ngày mới với quote ý nghĩa, thở sâu và kiểm tra cảm xúc.',
      'steps': [
        {'type': 'quote', 'title': 'Đọc danh ngôn truyền cảm hứng'},
        {'type': 'breathing', 'title': 'Hít thở điều hoà nhịp sinh học'},
        {'type': 'checkin', 'title': 'Ghi nhận cảm xúc buổi sáng'}
      ],
      'isPreset': true
    },
    {
      'id': 'lunch_break',
      'title': 'Lunch Break',
      'emoji': '🥗',
      'description': 'Nạp lại năng lượng giữa ngày với âm thanh thiên nhiên.',
      'steps': [
        {'type': 'soundscape', 'title': 'Lắng nghe âm thanh thư giãn'},
        {'type': 'journal', 'title': 'Ghi chép suy ngẫm nhanh'}
      ],
      'isPreset': true
    },
    {
      'id': 'after_work',
      'title': 'After Work',
      'emoji': '🌆',
      'description': 'Rũ bỏ mệt mỏi công sở, chuyển trạng thái nghỉ ngơi.',
      'steps': [
        {'type': 'breathing', 'title': 'Thở xả stress công việc'},
        {'type': 'journal', 'title': 'Viết nhật ký trút bỏ lo âu'}
      ],
      'isPreset': true
    },
    {
      'id': 'sleep_wind_down',
      'title': 'Sleep Wind-down',
      'emoji': '🌙',
      'description': 'Nhạc êm dịu, hẹn giờ tắt và ghi nhận lòng biết ơn trước ngủ.',
      'steps': [
        {'type': 'soundscape', 'title': 'Mở tiếng mưa rơi + Hẹn giờ ngủ'},
        {'type': 'journal', 'title': 'Viết 3 điều biết ơn hôm nay'}
      ],
      'isPreset': true
    },
    {
      'id': 'emergency_calm',
      'title': 'Emergency Calm',
      'emoji': '🚨',
      'description': 'Cấp cứu tâm trạng khi gặp cơn hoảng loạn hoặc stress quá tải.',
      'steps': [
        {'type': 'grounding', 'title': 'Bài tập chú tâm 5-4-3-2-1'},
        {'type': 'breathing', 'title': 'Hít thở bong bóng xoa dịu'},
        {'type': 'checkin', 'title': 'Đánh giá mức cải thiện tâm trạng'}
      ],
      'isPreset': true
    }
  ];

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _box = await Hive.openBox<String>('wellness_routines');
    _loadRoutines();
  }

  void _loadRoutines() {
    final List<Map<String, dynamic>> loaded = [];
    // Thêm các presets trước
    loaded.addAll(_presets);

    // Thêm các custom routines từ Hive
    for (final item in _box.values) {
      try {
        final map = Map<String, dynamic>.from(jsonDecode(item));
        map['isPreset'] = false;
        loaded.add(map);
      } catch (_) {}
    }

    setState(() {
      _routines = loaded;
      _loading = false;
    });
  }

  Future<void> _deleteRoutine(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t('Xoá routine này?')),
        content: Text(context.t('Bạn có chắc muốn xoá thói quen này?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t('Hủy')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RelaxColors.coral),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.t('Xoá')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _box.delete(id);
      _loadRoutines();
      if (mounted) {
        showSoftToast(
          context,
          message: context.t('Đã xoá thói quen'),
          tone: SoftToastTone.success,
        );
      }
    }
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String emoji = '🧘';
    final List<Map<String, String>> selectedSteps = [];

    final stepTypes = [
      {'type': 'quote', 'name': 'Đọc danh ngôn', 'icon': '💬'},
      {'type': 'breathing', 'name': 'Tập hít thở', 'icon': '🌬️'},
      {'type': 'checkin', 'name': 'Check-in cảm xúc', 'icon': '📊'},
      {'type': 'soundscape', 'name': 'Âm thanh tự nhiên', 'icon': '🎵'},
      {'type': 'journal', 'name': 'Viết nhật ký', 'icon': '✍️'},
      {'type': 'grounding', 'name': 'Tập trung Grounding', 'icon': '⚓'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.t('Tạo Routine mới'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: context.t('Tên Routine'),
                  hintText: 'Ví dụ: Morning Coffee Breathe',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: context.t('Mô tả'),
                  hintText: 'Nhắc nhở nhẹ nhàng cho bản thân',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.t('Chọn icon/emoji:'),
                style: TextStyle(color: context.mutedText, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['🧘', '🌤️', '🥗', '🌆', '🌙', '🚨', '☕', '⚡'].map((em) {
                  final sel = emoji == em;
                  return GestureDetector(
                    onTap: () => setModalState(() => emoji = em),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: sel ? RelaxColors.violet.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? RelaxColors.violet : Colors.transparent, width: 1.5),
                      ),
                      child: Text(em, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                context.t('Các bước thực hiện (Chọn tuần tự):'),
                style: TextStyle(color: context.mutedText, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stepTypes.map((st) {
                  return ChoiceChip(
                    label: Text('${st['icon']} ${st['name']}'),
                    selected: false,
                    onSelected: (_) {
                      setModalState(() {
                        selectedSteps.add({
                          'type': st['type']!,
                          'title': st['name']!,
                        });
                      });
                    },
                  );
                }).toList(),
              ),
              if (selectedSteps.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  context.t('Trình tự các bước:'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: context.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: selectedSteps.length,
                    itemBuilder: (c, idx) {
                      final s = selectedSteps[idx];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 12,
                          backgroundColor: RelaxColors.violet,
                          child: Text(
                            '${idx + 1}',
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(context.t(s['title']!)),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: RelaxColors.coral, size: 18),
                          onPressed: () {
                            setModalState(() {
                              selectedSteps.removeAt(idx);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    if (selectedSteps.isEmpty) {
                      showSoftToast(
                        ctx,
                        message: context.t('Vui lòng chọn ít nhất 1 bước'),
                        tone: SoftToastTone.error,
                      );
                      return;
                    }
                    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                    final newRoutine = {
                      'id': id,
                      'title': titleCtrl.text.trim(),
                      'emoji': emoji,
                      'description': descCtrl.text.trim(),
                      'steps': selectedSteps,
                    };
                    await _box.put(id, jsonEncode(newRoutine));
                    Navigator.pop(ctx);
                    _loadRoutines();
                    if (mounted) {
                      showSoftToast(
                        context,
                        message: context.t('Đã lưu routine mới! 🌿'),
                        tone: SoftToastTone.success,
                      );
                    }
                  },
                  child: Text(context.t('Lưu thói quen')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Routine Builder'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: context.appText),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                Text(
                  context.t('Thiết lập thói quen lành mạnh'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  context.t('Chạy các chuỗi hoạt động giúp bạn lấy lại thăng bằng nhanh nhất.'),
                  style: TextStyle(color: context.mutedText, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ..._routines.map((r) {
                  final isPreset = r['isPreset'] == true;
                  final steps = r['steps'] as List;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(r['emoji'] ?? '🧘', style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r['title'] ?? '',
                                      style: TextStyle(
                                        color: context.appText,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (isPreset)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        margin: const EdgeInsets.only(top: 2),
                                        decoration: BoxDecoration(
                                          color: RelaxColors.violet.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          context.t('Mẫu sẵn có'),
                                          style: const TextStyle(fontSize: 9, color: RelaxColors.violet, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (!isPreset)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: RelaxColors.coral, size: 20),
                                  onPressed: () => _deleteRoutine(r['id']),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.t(r['description'] ?? ''),
                            style: TextStyle(color: context.mutedText, fontSize: 12, height: 1.3),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: steps.map((s) {
                              String stepIcon = '🔹';
                              final type = s['type'];
                              if (type == 'quote') stepIcon = '💬';
                              if (type == 'breathing') stepIcon = '🌬️';
                              if (type == 'checkin') stepIcon = '📊';
                              if (type == 'soundscape') stepIcon = '🎵';
                              if (type == 'journal') stepIcon = '✍️';
                              if (type == 'grounding') stepIcon = '⚓';
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.surfaceAlt,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: context.fieldBorder),
                                ),
                                child: Text(
                                  '$stepIcon ${context.t(s['title'] ?? '')}',
                                  style: TextStyle(color: context.appText, fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                context.push('/routine-run', extra: r);
                              },
                              child: Text(context.t('Bắt đầu chuỗi')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
