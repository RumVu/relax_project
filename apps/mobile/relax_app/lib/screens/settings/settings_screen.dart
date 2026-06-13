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

import '../../core/vault_lock.dart';
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
                  _VaultToggleRow(),
                  const SettingsDivider(),
                  _HidePreviewToggleRow(),
                  const SettingsDivider(),
                  _PrivateAiToggleRow(),
                  const SettingsDivider(),
                  _ExportJournalsRow(),
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
              ctx.t('Thi Ái là ứng dụng hỗ trợ thư giãn, KHÔNG thay thế bác sĩ hoặc chuyên gia tâm lý. Nếu bạn đang cảm thấy quá sức chịu đựng, hãy liên hệ ngay:'),
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

class _VaultToggleRow extends StatefulWidget {
  @override
  State<_VaultToggleRow> createState() => _VaultToggleRowState();
}

class _VaultToggleRowState extends State<_VaultToggleRow> {
  bool _enabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final enabled = await VaultLock.instance.isEnabled;
    if (mounted) setState(() { _enabled = enabled; _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return SettingsRow(
      icon: Icons.lock_outline,
      title: context.t('Khóa nhật ký bằng PIN'),
      subtitle: _enabled
          ? context.t('Nhật ký được bảo vệ bằng mã PIN')
          : context.t('Bật để yêu cầu PIN khi mở nhật ký'),
      trailing: Switch.adaptive(
        value: _enabled,
        activeTrackColor: RelaxColors.violet,
        onChanged: (val) async {
          if (val) {
            final ok = await VaultLock.setupPin(context);
            if (ok) setState(() => _enabled = true);
          } else {
            final ok = await VaultLock.unlock(context);
            if (ok) {
              await VaultLock.instance.removePin();
              setState(() => _enabled = false);
            }
          }
        },
      ),
      onTap: () {},
    );
  }
}

class _HidePreviewToggleRow extends StatefulWidget {
  @override
  State<_HidePreviewToggleRow> createState() => _HidePreviewToggleRowState();
}

class _HidePreviewToggleRowState extends State<_HidePreviewToggleRow> {
  bool _enabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final val = await VaultLock.getHidePreview();
    if (mounted) setState(() { _enabled = val; _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return SettingsRow(
      icon: Icons.visibility_off_outlined,
      title: context.t('Ẩn nội dung nhật ký'),
      subtitle: _enabled
          ? context.t('Nội dung nhật ký đã được ẩn trong danh sách')
          : context.t('Hiển thị nội dung xem trước trong danh sách'),
      trailing: Switch.adaptive(
        value: _enabled,
        activeTrackColor: RelaxColors.violet,
        onChanged: (val) async {
          await VaultLock.setHidePreview(val);
          setState(() => _enabled = val);
        },
      ),
      onTap: () {},
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
