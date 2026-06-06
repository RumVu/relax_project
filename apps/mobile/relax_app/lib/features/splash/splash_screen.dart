import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/preferences.dart';
import '../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';
import '../auth/login_screen.dart';
import '../shell/app_shell.dart';

/// Splash gate thông minh — sau 1.25s, route theo session + onboarding flag:
///   - Đã login         → RelaxShell (skip onboarding)
///   - Onboarding done  → LoginScreen
///   - Lần đầu          → child (OnboardingScreen)
class SplashGate extends StatefulWidget {
  const SplashGate({
    super.key,
    required this.child,
    this.themeMode = ThemeMode.dark,
    this.onThemeChanged,
    this.onLanguageChanged,
  });

  final Widget child;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeChanged;
  final dynamic onLanguageChanged;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _showSplash = true;
  bool _onboardingDone = false;

  @override
  void initState() {
    super.initState();
    // Preload prefs để biết có cần onboarding không
    _loadPrefs();
    Future<void>.delayed(const Duration(milliseconds: 1250), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await AppPreferences.instance();
    if (!mounted) return;
    setState(() => _onboardingDone = prefs.onboardingDone);
  }

  Widget _routeTarget() {
    final session = SessionScope.maybeOf(context, listen: false);
    // Đã login → vào thẳng shell, skip onboarding
    if (session != null && session.isLoggedIn) {
      return RelaxShell(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged ?? (_) {},
        onLanguageChanged: widget.onLanguageChanged ?? (_) {},
      );
    }
    // Đã qua onboarding → login
    if (_onboardingDone) {
      return LoginScreen(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged ?? (_) {},
        onLanguageChanged: widget.onLanguageChanged ?? (_) {},
      );
    }
    // Lần đầu → onboarding
    return widget.child;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showSplash ? const SplashScreen() : _routeTarget(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final copy = context.copy;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0).toDouble(),
                  child: Transform.scale(scale: .86 + value * .14, child: child),
                );
              },
              child: PixelPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PixelCatScene(scene: CatScene.sleep, height: 190),
                    const SizedBox(height: 10),
                    Text(
                      copy.splashTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      copy.splashSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(minHeight: 6),
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
