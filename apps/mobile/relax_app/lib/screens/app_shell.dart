import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'breathing_screen.dart';
import 'home_screen.dart';
import 'journal_screen.dart';
import 'mood_screen.dart';

/// Khung chính sau khi đăng nhập: 4 tab (Tổng quan / Cảm xúc / Hít thở /
/// Nhật ký) chuyển qua IndexedStack để giữ state mỗi tab khi đổi. Settings
/// mở dạng route push riêng nên không nằm trong tab bar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // Lazy: chỉ build screen khi tab được mở lần đầu để tránh gọi API thừa.
  final _built = <int, Widget>{};

  Widget _screen(int i) {
    return _built.putIfAbsent(i, () {
      switch (i) {
        case 0:
          return const HomeScreen();
        case 1:
          return const MoodScreen();
        case 2:
          return const BreathingScreen();
        case 3:
        default:
          return const JournalScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: List.generate(4, _screen),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: RelaxColors.violet.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: RelaxColors.violet),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite, color: RelaxColors.violet),
            label: 'Cảm xúc',
          ),
          NavigationDestination(
            icon: Icon(Icons.air),
            selectedIcon: Icon(Icons.air, color: RelaxColors.violet),
            label: 'Hít thở',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book, color: RelaxColors.violet),
            label: 'Nhật ký',
          ),
        ],
      ),
    );
  }
}
