import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/auth_service.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';

/// Quên mật khẩu — gửi email reset, không cần auth.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _submitting = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService().forgotPassword(email: _emailCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _sent = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        // Vẫn show success-style để tránh email enumeration. Chỉ log error.
        _sent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: _sent ? _buildSentView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quên mật khẩu?',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Nhập email đã đăng ký. Mình sẽ gửi link đặt lại mật khẩu vào hộp thư của bạn.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 30),
          const Center(
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: PixelCatScene(scene: CatScene.window),
            ),
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return 'Nhập email nha';
              if (!RegExp(r"^[\w.\-+]+@[\w\-]+(\.[\w\-]+)+$").hasMatch(s)) {
                return 'Email chưa đúng định dạng';
              }
              return null;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.relax.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 20),
          PixelButton(
            icon: _submitting
                ? Icons.hourglass_top_rounded
                : Icons.email_outlined,
            label: _submitting ? 'Đang gửi...' : 'Gửi email đặt lại',
            filled: true,
            onPressed: _submitting ? null : () => _submit(),
          ),
        ],
      ),
    );
  }

  Widget _buildSentView() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const Spacer(),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: RelaxTheme.purple.withValues(alpha: .15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: RelaxTheme.purple,
            size: 44,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Đã gửi rồi nè ✦',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Mình đã gửi email tới ${_emailCtrl.text.trim()} với hướng dẫn đặt lại mật khẩu. Nhớ kiểm tra cả mục spam nha.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const Spacer(flex: 2),
        PixelButton(
          icon: Icons.login_rounded,
          label: 'Về trang đăng nhập',
          filled: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
