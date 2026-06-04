import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/auth_state.dart';
import '../core/theme.dart';
import '../core/theme_controller.dart';

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Cài đặt',
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _ProfileHero(name: name, email: email, avatar: avatar, role: role),
            const SizedBox(height: 24),
            const _SectionLabel('Tài khoản'),
            _Card(
              children: [
                _Row(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: email,
                ),
                const _Divider(),
                _Row(
                  icon: Icons.shield_outlined,
                  title: 'Vai trò',
                  subtitle: role,
                ),
                const _Divider(),
                _Row(
                  icon: Icons.verified_outlined,
                  title: 'Xác thực email',
                  subtitle: (user?['emailVerified'] == true)
                      ? 'Đã xác thực'
                      : 'Chưa xác thực',
                  trailing: (user?['emailVerified'] == true)
                      ? const Icon(Icons.check_circle, color: RelaxColors.mint)
                      : const Icon(Icons.warning_amber_rounded,
                          color: RelaxColors.coral),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Tùy chỉnh'),
            _Card(
              children: [
                _Row(
                  icon: Icons.language_outlined,
                  title: 'Ngôn ngữ',
                  subtitle: 'Tiếng Việt',
                  onTap: () => _showNotImplemented(context),
                ),
                const _Divider(),
                _Row(
                  icon: Icons.notifications_outlined,
                  title: 'Thông báo',
                  subtitle: 'Quản lý nhắc nhở hàng ngày',
                  onTap: () => _showNotImplemented(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Giao diện'),
            const _ThemeToggleCard(),
            const SizedBox(height: 24),
            const _SectionLabel('Hỗ trợ'),
            _Card(
              children: [
                _Row(
                  icon: Icons.help_outline,
                  title: 'Trung tâm trợ giúp',
                  subtitle: 'Câu hỏi thường gặp',
                  onTap: () => _showNotImplemented(context),
                ),
                const _Divider(),
                _Row(
                  icon: Icons.info_outline,
                  title: 'Giới thiệu',
                  subtitle: 'Phiên bản 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _LogoutButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: RelaxColors.violet,
      content: Text('Tính năng đang được hoàn thiện ở phiên bản kế.'),
    ));
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
}

class _ProfileHero extends StatelessWidget {
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
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            foregroundImage:
                avatar != null ? NetworkImage(avatar!) : null,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: RelaxColors.violet,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          onTap: () => controller.setMode(m),
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
