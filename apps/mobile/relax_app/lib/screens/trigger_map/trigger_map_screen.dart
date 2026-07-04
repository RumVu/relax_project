import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';

/// Trigger Map — map stress triggers to recommended relief activities.
class TriggerMapScreen extends StatefulWidget {
  const TriggerMapScreen({super.key});

  @override
  State<TriggerMapScreen> createState() => _TriggerMapScreenState();
}

class _TriggerMapScreenState extends State<TriggerMapScreen> {
  static const _boxName = 'trigger_map';
  List<_TriggerEntry> _entries = [];
  bool _loading = true;

  static const _defaultTriggers = <_TriggerEntry>[
    _TriggerEntry(
      trigger: 'Áp lực công việc',
      emoji: '💼',
      activities: ['breathing', 'sounds'],
    ),
    _TriggerEntry(
      trigger: 'Mất ngủ',
      emoji: '😴',
      activities: ['sleep', 'meditation'],
    ),
    _TriggerEntry(
      trigger: 'Lo lắng',
      emoji: '😰',
      activities: ['breathing', 'companion-chat'],
    ),
    _TriggerEntry(
      trigger: 'Cô đơn',
      emoji: '🥺',
      activities: ['journal', 'buddies'],
    ),
    _TriggerEntry(
      trigger: 'Tức giận',
      emoji: '😤',
      activities: ['breathing', 'break'],
    ),
    _TriggerEntry(
      trigger: 'Mệt mỏi',
      emoji: '😮‍💨',
      activities: ['sounds', 'sleep'],
    ),
  ];

  static const _activityInfo = <String, ({String label, String emoji, String route})>{
    'breathing': (label: 'Hít thở', emoji: '🌬️', route: '/breathing'),
    'sounds': (label: 'Âm thanh', emoji: '🎵', route: '/sounds'),
    'meditation': (label: 'Thiền', emoji: '🧘', route: '/meditation'),
    'journal': (label: 'Nhật ký', emoji: '✍️', route: '/journal'),
    'sleep': (label: 'Ngủ', emoji: '🌙', route: '/sleep'),
    'companion-chat': (label: 'Chat', emoji: '🤖', route: '/companion-chat'),
    'buddies': (label: 'Bạn bè', emoji: '👥', route: '/buddies'),
    'break': (label: 'Nghỉ', emoji: '☕', route: '/break'),
    'calm-now': (label: 'Calm', emoji: '🌊', route: '/calm-now'),
    'podcast': (label: 'Podcast', emoji: '🎙️', route: '/podcast'),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox(_boxName);
    final saved = box.get('entries') as List?;
    if (saved != null && saved.isNotEmpty) {
      _entries = saved
          .whereType<Map>()
          .map((m) => _TriggerEntry(
                trigger: m['trigger'] as String? ?? '',
                emoji: m['emoji'] as String? ?? '❓',
                activities: (m['activities'] as List?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [],
              ))
          .toList();
    } else {
      _entries = List.of(_defaultTriggers);
      await _save();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final box = await Hive.openBox(_boxName);
    await box.put(
      'entries',
      _entries
          .map((e) => {
                'trigger': e.trigger,
                'emoji': e.emoji,
                'activities': e.activities,
              })
          .toList(),
    );
  }

  void _addTrigger() {
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: '😟');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t('Thêm trigger mới')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: context.t('Ví dụ: Deadline gấp'),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emojiCtrl,
              decoration: InputDecoration(
                labelText: 'Emoji',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t('Hủy')),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              setState(() {
                _entries.add(_TriggerEntry(
                  trigger: name,
                  emoji: emojiCtrl.text.trim().isEmpty
                      ? '😟'
                      : emojiCtrl.text.trim(),
                  activities: ['breathing'],
                ));
              });
              _save();
            },
            child: Text(context.t('Thêm')),
          ),
        ],
      ),
    );
  }

  void _editActivities(int index) {
    final entry = _entries[index];
    final selected = Set<String>.from(entry.activities);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: ctx.fieldBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${entry.emoji} ${entry.trigger}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ctx.appText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.t('Chọn hoạt động giúp bạn khi gặp trigger này:'),
                style: TextStyle(color: ctx.mutedText, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _activityInfo.entries.map((act) {
                  final isSelected = selected.contains(act.key);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setSheetState(() {
                        if (isSelected) {
                          selected.remove(act.key);
                        } else {
                          selected.add(act.key);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? RelaxColors.violet.withValues(alpha: 0.12)
                            : ctx.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? RelaxColors.violet
                              : ctx.fieldBorder,
                        ),
                      ),
                      child: Text(
                        '${act.value.emoji} ${ctx.t(act.value.label)}',
                        style: TextStyle(
                          color: isSelected
                              ? RelaxColors.violet
                              : ctx.appText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RelaxColors.violet,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _entries[index] = _TriggerEntry(
                        trigger: entry.trigger,
                        emoji: entry.emoji,
                        activities: selected.toList(),
                      );
                    });
                    _save();
                  },
                  child: Text(
                    context.t('Lưu'),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          context.t('Bản đồ Trigger'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: context.appText),
            onPressed: _addTrigger,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: RelaxColors.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: RelaxColors.violet.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Text('🗺️', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.t(
                              'Nhận diện trigger stress và ánh xạ đến hoạt động giúp bạn cảm thấy tốt hơn.'),
                          style: TextStyle(
                            color: context.mutedText,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_entries.length, (i) {
                  final e = _entries[i];
                  return _TriggerCard(
                    entry: e,
                    activityInfo: _activityInfo,
                    onEdit: () => _editActivities(i),
                    onNavigate: (route) => context.push(route),
                    onDelete: () {
                      setState(() => _entries.removeAt(i));
                      _save();
                    },
                  );
                }),
              ],
            ),
    );
  }
}

class _TriggerEntry {
  const _TriggerEntry({
    required this.trigger,
    required this.emoji,
    required this.activities,
  });
  final String trigger;
  final String emoji;
  final List<String> activities;
}

class _TriggerCard extends StatelessWidget {
  const _TriggerCard({
    required this.entry,
    required this.activityInfo,
    required this.onEdit,
    required this.onNavigate,
    required this.onDelete,
  });
  final _TriggerEntry entry;
  final Map<String, ({String label, String emoji, String route})> activityInfo;
  final VoidCallback onEdit;
  final void Function(String route) onNavigate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(entry.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.trigger,
                  style: TextStyle(
                    color: context.appText,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Icon(Icons.edit_outlined,
                    color: context.mutedText, size: 18),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close,
                    color: context.mutedText, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: entry.activities.map((key) {
              final info = activityInfo[key];
              if (info == null) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onNavigate(info.route);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: RelaxColors.violet.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${info.emoji} ${context.t(info.label)}',
                    style: const TextStyle(
                      color: RelaxColors.violet,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
