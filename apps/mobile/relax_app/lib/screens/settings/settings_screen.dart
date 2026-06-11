import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/tour_controller.dart';
import '../../core/auth_state.dart';
import '../../core/theme.dart';
import '../../core/locale_controller.dart';
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
