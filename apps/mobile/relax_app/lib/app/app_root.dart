import 'package:flutter/material.dart';

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
        theme: RelaxTheme.light(),
        darkTheme: RelaxTheme.dark(),
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
                    child: child ?? const SizedBox.shrink(),
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
