import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/preferences.dart';
import '../core/session.dart';
import '../data/services/mobile_content_service.dart';
import '../data/services/relax_catalog_service.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/splash/splash_screen.dart';
import 'app_copy.dart';
import 'theme.dart';

class RelaxApp extends StatefulWidget {
  const RelaxApp({super.key, this.catalogRepository, this.contentRepository});

  final RelaxCatalogRepository? catalogRepository;
  final MobileContentRepository? contentRepository;

  @override
  State<RelaxApp> createState() => _RelaxAppState();
}

class _RelaxAppState extends State<RelaxApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  AppLanguage _language = AppLanguage.vi;
  Color _accent = RelaxTheme.purple;
  final SessionState _session = SessionState();
  AppPreferences? _prefs;

  String get _userName => (_session.user?['name'] as String?)?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await AppPreferences.instance();
    if (!mounted) return;
    setState(() {
      _prefs = p;
      _themeMode = p.themeMode;
      _language = p.language;
      _accent = Color(p.accentColorValue);
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    await _prefs?.setThemeMode(mode);
  }

  Future<void> _setLanguage(AppLanguage language) async {
    setState(() => _language = language);
    await _prefs?.setLanguage(language);
  }

  /// Customs theme save → live-apply không cần restart.
  Future<void> _setAccent(Color color) async {
    setState(() => _accent = color);
    await _prefs?.setAccentColorValue(color.toARGB32());
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      session: _session,
      child: MaterialApp(
        title: 'Thi Ai Chill',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: RelaxTheme.light(accent: _accent),
        darkTheme: RelaxTheme.dark(accent: _accent),
        locale: _language == AppLanguage.vi
            ? const Locale('vi')
            : const Locale('en'),
        supportedLocales: const [Locale('vi'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        builder: (context, child) {
          return ListenableBuilder(
            listenable: _session,
            builder: (context, ignored) => AppCopyScope(
              copy: AppCopy(_language, userName: _userName),
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Stack(
                      children: [
                        child ?? const SizedBox.shrink(),
                        // DEV banner luôn visible trong DEBUG để test login flow
                        if (!kReleaseMode) _DevBanner(session: _session),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        home: SplashGate(
          themeMode: _themeMode,
          onThemeChanged: _setThemeMode,
          onLanguageChanged: _setLanguage,
          onAccentChanged: _setAccent,
          child: OnboardingScreen(
            themeMode: _themeMode,
            onThemeChanged: _setThemeMode,
            onLanguageChanged: _setLanguage,
            catalogRepository: widget.catalogRepository,
            contentRepository: widget.contentRepository,
          ),
        ),
      ),
    );
  }
}

/// Small floating banner ở góc trên màn hình — chỉ visible trong DEBUG mode.
/// Tap → bottom sheet với nút "Đăng xuất + Reset onboarding".
class _DevBanner extends StatelessWidget {
  const _DevBanner({required this.session});
  final SessionState session;

  Future<void> _forceLogout(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    await session.logout();
    final prefs = await AppPreferences.instance();
    await prefs.setOnboardingDone(false);
    if (!context.mounted) return;
    // Pop tất cả routes về root → SplashGate sẽ re-route đúng
    navigator.popUntil((r) => r.isFirst);
  }

  void _showSheet(BuildContext context) {
    final loggedIn = session.isLoggedIn;
    final name = (session.user?['name'] as String?) ?? '';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🐛 DEV menu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                loggedIn
                    ? 'Đang đăng nhập: $name\nReset để test login lại.'
                    : 'Chưa đăng nhập.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE85A6A),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await _forceLogout(context);
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Đăng xuất + Reset onboarding'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 4,
      right: 8,
      child: ListenableBuilder(
        listenable: session,
        builder: (_, __) {
          final loggedIn = session.isLoggedIn;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showSheet(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  loggedIn
                      ? Icons.bug_report_rounded
                      : Icons.logout_rounded,
                  color: loggedIn ? Colors.greenAccent : Colors.orangeAccent,
                  size: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
