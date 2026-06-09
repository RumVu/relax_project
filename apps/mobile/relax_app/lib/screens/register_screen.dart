import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/auth_state.dart';
import '../core/locale_controller.dart';
import '../core/theme.dart';
import '../widgets/soft_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _busy = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    showSoftToast(context,
        message: context.t('Đang tiến hành tạo tài khoản...'),
        tone: SoftToastTone.info);
    setState(() => _busy = true);
    final auth = context.read<AuthState>();
    final ok = await auth.register(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      name: _nameCtrl.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      final token = await RelaxApi.instance.accessToken;
      debugPrint('=== [ĐĂNG KÝ THÀNH CÔNG] ===');
      debugPrint('Backend Access Token: $token');
      if (mounted) {
        showSoftToast(context,
            message: context.t('Đăng ký thành công! Đang vào ứng dụng...'),
            tone: SoftToastTone.success);
        context.go('/home');
      }
    } else {
      showSoftToast(context,
          message: context.t(auth.error ?? 'Đăng ký thất bại'),
          tone: SoftToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
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
                      controller: _nameCtrl,
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
                      controller: _emailCtrl,
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
                      controller: _passwordCtrl,
                      obscureText: _hidePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: context.t('Mật khẩu'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                      validator: (value) {
                        final v = value ?? '';
                        if (v.length < 8) return context.t('Mật khẩu cần ít nhất 8 ký tự');
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
                      controller: _confirmCtrl,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: context.t('Nhập lại mật khẩu'),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value != _passwordCtrl.text) {
                          return context.t('Hai mật khẩu chưa trùng nhau');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
