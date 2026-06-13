import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/smart_reminders.dart';
import '../../../core/theme.dart';

/// Card cài đặt nhắc nhở thông minh — toggle + chỉnh giờ.
class ReminderCard extends StatefulWidget {
  const ReminderCard({super.key});

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard> {
  Map<String, ({bool enabled, int hour, int minute, String title})> _reminders =
      {};
  bool _loading = true;

  static const _labels = {
    'morning_mood': 'Ghi cảm xúc buổi sáng',
    'afternoon_break': 'Nhắc nghỉ giải lao',
    'evening_journal': 'Nhật ký buổi tối',
    'breathing': 'Hít thở sâu',
  };

  static const _icons = {
    'morning_mood': Icons.wb_sunny_outlined,
    'afternoon_break': Icons.coffee_outlined,
    'evening_journal': Icons.nightlight_outlined,
    'breathing': Icons.air_outlined,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SmartReminders.instance.getAll();
    if (mounted) setState(() { _reminders = data; _loading = false; });
  }

  Future<void> _toggle(String key, bool value) async {
    if (value) {
      await SmartReminders.instance.enable(key);
    } else {
      await SmartReminders.instance.disable(key);
    }
    await _load();
  }

  Future<void> _pickTime(String key) async {
    final current = _reminders[key];
    if (current == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked != null) {
      await SmartReminders.instance
          .enable(key, hour: picked.hour, minute: picked.minute);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: RelaxColors.violet, strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        children: _reminders.entries.map((entry) {
          final key = entry.key;
          final r = entry.value;
          final label = _labels[key] ?? key;
          final icon = _icons[key] ?? Icons.notifications_outlined;
          final timeStr =
              '${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}';

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(icon, color: context.mutedText, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t(label),
                            style: TextStyle(
                              color: context.appText,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (r.enabled)
                            GestureDetector(
                              onTap: () => _pickTime(key),
                              child: Text(
                                timeStr,
                                style: const TextStyle(
                                  color: RelaxColors.violet,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: r.enabled,
                      activeTrackColor: RelaxColors.violet,
                      onChanged: (v) => _toggle(key, v),
                    ),
                  ],
                ),
              ),
              if (key != _reminders.keys.last)
                Divider(height: 1, color: context.fieldBorder, indent: 50),
            ],
          );
        }).toList(),
      ),
    );
  }
}
