part of 'package:relax_app/main.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final copy = context.copy;
    return AppScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            icon: Icons.settings_outlined,
            title: 'Setup ✦',
            subtitle: 'Tùy chỉnh không gian của Thi Ái ~',
            trailing: const PixelCatScene(scene: CatScene.sleep, height: 64),
          ),
          const SizedBox(height: 14),
          PixelPanel(
            child: Row(
              children: [
                const CatAvatar(size: 94),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thi Ái ✎',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tuổi: 22   |   Nữ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '0123 456 789',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'thiai.chill@email.com',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.relax.muted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'Thông báo',
                  icon: Icons.notifications_none_rounded,
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(child: TimeChip(time: '17:00', selected: false)),
                    SizedBox(width: 8),
                    Expanded(child: TimeChip(time: '19:00', selected: false)),
                    SizedBox(width: 8),
                    Expanded(child: TimeChip(time: '21:00', selected: true)),
                  ],
                ),
                const SizedBox(height: 10),
                SettingRow(
                  icon: Icons.volume_up_outlined,
                  title: 'Âm báo: Tiếng mèo con kêu',
                  subtitle:
                      'Người dùng ≤ 32 tuổi nên có thể chọn khung giờ sau 21:00',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PixelPanel(
            child: Column(
              children: [
                SettingRow(
                  icon: Icons.rule_folder_outlined,
                  title: 'Quy định & sử dụng',
                  subtitle: 'Điều khoản, chính sách & giấy phép',
                ),
                const Divider(height: 20),
                SectionTitle(
                  title: 'Thống kê tình trạng',
                  icon: Icons.query_stats_rounded,
                ),
                const SizedBox(height: 12),
                const MoodLineChart(compact: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title: 'Giao diện', icon: Icons.palette_outlined),
                const SizedBox(height: 10),
                ThemeSegmentedControl(
                  themeMode: themeMode,
                  onChanged: onThemeChanged,
                ),
                const SizedBox(height: 10),
                LanguageSegmentedControl(
                  language: copy.language,
                  onChanged: onLanguageChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SettingAction(
            icon: Icons.credit_card_rounded,
            title: 'Nạp thẻ / Nâng cấp',
            subtitle: 'Mở khóa tính năng nâng cao',
            action: 'Nạp ngay',
          ),
          const SizedBox(height: 10),
          SettingAction(
            icon: Icons.delete_outline_rounded,
            title: 'Xóa tài khoản',
            subtitle: 'Xóa vĩnh viễn toàn bộ dữ liệu của Thi Ái',
            danger: true,
            onTap: () => showConfirmSheet(
              context,
              title: 'Xóa tài khoản?',
              body:
                  'Mọi dữ liệu sẽ biến mất và Thi Ái sẽ không thể quay lại đâu á.',
              action: 'Xóa vĩnh viễn',
              danger: true,
            ),
          ),
          const SizedBox(height: 10),
          SettingAction(
            icon: Icons.logout_rounded,
            title: 'Đăng xuất',
            subtitle: 'Đăng xuất khỏi tài khoản hiện tại',
            onTap: () => showConfirmSheet(
              context,
              title: 'Đăng xuất?',
              body: 'Hẹn gặp lại Thi Ái nhé. Thi Ái nhớ chăm sóc bản thân nha.',
              action: 'Đăng xuất',
            ),
          ),
        ],
      ),
    );
  }
}
