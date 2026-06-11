import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme.dart';
import '../../../core/auth_state.dart';
import '../../../core/locale_controller.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

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
              title: Text(context.t('Đăng xuất?')),
              content: Text(
                context.t('Bạn sẽ phải đăng nhập lại để dùng app.'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(context.t('Hủy')),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(context.t('Đăng xuất')),
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
        label: Text(context.t('Đăng xuất'),
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
