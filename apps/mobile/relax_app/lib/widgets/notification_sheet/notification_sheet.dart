import 'package:flutter/material.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../soft_toast.dart';
import 'widgets/notification_item.dart';

/// Hộp thoại bottom sheet danh sách thông báo phong cách premium dark-mode.
class NotificationSheet extends StatefulWidget {
  const NotificationSheet({
    super.key,
    required this.onRefreshCount,
  });

  final VoidCallback onRefreshCount;

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await RelaxApi.instance
          .get('/notifications/me', query: {'limit': 50});
      final data = res.data;
      final list = data is Map ? data['items'] : data;
      if (list is List) {
        setState(() {
          _items = list
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(String id, int index) async {
    if (_items[index]['isRead'] == true) return;
    try {
      final res =
          await RelaxApi.instance.patch('/notifications/me/$id/read');
      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() => _items[index]['isRead'] = true);
        widget.onRefreshCount();
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _markAllRead() async {
    final unread = _items.any((e) => e['isRead'] != true);
    if (!unread) return;

    try {
      final res =
          await RelaxApi.instance.patch('/notifications/me/read-all');
      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() {
          for (final it in _items) {
            it['isRead'] = true;
          }
        });
        widget.onRefreshCount();
        if (mounted) {
          showSoftToast(context,
              message: context.t('Đã đọc tất cả thông báo'),
              tone: SoftToastTone.success);
        }
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: '${context.t('Lỗi:')} ${e.toString()}',
            tone: SoftToastTone.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _items.any((e) => e['isRead'] != true);

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          // Handlebar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.mutedText.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  context.t('Thông báo'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: context.appText,
                  ),
                ),
                const Spacer(),
                if (hasUnread)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: RelaxColors.violet,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    onPressed: _markAllRead,
                    icon: const Icon(Icons.done_all, size: 16),
                    label: Text(
                      context.t('Đã đọc hết'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 16, thickness: 0.5),
          // Body content
          Flexible(
            child: SizedBox(
              height: 420,
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: RelaxColors.violet))
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              context.t('Lỗi: {error}',
                                  {'error': '$_error'}),
                              style: const TextStyle(
                                  color: RelaxColors.coral, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_off_outlined,
                                    size: 48,
                                    color: context.mutedText
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    context.t(
                                        'Không có thông báo nào.'),
                                    style: TextStyle(
                                        color: context.mutedText,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: RelaxColors.violet,
                              onRefresh: _fetchNotifications,
                              child: ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                itemCount: _items.length,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  final id = item['id'] as String;
                                  return NotificationItem(
                                    item: item,
                                    onTap: () =>
                                        _markRead(id, index),
                                  );
                                },
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }
}
