import 'package:flutter/material.dart';
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

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  void _setLanguage(AppLanguage language) {
    setState(() => _language = language);
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thi Ai Chill',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: RelaxTheme.light(),
      darkTheme: RelaxTheme.dark(),
      builder: (context, child) {
        return AppCopyScope(
          copy: AppCopy(_language),
          child: SessionScope(
            session: _session,
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
        child: OnboardingScreen(
          themeMode: _themeMode,
          onThemeChanged: _setThemeMode,
          onLanguageChanged: _setLanguage,
          catalogRepository: widget.catalogRepository,
          contentRepository: widget.contentRepository,
        ),
      ),
    );
  }
}
