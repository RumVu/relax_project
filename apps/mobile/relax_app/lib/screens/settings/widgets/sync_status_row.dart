import 'package:flutter/material.dart';

import '../../../core/locale_controller.dart';
import '../../../core/offline_store.dart';
import '../../../core/theme.dart';
import 'settings_shared.dart';

class SyncStatusRow extends StatelessWidget {
  const SyncStatusRow({super.key});

  @override
  Widget build(BuildContext context) {
    final store = OfflineStore.instance;
    final pending = store.pendingCount;
    final failed = store.failedCount;
    final hasIssues = pending > 0 || failed > 0;

    return SettingsCard(
      children: [
        SettingsRow(
          icon: Icons.sync,
          title: context.t('Đồng bộ dữ liệu'),
          subtitle: hasIssues
              ? '${pending > 0 ? "$pending đang chờ" : ""}${pending > 0 && failed > 0 ? " · " : ""}${failed > 0 ? "$failed lỗi" : ""}'
              : context.t('Mọi thứ đã đồng bộ'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (failed > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: RelaxColors.coral.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$failed',
                    style: const TextStyle(
                      color: RelaxColors.coral,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                hasIssues ? Icons.warning_amber : Icons.check_circle,
                color: hasIssues ? const Color(0xFFF59E0B) : RelaxColors.mint,
                size: 18,
              ),
            ],
          ),
          onTap: () => _showSyncSheet(context),
        ),
      ],
    );
  }

  void _showSyncSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _SyncSheet(),
    );
  }
}

class _SyncSheet extends StatefulWidget {
  const _SyncSheet();

  @override
  State<_SyncSheet> createState() => _SyncSheetState();
}

class _SyncSheetState extends State<_SyncSheet> {
  @override
  void initState() {
    super.initState();
    OfflineStore.instance.addListener(_onUpdate);
  }

  @override
  void dispose() {
    OfflineStore.instance.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = OfflineStore.instance;
    final items = store.queueItems;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      expand: false,
      builder: (ctx, scrollCtrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.fieldBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.sync, color: RelaxColors.violet, size: 22),
                const SizedBox(width: 8),
                Text(
                  context.t('Hàng đợi đồng bộ'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: context.appText,
                  ),
                ),
                const Spacer(),
                if (store.failedCount > 0)
                  TextButton(
                    onPressed: () => store.retryAll(),
                    child: Text(context.t('Thử lại tất cả'),
                        style: const TextStyle(
                            color: RelaxColors.violet,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_done,
                              color: RelaxColors.mint, size: 48),
                          const SizedBox(height: 12),
                          Text(context.t('Mọi thứ đã đồng bộ!'),
                              style: TextStyle(
                                  color: context.appText,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollCtrl,
                      itemCount: items.length,
                      itemBuilder: (ctx, idx) =>
                          _buildSyncItem(context, items[idx]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncItem(BuildContext context, SyncQueueItem item) {
    final isFailed = item.status == SyncStatus.failed;
    final isSyncing = item.status == SyncStatus.syncing;

    Color statusColor;
    IconData statusIcon;
    switch (item.status) {
      case SyncStatus.pending:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.schedule;
      case SyncStatus.syncing:
        statusColor = RelaxColors.violet;
        statusIcon = Icons.sync;
      case SyncStatus.failed:
        statusColor = RelaxColors.coral;
        statusIcon = Icons.error_outline;
      case SyncStatus.resolved:
        statusColor = RelaxColors.mint;
        statusIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFailed
              ? RelaxColors.coral.withValues(alpha: 0.3)
              : context.fieldBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.method} ${item.path}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: context.appText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.createdAt.day}/${item.createdAt.month} ${item.createdAt.hour}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: context.mutedText, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isSyncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: RelaxColors.violet),
                ),
            ],
          ),
          if (isFailed && item.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              item.errorMessage!,
              style: const TextStyle(
                  color: RelaxColors.coral, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => OfflineStore.instance
                        .resolveConflict(item.id, keepLocal: true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RelaxColors.violet,
                      side: const BorderSide(color: RelaxColors.violet),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(context.t('Giữ bản local'),
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        OfflineStore.instance.discardItem(item.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RelaxColors.coral,
                      side: const BorderSide(color: RelaxColors.coral),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(context.t('Bỏ qua'),
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
