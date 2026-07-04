import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/cat_mascot.dart';
import '../../widgets/soft_toast.dart';
import 'widgets/register_form.dart';

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

    try {
      final res = await RelaxApi.instance.post('/auth/register', body: {
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
        'name': _nameCtrl.text.trim(),
      });

      if (!mounted) return;
      setState(() => _busy = false);

      final data = res.data as Map<String, dynamic>?;
      if (data != null && data['requiresOtp'] == true) {
        final email = data['email'] as String? ?? _emailCtrl.text.trim();
        showSoftToast(context,
            message: context.t('Mã OTP đã gửi tới email của bạn'),
            tone: SoftToastTone.success);
        context.go('/verify-otp?email=${Uri.encodeComponent(email)}&purpose=registration');
      } else {
        showSoftToast(context,
            message: context.t('Đăng ký thất bại'),
            tone: SoftToastTone.error);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      final msg = e.toString().contains('email already exists')
          ? 'Email này đã được sử dụng'
          : 'Đăng ký thất bại';
      showSoftToast(context,
          message: context.t(msg), tone: SoftToastTone.error);
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
              child: Column(
                children: [
                  const CatMascot(size: 80, variant: CatVariant.stand, glow: false),
                  const SizedBox(height: 20),
                  RegisterForm(
                formKey: _formKey,
                nameCtrl: _nameCtrl,
                emailCtrl: _emailCtrl,
                passwordCtrl: _passwordCtrl,
                confirmCtrl: _confirmCtrl,
                busy: _busy,
                hidePassword: _hidePassword,
                onTogglePassword: () =>
                    setState(() => _hidePassword = !_hidePassword),
                onSubmit: _submit,
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
