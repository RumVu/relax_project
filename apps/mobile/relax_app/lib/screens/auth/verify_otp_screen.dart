import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/cat_mascot.dart';
import '../../widgets/soft_toast.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String purpose;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.purpose = 'registration',
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _busy = false;
  int _cooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
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

  Future<void> _verify() async {
    final code = _otpCtrl.text.trim();
    if (code.length != 6) return;

    setState(() => _busy = true);
    HapticFeedback.mediumImpact();

    try {
      final res = await RelaxApi.instance.post('/auth/otp/verify', body: {
        'email': widget.email,
        'code': code,
      });

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data as Map<String, dynamic>?;
        if (data != null && data['accessToken'] != null) {
          final auth = context.read<AuthState>();
          await auth.loginWithTokens(
            accessToken: data['accessToken'] as String,
            refreshToken: data['refreshToken'] as String?,
            user: data['user'] as Map<String, dynamic>?,
          );
          if (mounted) {
            showSoftToast(context,
                message: context.t('Xác thực thành công!'),
                tone: SoftToastTone.success);
            context.go('/home');
          }
          return;
        }
      }

      if (mounted) {
        showSoftToast(context,
            message: context.t('Mã OTP không đúng hoặc đã hết hạn'),
            tone: SoftToastTone.error);
      }
    } catch (e) {
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
        'email': widget.email,
        'purpose': widget.purpose,
      });
      if (!mounted) return;
      showSoftToast(context,
          message: context.t('Đã gửi lại mã OTP'),
          tone: SoftToastTone.success);
      _startCooldown();
    } catch (_) {
      if (mounted) {
        showSoftToast(context,
            message: context.t('Không thể gửi lại mã. Thử lại sau.'),
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
          onPressed: () => context.go('/register'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const CatMascot(
                      size: 80, variant: CatVariant.stand, glow: false),
                  const SizedBox(height: 20),
                  Text(
                    context.t('Xác thực email'),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${context.t('Nhập mã 6 số đã gửi tới')}\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.mutedText,
                      fontSize: 14,
                      height: 1.5,
                    ),
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
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    onChanged: (_) {},
                    onCompleted: (_) => _verify(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          _busy || _otpCtrl.text.trim().length != 6
                              ? null
                              : _verify,
                      child: _busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.6, color: Colors.white),
                            )
                          : Text(context.t('Xác thực')),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _cooldown > 0 ? null : _resend,
                    child: Text(
                      _cooldown > 0
                          ? '${context.t('Gửi lại mã sau')} ${_cooldown}s'
                          : context.t('Gửi lại mã'),
                      style: TextStyle(
                        color: _cooldown > 0
                            ? context.mutedText
                            : RelaxColors.violet,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
