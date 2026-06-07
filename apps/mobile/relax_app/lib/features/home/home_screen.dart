import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../data/services/mobile_content_service.dart';
import '../../data/services/mood_service.dart';
import '../../data/services/weather_service.dart';
import '../../shared/widgets/common/section_title.dart';
import '../../shared/widgets/common/speech_bubble.dart';
import '../../shared/widgets/layout/app_scroll.dart';
import '../../shared/widgets/layout/header_bar.dart';
import '../../shared/widgets/charts/mood_line_chart.dart';
import '../../shared/widgets/home/daily_affirmation_card.dart';
import '../../shared/widgets/mood/method_chip.dart';
import '../../shared/widgets/mood/mood_progress.dart';
import '../../shared/widgets/mood/mood_tile.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';
import '../../data/services/inbox/inbox_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.content,
    required this.loadingContent,
    required this.contentError,
    required this.onRefreshContent,
    this.session,
    this.moodService,
    this.onMethodSelected,
    this.moodHistory = const [],
    this.moodHistoryLoading = false,
    this.onMoodLogged,
    this.onOpenNotifications,
    this.onOpenSearch,
    this.onOpenInsights,
    this.onOpenQuickRelief,
    this.onOpenChat,
    this.hasAccentTheme = false,
  });

  final MobileContentSnapshot content;
  final bool loadingContent;
  final String? contentError;
  final VoidCallback onRefreshContent;

  final SessionState? session;
  final MoodService? moodService;
  final ValueChanged<MethodOption>? onMethodSelected;

  /// Lịch sử mood check-in từ API — dùng để tính % và chart 7 ngày.
  final List<MoodCheckin> moodHistory;

  /// true khi đang fetch history lần đầu.
  final bool moodHistoryLoading;

  /// Khi user log mood mới từ Home → shell sẽ refetch history → Stats sheet
  /// & chart 7-day sync ngay không cần restart app hay reopen tab.
  final VoidCallback? onMoodLogged;

  /// Bell icon → push NotificationsScreen (real inbox).
  final VoidCallback? onOpenNotifications;

  /// Search icon → push SearchScreen.
  final VoidCallback? onOpenSearch;

  /// "Xem hành trình" → push InsightsScreen.
  final VoidCallback? onOpenInsights;

  /// SOS button — push QuickReliefScreen (60s breathing).
  final VoidCallback? onOpenQuickRelief;

  /// Companion chat với Thi Ái.
  final VoidCallback? onOpenChat;

  /// Để inbox biết có nên show "Customs theme đã sẵn" notification không.
  final bool hasAccentTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MoodService _moods = widget.moodService ?? MoodService();
  final _weather = WeatherService();

  String? _activeMoodCode;
  String? _pendingMoodCode;
  int _unreadInbox = 0;

  WeatherSnapshot? _weatherSnapshot;
  bool _weatherTried = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _refreshUnread();
  }

  @override
  void didUpdateWidget(HomeScreen old) {
    super.didUpdateWidget(old);
    // Khi shell refresh moodHistory hoặc session đổi → cập nhật badge bell.
    if (old.moodHistory.length != widget.moodHistory.length ||
        old.session?.isLoggedIn != widget.session?.isLoggedIn) {
      _refreshUnread();
    }
  }

  Future<void> _refreshUnread() async {
    final session = widget.session;
    final loggedIn = session?.isLoggedIn ?? false;
    final lastMood = widget.moodHistory.isEmpty
        ? null
        : widget.moodHistory.first.createdAt;
    final streak = _calcStreak(widget.moodHistory);
    final count = await InboxService.instance.unreadCount(
      isLoggedIn: loggedIn,
      moodHistoryCount: widget.moodHistory.length,
      streakDays: streak,
      hasAccentTheme: widget.hasAccentTheme,
      lastMoodAt: lastMood,
    );
    if (!mounted) return;
    setState(() => _unreadInbox = count);
  }

  int _calcStreak(List<MoodCheckin> history) {
    if (history.isEmpty) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayKeys = history
        .map((c) => DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day))
        .toSet();
    int streak = 0;
    var cursor = today;
    while (dayKeys.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<void> _loadWeather() async {
    final snap = await _weather.fetchCurrent();
    if (!mounted) return;
    setState(() {
      _weatherSnapshot = snap;
      _weatherTried = true;
    });
  }

  void _refreshHomeData() {
    widget.onRefreshContent();
    _loadWeather();
  }

  // ── Real data helpers ────────────────────────────────────────────────────

  /// Tính % xuất hiện của mỗi mood code trong lịch sử thật.
  /// Key = mood code (HAPPY, SAD...), value = % (0-100).
  Map<String, int> _realPercents(List<MoodCheckin> history) {
    if (history.isEmpty) return {};
    final counts = <String, int>{};
    for (final c in history) {
      counts[c.mood] = (counts[c.mood] ?? 0) + 1;
    }
    final total = history.length;
    return counts.map((k, v) => MapEntry(k, (v / total * 100).round()));
  }

  /// Tạo list 7 giá trị [0,1] cho biểu đồ từ lịch sử 7 ngày qua.
  /// Index 0 = cách đây 6 ngày, index 6 = hôm nay.
  List<double> _chartData(List<MoodCheckin> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = List<int>.filled(7, 0);
    for (final c in history) {
      final day = DateTime(
        c.createdAt.year,
        c.createdAt.month,
        c.createdAt.day,
      );
      final diff = today.difference(day).inDays;
      if (diff >= 0 && diff < 7) counts[6 - diff]++;
    }
    final max = counts.reduce((a, b) => a > b ? a : b);
    if (max == 0) return List.filled(7, 0.0);
    return counts.map((c) => c / max).toList();
  }

  Future<void> _logMood(MoodOption mood) async {
    final code = mood.code;
    final session = widget.session;
    if (code == null) return;
    if (session == null || !session.isLoggedIn) {
      _toast('Hãy đăng nhập để mình ghi nhớ cảm xúc của bạn nha 💜');
      return;
    }
    setState(() => _pendingMoodCode = code);
    try {
      await _moods.log(
        accessToken: session.accessToken!,
        mood: code,
        intensity: 3,
      );
      if (!mounted) return;
      setState(() {
        _activeMoodCode = code;
        _pendingMoodCode = null;
      });
      // Báo shell refetch history → chart 7-ngày + Stats sheet + Setup stats
      // đều cập nhật ngay khi user log thêm mood.
      widget.onMoodLogged?.call();
      _toast('Đã ghi: ${mood.label} ✦');
    } catch (e) {
      if (!mounted) return;
      setState(() => _pendingMoodCode = null);
      _toast('Không ghi được — $e');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = context.copy;
    final history = widget.moodHistory;
    final histLoading = widget.moodHistoryLoading;
    final session = widget.session;
    final isLoggedIn = session?.isLoggedIn == true;

    // Real % từ history — null khi đang load (chưa login thì luôn null)
    final percents = (!isLoggedIn || histLoading)
        ? null
        : _realPercents(history);
    // Real 7-day chart data — null khi load, [] khi empty
    final chartData = !isLoggedIn
        ? <double>[]
        : histLoading
        ? null
        : _chartData(history);

    final backendMoods = widget.content.moodOptions;
    final moods = backendMoods.isEmpty
        ? copy.moods
        : backendMoods
              .asMap()
              .entries
              .map((entry) => MoodOption.fromBackend(entry.value, entry.key))
              .toList(growable: false);
    // LUÔN dùng 4 phương thức cố định từ copy. Backend chỉ trả 3
    // recommendedActions nên không dùng để dựng grid 2×2 này.
    final visibleMoods = moods.take(9).toList(growable: false);
    final visibleMethods = copy.methods.take(4).toList(growable: false);
    final speech =
        widget.content.companionMessage?.content ??
        widget.content.quote?.content ??
        (backendMoods.isNotEmpty && backendMoods.first.companionLine.isNotEmpty
            ? backendMoods.first.companionLine
            : copy.homeSpeech);
    // Weather subtitle: ưu tiên data thật từ Open-Meteo. Fallback đẹp khi chưa có.
    final wx = _weatherSnapshot;
    final subtitle = wx != null
        ? '${wx.description} · ${wx.temperatureC.toStringAsFixed(0)}°C'
        : !_weatherTried
        ? 'Đang xem thời tiết...'
        : (context.dark ? copy.homeNightSubtitle : copy.homeDaySubtitle);
    final wxIcon = wx == null
        ? Icons.wb_sunny_outlined
        : wx.isDay
        ? Icons.wb_sunny_outlined
        : Icons.nights_stay_outlined;

    return RefreshIndicator(
      color: RelaxTheme.purple,
      onRefresh: () async {
        widget.onRefreshContent();
        await _loadWeather();
        await _refreshUnread();
      },
      child: AppScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            icon: wxIcon,
            title: copy.homeTitle,
            subtitle: subtitle,
            bellHasBadge: _unreadInbox > 0,
            onBellTap: () {
              widget.onOpenNotifications?.call();
              // delay refresh để khi user back → mark-as-read effect visible
              Future.delayed(const Duration(milliseconds: 600), _refreshUnread);
            },
          ),
          const SizedBox(height: 12),
          // ── Daily affirmation hero — rotate theo ngày
          const DailyAffirmationCard(compact: true),
          const SizedBox(height: 10),
          // ── Quick actions: 4 chips (SOS / Chat / Tìm kiếm / Hành trình)
          Row(
            children: [
              Expanded(
                child: _QuickActionChip(
                  icon: Icons.bolt_rounded,
                  label: 'SOS 60s',
                  color: const Color(0xFFE85A6A),
                  onTap: widget.onOpenQuickRelief,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickActionChip(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Trò chuyện',
                  color: const Color(0xFF48D3A8),
                  onTap: widget.onOpenChat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _QuickActionChip(
                  icon: Icons.search_rounded,
                  label: 'Tìm kiếm',
                  color: RelaxTheme.lavender,
                  onTap: widget.onOpenSearch,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickActionChip(
                  icon: Icons.insights_rounded,
                  label: 'Hành trình',
                  color: const Color(0xFFFFC96E),
                  onTap: widget.onOpenInsights,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PixelPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: SpeechBubble(text: speech)),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Đổi lời nhắn',
                      onPressed: widget.onRefreshContent,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const PixelCatScene(scene: CatScene.wave, height: 188),
                if (widget.loadingContent || widget.contentError != null) ...[
                  const SizedBox(height: 10),
                  _SoftSyncLine(
                    loading: widget.loadingContent,
                    onRefresh: widget.onRefreshContent,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionTitle(
            title: copy.moodPrompt,
            icon: Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 10),
          // Dùng Column+Row thay GridView để tránh semantics assertion crash
          // khi nest GridView shrinkWrap bên trong SingleChildScrollView.
          for (int row = 0; row < (visibleMoods.length + 2) ~/ 3; row++) ...[
            if (row > 0) const SizedBox(height: 10),
            Row(
              children: List.generate(3, (col) {
                final i = row * 3 + col;
                if (i >= visibleMoods.length) {
                  return const Expanded(child: SizedBox());
                }
                final mood = visibleMoods[i];
                final code = mood.code;
                final isActive = code != null && code == _activeMoodCode;
                final isBusy = code != null && code == _pendingMoodCode;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: col > 0 ? 10 : 0),
                    child: MoodTile(
                      mood: mood,
                      selected: isActive || (_activeMoodCode == null && i == 0),
                      busy: isBusy,
                      onTap: code == null ? null : () => _logMood(mood),
                    ),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 14),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: copy.moodChartTitle,
                  icon: Icons.bar_chart_rounded,
                ),
                const SizedBox(height: 8),
                MoodLineChart(compact: true, data: chartData),
                const SizedBox(height: 12),
                ...visibleMoods.map(
                  (mood) => MoodProgress(
                    mood: mood,
                    realPercent: percents == null
                        ? null // loading
                        : percents[mood.code ?? ''] ?? 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: copy.methodTitle,
                  icon: Icons.favorite_border_rounded,
                ),
                const SizedBox(height: 12),
                // 4 chips 1 hàng — khớp mockup hình 1
                Row(
                  children: [
                    for (var i = 0; i < visibleMethods.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: MethodChip(
                          method: visibleMethods[i],
                          onTap: () =>
                              widget.onMethodSelected?.call(visibleMethods[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: .3)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftSyncLine extends StatelessWidget {
  const _SoftSyncLine({required this.loading, required this.onRefresh});

  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final text = loading
        ? 'Đang làm mới không gian của bạn...'
        : 'Chưa lấy được dữ liệu mới. Chạm để thử lại.';
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onRefresh,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.relax.surfaceSoft.withValues(alpha: .7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.relax.border),
        ),
        child: Row(
          children: [
            Icon(
              loading ? Icons.sync_rounded : Icons.refresh_rounded,
              size: 16,
              color: RelaxTheme.lavender,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeNotificationPanel extends StatelessWidget {
  const _HomeNotificationPanel({
    required this.loadingContent,
    required this.contentError,
    required this.weather,
    required this.loggedIn,
    required this.moodHistoryLoading,
    required this.historyCount,
    required this.onRefresh,
  });

  final bool loadingContent;
  final String? contentError;
  final WeatherSnapshot? weather;
  final bool loggedIn;
  final bool moodHistoryLoading;
  final int historyCount;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final wx = weather;
    return PixelPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: RelaxTheme.lavender,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Thông báo hôm nay',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Làm mới',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _NotificationLine(
            icon: loadingContent
                ? Icons.sync_rounded
                : contentError == null
                ? Icons.cloud_done_outlined
                : Icons.cloud_off_outlined,
            title: loadingContent
                ? 'Đang đồng bộ nội dung'
                : contentError == null
                ? 'Nội dung đã sẵn sàng'
                : 'Chưa lấy được nội dung mới',
            subtitle: loadingContent
                ? 'Đợi một chút để app kéo dữ liệu mới nhất.'
                : contentError == null
                ? 'Âm thanh, lời nhắn và mood đã được nạp.'
                : 'Bấm làm mới để thử lại kết nối backend.',
          ),
          const SizedBox(height: 8),
          _NotificationLine(
            icon: wx == null
                ? Icons.location_searching_rounded
                : wx.isDay
                ? Icons.wb_sunny_outlined
                : Icons.nights_stay_outlined,
            title: wx == null
                ? 'Đang xem vị trí thời tiết'
                : '${wx.description} · ${wx.temperatureC.toStringAsFixed(0)}°C',
            subtitle: wx == null
                ? 'Nếu thiết bị chưa cấp quyền, app sẽ dùng dữ liệu mặc định.'
                : 'Gợi ý thư giãn sẽ mềm hơn theo thời tiết hiện tại.',
          ),
          const SizedBox(height: 8),
          _NotificationLine(
            icon: loggedIn
                ? Icons.sentiment_satisfied_alt_rounded
                : Icons.login_rounded,
            title: loggedIn ? 'Mood tracker hoạt động' : 'Chưa đăng nhập',
            subtitle: loggedIn
                ? moodHistoryLoading
                      ? 'Đang tải lịch sử cảm xúc...'
                      : '$historyCount check-in đang được dùng để tính gợi ý.'
                : 'Đăng nhập để đồng bộ mood, phiên thư giãn và nhắc nhở.',
          ),
        ],
      ),
    );
  }
}

class _NotificationLine extends StatelessWidget {
  const _NotificationLine({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.relax.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: RelaxTheme.lavender, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
