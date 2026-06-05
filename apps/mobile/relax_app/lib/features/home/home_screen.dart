import 'package:flutter/material.dart';
import '../../app/app_copy.dart';
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
import '../../shared/widgets/mood/method_chip.dart';
import '../../shared/widgets/mood/mood_progress.dart';
import '../../shared/widgets/mood/mood_tile.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';
import '../relax/sheets/stats_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.content,
    required this.loadingContent,
    required this.contentError,
    required this.onRefreshContent,
    this.session,
    this.moodService,
    this.onGoToRelax,
    this.moodHistory = const [],
    this.moodHistoryLoading = false,
  });

  final MobileContentSnapshot content;
  final bool loadingContent;
  final String? contentError;
  final VoidCallback onRefreshContent;

  final SessionState? session;
  final MoodService? moodService;
  final VoidCallback? onGoToRelax;

  /// Lịch sử mood check-in từ API — dùng để tính % và chart 7 ngày.
  final List<MoodCheckin> moodHistory;

  /// true khi đang fetch history lần đầu.
  final bool moodHistoryLoading;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MoodService _moods = widget.moodService ?? MoodService();
  final _weather = WeatherService();

  String? _activeMoodCode;
  String? _pendingMoodCode;

  WeatherSnapshot? _weatherSnapshot;
  bool _weatherTried = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final snap = await _weather.fetchCurrent();
    if (!mounted) return;
    setState(() {
      _weatherSnapshot = snap;
      _weatherTried = true;
    });
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
      final day = DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
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
    final percents = (!isLoggedIn || histLoading) ? null : _realPercents(history);
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
    final visibleMoods = moods.take(6).toList(growable: false);
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

    return AppScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            icon: wxIcon,
            title: copy.homeTitle,
            subtitle: subtitle,
            onBellTap: () => showStatsSheet(context),
          ),
          const SizedBox(height: 14),
          PixelPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SpeechBubble(text: speech),
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
                if (i >= visibleMoods.length) return const Expanded(child: SizedBox());
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
                MoodLineChart(
                  compact: true,
                  data: chartData,
                ),
                const SizedBox(height: 12),
                ...visibleMoods.map((mood) => MoodProgress(
                      mood: mood,
                      realPercent: percents == null
                          ? null  // loading
                          : percents[mood.code ?? ''] ?? 0,
                    )),
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
                // 2x2 grid dùng Column+Row tránh nested scroll semantics
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MethodChip(
                            method: visibleMethods[0],
                            onTap: widget.onGoToRelax,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (visibleMethods.length > 1)
                          Expanded(
                            child: MethodChip(
                              method: visibleMethods[1],
                              onTap: widget.onGoToRelax,
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                    if (visibleMethods.length > 2) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: MethodChip(
                              method: visibleMethods[2],
                              onTap: widget.onGoToRelax,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (visibleMethods.length > 3)
                            Expanded(
                              child: MethodChip(
                                method: visibleMethods[3],
                                onTap: widget.onGoToRelax,
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
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
        ? 'Đang nạp nội dung từ backend...'
        : 'Backend chưa sẵn sàng, đang dùng nội dung mẫu.';
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
