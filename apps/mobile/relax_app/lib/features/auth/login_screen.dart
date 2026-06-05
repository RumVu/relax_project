import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../app/app_copy.dart';
import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/mobile_content_service.dart';
import '../../data/services/relax_catalog_service.dart';
import '../../data/models/app_models.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';
import '../shell/app_shell.dart';
import 'register_screen.dart';

// Google Sign-In v7 dùng singleton instance.
// Để bật Google Sign-In: chạy với `--dart-define=GOOGLE_CLIENT_ID=<ios-client-id>`
// VÀ thêm URL scheme (reversed CLIENT_ID) vào ios/Runner/Info.plist.
final _gsi = GoogleSignIn.instance;
const _googleClientId = String.fromEnvironment(
  'GOOGLE_CLIENT_ID',
  defaultValue: '',
);
bool get _googleEnabled => _googleClientId.isNotEmpty;

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    this.catalogRepository,
    this.contentRepository,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final RelaxCatalogRepository? catalogRepository;
  final MobileContentRepository? contentRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  bool _googleSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _navigateToShell() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => RelaxShell(
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
          onLanguageChanged: widget.onLanguageChanged,
          catalogRepository: widget.catalogRepository,
          contentRepository: widget.contentRepository,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _submitting = true; _error = null; });
    try {
      final auth = AuthService();
      final result = await auth.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      final session = context.session;
      await session.apply(
        access: result.accessToken,
        refresh: result.refreshToken,
        user: result.user,
      );
      if (!mounted) return;
      _navigateToShell();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!_googleEnabled) {
      setState(() => _error =
          'Google Sign-In chưa được cấu hình. Build với --dart-define=GOOGLE_CLIENT_ID=... và setup Info.plist URL scheme.');
      return;
    }
    setState(() { _googleSubmitting = true; _error = null; });
    try {
      await _gsi.initialize(clientId: _googleClientId);
      final account = await _gsi.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw Exception('Không lấy được Google ID token');

      final auth = AuthService();
      final result = await auth.googleLogin(idToken: idToken);
      if (!mounted) return;
      final session = context.session;
      await session.apply(
        access: result.accessToken,
        refresh: result.refreshToken,
        user: result.user,
      );
      if (!mounted) return;
      _navigateToShell();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (!msg.contains('cancel') && !msg.contains('Cancel')) {
        setState(() => _error = 'Google Sign-In thất bại: $msg');
      }
    } finally {
      if (mounted) setState(() => _googleSubmitting = false);
    }
  }

  void _goRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
          onLanguageChanged: widget.onLanguageChanged,
          catalogRepository: widget.catalogRepository,
          contentRepository: widget.contentRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _submitting || _googleSubmitting;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Form(
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
                const SizedBox(height: 4),
                Text(
                  'Chào mừng quay lại ~',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Đăng nhập để mình nâng niu trút bỏ nỗi buồn của bạn 💜',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Center(
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: const PixelCatScene(scene: CatScene.wave),
                  ),
                ),
                const SizedBox(height: 18),
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
                    if (!s.contains('@')) return 'Email chưa đúng định dạng';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if ((v ?? '').isEmpty) return 'Nhập mật khẩu nha';
                    if ((v ?? '').length < 6) return 'Mật khẩu ≥ 6 ký tự';
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
                const SizedBox(height: 18),
                PixelButton(
                  icon: Icons.login_rounded,
                  label: _submitting ? 'Đang vào…' : 'Đăng nhập',
                  filled: true,
                  onPressed: busy ? () {} : () => _submit(),
                ),
                if (_googleEnabled) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Divider(color: context.relax.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'hoặc',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.relax.muted,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: context.relax.border)),
                    ],
                  ),
                  const SizedBox(height: 10),
                ] else
                  const SizedBox(height: 10),
                if (_googleEnabled) ...[
                  InkWell(
                    onTap: busy ? null : _signInWithGoogle,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: busy
                              ? context.relax.border
                              : RelaxTheme.purple.withValues(alpha: .4),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: RelaxTheme.purple.withValues(alpha: .06),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_googleSubmitting)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const _GoogleIcon(),
                          const SizedBox(width: 10),
                          Text(
                            _googleSubmitting
                                ? 'Đang kết nối Google...'
                                : 'Đăng nhập với Google',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: busy ? context.relax.muted : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                PixelButton(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Tạo tài khoản mới',
                  onPressed: busy ? () {} : _goRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Google "G" icon bằng Text vì không có package icon
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
