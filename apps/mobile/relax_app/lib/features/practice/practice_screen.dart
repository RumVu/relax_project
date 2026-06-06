import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/models/backend_models.dart';
import '../../shared/widgets/layout/app_scroll.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';
import '../relax/sheets/relax_sheets.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({
    super.key,
    required this.activity,
    this.allActivities = const [],
    this.onChainNext,
    this.onFinish,
  });

  final Activity activity;
  final List<Activity> allActivities;

  /// Khi user chọn activity tiếp theo trong recovery flow.
  /// Shell sẽ push 1 PracticeScreen mới với activity đó.
  final ValueChanged<Activity>? onChainNext;

  /// Khi non-null: Finish button → callback (Journey reflection chapter).
  /// Khi null (standalone): Finish → showFeedbackSheet legacy.
  final VoidCallback? onFinish;

  bool get _isBreathing => activity.type == 'BREATHING';
  bool get _isJournal => activity.type == 'JOURNAL';
  bool get _isAudio =>
      activity.type == 'MUSIC' ||
      activity.type == 'PODCAST' ||
      activity.type == 'MEDITATION';

  String get _title {
    return switch (activity.type) {
      'MUSIC' => 'Nghe nhạc ✦',
      'PODCAST' => 'Podcast ✦',
      'MEDITATION' => 'Thiền định ✦',
      'BREATHING' => 'Hít thở ✦',
      'JOURNAL' => 'Viết nhật ký ✦',
      _ => '${activity.compactTitle} ✦',
    };
  }

  String get _subtitle {
    return switch (activity.type) {
      'MUSIC' => 'Chọn một bản dịu tai để thả nhịp xuống.',
      'PODCAST' => 'Lắng nghe một đoạn ngắn để gỡ căng thẳng.',
      'MEDITATION' => 'Một nhịp ngồi yên để quay về với mình.',
      'BREATHING' => 'Theo vòng thở trực quan, không cần tự nhẩm.',
      'JOURNAL' => 'Viết vài dòng để gọi tên điều đang diễn ra.',
      _ => activity.description,
    };
  }

  String get _primaryLabel {
    return switch (activity.type) {
      'BREATHING' => 'Bắt đầu hít thở',
      'JOURNAL' => 'Mở nhật ký',
      'MEDITATION' => 'Bắt đầu thiền',
      'PODCAST' => 'Nghe podcast',
      _ => 'Bắt đầu nghe',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PracticeHeader(title: _title, subtitle: _subtitle),
              const SizedBox(height: 14),
              PixelPanel(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PixelIconBox(icon: activity.icon, size: 82),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.compactTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                activity.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _MetaPill(
                                    text:
                                        '${activity.durationMinutes ?? 12} phút',
                                  ),
                                  _MetaPill(
                                    text:
                                        'relief ${activity.reliefPercent ?? 0}%',
                                  ),
                                  _MetaPill(
                                    text: '${activity.contentCount} nội dung',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isAudio)
                      _AudioPreview(activity: activity, onFinish: onFinish),
                    if (_isBreathing) const _BreathingPreview(),
                    if (_isJournal) const _JournalPreview(),
                    const SizedBox(height: 16),
                    PixelButton(
                      icon: _isJournal
                          ? Icons.edit_note_rounded
                          : Icons.play_arrow_rounded,
                      label: _primaryLabel,
                      filled: true,
                      onPressed: () => showPlayerSheet(
                        context,
                        activity,
                        // Trong Journey: bubble Finish của sheet → Reflection
                        // chapter (qua onFinish của PracticeScreen).
                        onFinish: onFinish,
                      ),
                    ),
                    const SizedBox(height: 10),
                    PixelButton(
                      icon: Icons.flag_rounded,
                      label: 'Hoàn tất phiên',
                      onPressed: onFinish ??
                          () => showFeedbackSheet(
                                context,
                                activity,
                                allActivities: allActivities,
                                onContinueNext: onChainNext,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeHeader extends StatelessWidget {
  const _PracticeHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.relax.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const SizedBox(
          width: 92,
          height: 64,
          child: PixelCatScene(scene: CatScene.sleep, height: 64),
        ),
      ],
    );
  }
}

class _AudioPreview extends StatelessWidget {
  const _AudioPreview({required this.activity, this.onFinish});

  final Activity activity;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final resources = activity.resources;
    return PixelPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DANH SÁCH PHÁT', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          if (resources.isEmpty)
            Text(
              'Chưa có nội dung cụ thể. Bấm làm mới ở Khu thư giãn sau khi backend đồng bộ.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            SizedBox(
              height: 260,
              child: ListView.separated(
                itemCount: resources.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _ResourceRow(
                    resource: resources[index],
                    onTap: () => showPlayerSheet(
                      context,
                      activity,
                      onFinish: onFinish,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.resource, required this.onTap});

  final BackendResource resource;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.relax.surfaceSoft,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: RelaxTheme.purple.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.relax.border),
                ),
                child: const Icon(Icons.play_arrow_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  resource.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                resource.durationLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingPreview extends StatelessWidget {
  const _BreathingPreview();

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  RelaxTheme.lavender.withValues(alpha: .9),
                  RelaxTheme.purple.withValues(alpha: .5),
                  context.relax.surfaceSoft,
                ],
              ),
            ),
            child: const Center(
              child: Text('4-4-6', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Vòng thở sẽ tự phình to khi hít vào, giữ nhịp, rồi thu nhỏ khi thở ra.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalPreview extends StatelessWidget {
  const _JournalPreview();

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GỢI Ý VIẾT', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            'Điều gì đang làm bạn nặng lòng nhất lúc này?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Khi mở nhật ký, bạn có thể chọn prompt khác và viết trực tiếp trong phiên.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RelaxTheme.purple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
