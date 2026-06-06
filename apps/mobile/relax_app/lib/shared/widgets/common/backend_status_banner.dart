import 'package:flutter/material.dart';
import '../pixel/pixel_panel.dart';

class BackendStatusBanner extends StatelessWidget {
  const BackendStatusBanner({
    super.key,
    required this.loading,
    required this.error,
    required this.loadedCount,
    required this.resourceCount,
    required this.onRefresh,
  });

  final bool loading;
  final String? error;
  final int loadedCount;
  final int resourceCount;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    final icon = loading
        ? Icons.sync_rounded
        : hasError
        ? Icons.cloud_off_rounded
        : Icons.cloud_done_rounded;
    final title = loading
        ? 'Đang làm mới thư viện'
        : hasError
        ? 'Chưa nạp được thư viện'
        : 'Đã đồng bộ nội dung';
    final body = loading
        ? 'Đang lấy hoạt động, âm thanh và nội dung đi kèm.'
        : hasError
        ? 'Bấm thử lại để gọi lại dữ liệu mới.'
        : '$loadedCount mục hoạt động · $resourceCount nội dung đi kèm';

    return PixelPanel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          PixelIconBox(icon: icon, size: 42),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Nạp lại',
            onPressed: loading ? null : onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}
