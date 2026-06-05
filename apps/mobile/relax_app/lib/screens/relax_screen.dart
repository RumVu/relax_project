part of 'package:relax_app/main.dart';

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
          const SizedBox(height: 12),
          BackendStatusBanner(
            loading: loadingCatalog,
            error: catalogError,
            loadedCount: syncedActivities.length,
            resourceCount: resourceCount,
            onRefresh: onRefreshCatalog,
          ),
          const SizedBox(height: 12),
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
