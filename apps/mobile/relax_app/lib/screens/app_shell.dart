import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/audio_controller.dart';
import '../core/theme.dart';
import 'analytics_screen.dart';
import 'home_screen.dart';
import 'relax_screen.dart';
import 'settings_screen.dart';

/// Khung chính sau khi đăng nhập. 4 tab:
///   0. Trang chủ — daily snapshot (weather, mood check-in, companion)
///   1. Khu thư giãn — content discovery (nhạc, hít thở, nhật ký)
///   2. Cảm xúc — phân tích mood (Analytics)
///   3. Setup — settings
///
/// IndexedStack giữ state mỗi tab, lazy build để tránh gọi API thừa.
/// Tab có thể được preselect khi push qua route `/home?tab=N`.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialTab = 0});

  /// Tab muốn mở khi shell vừa mount. Dùng cho deeplink (vd: noti dẫn
  /// thẳng vào Insights tab).
  final int initialTab;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _tabCount = 4;
  late int _index = widget.initialTab.clamp(0, _tabCount - 1);
  final _built = <int, Widget>{};
  double _veilOpacity = 0;

  Widget _screen(int i) {
    return _built.putIfAbsent(i, () {
      switch (i) {
        case 0:
          return const HomeScreen();
        case 1:
          return const RelaxScreen();
        case 2:
          return const AnalyticsScreen(embedded: true);
        case 3:
        default:
          return const SettingsScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Bấm back trên Android khi đang ở tab phụ → về Home thay vì thoát.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _index == 0) return;
        setState(() => _index = 0);
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              // Stack: IndexedStack giữ state (scroll, controllers) +
              // một lớp overlay fade trắng khi đổi tab cho cảm giác
              // dịu dàng (không reset state như AnimatedSwitcher).
              child: Stack(
                children: [
                  IndexedStack(
                    index: _index,
                    children: List.generate(_tabCount, _screen),
                  ),
                  // Hiệu ứng fade veil — opacity 0.0 ổn định, sẽ
                  // animate qua _veil khi tab change.
                  IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      opacity: _veilOpacity,
                      child: Container(
                        color: context.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const _MiniPlayer(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) {
            if (i == _index) return;
            // Flash veil 0 → 0.6 → 0 trong ~440ms để có cảm giác
            // "chớp mắt" dịu dàng khi đổi tab — không reset state
            // của tab cũ.
            setState(() {
              _veilOpacity = 0.6;
              _index = i;
            });
            Future.delayed(const Duration(milliseconds: 220), () {
              if (mounted) setState(() => _veilOpacity = 0);
            });
          },
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
              label: 'Thư giãn',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights, color: RelaxColors.violet),
              label: 'Cảm xúc',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: RelaxColors.violet),
              label: 'Setup',
            ),
          ],
        ),
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
