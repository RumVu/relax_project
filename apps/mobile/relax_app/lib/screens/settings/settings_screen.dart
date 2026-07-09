import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth_state.dart';
import '../../core/theme.dart';
import '../../core/locale_controller.dart';
import '../../core/tour_controller.dart';
import '../../widgets/cat_mascot.dart';

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
import 'widgets/private_ai_toggle.dart';
import 'widgets/export_journals_row.dart';
import 'widgets/emergency_contact_row.dart';
import 'widgets/calendar_sync_row.dart';
import 'widgets/notification_style_row.dart';
import 'widgets/sync_status_row.dart';

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t('Tùy chỉnh không gian của {name} ~', {'name': name}),
                      style: TextStyle(color: context.mutedText, fontSize: 13),
                    ),
                  ),
                  const CatMascot(size: 56, variant: CatVariant.stand, glow: false),
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
              const SyncStatusRow(),
              const SizedBox(height: 24),
              _buildExploreSection(context, tour),
              const SizedBox(height: 24),
              _buildDeviceSection(context),
              const SizedBox(height: 24),
              _buildBuddySection(context),
              const SizedBox(height: 24),
              _buildLegalSection(context),
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
                _buildRestartTourButton(context, tour),
              ],
              const SizedBox(height: 24),
              SectionLabel(context.t('Nạp thẻ / Nâng cấp')),
              _buildBillingCard(context),
              const SizedBox(height: 24),
              SectionLabel(context.t('Bảo mật nhật ký')),
              const SettingsCard(
                children: [
                  PrivateAiToggleRow(),
                  SettingsDivider(),
                  ExportJournalsRow(),
                ],
              ),
              const SizedBox(height: 24),
              SectionLabel(context.t('Tùy chỉnh & Lịch')),
              SettingsCard(
                children: [
                  const CalendarSyncToggleRow(),
                  const SettingsDivider(),
                  const NotificationStyleRow(),
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
                  const EmergencyContactRow(),
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

  Widget _buildExploreSection(BuildContext context, TourController tour) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildDeviceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildBuddySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildRestartTourButton(BuildContext context, TourController tour) {
    return GestureDetector(
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
    );
  }

  Widget _buildBillingCard(BuildContext context) {
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
