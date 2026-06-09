import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/auth_state.dart';
import '../core/theme.dart';
import '../core/api_client.dart';
import '../core/locale_controller.dart';
import '../core/theme_controller.dart';
import '../widgets/cat_mascot.dart';
import '../widgets/mood_line_chart.dart';
import '../widgets/soft_toast.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final user = auth.user;
    final name = (user?['name'] as String?) ?? 'Người dùng';
    final email = (user?['email'] as String?) ?? '';
    final avatar = user?['avatar'] as String?;
    final role = (user?['role'] as String?) ?? 'USER';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          context.t('Setup ✨'),
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            // Header có mascot như mockup.
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tùy chỉnh không gian của $name ~',
                    style: TextStyle(color: context.mutedText, fontSize: 13),
                  ),
                ),
                const CatMascot(size: 56, emoji: '😺', glow: false),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileHero(name: name, email: email, avatar: avatar, role: role),
            const SizedBox(height: 24),
            _SectionLabel(context.t('Thông báo')),
            const _NotificationCard(),
            const SizedBox(height: 24),
            _SectionLabel(context.t('Khám phá')),
            _Card(
              children: [
                _Row(
                  icon: Icons.insights_outlined,
                  title: context.t('Phân tích cảm xúc'),
                  subtitle: context.t('Biểu đồ & phân bố cảm xúc của bạn'),
                  onTap: () => context.push('/analytics'),
                ),
                const _Divider(),
                _Row(
                  icon: Icons.cloud_outlined,
                  title: context.t('Thời tiết'),
                  subtitle: context.t('Theo dõi thời tiết & dự báo'),
                  onTap: () => context.push('/weather'),
                ),
                const _Divider(),
                _Row(
                  icon: Icons.pets_outlined,
                  title: context.t('Linh thú'),
                  subtitle: context.t('Nuôi và tương tác với bạn đồng hành'),
                  onTap: () => context.push('/companion'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel(context.t('Thiết bị & vị trí')),
            _Card(
              children: [
                _Row(
                  icon: Icons.place_outlined,
                  title: context.t('Vị trí của bạn'),
                  subtitle:
                      context.t('Gợi ý thời tiết & địa điểm thư giãn gần bạn'),
                  onTap: () => context.push('/location'),
                ),
                const _Divider(),
                _Row(
                  icon: Icons.phone_iphone_outlined,
                  title: context.t('Thông tin thiết bị'),
                  subtitle: context.t('Model, hệ điều hành, phiên bản app'),
                  onTap: () => context.push('/device-info'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel(context.t('Quy định & sử dụng')),
            _Card(
              children: [
                _Row(
                  icon: Icons.description_outlined,
                  title: context.t('Điều khoản, bản quyền & giấy phép'),
                  subtitle: context.t('Đọc trước khi sử dụng'),
                  onTap: () => context.push('/legal'),
                ),
                const _Divider(),
                _Row(
                  icon: Icons.info_outline,
                  title: context.t('Giới thiệu'),
                  subtitle: context.t('Phiên bản 1.0.0'),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel(context.t('Thống kê tình trạng')),
            const _StatsCard(),
            const SizedBox(height: 24),
            _SectionLabel(context.t('Giao diện')),
            const _ThemeToggleCard(),
            const SizedBox(height: 12),
            const _AccentPickerCard(),
            const SizedBox(height: 24),
            _SectionLabel(context.t('Ngôn ngữ')),
            const _LanguagePickerCard(),
            const SizedBox(height: 24),
            _SectionLabel(context.t('Nạp thẻ / Nâng cấp')),
            (() {
              final auth = context.watch<AuthState>();
              final user = auth.user;
              final subs = user?['subscriptions'] as List?;
              final sub = (subs != null && subs.isNotEmpty) ? subs.first as Map? : null;
              final planName = (sub?['planName'] as String?) ?? 'FREE';
              final subStatus = (sub?['status'] as String?) ?? 'ACTIVE';
              final isPremium = planName.toUpperCase() != 'FREE' && subStatus.toUpperCase() == 'ACTIVE';

              return _Card(
                children: [
                  _Row(
                    icon: Icons.workspace_premium_outlined,
                    title: isPremium ? '${context.t('Gói của bạn')}: ${planName.toUpperCase().replaceAll('_', ' ')}' : context.t('Mở khóa tính năng nâng cao'),
                    subtitle: isPremium ? context.t('Cảm ơn bạn đã nâng cấp dịch vụ!') : context.t('Phân tích sâu, companion theo cung & con giáp'),
                    trailing: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isPremium ? RelaxColors.mint : RelaxColors.violet,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isPremium ? context.t('Chi tiết') : context.t('Nạp ngay'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () => context.push('/billing'),
                  ),
                ],
              );
            })(),
                  onTap: () => context.push('/billing'),
                ),
              ],
            ),
>>>>>>> main
            const SizedBox(height: 24),
            _SectionLabel(context.t('Tài khoản')),
            _Card(
              children: [
                _Row(
                  icon: Icons.delete_outline,
                  title: context.t('Xóa tài khoản'),
                  subtitle:
                      context.t('Xóa vĩnh viễn toàn bộ dữ liệu của bạn'),
                  trailing: const Icon(Icons.chevron_right,
                      color: RelaxColors.coral),
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _LogoutButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }



  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Relax',
      applicationVersion: '1.0.0',
      applicationLegalese:
          'Theo dõi cảm xúc, hít thở và nhật ký mỗi ngày — phần thưởng nhỏ cho người chịu khó chăm sóc bản thân.',
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final mode = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: const Text(
          'Chọn cách xóa:\n\n'
          '• Ẩn danh: giữ lại dữ liệu thống kê nhưng xóa thông tin cá nhân.\n'
          '• Xóa vĩnh viễn: xóa toàn bộ — không thể khôi phục.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'SOFT'),
            child: const Text('Ẩn danh'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RelaxColors.coral),
            onPressed: () => Navigator.pop(ctx, 'HARD'),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
    if (mode == null || !context.mounted) return;

    // Xác nhận lần nữa bằng mật khẩu (nếu tài khoản có mật khẩu).
    final passwordCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(mode == 'HARD' ? 'Xóa vĩnh viễn?' : 'Ẩn danh tài khoản?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mode == 'HARD'
                  ? 'Nhập mật khẩu để xác nhận. Tất cả dữ liệu sẽ bị xóa!'
                  : 'Nhập mật khẩu để xác nhận ẩn danh hóa tài khoản.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                hintText: 'Để trống nếu dùng Google Sign-In',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  mode == 'HARD' ? RelaxColors.coral : RelaxColors.violet,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // Gọi API DELETE /auth/me
    try {
      final body = <String, dynamic>{'mode': mode};
      final pw = passwordCtrl.text.trim();
      if (pw.isNotEmpty) body['password'] = pw;

      final res = await RelaxApi.instance.delete('/auth/me', body: body);
      if (!context.mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        await context.read<AuthState>().logout();
        if (context.mounted) {
          showSoftToast(context,
              message: mode == 'HARD'
                  ? 'Tài khoản đã bị xóa vĩnh viễn.'
                  : 'Tài khoản đã được ẩn danh hóa.',
              tone: SoftToastTone.success);
          context.go('/login');
        }
      } else {
        final msg =
            (res.data is Map ? res.data['message'] as String? : null) ??
                'Không xóa được tài khoản.';
        showSoftToast(context, message: msg, tone: SoftToastTone.error);
      }
    } catch (e) {
      if (context.mounted) {
        showSoftToast(context,
            message: 'Lỗi: $e', tone: SoftToastTone.error);
      }
    }
  }
}

/// Khung giờ nhận nhắc nhở — chip 17:00 / 19:00 / 21:00 + "Mở rộng" + âm báo,
/// dựng theo mockup, đồng bộ với backend thông qua /reminders.
class _NotificationCard extends StatefulWidget {
  const _NotificationCard();

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  final _times = ['17:00', '19:00', '21:00'];
  String _selected = '21:00';
  String? _reminderId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadReminders();
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
                message: 'Đã cập nhật giờ nhắc nhở thành công!',
                tone: SoftToastTone.success);
          }
        } else {
          if (mounted) {
            showSoftToast(context,
                message: 'Cập nhật giờ nhắc nhở thất bại.',
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
                message: 'Đã cài đặt giờ nhắc nhở thành công!',
                tone: SoftToastTone.success);
            if (res.data is Map) {
              _reminderId = res.data['id'] as String?;
            }
          }
        } else {
          if (mounted) {
            showSoftToast(context,
                message: 'Cài đặt giờ nhắc nhở thất bại.',
                tone: SoftToastTone.error);
          }
        }
      }
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
            'Chọn khung giờ muốn nhận thông báo nhé ~',
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
                              'Mở rộng',
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
          Container(
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
                    'Âm báo: Tiếng mèo con kêu 🐱',
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
        ],
      ),
    );
  }
}


/// Thống kê tình trạng — biểu đồ cảm xúc 7 ngày + ước lượng giảm stress,
/// tính từ check-in cảm xúc gần nhất.
class _StatsCard extends StatefulWidget {
  const _StatsCard();

  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard> {
  bool _loading = true;
  List<double?> _daily = List.filled(7, null);
  int _stressDelta = 0; // % giảm stress (dương = giảm)
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res =
          await RelaxApi.instance.get('/mood-checkins/me', query: {'limit': 100});
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // 7 ngày gần nhất: index 0 = 6 ngày trước … 6 = hôm nay.
      final sums = List<double>.filled(7, 0);
      final counts = List<int>.filled(7, 0);
      int stressEarly = 0, stressLate = 0, earlyN = 0, lateN = 0;
      if (items is List) {
        for (final it in items.whereType<Map>()) {
          _total++;
          final createdRaw = it['createdAt'] as String?;
          final intensity = (it['intensity'] as num?)?.toDouble() ?? 3;
          final mood = it['mood'] as String?;
          if (createdRaw == null) continue;
          final created = DateTime.tryParse(createdRaw);
          if (created == null) continue;
          final day = DateTime(created.year, created.month, created.day);
          final diff = today.difference(day).inDays;
          if (diff >= 0 && diff < 7) {
            final idx = 6 - diff;
            sums[idx] += intensity;
            counts[idx] += 1;
          }
          // Stress đầu kỳ (3-7 ngày trước) vs cuối kỳ (0-3 ngày).
          final isStress = mood == 'STRESSED' || mood == 'ANXIOUS';
          if (diff >= 3 && diff < 7) {
            earlyN++;
            if (isStress) stressEarly++;
          } else if (diff >= 0 && diff < 3) {
            lateN++;
            if (isStress) stressLate++;
          }
        }
      }
      final daily = List<double?>.generate(7, (i) {
        if (counts[i] == 0) return null;
        // intensity 1..5 → 0..1.
        return ((sums[i] / counts[i]) - 1) / 4;
      });
      final earlyRate = earlyN == 0 ? 0.0 : stressEarly / earlyN;
      final lateRate = lateN == 0 ? 0.0 : stressLate / lateN;
      final delta = ((earlyRate - lateRate) * 100).round();
      if (mounted) {
        setState(() {
          _daily = daily;
          _stressDelta = delta;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Xem lại hành trình cảm xúc của bạn',
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Theo tuần',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.appText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const SizedBox(
              height: 130,
              child: Center(
                child: CircularProgressIndicator(color: RelaxColors.violet),
              ),
            )
          else if (_total == 0)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Chưa có dữ liệu cảm xúc.\nGhi vài lần để xem biểu đồ nhé!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
              ),
            )
          else ...[
            MoodLineChart(values: _daily),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _stressDelta >= 0
                        ? Icons.trending_down
                        : Icons.trending_up,
                    color:
                        _stressDelta >= 0 ? RelaxColors.mint : RelaxColors.coral,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _stressDelta >= 0
                          ? 'Giảm stress $_stressDelta% so với đầu tuần'
                          : 'Stress tăng ${-_stressDelta}% — nhớ nghỉ ngơi nhé',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.appText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileHero extends StatefulWidget {
  const _ProfileHero({
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
  });
  final String name;
  final String email;
  final String? avatar;
  final String role;

  @override
  State<_ProfileHero> createState() => _ProfileHeroState();
}

class _ProfileHeroState extends State<_ProfileHero> {
  bool _uploading = false;
  String? _birthday;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await RelaxApi.instance.get('/user-profiles/me/profile');
      if (res.statusCode == 200 && res.data is Map) {
        final birthdayStr = res.data['birthday'] as String?;
        if (mounted) {
          setState(() {
            _birthday = birthdayStr;
            _loadingProfile = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

  String _formatBirthday(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _editBirthday() async {
    DateTime initial = DateTime.now();
    if (_birthday != null) {
      initial = DateTime.tryParse(_birthday!) ?? DateTime.now();
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: RelaxColors.violet,
              onPrimary: Colors.white,
              surface: context.surface,
              onSurface: context.appText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final res = await RelaxApi.instance.patch(
        '/user-profiles/me/profile',
        body: {'birthday': picked.toUtc().toIso8601String()},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          setState(() {
            _birthday = picked.toUtc().toIso8601String();
          });
          showSoftToast(context,
              message: 'Cập nhật ngày sinh thành công!',
              tone: SoftToastTone.success);
        }
      } else {
        if (mounted) {
          showSoftToast(context,
              message: 'Cập nhật ngày sinh thất bại.',
              tone: SoftToastTone.error);
        }
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: 'Lỗi: $e', tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file == null) return;

      setState(() => _uploading = true);

      if (!mounted) return;
      final auth = context.read<AuthState>();
      final success = await auth.updateAvatar(file.path);

      if (mounted) {
        setState(() => _uploading = false);
        if (success) {
          showSoftToast(context,
              message: 'Cập nhật ảnh đại diện thành công!',
              tone: SoftToastTone.success);
        } else {
          showSoftToast(context,
              message: 'Cập nhật ảnh đại diện thất bại.',
              tone: SoftToastTone.error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        showSoftToast(context,
            message: 'Lỗi: $e', tone: SoftToastTone.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RelaxColors.violet, RelaxColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RelaxColors.violet.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _uploading ? null : _pickAndUploadAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  foregroundImage:
                      widget.avatar != null ? NetworkImage(widget.avatar!) : null,
                  child: Text(
                    widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: RelaxColors.violet,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ),
                if (_uploading)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: RelaxColors.violet,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _editName(context, widget.name),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.white70, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _loadingProfile
                    ? const SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.white70,
                        ),
                      )
                    : GestureDetector(
                        onTap: _uploading ? null : _editBirthday,
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined,
                                color: Colors.white70, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              _birthday != null
                                  ? _formatBirthday(_birthday!)
                                  : 'Thiết lập ngày sinh 🎂',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    (() {
                      final auth = context.watch<AuthState>();
                      final user = auth.user;
                      final subs = user?['subscriptions'] as List?;
                      final sub = (subs != null && subs.isNotEmpty) ? subs.first as Map? : null;
                      final planName = (sub?['planName'] as String?) ?? 'FREE';
                      final subStatus = (sub?['status'] as String?) ?? 'ACTIVE';
                      final isPremium = planName.toUpperCase() != 'FREE' && subStatus.toUpperCase() == 'ACTIVE';

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPremium
                              ? RelaxColors.sun.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPremium) ...[
                              const Icon(Icons.star, color: Colors.white, size: 10),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              isPremium ? planName.toUpperCase().replaceAll('_', ' ') : 'GÓI FREE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      );
                    })(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên hiển thị'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(hintText: 'Tên hiển thị'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == current) return;
    if (!context.mounted) return;
    final ok = await context.read<AuthState>().updateDisplayName(newName);
    if (!context.mounted) return;
    showSoftToast(context,
        message: ok ? 'Đã đổi tên hiển thị' : 'Không đổi được tên',
        tone: ok ? SoftToastTone.success : SoftToastTone.error);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: RelaxColors.slate,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(children: children),
    );
  }
}

/// Bộ chọn giao diện Sáng / Tối / Hệ thống — lưu ngay qua ThemeController.
class _ThemeToggleCard extends StatelessWidget {
  const _ThemeToggleCard();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final mode = controller.mode;
    Widget option(ThemeMode m, IconData icon, String label) {
      final selected = mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            controller.setMode(m);
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? RelaxColors.violet : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : context.mutedText,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : context.mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          option(ThemeMode.light, Icons.light_mode_outlined, 'Sáng'),
          option(ThemeMode.dark, Icons.dark_mode_outlined, 'Tối'),
          option(ThemeMode.system, Icons.brightness_auto_outlined, 'Hệ thống'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: RelaxColors.violet.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: RelaxColors.violet, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right, color: context.mutedText)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      color: context.fieldBorder,
      indent: 64,
      endIndent: 14,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: RelaxColors.coral.withValues(alpha: 0.1),
          foregroundColor: RelaxColors.coral,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: RelaxColors.coral),
          ),
        ),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Đăng xuất?'),
              content: const Text(
                'Bạn sẽ phải đăng nhập lại để dùng app.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            await context.read<AuthState>().logout();
            if (context.mounted) context.go('/login');
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}


/// Chip màu để user đổi accent color cho toàn app — màu nhấn của nút, biểu
/// đồ, focus ring. Lưu vào ThemeController + secure storage, đổi ngay tức
/// thì nhờ MaterialApp.theme rebuild.
class _AccentPickerCard extends StatelessWidget {
  const _AccentPickerCard();

  @override
  Widget build(BuildContext context) {
    final t = context.watch<ThemeController>();
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
            'Màu nhấn',
            style: TextStyle(
              color: context.appText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chọn tông gần với cảm xúc bạn đang muốn nuôi dưỡng',
            style: TextStyle(color: context.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final p in ThemeController.palette)
                GestureDetector(
                  // ignore: deprecated_member_use
                  onTap: () => context.read<ThemeController>().setAccent(p.color),
                  child: Tooltip(
                    message: p.name,
                    child: Container(
                      // ignore: deprecated_member_use
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: p.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: t.accent.value == p.color.value
                              ? context.appText
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: p.color.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      // ignore: deprecated_member_use
                      child: t.accent.value == p.color.value
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hai chip Tiếng Việt / English — đổi locale toàn app ngay tại chỗ.
class _LanguagePickerCard extends StatelessWidget {
  const _LanguagePickerCard();

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleController>();
    Widget chip(String code, String label, String flag) {
      final selected = loc.code == code;
      return Expanded(
        child: GestureDetector(
          onTap: () => context.read<LocaleController>().set(code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 14),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : context.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : context.fieldBorder,
              ),
            ),
            child: Column(
              children: [
                Text(flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : context.appText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          chip('vi', 'Tiếng Việt', '🇻🇳'),
          chip('en', 'English', '🇬🇧'),
        ],
      ),
    );
  }
}
