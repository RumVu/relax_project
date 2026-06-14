import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/audio_controller.dart';
import '../core/smart_reminders.dart';
import '../core/auth_state.dart';
import '../core/locale_controller.dart';
import '../core/tour_controller.dart';
import '../core/theme.dart';
import '../widgets/checkin_sheet/checkin_sheet.dart';
import '../widgets/journey_prompt/journey_prompt.dart';
import '../widgets/tour_overlay/tour_overlay.dart';
import 'analytics/analytics_screen.dart';
import 'home/home_screen.dart';
import 'relax/relax_screen.dart';
import 'settings/settings_screen.dart';

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

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = context.read<AudioController>();
      _audioCompletionSub = audio.onTrackCompleted.listen(_onAudioFinished);

      // Start the app tour automatically for new users
      final tour = TourController.instance;
      if (!tour.hasCompletedTour) {
        tour.startTour();
      }

      // Hoi user chia se vi tri khi vao app (delay 2s de UX muot hon).
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _promptLocationIfNeeded();
      });

      SmartReminders.instance.enableDefaults();
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
      if (newIndex == 3) {
        context.read<AuthState>().refreshUser();
      }
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AuthState>().refreshUser();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    TourController.instance.removeListener(_onTourStepChanged);
    _audioCompletionSub?.cancel();
    super.dispose();
  }

  /// Kiem tra xem user da chia se vi tri chua. Neu chua → hien dialog hoi.
  /// Neu dong y → lay GPS + geocode + luu len backend.
  Future<void> _promptLocationIfNeeded() async {
    try {
      // Kiem tra xem da co vi tri tren backend chua.
      final res =
          await RelaxApi.instance.get('/user-preferences/me/preferences');
      final data = res.data;
      if (data is Map &&
          data['latitude'] is num &&
          data['longitude'] is num) {
        // Da co vi tri → khong hoi nua.
        return;
      }
    } catch (_) {
      // API fail → khong hoi, tranh lam phien user.
      return;
    }

    if (!mounted) return;

    // Hien dialog hoi user.
    final agreed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: RelaxColors.violet, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ctx.t('Chia sẻ vị trí'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          ctx.t(
              'Cho phép Thi Ái biết vị trí của bạn để gợi ý thời tiết và địa điểm phù hợp nhé? 🌤️'),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.t('Để sau'),
                style: TextStyle(color: ctx.appText.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RelaxColors.violet,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.t('Đồng ý')),
          ),
        ],
      ),
    );

    if (agreed != true || !mounted) return;

    // Lay GPS.
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();

      // Reverse geocode.
      String? address;
      try {
        final placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final pm = placemarks.first;
          final parts = <String>[
            if (pm.street != null && pm.street!.isNotEmpty) pm.street!,
            if (pm.subLocality != null && pm.subLocality!.isNotEmpty)
              pm.subLocality!,
            if (pm.locality != null && pm.locality!.isNotEmpty) pm.locality!,
            if (pm.administrativeArea != null &&
                pm.administrativeArea!.isNotEmpty)
              pm.administrativeArea!,
            if (pm.country != null && pm.country!.isNotEmpty) pm.country!,
          ];
          address = parts.join(', ');
        }
      } catch (_) {}

      // Luu len backend.
      await RelaxApi.instance
          .patch('/user-preferences/me/preferences', body: {
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        if (address != null) 'locationName': address,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('Đã lưu vị trí của bạn 💜')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      // Silent fail — khong lam phien user.
    }
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
    if (i == 3) return const SettingsScreen();
    return _built.putIfAbsent(i, () => switch (i) {
      0 => const HomeScreen(),
      1 => const RelaxScreen(),
      _ => const AnalyticsScreen(embedded: true),
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
                if (i == _index && i != 3) return;
                if (i == _index) {
                  context.read<AuthState>().refreshUser();
                  return;
                }
                HapticFeedback.selectionClick();
                setState(() {
                  _veilOpacity = 0.6;
                  _index = i;
                });
                if (i == 3) {
                  context.read<AuthState>().refreshUser();
                }
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
