import 'package:flutter/material.dart';
import '../../data/models/app_models.dart';
import '../../app/theme.dart';
import '../../data/models/backend_models.dart';
import '../../shared/widgets/activity/activity_card.dart';
import '../../shared/widgets/layout/app_scroll.dart';
import '../../shared/widgets/layout/header_bar.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';

/// Khu thư giãn — không còn là 1 menu phẳng. Bây giờ là 1 cuộc dẫn dắt:
///
/// 1. Header chào hỏi
/// 2. Intro narrative — kể vắn tắt "hành trình thư giãn" có 5 chương
/// 3. Mood quick-pick — tap mood → app tự chọn activity hợp + push Journey
/// 4. Danh sách hoạt động dạng "Chương 01 → Chương N" — mỗi card 1 chương,
///    tap toàn bộ card → Journey 5 chương cho activity đó
/// 5. Closing line "Sau khi hoàn tất, mình sẽ cùng nhìn lại nha ✦"
class RelaxScreen extends StatelessWidget {
  const RelaxScreen({
    super.key,
    required this.backendActivities,
    required this.loadingCatalog,
    required this.catalogError,
    required this.onRefreshCatalog,
    this.onBack,
    required this.onStartJourney,
  });

  final List<BackendRelaxActivity> backendActivities;
  final bool loadingCatalog;
  final String? catalogError;
  final VoidCallback onRefreshCatalog;
  final VoidCallback? onBack;

  /// Khi user chọn 1 activity (tap card hoặc qua mood quick-pick) →
  /// shell push JourneyScreen 5 chương cho activity đó.
  final ValueChanged<Activity> onStartJourney;

  @override
  Widget build(BuildContext context) {
    final displayActivities = backendActivities
        .map(Activity.fromBackend)
        .toList(growable: false);
    final resourceCount = displayActivities.fold<int>(
      0,
      (sum, activity) => sum + activity.contentCount,
    );

    return AppScroll(
      child: Column(
        children: [
          HeaderBar(
            icon: Icons.arrow_back_ios_new_rounded,
            title: 'Thư giãn ✦',
            subtitle: 'Cùng mình đi qua một hành trình nhỏ nha ~',
            onLeadingTap: onBack,
            trailing: const PixelCatScene(scene: CatScene.sleep, height: 66),
          ),
          if (loadingCatalog || catalogError != null) ...[
            const SizedBox(height: 12),
            _RelaxSyncStrip(
              loading: loadingCatalog,
              error: catalogError,
              activityCount: displayActivities.length,
              resourceCount: resourceCount,
              onRefresh: onRefreshCatalog,
            ),
          ],
          const SizedBox(height: 14),
          const _NarrativeIntro(),
          const SizedBox(height: 12),
          if (displayActivities.isNotEmpty)
            _MoodQuickPick(
              activities: displayActivities,
              onStartJourney: onStartJourney,
            ),
          const SizedBox(height: 14),
          _SectionDivider(label: 'Chọn nhịp nghỉ của bạn'),
          const SizedBox(height: 10),
          if (!loadingCatalog && displayActivities.isEmpty)
            _EmptyState(onRetry: onRefreshCatalog)
          else if (loadingCatalog && displayActivities.isEmpty)
            const _LoadingIndicator()
          else
            ...displayActivities.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ActivityCard(
                  activity: entry.value,
                  chapterIndex: entry.key + 1,
                  onStart: onStartJourney,
                ),
              );
            }),
          if (displayActivities.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ClosingLine(),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Narrative intro card — kể vắn tắt hành trình 5 chương
// ════════════════════════════════════════════════════════════════════════════

class _NarrativeIntro extends StatelessWidget {
  const _NarrativeIntro();

  static const _chapters = [
    ('🌿', 'Lắng nghe', 'cảm xúc hôm nay'),
    ('🌬️', 'Hít thở', '3 nhịp chuẩn bị'),
    ('✨', 'Đi vào', 'phiên thư giãn'),
    ('💭', 'Phản chiếu', 'cảm nhận sau cùng'),
    ('💜', 'Chữa lành', 'mang đi điều dịu dàng'),
  ];

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [RelaxTheme.purple, RelaxTheme.lavender],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '✦ HÀNH TRÌNH ✦',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Mỗi hoạt động là một câu chuyện nhỏ ~',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Khi bạn chọn 1 nhịp nghỉ bên dưới, mình sẽ dẫn bạn đi qua 5 chương — '
            'từ lắng nghe cảm xúc, hít thở, đi vào phiên, đến lúc cảm ơn bản thân. '
            'Cứ thả lỏng, mình ở đây với bạn ✦',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          // 5 chapter mini-pills horizontal
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: _chapters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final (emoji, title, subtitle) = _chapters[i];
                return _ChapterMiniPill(
                  index: i + 1,
                  emoji: emoji,
                  title: title,
                  subtitle: subtitle,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterMiniPill extends StatelessWidget {
  const _ChapterMiniPill({
    required this.index,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
  final int index;
  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: RelaxTheme.lavender.withValues(alpha: .25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: RelaxTheme.lavender,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              color: context.relax.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Mood quick-pick — tap mood → app gợi ý activity → push Journey
// ════════════════════════════════════════════════════════════════════════════

class _MoodQuickPick extends StatelessWidget {
  const _MoodQuickPick({
    required this.activities,
    required this.onStartJourney,
  });

  final List<Activity> activities;
  final ValueChanged<Activity> onStartJourney;

  /// Map mood → ưu tiên activity type. Nếu không có match → trả về activity[0].
  Activity _recommend(String mood) {
    final preferredType = switch (mood) {
      'STRESSED' => 'BREATHING',
      'SAD' => 'JOURNAL',
      'TIRED' => 'MEDITATION',
      'HAPPY' => 'MUSIC',
      _ => 'MEDITATION',
    };
    for (final a in activities) {
      if (a.type == preferredType) return a;
    }
    return activities.first;
  }

  @override
  Widget build(BuildContext context) {
    const moods = [
      ('🌪️', 'Nặng nề', 'STRESSED'),
      ('🌧️', 'Hơi xuống', 'SAD'),
      ('😴', 'Mệt mỏi', 'TIRED'),
      ('🌤️', 'Bình thường', 'NEUTRAL'),
      ('😊', 'Ổn áp', 'HAPPY'),
    ];
    return PixelPanel(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: RelaxTheme.lavender,
              ),
              const SizedBox(width: 6),
              Text(
                'Bạn cảm thấy thế nào lúc này?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap 1 mood, mình sẽ gợi ý nhịp nghỉ hợp nhất và dẫn bạn vào ngay.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.relax.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final m in moods)
                Expanded(
                  child: _MoodQuickChip(
                    emoji: m.$1,
                    label: m.$2,
                    onTap: () => onStartJourney(_recommend(m.$3)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodQuickChip extends StatelessWidget {
  const _MoodQuickChip({
    required this.emoji,
    required this.label,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: RelaxTheme.purple.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: RelaxTheme.lavender.withValues(alpha: .3),
              ),
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Section divider — visual break between intro/quick-pick and list
// ════════════════════════════════════════════════════════════════════════════

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: context.relax.border,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 10,
              letterSpacing: 1.5,
              color: context.relax.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: context.relax.border,
          ),
        ),
      ],
    );
  }
}

class _ClosingLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Center(
        child: Text(
          '✦ Sau khi hoàn tất, mình sẽ cùng nhìn lại nha ✦',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.relax.muted,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          Icon(
            Icons.spa_outlined,
            size: 40,
            color: RelaxTheme.lavender.withValues(alpha: .6),
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có hoạt động nào',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Chưa lấy được danh sách thư giãn.\nThử nạp lại nha.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          PixelButton(
            icon: Icons.refresh_rounded,
            label: 'Nạp lại',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: RelaxTheme.lavender.withValues(alpha: .6),
          ),
        ),
      ),
    );
  }
}

class _RelaxSyncStrip extends StatelessWidget {
  const _RelaxSyncStrip({
    required this.loading,
    required this.error,
    required this.activityCount,
    required this.resourceCount,
    required this.onRefresh,
  });

  final bool loading;
  final String? error;
  final int activityCount;
  final int resourceCount;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final text = loading
        ? 'Đang chuẩn bị thư viện thư giãn...'
        : error != null
        ? 'Chưa nạp được thư viện, bấm để thử lại.'
        : '$activityCount mục hoạt động · $resourceCount nội dung đi kèm';
    return PixelPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          PixelIconBox(
            icon: error == null
                ? Icons.cloud_done_rounded
                : Icons.cloud_off_outlined,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
          IconButton(
            tooltip: 'Tải lại',
            onPressed: onRefresh,
            icon: Icon(Icons.refresh_rounded, color: context.relax.muted),
          ),
        ],
      ),
    );
  }
}
