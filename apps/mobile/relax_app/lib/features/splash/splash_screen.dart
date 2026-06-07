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
    this.onAccentChanged,
  });

  final Widget child;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeChanged;
  final dynamic onLanguageChanged;
  final ValueChanged<Color>? onAccentChanged;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _minSplashElapsed = false;
  bool _prefsLoaded = false;
  bool _maxSplashElapsed = false; // safety net khi session bootstrap kẹt
  bool _onboardingDone = false;
  SessionState? _watchedSession;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    // Min splash 3s — đủ thời gian để user nhận diện brand "Thi Ái Chill"
    // (cat scene + title + tagline + linear progress).
    Future<void>.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _minSplashElapsed = true);
    });
    // Max wait — fallback nếu session bootstrap không xong sau 3.8s (offline,
    // network timeout, secure storage block trong test...) → route đi tiếp.
    Future<void>.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) setState(() => _maxSplashElapsed = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe SessionState để rebuild khi isBooting flip false
    final session = SessionScope.maybeOf(context);
    if (session != _watchedSession) {
      _watchedSession?.removeListener(_onSessionChanged);
      _watchedSession = session;
      _watchedSession?.addListener(_onSessionChanged);
    }
  }

  @override
  void dispose() {
    _watchedSession?.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPrefs() async {
    final prefs = await AppPreferences.instance();
    if (!mounted) return;
    setState(() {
      _onboardingDone = prefs.onboardingDone;
      _prefsLoaded = true;
    });
  }

  /// Splash chỉ tắt khi:
  ///   1. Min duration (3s) đã trôi qua VÀ
  ///   2. (AppPreferences load + SessionState bootstrap xong) HOẶC max wait
  ///      (3.8s) đã trôi qua như safety net.
  /// Tránh race: trước đây splash tắt sau 1250ms cứng → nếu session bootstrap
  /// chậm hơn → user logged-in vẫn bị đá về Login screen. Max wait handles
  /// offline + test env nơi method channels không có platform mock.
  bool get _ready {
    if (!_minSplashElapsed) return false;
    if (_maxSplashElapsed) return true; // safety net
    if (!_prefsLoaded) return false;
    final session = _watchedSession;
    if (session != null && session.isBooting) return false;
    return true;
  }

  Widget _routeTarget() {
    final session = _watchedSession;
    // Đã login → vào thẳng shell, skip onboarding
    if (session != null && session.isLoggedIn) {
      return RelaxShell(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged ?? (_) {},
        onLanguageChanged: widget.onLanguageChanged ?? (_) {},
        onAccentChanged: widget.onAccentChanged,
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
      child: _ready ? _routeTarget() : const SplashScreen(),
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
                  child: Transform.scale(
                    scale: .86 + value * .14,
                    child: child,
                  ),
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
