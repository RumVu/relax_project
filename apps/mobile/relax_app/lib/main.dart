import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/auth_state.dart';
import 'core/theme.dart';
import 'core/theme_controller.dart';
import 'screens/app_shell.dart';
import 'screens/companion_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/weather_screen.dart';

void main() {
  runApp(const RelaxApp());
}

class RelaxApp extends StatelessWidget {
  const RelaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Builder(builder: (context) {
        final auth = context.watch<AuthState>();
        final themeMode = context.watch<ThemeController>().mode;
        final router = _buildRouter(auth);
        return MaterialApp.router(
          title: 'Relax',
          debugShowCheckedModeBanner: false,
          theme: buildRelaxTheme(),
          darkTheme: buildRelaxDarkTheme(),
          themeMode: themeMode,
          routerConfig: router,
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
      if (!loggedIn && !atAuthScreen && path != '/') return '/login';
      if (loggedIn && (atAuthScreen || path == '/')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _Splash()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const AppShell()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/weather',
        builder: (context, state) => const WeatherScreen(),
      ),
      GoRoute(
        path: '/companion',
        builder: (context, state) => const CompanionScreen(),
      ),
    ],
  );
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [RelaxColors.violet, RelaxColors.plum],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.spa_outlined,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: RelaxColors.violet),
          ],
        ),
      ),
    );
  }
}
