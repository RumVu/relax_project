import 'package:flutter/material.dart';
import '../../data/models/app_models.dart';
import '../../app/theme.dart';
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
    this.onBack,
    this.onChainNext,
  });

  final List<BackendRelaxActivity> backendActivities;
  final bool loadingCatalog;
  final String? catalogError;
  final VoidCallback onRefreshCatalog;
  final VoidCallback? onBack;

  /// Khi user finish 1 activity và chọn tiếp tục với activity khác từ recovery flow.
  final ValueChanged<Activity>? onChainNext;

  @override
  Widget build(BuildContext context) {
    // Chỉ dùng dữ liệu REAL từ backend. Không có fallback hardcode.
    final displayActivities = backendActivities
        .map(Activity.fromBackend)
        .toList(growable: false)
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
    final syncedActivities = displayActivities;
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
            onLeadingTap: onBack,
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
          if (!loadingCatalog && displayActivities.isEmpty)
            PixelPanel(
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
                ],
              ),
            )
          else if (loadingCatalog && displayActivities.isEmpty)
            Padding(
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
            )
          else
            ...displayActivities.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ActivityCard(
                  activity: activity,
                  allActivities: displayActivities,
                  onChainNext: onChainNext,
                ),
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
