import 'package:flutter/material.dart';
import '../../../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/models/backend_models.dart';
import '../../shared/widgets/activity/activity_card.dart';
import '../../shared/widgets/layout/app_scroll.dart';
import '../../shared/widgets/layout/header_bar.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';

class RelaxScreen extends StatelessWidget {
  const RelaxScreen({
    super.key,
    required this.backendActivities,
    required this.loadingCatalog,
    required this.catalogError,
    required this.onRefreshCatalog,
  });

  final List<BackendRelaxActivity> backendActivities;
  final bool loadingCatalog;
  final String? catalogError;
  final VoidCallback onRefreshCatalog;

  static const activities = [
    Activity(
      '01. Nhạc',
      'Những giai điệu nhẹ nhàng giúp tâm trí bạn thư giãn.',
      Icons.radio_rounded,
    ),
    Activity(
      '02. Podcast',
      'Lắng nghe những câu chuyện truyền cảm hứng mỗi ngày.',
      Icons.mic_external_on_rounded,
    ),
    Activity(
      '03. Viết nhật kí',
      'Ghi lại cảm xúc và suy nghĩ để nhẹ lòng hơn nhé.',
      Icons.menu_book_rounded,
    ),
    Activity(
      '04. Hít thở không khí',
      'Hít thở sâu, thả lỏng cơ thể và sống chậm lại nào.',
      Icons.cloud_rounded,
    ),
    Activity(
      '05. Bí ẩn',
      'Để Thi Ái chọn một hoạt động bất ngờ phù hợp với bạn!',
      Icons.inventory_2_rounded,
    ),
    Activity(
      '06. Thiền định',
      'Ngồi yên một chút để tâm trí có chỗ thở.',
      Icons.self_improvement_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final syncedActivities = backendActivities
        .map(Activity.fromBackend)
        .toList(growable: false);
    final displayActivities = syncedActivities.isEmpty
        ? activities
        : syncedActivities
              .asMap()
              .entries
              .map(
                (entry) => Activity(
                  '${(entry.key + 1).toString().padLeft(2, '0')}. ${entry.value.title}',
                  entry.value.description,
                  entry.value.icon,
                  type: entry.value.type,
                  durationMinutes: entry.value.durationMinutes,
                  reliefPercent: entry.value.reliefPercent,
                  resources: entry.value.resources,
                ),
              )
              .toList(growable: false);
    final resourceCount = syncedActivities.fold<int>(
      0,
      (sum, activity) => sum + activity.contentCount,
    );

    return AppScroll(
      child: Column(
        children: [
          HeaderBar(
            icon: Icons.arrow_back_ios_new_rounded,
            title: 'Thư giãn ✦',
            subtitle: 'Chọn một cách để thư giãn nhé ~',
            trailing: const PixelCatScene(scene: CatScene.sleep, height: 66),
          ),
          if (loadingCatalog || catalogError != null) ...[
            const SizedBox(height: 14),
            _RelaxSyncStrip(
              loading: loadingCatalog,
              error: catalogError,
              activityCount: displayActivities.length,
              resourceCount: resourceCount,
              onRefresh: onRefreshCatalog,
            ),
          ],
          const SizedBox(height: 14),
          ...displayActivities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActivityCard(activity: activity),
            ),
          ),
        ],
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
