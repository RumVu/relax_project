import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../data/models/backend_models.dart';
import '../../data/services/mobile_content_service.dart';
import '../../shared/widgets/charts/mood_line_chart.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../relax/sheets/relax_sheets.dart';
import '../relax/sheets/stats_sheet.dart';

/// Setup screen — khớp đúng mockup hình 4 anh đã thiết kế.
///
/// Cấu trúc dọc:
///   1. Header "Setup ✦" + cat sleeping top-right
///   2. "Trang cá nhân" + profile card (avatar + tên + 4 info lines)
///   3. "Thông báo" + 4 time chips + Âm báo row + hint nhỏ
///   4. "Quy định & sử dụng" tappable row
///   5. "Thống kê tình trạng" với chart + side panel stress %
///   6. "Giao diện" + 3 pills Light/Dark/Customs + theme color
///   7. "Nạp thẻ / Nâng cấp" tappable với chip "Nạp ngay"
///   8. "Xóa tài khoản" red row
///   9. "Đăng xuất" row
///  10. Footer "MỘT SỐ LƯU Ý NHỎ" với 4 hints
class SetupScreen extends StatefulWidget {
  const SetupScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.content,
    required this.loadingContent,
    required this.contentError,
    required this.onRefreshContent,
    this.moodHistory = const [],
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final MobileContentSnapshot content;
  final bool loadingContent;
  final String? contentError;
  final VoidCallback onRefreshContent;
  final List<dynamic> moodHistory; // type kept loose to avoid import cycle

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  /// Khung giờ thông báo được chọn (default 21:00).
  String _selectedTime = '21:00';

  /// Theme tab tự quản — Light / Dark / Customs.
  String _themeTab = 'dark';

  @override
  void initState() {
    super.initState();
    _themeTab = widget.themeMode == ThemeMode.light ? 'light' : 'dark';
  }

  @override
  Widget build(BuildContext context) {
    final session = context.sessionOrNull;
    final user = session?.user;
    final asset = widget.content.companionAsset;
    final featuredPlan = widget.content.billingPlans.isNotEmpty
        ? widget.content.billingPlans.first
        : null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _SetupHeader(),

        const SizedBox(height: 8),
        const _SectionLabel(icon: Icons.person_outline, label: 'Trang cá nhân'),
        const SizedBox(height: 8),
        _SectionCard(
          child: _ProfileBody(
            user: user,
            assetName: asset?.name,
            avatarUrl: asset?.previewImageUrl ?? (user?['avatar'] as String?),
            onEdit: () => _toast(context, 'Form sửa profile ở batch sau nha 💜'),
          ),
        ),

        const SizedBox(height: 10),
        const _SectionLabel(
          icon: Icons.notifications_none_rounded,
          label: 'Thông báo',
        ),
        const SizedBox(height: 8),
        _SectionCard(
          child: _NotificationBody(
            selected: _selectedTime,
            onSelected: (t) => setState(() => _selectedTime = t),
            soundLabel: widget.content.companionMessage?.content != null
                ? 'Tiếng companion: ${widget.content.companionMessage!.content.split('.').first}'
                : 'Tiếng mèo con kêu',
          ),
        ),

        const SizedBox(height: 10),
        _SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: _TapRow(
            icon: Icons.description_outlined,
            title: 'Quy định & sử dụng',
            subtitle: 'Điều khoản, chính sách & giấy phép',
            onTap: () => _toast(context, 'Trang quy định sẽ có ở batch sau ✦'),
          ),
        ),

        const SizedBox(height: 10),
        const _SectionLabel(
          icon: Icons.bar_chart_rounded,
          label: 'Thống kê tình trạng',
        ),
        const SizedBox(height: 8),
        _SectionCard(
          child: _StatsBody(
            moodHistory: widget.moodHistory,
            onOpen: () => showStatsSheet(context),
          ),
        ),

        const SizedBox(height: 10),
        const _SectionLabel(
          icon: Icons.palette_outlined,
          label: 'Giao diện',
        ),
        const SizedBox(height: 8),
        _SectionCard(
          child: _AppearanceBody(
            tab: _themeTab,
            onTabChanged: (tab) {
              setState(() => _themeTab = tab);
              if (tab == 'light') widget.onThemeChanged(ThemeMode.light);
              if (tab == 'dark') widget.onThemeChanged(ThemeMode.dark);
            },
            appTheme: widget.content.appTheme,
          ),
        ),

        const SizedBox(height: 10),
        _SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: _TapRow(
            icon: Icons.credit_card_rounded,
            title: featuredPlan?.title ?? 'Nạp thẻ / Nâng cấp',
            subtitle: featuredPlan == null
                ? 'Mở khóa tính năng nâng cao'
                : featuredPlan.description,
            trailing: _PurpleChip(
              text: featuredPlan?.priceLabel ?? 'Nạp ngay',
            ),
            onTap: () => _toast(context, 'Trang nạp thẻ sẽ có ở batch sau ✦'),
          ),
        ),

        const SizedBox(height: 10),
        _SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: _TapRow(
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
        ),

        const SizedBox(height: 10),
        _SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: _TapRow(
            icon: Icons.logout_rounded,
            title: 'Đăng xuất',
            subtitle: 'Đăng xuất khỏi tài khoản hiện tại',
            onTap: () async {
              final navigator = Navigator.of(context);
              await showConfirmSheet(
                context,
                title: 'Đăng xuất?',
                body: 'Hẹn gặp lại nhé. Nhớ chăm sóc bản thân nha.',
                action: 'Đăng xuất',
                onConfirm: () async => session?.logout(),
              );
              if (session?.isLoggedIn == false && navigator.canPop()) {
                navigator.popUntil((r) => r.isFirst);
              }
            },
          ),
        ),

        const SizedBox(height: 24),
        const _HintsFooter(),
        const SizedBox(height: 32),
      ],
    );
  }
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

// ════════════════════════════════════════════════════════════════════════════
//  SECTIONS
// ════════════════════════════════════════════════════════════════════════════

class _SetupHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Setup',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.auto_awesome,
                      color: RelaxTheme.lavender,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tùy chỉnh không gian của bạn ~',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const PixelCatScene(scene: CatScene.sleep, height: 64),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: RelaxTheme.lavender),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: RelaxTheme.lavender.withValues(alpha: .14),
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PROFILE
// ════════════════════════════════════════════════════════════════════════════

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.user,
    required this.assetName,
    required this.avatarUrl,
    required this.onEdit,
  });

  final Map<String, dynamic>? user;
  final String? assetName;
  final String? avatarUrl;
  final VoidCallback onEdit;

  String get _name {
    final n = (user?['name'] as String?)?.trim();
    if (n != null && n.isNotEmpty) return n;
    return assetName ?? 'Người dùng';
  }

  int? get _age {
    final a = user?['age'] as num?;
    if (a != null) return a.toInt();
    final by = user?['birthYear'] as num?;
    if (by != null) return DateTime.now().year - by.toInt();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final phone = (user?['phone'] as String?)?.trim();
    final email = (user?['email'] as String?)?.trim();
    final social = (user?['socialUrl'] as String?)?.trim() ??
        (user?['link'] as String?)?.trim();
    final gender = (user?['gender'] as String?)?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Avatar with camera badge ──────────────────────────────────────
        Stack(
          children: [
            CatAvatar(size: 88, imageUrl: avatarUrl),
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 28,
                  height: 28,
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
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        // ── Info column ───────────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _name,
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
                      Icons.edit_outlined,
                      size: 16,
                      color: context.relax.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (_age != null || (gender != null && gender.isNotEmpty))
                _ProfileLine(
                  icon: Icons.cake_outlined,
                  text: [
                    if (_age != null) 'Tuổi: $_age',
                    if (gender != null && gender.isNotEmpty) gender,
                  ].join('   |   '),
                ),
              if (phone != null && phone.isNotEmpty)
                _ProfileLine(icon: Icons.call_outlined, text: phone),
              if (email != null && email.isNotEmpty)
                _ProfileLine(icon: Icons.mail_outline_rounded, text: email),
              if (social != null && social.isNotEmpty)
                _ProfileLine(icon: Icons.link_rounded, text: social),
              if ((_age == null) &&
                  (phone == null || phone.isEmpty) &&
                  (email == null || email.isEmpty) &&
                  (social == null || social.isEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Bấm bút chì để thêm thông tin ~',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: context.relax.muted),
      ],
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: RelaxTheme.lavender),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  NOTIFICATION
// ════════════════════════════════════════════════════════════════════════════

class _NotificationBody extends StatelessWidget {
  const _NotificationBody({
    required this.selected,
    required this.onSelected,
    required this.soundLabel,
  });

  final String selected;
  final ValueChanged<String> onSelected;
  final String soundLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn khung giờ bạn muốn nhận thông báo nhé ~',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12.5,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TimeChip(
                time: '17:00',
                selected: selected == '17:00',
                onTap: () => onSelected('17:00'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TimeChip(
                time: '19:00',
                selected: selected == '19:00',
                onTap: () => onSelected('19:00'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TimeChip(
                time: '21:00',
                selected: selected == '21:00',
                onTap: () => onSelected('21:00'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ExpandChip(
                onTap: () => _toast(context, 'Thêm khung giờ ở batch sau ~'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SoundRow(soundLabel: soundLabel),
        const SizedBox(height: 8),
        Text(
          '✦ Bạn ≤ 32 tuổi mới có thể chọn khung giờ sau 21:00',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: context.relax.muted,
              ),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.time,
    required this.selected,
    required this.onTap,
  });
  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? RelaxTheme.purple : context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? RelaxTheme.purple : context.relax.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ],
            ),
            Text(
              time,
              style: TextStyle(
                color: selected
                    ? Colors.white.withValues(alpha: .7)
                    : context.relax.muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandChip extends StatelessWidget {
  const _ExpandChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: RelaxTheme.lavender.withValues(alpha: .4),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: const [
            Icon(Icons.add, size: 16, color: RelaxTheme.lavender),
            Text(
              'Mở rộng',
              style: TextStyle(
                color: RelaxTheme.lavender,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundRow extends StatelessWidget {
  const _SoundRow({required this.soundLabel});
  final String soundLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.volume_up_outlined,
            size: 18,
            color: RelaxTheme.lavender,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Âm báo: $soundLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12.5,
                  ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.relax.muted),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  STATS BODY (inline chart + side panel)
// ════════════════════════════════════════════════════════════════════════════

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.moodHistory, required this.onOpen});
  final List<dynamic> moodHistory;
  final VoidCallback onOpen;

  /// Chuẩn hóa 7 ngày cuối thành List<double> [0,1].
  List<double> get _chartData {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = List<int>.filled(7, 0);
    for (final c in moodHistory) {
      try {
        final createdAt = c.createdAt as DateTime;
        final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final diff = today.difference(day).inDays;
        if (diff >= 0 && diff < 7) counts[6 - diff]++;
      } catch (_) {}
    }
    final max = counts.fold<int>(0, (a, b) => a > b ? a : b);
    if (max == 0) return List.filled(7, 0.0);
    return counts.map((c) => c / max).toList();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Xem lại hành trình cảm xúc của bạn',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12.5,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: RelaxTheme.purple.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Theo tuần',
                      style: TextStyle(
                        color: RelaxTheme.lavender,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: RelaxTheme.lavender,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: MoodLineChart(compact: true, data: _chartData),
              ),
              if (moodHistory.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _StressDropPanel(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Side panel "Tuần này / Giảm stress X% / So với tuần trước".
class _StressDropPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: RelaxTheme.purple.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tuần này',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bấm xem chi tiết',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                  color: context.relax.muted,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                size: 14,
                color: RelaxTheme.lavender,
              ),
              const SizedBox(width: 4),
              Text(
                'Mở rộng',
                style: TextStyle(
                  color: RelaxTheme.lavender,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  APPEARANCE (3 pills)
// ════════════════════════════════════════════════════════════════════════════

class _AppearanceBody extends StatelessWidget {
  const _AppearanceBody({
    required this.tab,
    required this.onTabChanged,
    required this.appTheme,
  });
  final String tab;
  final ValueChanged<String> onTabChanged;
  final BackendAppTheme? appTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thay đổi màu sắc của app',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12.5,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ThemePill(
                icon: Icons.light_mode_rounded,
                label: 'Light',
                selected: tab == 'light',
                onTap: () => onTabChanged('light'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ThemePill(
                icon: Icons.dark_mode_rounded,
                label: 'Dark',
                selected: tab == 'dark',
                onTap: () => onTabChanged('dark'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ThemePill(
                icon: Icons.auto_awesome,
                label: 'Customs',
                selected: tab == 'custom',
                onTap: () => onTabChanged('custom'),
              ),
            ),
          ],
        ),
        if (appTheme != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ColorSwatch(
                  color: _hex(appTheme!.primaryColor, RelaxTheme.purple),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ColorSwatch(
                  color: _hex(appTheme!.accentColor, RelaxTheme.lavender),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ThemePill extends StatelessWidget {
  const _ThemePill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? RelaxTheme.purple : context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? RelaxTheme.purple : context.relax.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : context.relax.muted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : context.relax.muted,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  TAP ROW & CHIPS
// ════════════════════════════════════════════════════════════════════════════

class _TapRow extends StatelessWidget {
  const _TapRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.danger = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? context.relax.danger : RelaxTheme.lavender;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: danger ? color : null,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11.5,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
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

class _PurpleChip extends StatelessWidget {
  const _PurpleChip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: RelaxTheme.purple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  FOOTER HINTS
// ════════════════════════════════════════════════════════════════════════════

class _HintsFooter extends StatelessWidget {
  const _HintsFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: context.relax.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '✦ MỘT SỐ LƯU Ý NHỎ ✦',
                  style: TextStyle(
                    fontSize: 11,
                    color: RelaxTheme.lavender,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(child: Divider(color: context.relax.border)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: _HintCol(
                  icon: Icons.notifications_active_outlined,
                  title: 'Thông báo\nthông minh',
                  body: 'Sau 21:00 sẽ hạn chế thông báo nếu bạn ≤ 32 tuổi ~',
                ),
              ),
              Expanded(
                child: _HintCol(
                  icon: Icons.volume_up_outlined,
                  title: 'Âm thanh\ndễ thương',
                  body:
                      'Chỉ dùng tiếng mèo con kêu để thông báo, nhẹ nhàng và không gây khó chịu.',
                ),
              ),
              Expanded(
                child: _HintCol(
                  icon: Icons.bar_chart_rounded,
                  title: 'Thống kê\ntrực quan',
                  body:
                      'Theo dõi cảm xúc theo ngày, tuần, tháng để bạn hiểu bản thân mình hơn mỗi ngày.',
                ),
              ),
              Expanded(
                child: _HintCol(
                  icon: Icons.lock_outline_rounded,
                  title: 'Quyền\nriêng tư',
                  body:
                      'Dữ liệu của bạn được bảo mật an toàn. Bạn toàn quyền kiểm soát tài khoản của mình.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HintCol extends StatelessWidget {
  const _HintCol({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: RelaxTheme.purple.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: RelaxTheme.lavender),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: RelaxTheme.lavender,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 9.5,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════════════════════

Color _hex(String s, Color fb) {
  final v = s.replaceFirst('#', '').trim();
  if (v.length != 6) return fb;
  final n = int.tryParse('FF$v', radix: 16);
  return n == null ? fb : Color(n);
}
