import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/auth_state.dart';
import '../core/env.dart';
import '../core/theme.dart';
import '../widgets/soft_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'dashboard.demo@relax.local');
  final _passwordCtrl = TextEditingController(text: 'Relax123!@#');
  bool _busy = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    showSoftToast(context,
        message: 'Đã chọn đăng nhập bằng Email. Đang tiến hành...',
        tone: SoftToastTone.info);
    debugPrint('=== [ĐÃ CHỌN ĐĂNG NHẬP: EMAIL LÀM BẰNG TAY] ===');
    debugPrint('Tiến hành đăng nhập bằng email: ${_emailCtrl.text}');
    setState(() => _busy = true);
    final auth = context.read<AuthState>();
    final ok = await auth.login(_emailCtrl.text, _passwordCtrl.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      final token = await RelaxApi.instance.accessToken;
      debugPrint('=== [ĐĂNG NHẬP EMAIL THÀNH CÔNG] ===');
      debugPrint('Backend Access Token: $token');
      if (mounted) {
        showSoftToast(context,
            message: 'Đăng nhập thành công! Đang vào ứng dụng...',
            tone: SoftToastTone.success);
        debugPrint('Tiến hành chuyển hướng vào màn hình Home...');
        context.go('/home');
      }
    } else {
      debugPrint('=== [ĐĂNG NHẬP EMAIL THẤT BẠI]: ${auth.error} ===');
      showSoftToast(context,
          message: auth.error ?? 'Đăng nhập thất bại',
          tone: SoftToastTone.error);
    }
  }

  Future<void> _loginWithGoogle() async {
    showSoftToast(context,
        message: 'Đã chọn đăng nhập bằng Google. Đang kết nối...',
        tone: SoftToastTone.info);
    debugPrint('=== [ĐÃ CHỌN ĐĂNG NHẬP: GOOGLE SIGN-IN] ===');
    setState(() => _busy = true);
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        serverClientId: Env.googleServerClientId,
      );
      debugPrint('Đang kích hoạt Google Sign-In SDK...');
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        debugPrint('=== [GOOGLE SIGN-IN BỊ HỦY BỞI NGƯỜI DÙNG] ===');
        if (!mounted) return;
        showSoftToast(context,
            message: 'Đăng nhập Google bị hủy bởi người dùng',
            tone: SoftToastTone.info);
        setState(() => _busy = false);
        return;
      }

      debugPrint('Google Sign-In thành công cho tài khoản: ${account.email}');
      if (mounted) {
        showSoftToast(context,
            message: 'Đăng nhập Google thành công. Đang lấy xác thực...',
            tone: SoftToastTone.info);
      }
      debugPrint('Đang lấy Google Authentication details...');
      final GoogleSignInAuthentication authDetails = await account.authentication;
      final idToken = authDetails.idToken;
      final accessToken = authDetails.accessToken;

      debugPrint('Google ID Token lấy được: $idToken');
      debugPrint('Google Access Token lấy được: $accessToken');

      if (idToken == null) {
        debugPrint('=== [GOOGLE SIGN-IN THẤT BẠI]: Không lấy được ID Token ===');
        if (mounted) {
          showSoftToast(context,
              message: 'Không lấy được Google ID Token',
              tone: SoftToastTone.error);
        }
        setState(() => _busy = false);
        return;
      }

      if (!mounted) return;
      final auth = context.read<AuthState>();
      debugPrint('Đang gửi ID Token lên backend để xác thực...');
      showSoftToast(context,
          message: 'Đang gửi ID Token xác thực với máy chủ...',
          tone: SoftToastTone.info);
      final ok = await auth.loginWithGoogle(idToken: idToken, accessToken: accessToken);

      if (mounted) {
        setState(() => _busy = false);
        if (ok) {
          final token = await RelaxApi.instance.accessToken;
          if (!mounted) return;
          debugPrint('=== [ĐĂNG NHẬP GOOGLE THÀNH CÔNG] ===');
          debugPrint('Backend Access Token: $token');
          showSoftToast(context,
              message: 'Đăng nhập Google thành công! Đang vào ứng dụng...',
              tone: SoftToastTone.success);
          debugPrint('Tiến hành chuyển hướng vào màn hình Home...');
          context.go('/home');
        } else {
          debugPrint('=== [ĐĂNG NHẬP GOOGLE THẤT BẠI]: ${auth.error} ===');
          showSoftToast(context,
              message: auth.error ?? 'Đăng nhập Google thất bại',
              tone: SoftToastTone.error);
        }
      }
    } catch (e) {
      debugPrint('=== [GOOGLE SIGN-IN GẶP NGOẠI LỆ]: $e ===');
      if (mounted) {
        setState(() => _busy = false);
        showSoftToast(context,
            message: 'Lỗi đăng nhập Google: $e',
            tone: SoftToastTone.error);
      }
    }
  }

  Future<void> _simulateGoogleLogin() async {
    debugPrint('=== [ĐÃ CHỌN ĐĂNG NHẬP: GIẢ LẬP GOOGLE BYPASS] ===');
    setState(() => _busy = true);
    final auth = context.read<AuthState>();
    final ok = await auth.login('dashboard.demo@relax.local', 'Relax123!@#');
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      debugPrint('=== [ĐĂNG NHẬP GIẢ LẬP THÀNH CÔNG] ===');
      debugPrint('Tiến hành chuyển hướng vào màn hình Home...');
      showSoftToast(context,
          message: 'Bypass: Đăng nhập giả lập Google thành công!',
          tone: SoftToastTone.success);
      context.go('/home');
    } else {
      debugPrint('=== [ĐĂNG NHẬP GIẢ LẬP THẤT BẠI]: ${auth.error} ===');
      showSoftToast(context,
          message: auth.error ?? 'Đăng nhập giả lập thất bại',
          tone: SoftToastTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand hero
                    Container(
                      height: 84,
                      width: 84,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [RelaxColors.violet, RelaxColors.plum],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: RelaxColors.violet.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.spa_outlined,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Chào mừng tới Relax',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Đăng nhập để xem cảm xúc và nhiệm vụ hôm nay của bạn.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: RelaxColors.slate,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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
                      autofillHints: const [AutofillHints.password],
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
                        if ((value ?? '').isEmpty) return 'Hãy nhập mật khẩu';
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
                            : const Text('Đăng nhập'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: RelaxColors.slate, endIndent: 8, indent: 8)),
                        Text('Hoặc', style: TextStyle(color: RelaxColors.slate, fontSize: 13)),
                        Expanded(child: Divider(color: RelaxColors.slate, endIndent: 8, indent: 8)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: context.fieldBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _busy ? null : _loginWithGoogle,
                        onLongPress: _busy ? null : _simulateGoogleLogin,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_"G"_logo.svg/320px-Google_"G"_logo.svg.png',
                              height: 18,
                              width: 18,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.g_mobiledata,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Đăng nhập bằng Google',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Chưa có tài khoản? ',
                          style: TextStyle(color: RelaxColors.slate),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: const Text(
                            'Đăng ký',
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
