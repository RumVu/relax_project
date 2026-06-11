import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
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
      debugPrint('=== [ĐĂNG KÝ THÀNH CÔNG] ===');
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
              child: RegisterForm(
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
            ),
          ),
        ),
      ),
    );
  }
}
