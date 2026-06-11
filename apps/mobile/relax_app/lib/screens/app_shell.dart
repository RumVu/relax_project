import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/audio_controller.dart';
import '../core/auth_state.dart';
import '../core/locale_controller.dart';
import '../core/tour_controller.dart';
import '../core/theme.dart';
import '../widgets/checkin_sheet.dart';
import '../widgets/journey_prompt.dart';
import '../widgets/tour_overlay.dart';
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
  StreamSubscription<Map<String, dynamic>>? _audioCompletionSub;

  @override
  void initState() {
    super.initState();
    // Listen audio completion ở shell level → JourneyPrompt fire dù
    // user đang ở tab nào. AppShell sống suốt session sau login.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = context.read<AudioController>();
      _audioCompletionSub = audio.onTrackCompleted.listen(_onAudioFinished);

      // Start the app tour automatically for new users
      final tour = TourController.instance;
      if (!tour.hasCompletedTour) {
        tour.startTour();
      }
    });

    TourController.instance.addListener(_onTourStepChanged);
  }

  void _onTourStepChanged() {
    if (!mounted) return;
    final tour = TourController.instance;
    if (!tour.isTourActive) return;

    int newIndex = _index;
    final step = tour.currentStep;
    if (step >= 0 && step <= 2) {
      newIndex = 0;
    } else if (step >= 3 && step <= 5) {
      newIndex = 1;
    } else if (step >= 6 && step <= 7) {
      newIndex = 2;
    } else if (step >= 8 && step <= 10) {
      newIndex = 3;
    }

    if (newIndex != _index) {
      setState(() {
        _index = newIndex;
      });
    }
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _index = widget.initialTab.clamp(0, _tabCount - 1);
      });
    }
  }

  @override
  void dispose() {
    TourController.instance.removeListener(_onTourStepChanged);
    _audioCompletionSub?.cancel();
    super.dispose();
  }

  void _onAudioFinished(Map<String, dynamic> track) {
    if (!mounted) return;
    final title = context.t((track['title'] as String?) ?? 'Phiên nghe');
    final auth = context.read<AuthState>();
    final activeId = auth.activeSessionId;
    final activeType = auth.activeActivityType;

    if (activeId != null &&
        (activeType == 'MUSIC' ||
            activeType == 'PODCAST' ||
            activeType == 'MEDITATION')) {
      showCheckInSheet(context, title, sessionId: activeId).then((_) {
        if (!mounted) return;
        _showAudioJourneyPrompt(title);
      });
    } else {
      _showAudioJourneyPrompt(title);
    }
  }

  void _showAudioJourneyPrompt(String title) {
    showJourneyPrompt(
      context,
      title: '${context.t('Phiên')} "$title" ${context.t('đã xong 🎧')}',
      subtitle:
          context.t('Cảm thấy dịu hơn chưa? Mình đi tiếp một bước nhẹ nha — hoặc nghe thêm bài khác cũng được.'),
      suggestions: [
        JourneySuggestion(
          icon: Icons.playlist_play,
          label: context.t('Nghe danh sách khác'),
          route: '/sounds',
        ),
        JourneySuggestion(
          icon: Icons.edit_note,
          label: context.t('Ghi cảm giác vào nhật ký'),
          route: '/journal',
        ),
        JourneySuggestion(
          icon: Icons.mood,
          label: context.t('Cập nhật cảm xúc'),
          route: '/mood',
        ),
      ],
    );
  }

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
      child: Stack(
        children: [
          Scaffold(
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
                // Haptic nhẹ cho tap chính xác — không rung mạnh, chỉ nhỏ.
                HapticFeedback.selectionClick();
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
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home, color: RelaxColors.violet),
                  label: context.t('Trang chủ'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.spa_outlined),
                  selectedIcon: const Icon(Icons.spa, color: RelaxColors.violet),
                  label: context.t('Thư giãn'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.insights_outlined),
                  selectedIcon: const Icon(Icons.insights, color: RelaxColors.violet),
                  label: context.t('Cảm xúc'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings, color: RelaxColors.violet),
                  label: context.t('Setup'),
                ),
              ],
            ),
          ),
          const TourOverlay(),
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
                context.t((t['title'] as String?) ?? 'Đang phát'),
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
