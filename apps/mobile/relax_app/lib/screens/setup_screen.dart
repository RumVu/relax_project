part of 'package:relax_app/main.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.content,
    required this.loadingContent,
    required this.contentError,
    required this.onRefreshContent,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final MobileContentSnapshot content;
  final bool loadingContent;
  final String? contentError;
  final VoidCallback onRefreshContent;

  @override
  Widget build(BuildContext context) {
    final copy = context.copy;
    final asset = content.companionAsset;
    final theme = content.appTheme;
    final paidPlans = content.billingPlans
        .where((plan) => plan.effectivePrice > 0)
        .toList(growable: false);
    final featuredPlan = paidPlans.isNotEmpty
        ? paidPlans.first
        : content.billingPlans.isNotEmpty
        ? content.billingPlans.first
        : null;
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
          if (loadingContent || contentError != null) ...[
            const SizedBox(height: 12),
            _SetupSyncNote(
              loading: loadingContent,
              onRefresh: onRefreshContent,
            ),
          ],
          const SizedBox(height: 12),
          PixelPanel(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CatAvatar(size: 88, imageUrl: asset?.previewImageUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset?.name ?? 'Thi Ái ✎',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        asset?.description ?? 'Linh thú đồng hành cùng bạn.',
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
                  children: [
                    const Expanded(
                      child: TimeChip(time: '17:00', selected: false),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TimeChip(time: '19:00', selected: false),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TimeChip(
                        time: content.companionMessage == null
                            ? '21:00'
                            : '21:30',
                        selected: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SettingRow(
                  icon: Icons.volume_up_outlined,
                  title: 'Tin nhắn companion',
                  subtitle:
                      content.companionMessage?.content ??
                      'Đang dùng thông báo mẫu đến khi backend trả message.',
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
                if (theme != null) ...[
                  const SizedBox(height: 12),
                  SettingRow(
                    icon: Icons.color_lens_outlined,
                    title: theme.name,
                    subtitle: 'Giao diện gợi ý từ backend',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ThemeSwatch(color: theme.primaryColor),
                      const SizedBox(width: 8),
                      _ThemeSwatch(color: theme.accentColor),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SettingAction(
            icon: Icons.credit_card_rounded,
            title: featuredPlan?.title ?? 'Nạp thẻ / Nâng cấp',
            subtitle: featuredPlan == null
                ? 'Mở khóa tính năng nâng cao'
                : '${featuredPlan.description} · ${featuredPlan.priceLabel}',
            action: featuredPlan == null ? 'Nạp ngay' : featuredPlan.priceLabel,
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

class _SetupSyncNote extends StatelessWidget {
  const _SetupSyncNote({required this.loading, required this.onRefresh});

  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onRefresh,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.relax.border),
        ),
        child: Row(
          children: [
            Icon(
              loading ? Icons.sync_rounded : Icons.refresh_rounded,
              color: RelaxTheme.lavender,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                loading
                    ? 'Đang nạp cài đặt từ backend...'
                    : 'Chưa nạp được cài đặt, bấm để thử lại.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.color});

  final String color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: _colorFromHex(color, RelaxTheme.purple),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.relax.border),
        ),
      ),
    );
  }
}
