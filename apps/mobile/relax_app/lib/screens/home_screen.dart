part of 'package:relax_app/main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.content,
    required this.loadingContent,
    required this.contentError,
    required this.onRefreshContent,
  });

  final MobileContentSnapshot content;
  final bool loadingContent;
  final String? contentError;
  final VoidCallback onRefreshContent;

  @override
  Widget build(BuildContext context) {
    final copy = context.copy;
    final backendMoods = content.moodOptions;
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
    final speech =
        content.companionMessage?.content ??
        content.quote?.content ??
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
          BackendStatusBanner(
            loading: loadingContent,
            error: contentError,
            loadedCount: content.loadedSections,
            resourceCount:
                content.moodOptions.length +
                content.breathingExercises.length +
                content.billingPlans.length,
            onRefresh: onRefreshContent,
          ),
          const SizedBox(height: 14),
          PixelPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SpeechBubble(text: speech),
                const SizedBox(height: 12),
                const PixelCatScene(scene: CatScene.wave, height: 188),
              ],
            ),
          ),
          if (content.quote != null) ...[
            const SizedBox(height: 14),
            PixelPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    title: 'Lời nhắn chữa lành',
                    icon: Icons.format_quote_rounded,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.quote!.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (content.quote!.mood != null) ...[
                    const SizedBox(height: 8),
                    PixelBadge(label: content.quote!.mood!),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SectionTitle(
            title: copy.moodPrompt,
            icon: Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moods.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .96,
            ),
            itemBuilder: (context, index) {
              final mood = moods[index];
              return MoodTile(mood: mood, selected: index == 0);
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
                ...moods.map((mood) => MoodProgress(mood: mood)),
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: methods
                      .map(
                        (method) => SizedBox(
                          width: 84,
                          child: MethodChip(method: method),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
