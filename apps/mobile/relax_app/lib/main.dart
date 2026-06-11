import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/audio_controller.dart';
import 'core/auth_state.dart';
import 'core/locale_controller.dart';
import 'core/page_transitions.dart';
import 'core/theme.dart';
import 'core/theme_controller.dart';
import 'widgets/soft_toast.dart';
import 'core/tour_controller.dart';
import 'core/local_notifications.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/billing/billing_screen.dart';
import 'screens/app_shell.dart';
import 'screens/breathing/breathing_screen.dart';
import 'screens/companion/companion_screen.dart';
import 'screens/companion_chat_screen.dart';
import 'screens/meditation/meditation_screen.dart';
import 'screens/sleep/sleep_screen.dart';
import 'screens/device_info_screen.dart';
import 'screens/journal/journal_screen.dart';
import 'screens/legal_screen.dart';
import 'screens/location_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mood/mood_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/relax/relax_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/sounds/sounds_screen.dart';
import 'screens/weather/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();
  runApp(const RelaxApp());
}

class RelaxApp extends StatefulWidget {
  const RelaxApp({super.key});

  @override
  State<RelaxApp> createState() => _RelaxAppState();
}

class _RelaxAppState extends State<RelaxApp> {
  late final AuthState _auth;
  late final AudioController _audio;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthState();
    _audio = AudioController();
    // Đăng ký cleanup hooks cho logout — reset các per-session
    // flag để user kế tiếp không kế thừa state user cũ.
    _auth.onLogoutCleanup = () {
      RelaxScreen.resetIntroForLogout();
      _audio.stop();
    };
    RelaxApi.onRateLimitExceeded = (msg) {
      if (mounted) {
        showSoftToast(context, message: msg, tone: SoftToastTone.error);
      }
    };
    _router = _buildRouter(_auth);
  }

  @override
  void dispose() {
    _auth.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider.value(value: _audio),
        ChangeNotifierProvider(create: (_) => LocaleController()),
        ChangeNotifierProvider.value(value: TourController.instance),
      ],
      child: Builder(builder: (context) {
        final theme = context.watch<ThemeController>();
        final loc = context.watch<LocaleController>();
        return LocaleScope(
          lang: loc.code,
          child: MaterialApp.router(
            title: 'Relax',
            debugShowCheckedModeBanner: false,
            theme: buildRelaxTheme(accent: theme.accent),
            darkTheme: buildRelaxDarkTheme(accent: theme.accent),
            themeMode: theme.mode,
            locale: loc.locale,
            routerConfig: _router,
          ),
        );
      }),
    );
  }
}

GoRouter _buildRouter(AuthState auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      if (auth.checking) {
        return state.matchedLocation == '/' ? null : '/';
      }
      final loggedIn = auth.isLoggedIn;
      final path = state.matchedLocation;
      final atAuthScreen = path == '/login' || path == '/register';
      final atOnboarding = path == '/onboarding';

      if (!loggedIn) {
        if (!atAuthScreen && !atOnboarding) {
          return auth.onboardingSeen ? '/login' : '/onboarding';
        }
        return null;
      }

      if (atAuthScreen || atOnboarding || path == '/') {
        return '/home';
      }
      return null;
    },
    routes: [
      // Tất cả routes dùng softPage() để có cùng cảm giác đầm thắm:
      // fade + slight rise + slow easeOutCubic 360ms.
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const _Splash()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const RegisterScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final tab = int.tryParse(tabParam ?? '') ?? 0;
          return softPage(
            key: state.pageKey,
            child: AppShell(initialTab: tab),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const SettingsScreen()),
      ),
      GoRoute(
        path: '/weather',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const WeatherScreen()),
      ),
      GoRoute(
        path: '/companion',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const CompanionScreen()),
      ),
      GoRoute(
        path: '/companion-chat',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const CompanionChatScreen()),
      ),
      GoRoute(
        path: '/meditation',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const MeditationScreen()),
      ),
      GoRoute(
        path: '/sleep',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const SleepScreen()),
      ),
      GoRoute(
        path: '/mood',
        pageBuilder: (context, state) => softPage(
          key: state.pageKey,
          child: const _PushedScreen(
            title: 'Chi tiết cảm xúc',
            child: MoodScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/breathing',
        pageBuilder: (context, state) => softPage(
          key: state.pageKey,
          child: const _PushedScreen(
            title: 'Hít thở',
            child: BreathingScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/journal',
        pageBuilder: (context, state) => softPage(
          key: state.pageKey,
          child: const _PushedScreen(
            title: 'Nhật ký',
            child: JournalScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/sounds',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const SoundsScreen()),
      ),
      GoRoute(
        path: '/podcast',
        pageBuilder: (context, state) => softPage(
          key: state.pageKey,
          child: const SoundsScreen(category: 'PODCAST'),
        ),
      ),
      GoRoute(
        path: '/meditation',
        pageBuilder: (context, state) => softPage(
          key: state.pageKey,
          child: const SoundsScreen(category: 'MEDITATION'),
        ),
      ),
      GoRoute(
        path: '/analytics',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const AnalyticsScreen()),
      ),
      GoRoute(
        path: '/billing',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const BillingScreen()),
      ),
      GoRoute(
        path: '/legal',
        pageBuilder: (context, state) =>
            softPage(key: state.pageKey, child: const LegalScreen()),
      ),
      GoRoute(
        path: '/location',
        builder: (context, state) => const LocationScreen(),
      ),
      GoRoute(
        path: '/device-info',
        builder: (context, state) => const DeviceInfoScreen(),
      ),
    ],
  );
}

/// Bọc một tab-screen (vốn trả body-only) trong Scaffold + AppBar khi mở
/// dạng route push, để nút back hoạt động.
class _PushedScreen extends StatelessWidget {
  const _PushedScreen({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t(title),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: child,
    );
  }
}

/// Splash brand: logo gradient + tên + tagline + spinner. Fade-in mềm
/// để cảm giác "wake up" dịu thay vì flash. Hiển thị tối thiểu 3s do
/// AuthState._minSplashDuration enforce.
class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _ctrl,
              curve: Curves.easeOutCubic,
            )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 96,
                  width: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [RelaxColors.violet, RelaxColors.plum],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: RelaxColors.violet.withValues(alpha: 0.32),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.spa_outlined,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Thi Ái',
                  style: TextStyle(
                    color: context.appText,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.t('Một góc nhỏ để bạn nghỉ nhẹ ✦'),
                  style: TextStyle(
                    color: context.appText.withValues(alpha: 0.65),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: RelaxColors.violet,
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
