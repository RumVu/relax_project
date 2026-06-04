import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'home_screen.dart';
import 'relax_screen.dart';
import 'settings_screen.dart';

/// Khung chính sau khi đăng nhập. 3 tab theo mockup: Trang chủ / Khu thư
/// giãn / Setup. IndexedStack giữ state mỗi tab, lazy build để tránh gọi
/// API thừa.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _built = <int, Widget>{};

  Widget _screen(int i) {
    return _built.putIfAbsent(i, () {
      switch (i) {
        case 0:
          return const HomeScreen();
        case 1:
          return const RelaxScreen();
        case 2:
        default:
          return const SettingsScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: List.generate(3, _screen),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: context.surface,
        indicatorColor: RelaxColors.violet.withValues(alpha: 0.18),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: RelaxColors.violet),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa, color: RelaxColors.violet),
            label: 'Khu thư giãn',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: RelaxColors.violet),
            label: 'Setup',
          ),
        ],
      ),
    );
  }
}
