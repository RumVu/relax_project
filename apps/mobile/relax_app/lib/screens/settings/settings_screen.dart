import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/tour_controller.dart';
import '../../core/auth_state.dart';
import '../../core/theme.dart';
import '../../core/locale_controller.dart';
import '../../widgets/cat_mascot.dart';
import '../../widgets/soft_toast.dart';

import '../../core/offline_store.dart';
import '../../core/vault_lock.dart';
import '../../core/calendar_integration_service.dart';
import 'helpers/account_deletion.dart';
import 'widgets/settings_shared.dart';
import 'widgets/notification_card.dart';
import 'widgets/stats_card.dart';
import 'widgets/profile_hero.dart';
import 'widgets/theme_toggle_card.dart';
import 'widgets/accent_picker_card.dart';
import 'widgets/language_picker_card.dart';
import 'widgets/logout_button.dart';
import 'widgets/reminder_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final tour = context.watch<TourController>();
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home?tab=0');
            }
          },
        ),
        title: Text(
          context.t('Setup ✨'),
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: RelaxColors.violet,
          onRefresh: () => auth.refreshUser(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            cacheExtent: 9999,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              // Header có mascot như mockup.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t('Tùy chỉnh không gian của {name} ~', {'name': name}),
                      style: TextStyle(color: context.mutedText, fontSize: 13),
                    ),
                  ),
                  const CatMascot(size: 56, emoji: '😺', glow: false),
                ],
              ),
              const SizedBox(height: 16),
              ProfileHero(name: name, email: email, avatar: avatar, role: role),
              const SizedBox(height: 24),
              SectionLabel(context.t('Thông báo')),
              Container(
                key: tour.notificationsKey,
                child: const NotificationCard(),
              ),
              const SizedBox(height: 12),
              SectionLabel(context.t('Nhắc nhở thông minh')),
              const ReminderCard(),
              const SizedBox(height: 12),
              SettingsCard(
                children: [
                  SettingsRow(
                    icon: Icons.science_outlined,
                    title: context.t('Phòng thí nghiệm thông báo'),
                    subtitle: context.t('Tuỳ chỉnh nâng cao nhắc nhở'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/notification-lab'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _SyncStatusRow(),
              const SizedBox(height: 24),
              SectionLabel(context.t('Khám phá')),
              SettingsCard(
                children: [
                  SettingsRow(
                    icon: Icons.insights_outlined,
                    title: context.t('Phân tích cảm xúc'),
                    subtitle: context.t('Biểu đồ & phân bố cảm xúc của bạn'),
                    onTap: () => context.push('/analytics'),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.calendar_view_week_outlined,
                    title: context.t('Báo cáo tuần'),
                    subtitle: context.t('Tổng hợp cảm xúc & hoạt động 7 ngày'),
                    onTap: () => context.push('/weekly-report'),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.event_note_outlined,
                    title: context.t('Kế hoạch tuần'),
                    subtitle: context.t('Gợi ý hoạt động 7 ngày theo mood'),
                    onTap: () => context.push('/wellness-plan'),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.emoji_events_outlined,
                    title: context.t('Thành tựu'),
                    subtitle: context.t('Xem huy hiệu & điểm thưởng'),
                    onTap: () => context.push('/achievements'),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.map_outlined,
                    title: context.t('Bản đồ Trigger'),
                    subtitle: context.t('Ánh xạ stress → hoạt động phù hợp'),
                    onTap: () => context.push('/trigger-map'),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.graphic_eq_outlined,
                    title: context.t('Soundscape'),
                    subtitle: context.t('Mix nhiều âm thanh theo mood'),
                    onTap: () => context.push('/soundscape'),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.timer_outlined,
                    title: context.t('Focus Break'),
                    subtitle: context.t('Pomodoro — tập trung & nghỉ xen kẽ'),
                    onTap: () => context.push('/focus-break'),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.cloud_outlined,
                    title: context.t('Thời tiết'),
                    subtitle: context.t('Theo dõi thời tiết & dự báo'),
                    onTap: () => context.push('/weather'),
                  ),
                  const SettingsDivider(),
                  Container(
                    key: tour.companionCustomizerKey,
                    child: SettingsRow(
                      icon: Icons.pets_outlined,
                      title: context.t('Linh thú'),
                      subtitle: context.t('Nuôi và tương tác với bạn đồng hành'),
                      onTap: () => context.push('/companion'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionLabel(context.t('Thiết bị & vị trí')),
              SettingsCard(
                children: [
                  SettingsRow(
                    icon: Icons.place_outlined,
                    title: context.t('Vị trí của bạn'),
                    subtitle:
                        context.t('Gợi ý thời tiết & địa điểm thư giãn gần bạn'),
                    onTap: () => context.push('/location'),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.phone_iphone_outlined,
                    title: context.t('Thông tin thiết bị'),
                    subtitle: context.t('Model, hệ điều hành, phiên bản app'),
                    onTap: () => context.push('/device-info'),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.devices_outlined,
                    title: context.t('Phiên đăng nhập'),
                    subtitle: context.t('Xem & thu hồi thiết bị đã đăng nhập'),
                    onTap: () => context.push('/sessions'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionLabel(context.t('Bạn đồng hành')),
              SettingsCard(
                children: [
                  SettingsRow(
                    icon: Icons.people_outline,
                    title: context.t('Bạn đồng hành'),
                    subtitle: context.t('Mời bạn bè, nhắc nhẹ, cùng theo dõi streak'),
                    onTap: () => context.push('/buddies'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionLabel(context.t('Quy định & sử dụng')),
              SettingsCard(
                children: [
                  SettingsRow(
                    icon: Icons.description_outlined,
                    title: context.t('Điều khoản, bản quyền & giấy phép'),
                    subtitle: context.t('Đọc trước khi sử dụng'),
                    onTap: () => context.push('/legal'),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.info_outline,
                    title: context.t('Giới thiệu'),
                    subtitle: context.t('Phiên bản 1.1.1.0'),
                    onTap: () => _showAboutDialog(context),
                  ),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.shield_outlined,
                    title: context.t('Dữ liệu & Quyền riêng tư'),
                    subtitle: context.t('Xuất, xóa dữ liệu cá nhân (GDPR)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/data-privacy'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionLabel(context.t('Thống kê tình trạng')),
              const StatsCard(),
              const SizedBox(height: 24),
              SectionLabel(context.t('Giao diện')),
              const ThemeToggleCard(),
              const SizedBox(height: 12),
              const AccentPickerCard(),
              const SizedBox(height: 24),
              SectionLabel(context.t('Ngôn ngữ')),
              Container(
                key: tour.languagePickerKey,
                child: const LanguagePickerCard(),
              ),
              if (tour.hasCompletedTour && !tour.isTourActive) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    tour.restartTour();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_run_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.t('Cần đi tour du lịch app này nha'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SectionLabel(context.t('Nạp thẻ / Nâng cấp')),
              (() {
                final auth = context.watch<AuthState>();
                final user = auth.user;
                final subs = user?['subscriptions'] as List?;
                final sub = (subs != null && subs.isNotEmpty) ? subs.first as Map? : null;
                final planName = (sub?['planName'] as String?) ?? 'FREE';
                final subStatus = (sub?['status'] as String?) ?? 'ACTIVE';
                final isPremium = planName.toUpperCase() != 'FREE' && subStatus.toUpperCase() == 'ACTIVE';

                return SettingsCard(
                  children: [
                    SettingsRow(
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
              const SizedBox(height: 24),
              SectionLabel(context.t('Bảo mật nhật ký')),
              SettingsCard(
                children: [
                  _PrivateAiToggleRow(),
                  const SettingsDivider(),
                  _ExportJournalsRow(),
                ],
              ),
              const SizedBox(height: 24),
              SectionLabel(context.t('Tùy chỉnh & Lịch')),
              SettingsCard(
                children: [
                  _CalendarSyncToggleRow(),
                  const SettingsDivider(),
                  _NotificationStyleRow(),
                  const SettingsDivider(),
                  SettingsRow(
                    icon: Icons.feedback_outlined,
                    title: context.t('Gửi phản hồi đóng góp'),
                    subtitle: context.t('Báo lỗi, đề xuất tính năng cho phát triển'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/feedback'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionLabel(context.t('An toàn & hỗ trợ')),
              SettingsCard(
                children: [
                  SettingsRow(
                    icon: Icons.favorite_outline,
                    title: context.t('Cần hỗ trợ khẩn cấp?'),
                    subtitle:
                        context.t('Đường dây nóng tâm lý & liên hệ người thân'),
                    trailing: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: RelaxColors.coral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.t('SOS'),
                        style: const TextStyle(
                          color: RelaxColors.coral,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    onTap: () => context.push('/crisis-help'),
                  ),
                  const SettingsDivider(),
                  _EmergencyContactRow(),
                ],
              ),
              const SizedBox(height: 24),
              SectionLabel(context.t('Tài khoản')),
              SettingsCard(
                children: [
                  SettingsRow(
                    icon: Icons.delete_outline,
                    title: context.t('Xóa tài khoản'),
                    subtitle:
                        context.t('Xóa vĩnh viễn toàn bộ dữ liệu của bạn'),
                    trailing: const Icon(Icons.chevron_right,
                        color: RelaxColors.coral),
                    onTap: () => confirmAccountDeletion(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const LogoutButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }



  /*
  void _showSafetySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.favorite, color: RelaxColors.coral, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ctx.t('Bạn không đơn độc'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: ctx.appText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              ctx.t('Relax Time là ứng dụng hỗ trợ thư giãn, KHÔNG thay thế bác sĩ hoặc chuyên gia tâm lý. Nếu bạn đang cảm thấy quá sức chịu đựng, hãy liên hệ ngay:'),
              style: TextStyle(
                color: ctx.mutedText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _safetyRow(ctx, '🇻🇳', ctx.t('Đường dây nóng VN'), '1800 599 920',
                ctx.t('Miễn phí, 24/7')),
            const SizedBox(height: 12),
            _safetyRow(ctx, '🌏', ctx.t('Tâm lý trẻ em & thanh niên'),
                '111', ctx.t('Tổng đài bảo vệ trẻ em')),
            const SizedBox(height: 12),
            _safetyRow(ctx, '📞', ctx.t('Cấp cứu'), '115',
                ctx.t('Cấp cứu y tế')),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RelaxColors.violet.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                ctx.t('Nhắn với người thân bạn tin tưởng. Việc chia sẻ không phải là yếu đuối — đó là dũng cảm. 💜'),
                style: TextStyle(
                  color: ctx.appText,
                  fontSize: 14,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  */

  /*
  Widget _safetyRow(
      BuildContext ctx, String flag, String title, String number, String note) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ctx.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ctx.fieldBorder),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: ctx.appText)),
                Text(note,
                    style: TextStyle(color: ctx.mutedText, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: RelaxColors.coral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: RelaxColors.coral,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
  */

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Relax',
      applicationVersion: '1.1.1.0',
      applicationLegalese:
          context.t('Theo dõi cảm xúc, hít thở và nhật ký mỗi ngày — phần thưởng nhỏ cho người chịu khó chăm sóc bản thân.'),
    );
  }
}

class _PrivateAiToggleRow extends StatefulWidget {
  @override
  State<_PrivateAiToggleRow> createState() => _PrivateAiToggleRowState();
}

class _PrivateAiToggleRowState extends State<_PrivateAiToggleRow> {
  bool _enabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final val = await VaultLock.getPrivateAiMode();
    if (mounted) setState(() { _enabled = val; _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return SettingsRow(
      icon: Icons.smart_toy_outlined,
      title: context.t('Chế độ AI riêng tư'),
      subtitle: _enabled
          ? context.t('Nhật ký sẽ KHÔNG được gửi cho AI phân tích')
          : context.t('AI có thể đọc nhật ký để gợi ý cảm xúc'),
      trailing: Switch.adaptive(
        value: _enabled,
        activeTrackColor: RelaxColors.violet,
        onChanged: (val) async {
          await VaultLock.setPrivateAiMode(val);
          setState(() => _enabled = val);
        },
      ),
      onTap: () {},
    );
  }
}

class _ExportJournalsRow extends StatefulWidget {
  @override
  State<_ExportJournalsRow> createState() => _ExportJournalsRowState();
}

class _ExportJournalsRowState extends State<_ExportJournalsRow> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final res = await RelaxApi.instance
          .get('/journals/me', query: {'limit': 999});
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      final journals = (items is List)
          ? items
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      if (journals.isEmpty) {
        if (mounted) {
          showSoftToast(context,
              message: context.t('Không có nhật ký nào để xuất'),
              tone: SoftToastTone.info);
        }
        return;
      }

      final text = await VaultLock.exportJournals(journals);

      // Use share / clipboard as a simple export mechanism
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        showSoftToast(context,
            message: context.t('Đã sao chép {count} nhật ký vào clipboard', {
              'count': journals.length.toString(),
            }),
            tone: SoftToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: e.toString(), tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: Icons.download_outlined,
      title: context.t('Xuất nhật ký'),
      subtitle: context.t('Sao chép toàn bộ nhật ký dạng văn bản'),
      trailing: _exporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: RelaxColors.violet,
              ),
            )
          : const Icon(Icons.chevron_right, color: RelaxColors.slate),
      onTap: _exporting ? () {} : _export,
    );
  }
}

class _EmergencyContactRow extends StatefulWidget {
  @override
  State<_EmergencyContactRow> createState() => _EmergencyContactRowState();
}

class _EmergencyContactRowState extends State<_EmergencyContactRow> {
  String _contact = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox('emergency_contact');
    if (mounted) {
      setState(() {
        _contact = box.get('contact', defaultValue: '') as String;
        _loaded = true;
      });
    }
  }

  Future<void> _edit() async {
    final ctrl = TextEditingController(text: _contact);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t('Liên hệ khẩn cấp')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.t('Số điện thoại người thân tin tưởng. Sẽ hiện khi phát hiện dấu hiệu cần hỗ trợ.'),
              style: TextStyle(color: context.mutedText, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: context.t('Số điện thoại'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(context.t('Lưu')),
          ),
        ],
      ),
    );
    if (result != null) {
      final box = await Hive.openBox('emergency_contact');
      await box.put('contact', result);
      if (mounted) setState(() => _contact = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return SettingsRow(
      icon: Icons.contact_phone_outlined,
      title: context.t('Liên hệ khẩn cấp'),
      subtitle: _contact.isEmpty
          ? context.t('Thêm số người thân tin tưởng')
          : _contact,
      onTap: _edit,
    );
  }
}

class _CalendarSyncToggleRow extends StatefulWidget {
  @override
  State<_CalendarSyncToggleRow> createState() => _CalendarSyncToggleRowState();
}

class _CalendarSyncToggleRowState extends State<_CalendarSyncToggleRow> {
  bool _syncing = false;
  
  @override
  Widget build(BuildContext context) {
    final service = CalendarIntegrationService.instance;
    return SettingsRow(
      icon: Icons.calendar_today_outlined,
      title: context.t('Đồng bộ Lịch cá nhân'),
      subtitle: service.isSynced
          ? context.t('Đã đồng bộ. Gợi ý wellness sẽ cập nhật theo lịch làm việc.')
          : context.t('Đồng bộ Google/Apple Calendar để tự động gợi ý bài tập'),
      trailing: _syncing 
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(strokeWidth: 2, color: RelaxColors.violet)
            )
          : Switch.adaptive(
              value: service.isSynced,
              activeTrackColor: RelaxColors.violet,
              onChanged: (val) async {
                setState(() => _syncing = true);
                await service.toggleSync();
                setState(() => _syncing = false);
                if (mounted) {
                  showSoftToast(
                    context,
                    message: service.isSynced 
                        ? context.t('Đã đồng bộ lịch thành công 📅') 
                        : context.t('Đã tắt đồng bộ lịch'),
                    tone: SoftToastTone.success,
                  );
                }
              },
            ),
      onTap: () {},
    );
  }
}

class _NotificationStyleRow extends StatefulWidget {
  @override
  State<_NotificationStyleRow> createState() => _NotificationStyleRowState();
}

class _NotificationStyleRowState extends State<_NotificationStyleRow> {
  String _style = 'Gentle';
  
  final Map<String, String> _previews = {
    'Gentle': '“Nghỉ một chút nha bạn ơi.”',
    'Funny': '“Não bạn đang quá tải rồi, cho nó thở đi thôi!”',
    'Minimal': '“2-minute break.”',
    'Companion': '“Linh thú: Meow! Hãy dừng lại hít thở một tẹo nào.”',
    'Silent': 'Chỉ hiện huy hiệu ứng dụng (Silent)',
  };

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: Icons.notifications_active_outlined,
      title: context.t('Phong cách thông báo'),
      subtitle: '${context.t("Đang chọn")}: $_style',
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showStyleChooser(context),
    );
  }

  void _showStyleChooser(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.t('Phong cách Thông báo (Lab) 🧪'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.t('Chọn phong cách nhắc nhở thư giãn phù hợp nhất với bạn.'),
                    style: TextStyle(fontSize: 12, color: context.mutedText),
                  ),
                  const SizedBox(height: 16),
                  ..._previews.keys.map((style) {
                    final selected = _style == style;
                    return InkWell(
                      onTap: () {
                        setState(() => _style = style);
                        setModalState(() {});
                        showSoftToast(
                          context,
                          message: '${context.t("Đã chuyển sang phong cách:")} $style 🔔',
                          tone: SoftToastTone.success,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: selected ? RelaxColors.violet.withValues(alpha: 0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: selected ? RelaxColors.violet : context.mutedText,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.t(style),
                                    style: TextStyle(
                                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                      color: context.appText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.t(_previews[style]!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: context.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SyncStatusRow extends StatelessWidget {
  const _SyncStatusRow();

  @override
  Widget build(BuildContext context) {
    final store = OfflineStore.instance;
    final pending = store.pendingCount;
    final failed = store.failedCount;
    final hasIssues = pending > 0 || failed > 0;

    return SettingsCard(
      children: [
        SettingsRow(
          icon: Icons.sync,
          title: context.t('Đồng bộ dữ liệu'),
          subtitle: hasIssues
              ? '${pending > 0 ? "$pending đang chờ" : ""}${pending > 0 && failed > 0 ? " · " : ""}${failed > 0 ? "$failed lỗi" : ""}'
              : context.t('Mọi thứ đã đồng bộ'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (failed > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: RelaxColors.coral.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$failed',
                    style: const TextStyle(
                      color: RelaxColors.coral,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                hasIssues ? Icons.warning_amber : Icons.check_circle,
                color: hasIssues ? const Color(0xFFF59E0B) : RelaxColors.mint,
                size: 18,
              ),
            ],
          ),
          onTap: () => _showSyncSheet(context),
        ),
      ],
    );
  }

  void _showSyncSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _SyncSheet(),
    );
  }
}

class _SyncSheet extends StatefulWidget {
  const _SyncSheet();

  @override
  State<_SyncSheet> createState() => _SyncSheetState();
}

class _SyncSheetState extends State<_SyncSheet> {
  @override
  void initState() {
    super.initState();
    OfflineStore.instance.addListener(_onUpdate);
  }

  @override
  void dispose() {
    OfflineStore.instance.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = OfflineStore.instance;
    final items = store.queueItems;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      expand: false,
      builder: (ctx, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.fieldBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.sync, color: RelaxColors.violet, size: 22),
                const SizedBox(width: 8),
                Text(
                  context.t('Hàng đợi đồng bộ'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: context.appText,
                  ),
                ),
                const Spacer(),
                if (store.failedCount > 0)
                  TextButton(
                    onPressed: () => store.retryAll(),
                    child: Text(context.t('Thử lại tất cả'),
                        style: const TextStyle(
                            color: RelaxColors.violet,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_done,
                              color: RelaxColors.mint, size: 48),
                          const SizedBox(height: 12),
                          Text(context.t('Mọi thứ đã đồng bộ!'),
                              style: TextStyle(
                                  color: context.appText,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollCtrl,
                      itemCount: items.length,
                      itemBuilder: (ctx, idx) =>
                          _buildSyncItem(context, items[idx]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncItem(BuildContext context, SyncQueueItem item) {
    final isFailed = item.status == SyncStatus.failed;
    final isSyncing = item.status == SyncStatus.syncing;

    Color statusColor;
    IconData statusIcon;
    switch (item.status) {
      case SyncStatus.pending:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.schedule;
      case SyncStatus.syncing:
        statusColor = RelaxColors.violet;
        statusIcon = Icons.sync;
      case SyncStatus.failed:
        statusColor = RelaxColors.coral;
        statusIcon = Icons.error_outline;
      case SyncStatus.resolved:
        statusColor = RelaxColors.mint;
        statusIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFailed
              ? RelaxColors.coral.withValues(alpha: 0.3)
              : context.fieldBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.method} ${item.path}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: context.appText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.createdAt.day}/${item.createdAt.month} ${item.createdAt.hour}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: context.mutedText, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isSyncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: RelaxColors.violet),
                ),
            ],
          ),
          if (isFailed && item.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              item.errorMessage!,
              style: const TextStyle(
                  color: RelaxColors.coral, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => OfflineStore.instance
                        .resolveConflict(item.id, keepLocal: true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RelaxColors.violet,
                      side: const BorderSide(color: RelaxColors.violet),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(context.t('Giữ bản local'),
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        OfflineStore.instance.discardItem(item.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RelaxColors.coral,
                      side: const BorderSide(color: RelaxColors.coral),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(context.t('Bỏ qua'),
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
