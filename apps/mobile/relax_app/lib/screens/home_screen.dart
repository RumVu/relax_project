part of 'package:relax_app/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.content,
    required this.loadingContent,
    required this.contentError,
    required this.onRefreshContent,
    this.session,
    this.moodService,
  });

  final MobileContentSnapshot content;
  final bool loadingContent;
  final String? contentError;
  final VoidCallback onRefreshContent;

  /// Phiên đăng nhập — null khi chưa wire (test / preview).
  final SessionState? session;

  /// Dịch vụ POST mood — DI để test dễ.
  final MoodService? moodService;

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
      _toast('Hãy đăng nhập để Thi Ái nhớ cảm xúc của bạn nha 💜');
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleMoods.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .96,
            ),
            itemBuilder: (context, index) {
              final mood = visibleMoods[index];
              final code = mood.code;
              final isActive = code != null && code == _activeMoodCode;
              final isBusy = code != null && code == _pendingMoodCode;
              return MoodTile(
                mood: mood,
                selected: isActive || (_activeMoodCode == null && index == 0),
                busy: isBusy,
                onTap: code == null ? null : () => _logMood(mood),
              );
            },
          ),
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
                Row(
                  children: [
                    for (var i = 0; i < visibleMethods.length; i++) ...[
                      Expanded(child: MethodChip(method: visibleMethods[i])),
                      if (i != visibleMethods.length - 1)
                        const SizedBox(width: 8),
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
