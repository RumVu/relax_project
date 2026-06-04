import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/audio_controller.dart';
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
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _index,
              children: List.generate(3, _screen),
            ),
          ),
          const _MiniPlayer(),
        ],
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

/// Thanh phát nhạc thu gọn — hiện phía trên bottom nav khi đang có bài phát.
/// Bấm vào mở lại màn nhạc; nút phát/dừng + đóng.
class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer();

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioController>();
    if (!audio.hasTrack) return const SizedBox.shrink();
    final t = audio.current!;
    return GestureDetector(
      onTap: () => context.push('/sounds'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [RelaxColors.violet, RelaxColors.plum],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                (t['title'] as String?) ?? 'Đang phát',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: audio.toggle,
              icon: Icon(
                audio.playing ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: audio.stop,
              icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
