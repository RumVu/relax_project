import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';
import '../../../core/api_client.dart';
import '../../../core/locale_controller.dart';
import '../../../core/secure_storage.dart';
import '../../../core/local_notifications.dart';
import '../../../widgets/soft_toast.dart';

/// Khung giờ nhận nhắc nhở — chip 17:00 / 19:00 / 21:00 + "Mở rộng" + âm báo,
/// dựng theo mockup, đồng bộ với backend thông qua /reminders.
class NotificationCard extends StatefulWidget {
  const NotificationCard({super.key});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  final _times = ['17:00', '19:00', '21:00'];
  String _selected = '21:00';
  String? _reminderId;
  bool _loading = false;
  String _selectedSound = 'Tiếng mèo con kêu 🐱';

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _loadSoundPreference();
  }

  Future<void> _loadSoundPreference() async {
    try {
      final savedSound = await secureStorage.read(key: 'relax_reminder_sound');
      if (savedSound != null && mounted) {
        setState(() {
          _selectedSound = savedSound;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadReminders() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final res = await RelaxApi.instance.get('/reminders/me');
      if (res.statusCode == 200 && res.data is Map) {
        final items = res.data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          // Tìm nhắc nhở đầu tiên có loại JOURNAL (Nhắc nhở viết nhật ký / check-in)
          final journalReminder = items.firstWhere(
            (item) => item is Map && item['type'] == 'JOURNAL',
            orElse: () => null,
          );
          if (journalReminder != null) {
            _reminderId = journalReminder['id'] as String?;
            final scheduledAtStr = journalReminder['scheduledAt'] as String?;
            if (scheduledAtStr != null) {
              final date = DateTime.parse(scheduledAtStr).toLocal();
              final timeStr =
                  "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
              if (mounted) {
                setState(() {
                  _selected = timeStr;
                });
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Load reminders failed: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveReminder(int hour, int minute) async {
    if (!mounted) return;
    final localTitle = context.t('Nhắc nhở tự phản chiếu');
    final localBody = context.t('Viết vài dòng cuối ngày để giữ tâm trạng cân bằng nhé.');
    setState(() => _loading = true);
    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      final repeatRule = '$minute $hour * * *';

      if (_reminderId != null) {
        // Cập nhật nhắc nhở cũ
        final res = await RelaxApi.instance.patch('/reminders/$_reminderId', body: {
          'scheduledAt': scheduledDate.toUtc().toIso8601String(),
          'repeatRule': repeatRule,
        });
        if (res.statusCode == 200 || res.statusCode == 201) {
          if (mounted) {
            showSoftToast(context,
                message: context.t('Đã cập nhật giờ nhắc nhở thành công!'),
                tone: SoftToastTone.success);
          }
        } else {
          if (mounted) {
            showSoftToast(context,
                message: context.t('Cập nhật giờ nhắc nhở thất bại.'),
                tone: SoftToastTone.error);
          }
        }
      } else {
        // Tạo nhắc nhở mới
        final res = await RelaxApi.instance.post('/reminders/me', body: {
          'title': 'Nhắc nhở tự phản chiếu',
          'message': 'Viết vài dòng cuối ngày để giữ tâm trạng cân bằng nhé.',
          'type': 'JOURNAL',
          'scheduledAt': scheduledDate.toUtc().toIso8601String(),
          'repeatRule': repeatRule,
          'isActive': true,
        });
        if (res.statusCode == 200 || res.statusCode == 201) {
          if (mounted) {
            showSoftToast(context,
                message: context.t('Đã cài đặt giờ nhắc nhở thành công!'),
                tone: SoftToastTone.success);
            if (res.data is Map) {
              _reminderId = res.data['id'] as String?;
            }
          }
        } else {
          if (mounted) {
            showSoftToast(context,
                message: context.t('Cài đặt giờ nhắc nhở thất bại.'),
                tone: SoftToastTone.error);
          }
        }
      }
      // Lên lịch nhắc nhở cục bộ offline
      await LocalNotifications.requestPermissions();
      await LocalNotifications.scheduleDaily(
        id: 1,
        title: localTitle,
        body: localBody,
        hour: hour,
        minute: minute,
      );

      await _loadReminders();
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: 'Lỗi: $e', tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _selectCustomTime() async {
    var initialHour = 21;
    var initialMinute = 0;
    if (_selected.contains(':')) {
      final parts = _selected.split(':');
      initialHour = int.tryParse(parts[0]) ?? 21;
      initialMinute = int.tryParse(parts[1]) ?? 0;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: RelaxColors.violet,
              onPrimary: Colors.white,
              surface: context.surface,
              onSurface: context.appText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: RelaxColors.violet,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeStr =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      setState(() {
        _selected = timeStr;
      });
      await _saveReminder(picked.hour, picked.minute);
    }
  }

  void _showSoundSelectorSheet() {
    final sounds = [
      {'name': 'Tiếng mèo con kêu 🐱', 'key': 'cat_meow'},
      {'name': 'Chuông gió mùa xuân 🎐', 'key': 'wind_chimes'},
      {'name': 'Tiếng mưa rơi tí tách 🌧️', 'key': 'rain'},
      {'name': 'Sóng biển rì rào 🌊', 'key': 'ocean'},
      {'name': 'Tiếng chuông thiền 🔔', 'key': 'bell'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: sheetCtx.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: sheetCtx.fieldBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.t('Chọn âm báo nhắc nhở 🔔'),
              style: TextStyle(
                color: sheetCtx.appText,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sounds.length,
                itemBuilder: (ctx, index) {
                  final s = sounds[index];
                  final name = s['name']!;
                  final isSelected = _selectedSound == name;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      context.t(name),
                      style: TextStyle(
                        color: sheetCtx.appText,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: RelaxColors.violet)
                        : null,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedSound = name;
                      });
                      try {
                        await secureStorage.write(
                          key: 'relax_reminder_sound',
                          value: name,
                        );
                      } catch (_) {}
                      if (!mounted) return;
                      showSoftToast(context,
                          message: context.t('Đã thay đổi âm báo: {sound}', {'sound': context.t(name)}),
                          tone: SoftToastTone.success);

                      if (!sheetCtx.mounted) return;
                      Navigator.pop(sheetCtx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('Chọn khung giờ muốn nhận thông báo nhé ~'),
            style: TextStyle(color: context.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ..._times.map((t) {
                final sel = _selected == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: _loading
                        ? null
                        : () async {
                            if (sel) return;
                            final parts = t.split(':');
                            final hour = int.parse(parts[0]);
                            final minute = int.parse(parts[1]);
                            setState(() => _selected = t);
                            await _saveReminder(hour, minute);
                          },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? RelaxColors.violet : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? RelaxColors.violet : context.fieldBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            t,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: sel ? Colors.white : context.appText,
                            ),
                          ),
                          if (sel) ...[
                            const SizedBox(height: 4),
                            const Icon(Icons.check_circle,
                                size: 14, color: Colors.white),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
              (() {
                final isPresetSelected = _times.contains(_selected);
                final isCustomSelected = !isPresetSelected && _selected.isNotEmpty;
                return Expanded(
                  child: GestureDetector(
                    onTap: _loading ? null : _selectCustomTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isCustomSelected ? RelaxColors.violet : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCustomSelected ? RelaxColors.violet : context.fieldBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (isCustomSelected) ...[
                            Text(
                              _selected,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(Icons.check_circle,
                                size: 14, color: Colors.white),
                          ] else ...[
                            Icon(Icons.add, color: context.mutedText, size: 18),
                            Text(
                              context.t('Mở rộng'),
                              style: TextStyle(
                                  fontSize: 11, color: context.mutedText),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              })(),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _showSoundSelectorSheet();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volume_up_outlined,
                      color: RelaxColors.violet, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.t('Âm báo: {sound}', {'sound': context.t(_selectedSound)}),
                      style: TextStyle(
                        color: context.appText,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: context.mutedText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
