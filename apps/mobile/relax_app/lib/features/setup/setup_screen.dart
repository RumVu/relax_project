
import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../data/models/backend_models.dart';
import '../../data/services/mobile_content_service.dart';
import '../../shared/widgets/buttons/pill_controls.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/settings/time_chip.dart';
import '../relax/sheets/relax_sheets.dart';
import '../relax/sheets/stats_sheet.dart';

// ─── Main screen ────────────────────────────────────────────────────────────

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
    final appTheme = content.appTheme;
    final session = context.sessionOrNull;
    final user = session?.user;

    final displayName =
        (user?['name'] as String?)?.trim().isNotEmpty == true
            ? user!['name'] as String
            : asset?.name ?? 'Người dùng';
    final email = (user?['email'] as String?) ?? '';
    final avatarUrl =
        asset?.previewImageUrl ?? (user?['avatar'] as String?);

    final paidPlans = content.billingPlans
        .where((p) => p.effectivePrice > 0)
        .toList(growable: false);
    final featuredPlan = paidPlans.isNotEmpty
        ? paidPlans.first
        : content.billingPlans.isNotEmpty
            ? content.billingPlans.first
            : null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Profile header (gradient banner) ────────────────────────────
        _ProfileHeader(
          displayName: displayName,
          email: email,
          avatarUrl: avatarUrl,
          catScene: CatScene.sleep,
          onEdit: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Form sửa profile ở batch sau nha 💜')),
          ),
        ),

        if (loadingContent || contentError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SyncBanner(
              loading: loadingContent,
              onRefresh: onRefreshContent,
            ),
          ),

        const SizedBox(height: 8),

        // ── Notification ────────────────────────────────────────────────
        _SectionCard(
          children: [
            _SectionHeader(
              icon: Icons.notifications_none_rounded,
              label: 'Thông báo',
            ),
            const SizedBox(height: 12),
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
                    time:
                        content.companionMessage == null ? '21:00' : '21:30',
                    selected: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TapRow(
              icon: Icons.volume_up_outlined,
              title: 'Tin nhắn companion',
              subtitle: content.companionMessage?.content ??
                  'Nhớ duỗi vai một chút nhé.',
              onTap: null,
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Quy định + Thống kê ─────────────────────────────────────────
        _SectionCard(
          children: [
            _TapRow(
              icon: Icons.rule_folder_outlined,
              title: 'Quy định & sử dụng',
              subtitle: 'Điều khoản, chính sách & giấy phép',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Điều khoản sẽ có ở batch sau nha')),
              ),
            ),
            _Divider(),
            _TapRow(
              icon: Icons.query_stats_rounded,
              title: 'Thống kê tình trạng',
              subtitle: 'Streak · Thời gian · Hoạt động yêu thích',
              onTap: () => showStatsSheet(context),
              trailing: _PurpleChevron(),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Giao diện ───────────────────────────────────────────────────
        _SectionCard(
          children: [
            _SectionHeader(icon: Icons.palette_outlined, label: 'Giao diện'),
            const SizedBox(height: 14),
            ThemeSegmentedControl(
              themeMode: themeMode,
              onChanged: onThemeChanged,
            ),
            const SizedBox(height: 10),
            LanguageSegmentedControl(
              language: copy.language,
              onChanged: onLanguageChanged,
            ),
            if (appTheme != null) ...[
              const SizedBox(height: 14),
              _Divider(),
              const SizedBox(height: 12),
              _TapRow(
                icon: Icons.color_lens_outlined,
                title: appTheme.name,
                subtitle: 'Bảng màu được đề xuất cho không gian của bạn',
                onTap: null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ColorSwatch(
                      color: _hexColor(appTheme.primaryColor, RelaxTheme.purple),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ColorSwatch(
                      color: _hexColor(appTheme.accentColor, RelaxTheme.lavender),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),

        const SizedBox(height: 10),

        // ── Plan ────────────────────────────────────────────────────────
        if (featuredPlan != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _PlanBanner(plan: featuredPlan),
          ),

        const SizedBox(height: 10),

        // ── Account actions ─────────────────────────────────────────────
        _SectionCard(
          children: [
            _TapRow(
              icon: Icons.logout_rounded,
              title: 'Đăng xuất',
              subtitle: session?.isLoggedIn == true
                  ? 'Đang đăng nhập: ${email.isEmpty ? displayName : email}'
                  : 'Bạn chưa đăng nhập',
              onTap: () async {
                final navigator = Navigator.of(context);
                await showConfirmSheet(
                  context,
                  title: 'Đăng xuất?',
                  body: 'Hẹn gặp lại Thi Ái nhé. Nhớ chăm sóc bản thân nha.',
                  action: 'Đăng xuất',
                  onConfirm: () async => session?.logout(),
                );
                if (session?.isLoggedIn == false && navigator.canPop()) {
                  navigator.popUntil((r) => r.isFirst);
                }
              },
            ),
            _Divider(),
            _TapRow(
              icon: Icons.delete_outline_rounded,
              title: 'Xóa tài khoản',
              subtitle: 'Xóa vĩnh viễn toàn bộ dữ liệu của bạn',
              danger: true,
              onTap: () => showConfirmSheet(
                context,
                title: 'Xóa tài khoản?',
                body: 'Mọi dữ liệu sẽ biến mất và không thể khôi phục.',
                action: 'Xóa vĩnh viễn',
                danger: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ── Tagline ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Chúc các stress-er có những trải nghiệm tốt ở sản phẩm của chúng tôi 💜',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.relax.muted,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Profile Header ──────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.catScene,
    required this.onEdit,
  });

  final String displayName;
  final String email;
  final String? avatarUrl;
  final CatScene catScene;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RelaxTheme.purple.withValues(alpha: .18),
            RelaxTheme.lavender.withValues(alpha: .06),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: context.relax.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar
          Stack(
            children: [
              CatAvatar(size: 76, imageUrl: avatarUrl),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: RelaxTheme.purple,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onEdit,
                      child: Icon(
                        Icons.edit_rounded,
                        size: 15,
                        color: context.relax.muted,
                      ),
                    ),
                  ],
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        size: 12,
                        color: context.relax.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Sleeping cat top-right (decorative only)
          PixelCatScene(scene: catScene, height: 54),
        ],
      ),
    );
  }
}

// ─── Section Card ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.relax.border),
        boxShadow: [
          BoxShadow(
            color: RelaxTheme.purple.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: RelaxTheme.purple.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: RelaxTheme.lavender),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

// ─── Tap Row ─────────────────────────────────────────────────────────────────

class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.danger = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool danger;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final iconColor = danger ? context.relax.danger : RelaxTheme.lavender;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (danger
                        ? context.relax.danger
                        : RelaxTheme.purple)
                    .withValues(alpha: .10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: danger ? iconColor : null,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.relax.muted,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}

class _PurpleChevron extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: RelaxTheme.purple.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Xem',
            style: TextStyle(
              color: RelaxTheme.lavender,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 2),
          Icon(Icons.chevron_right_rounded, color: RelaxTheme.lavender, size: 16),
        ],
      ),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        color: context.relax.border,
      ),
    );
  }
}

// ─── Color Swatch ────────────────────────────────────────────────────────────

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

// ─── Plan Banner ─────────────────────────────────────────────────────────────

class _PlanBanner extends StatelessWidget {
  const _PlanBanner({required this.plan});
  final BackendBillingPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RelaxTheme.purple, Color(0xFF9C6DFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: RelaxTheme.purple.withValues(alpha: .35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: .4),
              ),
            ),
            child: Text(
              plan.priceLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sync Banner ─────────────────────────────────────────────────────────────

class _SyncBanner extends StatelessWidget {
  const _SyncBanner({required this.loading, required this.onRefresh});
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onRefresh,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.relax.border),
        ),
        child: Row(
          children: [
            Icon(
              loading ? Icons.sync_rounded : Icons.refresh_rounded,
              color: RelaxTheme.lavender,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                loading
                    ? 'Đang nạp cài đặt...'
                    : 'Chưa nạp được cài đặt, bấm để thử lại.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Color _hexColor(String value, Color fallback) {
  final s = value.replaceFirst('#', '').trim();
  if (s.length != 6) return fallback;
  final parsed = int.tryParse('FF$s', radix: 16);
  return parsed == null ? fallback : Color(parsed);
}
