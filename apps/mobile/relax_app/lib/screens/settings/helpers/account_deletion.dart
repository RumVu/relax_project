import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/auth_state.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';

// Two-step account deletion flow: choose mode, then confirm with password.
Future<void> confirmAccountDeletion(BuildContext context) async {
  final mode = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.t('Xóa tài khoản?')),
      content: Text(
        context.t(
            'Chọn cách xóa:\n\n• Ẩn danh: giữ lại dữ liệu thống kê nhưng xóa thông tin cá nhân.\n• Xóa vĩnh viễn: xóa toàn bộ — không thể khôi phục.'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.t('Hủy bỏ')),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx, 'SOFT'),
          child: Text(context.t('Ẩn danh')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: RelaxColors.coral),
          onPressed: () => Navigator.pop(ctx, 'HARD'),
          child: Text(context.t('Xóa vĩnh viễn')),
        ),
      ],
    ),
  );
  if (mode == null || !context.mounted) return;

  final passwordCtrl = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(mode == 'HARD'
          ? context.t('Xóa vĩnh viễn?')
          : context.t('Ẩn danh tài khoản?')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mode == 'HARD'
                ? context.t(
                    'Nhập mật khẩu để xác nhận. Tất cả dữ liệu sẽ bị xóa!')
                : context.t(
                    'Nhập mật khẩu để xác nhận ẩn danh hóa tài khoản.'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: context.t('Mật khẩu'),
              hintText: context.t('Để trống nếu dùng Google Sign-In'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(context.t('Hủy')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                mode == 'HARD' ? RelaxColors.coral : RelaxColors.violet,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(context.t('Xác nhận')),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    final body = <String, dynamic>{'mode': mode};
    final pw = passwordCtrl.text.trim();
    if (pw.isNotEmpty) body['password'] = pw;

    final res = await RelaxApi.instance.delete('/auth/me', body: body);
    if (!context.mounted) return;

    if (res.statusCode == 200 || res.statusCode == 201) {
      await context.read<AuthState>().logout();
      if (context.mounted) {
        showSoftToast(context,
            message: mode == 'HARD'
                ? context.t('Tài khoản đã bị xóa vĩnh viễn.')
                : context.t('Tài khoản đã được ẩn danh hóa.'),
            tone: SoftToastTone.success);
        context.go('/login');
      }
    } else {
      final msg =
          (res.data is Map ? res.data['message'] as String? : null) ??
              'Không xóa được tài khoản.';
      showSoftToast(context, message: msg, tone: SoftToastTone.error);
    }
  } catch (e) {
    if (context.mounted) {
      showSoftToast(context,
          message: 'Lỗi: $e', tone: SoftToastTone.error);
    }
  }
}
