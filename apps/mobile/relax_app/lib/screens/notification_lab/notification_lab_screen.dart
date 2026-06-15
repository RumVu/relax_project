import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/local_notifications.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

class _ReminderSlot {
  final String key;
  final String label;
  final String emoji;
  final int defaultHour;
  final int defaultMinute;
  final String defaultMessage;

  const _ReminderSlot({
    required this.key,
    required this.label,
    required this.emoji,
    required this.defaultHour,
    required this.defaultMinute,
    required this.defaultMessage,
  });
}

const _slots = [
  _ReminderSlot(
    key: 'morning',
    label: 'Buổi sáng',
    emoji: '🌅',
    defaultHour: 8,
    defaultMinute: 0,
    defaultMessage: 'Chào buổi sáng! Hôm nay bạn cảm thấy thế nào?',
  ),
  _ReminderSlot(
    key: 'midday',
    label: 'Giữa trưa',
    emoji: '☀️',
    defaultHour: 12,
    defaultMinute: 30,
    defaultMessage: 'Nghỉ trưa nhé! Hít thở sâu 3 lần rồi tiếp tục.',
  ),
  _ReminderSlot(
    key: 'afternoon',
    label: 'Chiều',
    emoji: '🌤️',
    defaultHour: 15,
    defaultMinute: 0,
    defaultMessage: 'Buổi chiều rồi — cập nhật cảm xúc nhé!',
  ),
  _ReminderSlot(
    key: 'evening',
    label: 'Buổi tối',
    emoji: '🌙',
    defaultHour: 21,
    defaultMinute: 0,
    defaultMessage: 'Kết thúc ngày — viết nhật ký hoặc nghe nhạc thư giãn nhé.',
  ),
  _ReminderSlot(
    key: 'bedtime',
    label: 'Trước khi ngủ',
    emoji: '😴',
    defaultHour: 23,
    defaultMinute: 0,
    defaultMessage: 'Đến giờ ngủ! Thử bài thiền ngắn để ngủ ngon hơn.',
  ),
];

const _toneOptions = [
  {'key': 'gentle', 'label': 'Nhẹ nhàng', 'emoji': '🔔'},
  {'key': 'cheer', 'label': 'Vui tươi', 'emoji': '🎵'},
  {'key': 'calm', 'label': 'Bình tĩnh', 'emoji': '🎶'},
  {'key': 'urgent', 'label': 'Nhắc nhở', 'emoji': '⏰'},
];

class NotificationLabScreen extends StatefulWidget {
  const NotificationLabScreen({super.key});

  @override
  State<NotificationLabScreen> createState() => _NotificationLabScreenState();
}

class _NotificationLabScreenState extends State<NotificationLabScreen> {
  late Box _box;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox('notification_lab');
    if (mounted) setState(() => _ready = true);
  }

  bool _isEnabled(String key) => _box.get('${key}_enabled', defaultValue: false);

  int _getHour(String key, int def) => _box.get('${key}_hour', defaultValue: def);

  int _getMinute(String key, int def) => _box.get('${key}_minute', defaultValue: def);

  String _getMessage(String key, String def) =>
      _box.get('${key}_message', defaultValue: def);

  String _getTone() => _box.get('tone', defaultValue: 'gentle');

  Future<void> _toggle(String key, bool value, _ReminderSlot slot) async {
    await _box.put('${key}_enabled', value);
    if (value) {
      final hour = _getHour(key, slot.defaultHour);
      final minute = _getMinute(key, slot.defaultMinute);
      final message = _getMessage(key, slot.defaultMessage);
      await LocalNotifications.scheduleDaily(
        id: _slotId(key),
        title: 'Thi Ái',
        body: message,
        hour: hour,
        minute: minute,
      );
    } else {
      await LocalNotifications.cancel(_slotId(key));
    }
    setState(() {});
  }

  Future<void> _pickTime(String key, _ReminderSlot slot) async {
    final current = TimeOfDay(
      hour: _getHour(key, slot.defaultHour),
      minute: _getMinute(key, slot.defaultMinute),
    );
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    await _box.put('${key}_hour', picked.hour);
    await _box.put('${key}_minute', picked.minute);
    if (_isEnabled(key)) {
      await LocalNotifications.scheduleDaily(
        id: _slotId(key),
        title: 'Thi Ái',
        body: _getMessage(key, slot.defaultMessage),
        hour: picked.hour,
        minute: picked.minute,
      );
    }
    setState(() {});
  }

  Future<void> _editMessage(String key, _ReminderSlot slot) async {
    final controller =
        TextEditingController(text: _getMessage(key, slot.defaultMessage));
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.t('Tuỳ chỉnh tin nhắn')),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: ctx.t('Nội dung nhắc nhở...'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.t('Huỷ')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(ctx.t('Lưu')),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _box.put('${key}_message', result);
      if (_isEnabled(key)) {
        await LocalNotifications.scheduleDaily(
          id: _slotId(key),
          title: 'Thi Ái',
          body: result,
          hour: _getHour(key, slot.defaultHour),
          minute: _getMinute(key, slot.defaultMinute),
        );
      }
      setState(() {});
    }
  }

  Future<void> _setTone(String tone) async {
    await _box.put('tone', tone);
    setState(() {});
  }

  Future<void> _testNotification() async {
    HapticFeedback.mediumImpact();
    await LocalNotifications.showInstant(
      title: 'Thi Ái',
      body: 'Đây là thông báo thử nghiệm! 🎉',
    );
    if (mounted) {
      showSoftToast(context,
          message: context.t('Đã gửi thông báo thử!'),
          tone: SoftToastTone.success);
    }
  }

  int _slotId(String key) {
    switch (key) {
      case 'morning': return 100;
      case 'midday': return 101;
      case 'afternoon': return 102;
      case 'evening': return 103;
      case 'bedtime': return 104;
      default: return 199;
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
          context.t('Phòng thí nghiệm thông báo'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: !_ready
          ? const Center(
              child: CircularProgressIndicator(color: RelaxColors.violet))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text('🔔', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(
                        context.t('Nhắc nhở thông minh'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.t(
                            'Tuỳ chỉnh thời gian, nội dung và phong cách nhắc nhở'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tone selector
                Text(
                  context.t('Phong cách thông báo'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: context.appText,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _toneOptions.map((t) {
                    final selected = _getTone() == t['key'];
                    return GestureDetector(
                      onTap: () => _setTone(t['key']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? RelaxColors.violet.withValues(alpha: 0.15)
                              : context.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? RelaxColors.violet
                                : context.fieldBorder,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t['emoji']!,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              context.t(t['label']!),
                              style: TextStyle(
                                color: selected
                                    ? RelaxColors.violet
                                    : context.appText,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Reminder slots
                Text(
                  context.t('Lịch nhắc nhở'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: context.appText,
                  ),
                ),
                const SizedBox(height: 10),
                ..._slots.map((slot) => _buildSlotCard(context, slot)),

                const SizedBox(height: 16),

                // Test button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _testNotification,
                    icon: const Icon(Icons.notifications_active, size: 18),
                    label: Text(context.t('Gửi thông báo thử')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RelaxColors.violet,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSlotCard(BuildContext context, _ReminderSlot slot) {
    final enabled = _isEnabled(slot.key);
    final hour = _getHour(slot.key, slot.defaultHour);
    final minute = _getMinute(slot.key, slot.defaultMinute);
    final message = _getMessage(slot.key, slot.defaultMessage);
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? RelaxColors.violet.withValues(alpha: 0.3)
              : context.fieldBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(slot.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t(slot.label),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: context.appText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _pickTime(slot.key, slot),
                      child: Text(
                        timeStr,
                        style: TextStyle(
                          color: RelaxColors.violet,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (v) => _toggle(slot.key, v, slot),
                activeColor: RelaxColors.violet,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _editMessage(slot.key, slot),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: context.appText.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 14, color: context.mutedText),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
