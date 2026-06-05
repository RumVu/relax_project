import 'package:flutter/material.dart';
import '../../../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/services/mobile_content_service.dart';
import '../../data/services/mood_service.dart';
import '../../shared/widgets/common/section_title.dart';
import '../../shared/widgets/common/speech_bubble.dart';
import '../../shared/widgets/layout/app_scroll.dart';
import '../../shared/widgets/layout/header_bar.dart';
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
  });

  final MobileContentSnapshot content;
  final bool loadingContent;
  final String? contentError;
  final VoidCallback onRefreshContent;

  /// Phiên đăng nhập — null khi chưa wire (test / preview).
  final SessionState? session;

  /// Dịch vụ POST mood — DI để test dễ.
  final MoodService? moodService;

  /// Callback để navigate sang tab Khu thư giãn.
  final VoidCallback? onGoToRelax;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MoodService _moods = widget.moodService ?? MoodService();

  /// Code mood đang highlight (sau khi user bấm hoặc lần cuối log).
  String? _activeMoodCode;

  /// Code mood đang POST — chỉ để hiện loader trên đúng ô.
  String? _pendingMoodCode;

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
      _toast('Đã ghi: ${mood.label} • Thi Ái sẽ nhớ nha ✦');
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
    final backendMoods = widget.content.moodOptions;
    final moods = backendMoods.isEmpty
        ? copy.moods
        : backendMoods
              .asMap()
              .entries
              .map((entry) => MoodOption.fromBackend(entry.value, entry.key))
              .toList(growable: false);
    final actions = backendMoods.isEmpty
        ? const <String>[]
        : backendMoods.first.recommendedActions;
    final methods = actions.isEmpty
        ? copy.methods
        : actions.map(MethodOption.fromAction).toList(growable: false);
    final visibleMoods = moods.take(6).toList(growable: false);
    final visibleMethods = methods.take(4).toList(growable: false);
    final speech =
        widget.content.companionMessage?.content ??
        widget.content.quote?.content ??
        (backendMoods.isNotEmpty && backendMoods.first.companionLine.isNotEmpty
            ? backendMoods.first.companionLine
            : copy.homeSpeech);
    return AppScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            icon: Icons.wb_sunny_outlined,
            title: copy.homeTitle,
            subtitle: context.dark
                ? copy.homeNightSubtitle
                : copy.homeDaySubtitle,
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
                const SizedBox(height: 12),
                ...visibleMoods.map((mood) => MoodProgress(mood: mood)),
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
