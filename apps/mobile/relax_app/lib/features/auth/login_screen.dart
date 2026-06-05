import 'package:flutter/material.dart';
import '../../../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../app/app_copy.dart';
import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/mobile_content_service.dart';
import '../../data/services/relax_catalog_service.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';
import '../shell/app_shell.dart';
import 'register_screen.dart';

/// Form đăng nhập đơn giản — pixel style, có nút Đăng kí ở dưới đổi qua
/// [RegisterScreen]. Sau khi login thành công, đẩy thẳng [RelaxShell].
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
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RelaxShell(
            themeMode: widget.themeMode,
            onThemeChanged: widget.onThemeChanged,
            onLanguageChanged: widget.onLanguageChanged,
            catalogRepository: widget.catalogRepository,
            contentRepository: widget.contentRepository,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
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
                  'Đăng nhập để Thi Ái nhớ cảm xúc của bạn nha 💜',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                const Center(
                  child: PixelCatScene(scene: CatScene.wave, height: 150),
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
                        _obscure
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
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
                  onPressed: _submitting ? () {} : () => _submit(),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Sign-In sẽ được thêm vào batch tiếp theo nha 💜'),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.relax.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata, color: context.relax.muted),
                        const SizedBox(width: 8),
                        Text(
                          'Đăng nhập với Google',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                PixelButton(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Tạo tài khoản mới',
                  onPressed: _submitting ? () {} : _goRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
