import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

// Registration form with name, email, password, and confirm fields.
class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.busy,
    required this.hidePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool busy;
  final bool hidePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.t('Tạo tài khoản mới'),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('Vài giây thôi, không cần thẻ ngân hàng.'),
            style: const TextStyle(color: RelaxColors.slate, fontSize: 14),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: nameCtrl,
            autofillHints: const [AutofillHints.name],
            decoration: InputDecoration(
              labelText: context.t('Tên hiển thị'),
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return context.t('Hãy nhập tên hiển thị');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: context.t('Email'),
              prefixIcon: const Icon(Icons.alternate_email),
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return context.t('Hãy nhập email');
              if (!v.contains('@')) return context.t('Email chưa đúng định dạng');
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordCtrl,
            obscureText: hidePassword,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: context.t('Mật khẩu'),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            validator: (value) {
              final v = value ?? '';
              if (v.length < 8) {
                return context.t('Mật khẩu cần ít nhất 8 ký tự');
              }
              if (!RegExp(r'[A-Z]').hasMatch(v)) {
                return context.t('Cần ít nhất 1 chữ HOA');
              }
              if (!RegExp(r'[0-9]').hasMatch(v)) {
                return context.t('Cần ít nhất 1 chữ số');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: confirmCtrl,
            obscureText: hidePassword,
            decoration: InputDecoration(
              labelText: context.t('Nhập lại mật khẩu'),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            validator: (value) {
              if (value != passwordCtrl.text) {
                return context.t('Hai mật khẩu chưa trùng nhau');
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: busy ? null : onSubmit,
              child: busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.t('Tạo tài khoản')),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.t('Đã có tài khoản? '),
                style: const TextStyle(color: RelaxColors.slate),
              ),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text(
                  context.t('Đăng nhập'),
                  style: const TextStyle(
                    color: RelaxColors.violet,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
