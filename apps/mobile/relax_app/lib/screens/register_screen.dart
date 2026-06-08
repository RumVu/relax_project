import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/auth_state.dart';
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
      context.go('/home');
    } else {
      showSoftToast(context,
          message: auth.error ?? 'Đăng ký thất bại',
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
                    const Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Vài giây thôi, không cần thẻ ngân hàng.',
                      style: TextStyle(color: RelaxColors.slate, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _nameCtrl,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Tên hiển thị',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Hãy nhập tên hiển thị';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Hãy nhập email';
                        if (!v.contains('@')) return 'Email chưa đúng định dạng';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _hidePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
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
                        if (v.length < 8) return 'Mật khẩu cần ít nhất 8 ký tự';
                        if (!RegExp(r'[A-Z]').hasMatch(v)) {
                          return 'Cần ít nhất 1 chữ HOA';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(v)) {
                          return 'Cần ít nhất 1 chữ số';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _hidePassword,
                      decoration: const InputDecoration(
                        labelText: 'Nhập lại mật khẩu',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value != _passwordCtrl.text) {
                          return 'Hai mật khẩu chưa trùng nhau';
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
                            : const Text('Tạo tài khoản'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Đã có tài khoản? ',
                          style: TextStyle(color: RelaxColors.slate),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(
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
