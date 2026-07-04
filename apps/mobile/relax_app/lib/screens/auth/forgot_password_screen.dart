import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/cat_mascot.dart';
import '../../widgets/soft_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum _Step { email, otp, done }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _busy = false;
  bool _hidePassword = true;
  _Step _step = _Step.email;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _cooldown--;
        if (_cooldown <= 0) {
          t.cancel();
        }
      });
    });
  }

  Future<void> _requestOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) return;

    setState(() => _busy = true);
    try {
      await RelaxApi.instance.post('/auth/password-reset/request', body: {
        'email': email,
      });
      if (!mounted) return;
      setState(() => _step = _Step.otp);
      _startCooldown();
    } catch (_) {
      if (mounted) {
        showSoftToast(context,
            message: context.t('Không thể gửi mã. Thử lại sau.'),
            tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final code = _otpCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (code.length != 6 || password.length < 10) return;

    setState(() => _busy = true);
    HapticFeedback.mediumImpact();

    try {
      await RelaxApi.instance.post('/auth/password-reset/otp', body: {
        'email': _emailCtrl.text.trim(),
        'code': code,
        'password': password,
      });
      if (!mounted) return;
      setState(() => _step = _Step.done);
    } catch (_) {
      if (mounted) {
        showSoftToast(context,
            message: context.t('Mã OTP không đúng hoặc đã hết hạn'),
            tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_cooldown > 0) return;
    try {
      await RelaxApi.instance.post('/auth/otp/resend', body: {
        'email': _emailCtrl.text.trim(),
        'purpose': 'password-reset',
      });
      if (!mounted) return;
      showSoftToast(context,
          message: context.t('Đã gửi lại mã OTP'),
          tone: SoftToastTone.success);
      _startCooldown();
    } catch (_) {
      if (mounted) {
        showSoftToast(context,
            message: context.t('Không thể gửi lại mã'),
            tone: SoftToastTone.error);
      }
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
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.email:
        return _emailStep();
      case _Step.otp:
        return _otpStep();
      case _Step.done:
        return _doneStep();
    }
  }

  Widget _emailStep() {
    return Column(
      children: [
        const CatMascot(size: 80, variant: CatVariant.sleep, glow: false),
        const SizedBox(height: 20),
        Text(
          context.t('Quên mật khẩu'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          context.t('Nhập email để nhận mã đặt lại mật khẩu'),
          textAlign: TextAlign.center,
          style: TextStyle(color: context.mutedText, fontSize: 14),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: context.t('Email'),
            prefixIcon: const Icon(Icons.alternate_email),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _busy ? null : _requestOtp,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.6, color: Colors.white),
                  )
                : Text(context.t('Gửi mã OTP')),
          ),
        ),
      ],
    );
  }

  Widget _otpStep() {
    return Column(
      children: [
        const CatMascot(size: 80, variant: CatVariant.stand, glow: false),
        const SizedBox(height: 20),
        Text(
          context.t('Nhập mã OTP'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          '${context.t('Mã đã gửi tới')}\n${_emailCtrl.text.trim()}',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.mutedText, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 32),
        PinCodeTextField(
          appContext: context,
          controller: _otpCtrl,
          length: 6,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          animationType: AnimationType.fade,
          autoFocus: true,
          enabled: !_busy,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 56,
            fieldWidth: 46,
            activeFillColor: context.surface,
            inactiveFillColor: context.surface,
            selectedFillColor: context.surface,
            activeColor: RelaxColors.violet,
            inactiveColor: context.fieldBorder,
            selectedColor: RelaxColors.violet,
          ),
          enableActiveFill: true,
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: _hidePassword,
          decoration: InputDecoration(
            labelText: context.t('Mật khẩu mới'),
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
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.t('Tối thiểu 10 ký tự, chữ hoa, chữ thường, số và ký tự đặc biệt'),
            style: TextStyle(fontSize: 11, color: context.mutedText),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _busy ? null : _resetPassword,
            child: _busy
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.6, color: Colors.white),
                  )
                : Text(context.t('Đặt lại mật khẩu')),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _cooldown > 0 ? null : _resend,
          child: Text(
            _cooldown > 0
                ? '${context.t('Gửi lại mã sau')} ${_cooldown}s'
                : context.t('Gửi lại mã'),
            style: TextStyle(
              color: _cooldown > 0 ? context.mutedText : RelaxColors.violet,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _doneStep() {
    return Column(
      children: [
        const CatMascot(size: 80, variant: CatVariant.stand, glow: true),
        const SizedBox(height: 20),
        Text(
          context.t('Đổi mật khẩu thành công!'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          context.t('Bạn có thể đăng nhập bằng mật khẩu mới.'),
          textAlign: TextAlign.center,
          style: TextStyle(color: context.mutedText, fontSize: 14),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: Text(context.t('Đăng nhập')),
          ),
        ),
      ],
    );
  }
}
