import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/audio_controller.dart';
import 'core/offline_store.dart';
import 'core/auth_state.dart';
import 'core/locale_controller.dart';
import 'core/page_transitions.dart';
import 'core/theme.dart';
import 'core/theme_controller.dart';
import 'core/tour_controller.dart';
import 'core/local_notifications.dart';
import 'widgets/soft_toast.dart';

import 'screens/app_shell.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/billing/billing_screen.dart';
import 'screens/breathing/breathing_screen.dart';
import 'screens/buddies/buddies_screen.dart';
import 'screens/calm_now/calm_now_screen.dart';
import 'screens/companion/companion_screen.dart';
import 'screens/companion_chat/companion_chat_screen.dart';
import 'screens/craving_break/craving_break_screen.dart';
import 'screens/crisis/crisis_help_screen.dart';
import 'screens/demo/demo_checklist_screen.dart';
import 'screens/device_info/device_info_screen.dart';
import 'screens/focus_break/focus_break_screen.dart';
import 'screens/journal/journal_screen.dart';
import 'screens/legal/legal_screen.dart';
import 'screens/location/location_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/meditation/meditation_screen.dart';
import 'screens/mood/mood_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/recommendations/recommendations_screen.dart';
import 'screens/register/register_screen.dart';
import 'screens/relax/relax_screen.dart';
import 'screens/sessions/sessions_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/sleep/sleep_screen.dart';
import 'screens/soundscape/soundscape_screen.dart';
import 'screens/sounds/sounds_screen.dart';
import 'screens/trigger_map/trigger_map_screen.dart';
import 'screens/weather/weather_screen.dart';
import 'screens/weekly_report/weekly_report_screen.dart';
import 'screens/wellness_plan/wellness_plan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Translations.load();
  await LocalNotifications.init();
  await OfflineStore.instance.init();
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

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

GoRoute _soft(String path, Widget child) => GoRoute(
      path: path,
      pageBuilder: (_, s) => softPage(key: s.pageKey, child: child),
    );

GoRoute _wrapped(String path, String title, Widget child) => GoRoute(
      path: path,
      pageBuilder: (_, s) => softPage(
        key: s.pageKey,
        child: _PushedScreen(title: title, child: child),
      ),
    );

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
      final atAuth = path == '/login' || path == '/register';
      final atOnboarding = path == '/onboarding';

      if (!loggedIn) {
        if (!atAuth && !atOnboarding) {
          return auth.onboardingSeen ? '/login' : '/onboarding';
        }
        return null;
      }
      if (atAuth || atOnboarding || path == '/') return '/home';
      return null;
    },
    routes: [
      _soft('/', const _Splash()),
      _soft('/onboarding', const OnboardingScreen()),
      _soft('/login', const LoginScreen()),
      _soft('/register', const RegisterScreen()),

      // Home (tab param)
      GoRoute(
        path: '/home',
        pageBuilder: (_, s) {
          final tab = int.tryParse(s.uri.queryParameters['tab'] ?? '') ?? 0;
          return softPage(key: s.pageKey, child: AppShell(initialTab: tab));
        },
      ),

      // Wrapped screens (body-only widgets that need an AppBar)
      _wrapped('/mood', 'Chi tiết cảm xúc', const MoodScreen()),
      _wrapped('/breathing', 'Hít thở', const BreathingScreen()),
      _wrapped('/journal', 'Nhật ký', const JournalScreen()),

      // Simple screens
      _soft('/settings', const SettingsScreen()),
      _soft('/weather', const WeatherScreen()),
      _soft('/companion', const CompanionScreen()),
      _soft('/companion-chat', const CompanionChatScreen()),
      _soft('/meditation', const MeditationScreen()),
      _soft('/sleep', const SleepScreen()),
      _soft('/sounds', const SoundsScreen()),
      _soft('/podcast', const SoundsScreen(category: 'PODCAST')),
      _soft('/analytics', const AnalyticsScreen()),
      _soft('/billing', const BillingScreen()),
      _soft('/legal', const LegalScreen()),
      _soft('/calm-now', const CalmNowScreen()),
      _soft('/break', const CravingBreakScreen()),
      _soft('/weekly-report', const WeeklyReportScreen()),
      _soft('/wellness-plan', const WellnessPlanScreen()),
      _soft('/sessions', const SessionsScreen()),
      _soft('/buddies', const BuddiesScreen()),
      _soft('/achievements', const AchievementsScreen()),
      _soft('/trigger-map', const TriggerMapScreen()),
      _soft('/soundscape', const SoundscapeScreen()),
      _soft('/focus-break', const FocusBreakScreen()),
      _soft('/recommendations', const RecommendationsScreen()),
      _soft('/crisis-help', const CrisisHelpScreen()),
      _soft('/demo-guide', const DemoChecklistScreen()),

      // Raw builder (no transition)
      GoRoute(path: '/location', builder: (c, s) => const LocationScreen()),
      GoRoute(path: '/device-info', builder: (c, s) => const DeviceInfoScreen()),
    ],
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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
            ).animate(
              CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
            ),
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
                  child: const Icon(Icons.spa_outlined,
                      color: Colors.white, size: 52),
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
