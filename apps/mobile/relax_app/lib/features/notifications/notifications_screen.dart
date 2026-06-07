import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/models/notification_item.dart';
import '../../data/services/inbox/inbox_service.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';

/// Hộp thư thông báo — inbox thật với mark-as-read + action CTA.
///
/// Thay thế cho notification panel ở Home (chỉ là status, không phải inbox).
/// Mỗi notification có:
///   - Icon + color riêng (xanh = info, vàng = streak, đỏ = crisis...)
///   - Action button nếu actionPayload không null → invoke onAction
///   - Read state lưu vào SharedPreferences (per id)
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.isLoggedIn,
    required this.moodHistoryCount,
    required this.streakDays,
    required this.hasAccentTheme,
    this.lastMoodAt,
    this.onAction,
  });

  final bool isLoggedIn;
  final int moodHistoryCount;
  final int streakDays;
  final bool hasAccentTheme;
  final DateTime? lastMoodAt;

  /// Khi user tap CTA của 1 noti → invoke với payload key.
  /// Caller (shell) dispatch: 'home'→tab 0, 'relax'→tab 1, 'setup'→tab 3,
  /// 'crisis'→push CrisisSupport, 'insights'→push Insights, etc.
  final ValueChanged<String>? onAction;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await InboxService.instance.build(
      isLoggedIn: widget.isLoggedIn,
      moodHistoryCount: widget.moodHistoryCount,
      streakDays: widget.streakDays,
      hasAccentTheme: widget.hasAccentTheme,
      lastMoodAt: widget.lastMoodAt,
    );
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _markRead(NotificationItem item) async {
    if (item.read) return;
    await InboxService.instance.markRead(item.id);
    if (!mounted) return;
    setState(() {
      _items = _items
          .map((n) => n.id == item.id ? n.copyWith(read: true) : n)
          .toList(growable: false);
    });
  }

  Future<void> _markAllRead() async {
    final unread = _items.where((n) => !n.read).map((n) => n.id);
    if (unread.isEmpty) return;
    await InboxService.instance.markAllRead(unread);
    if (!mounted) return;
    setState(() {
      _items = _items.map((n) => n.copyWith(read: true)).toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((n) => !n.read).length;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          unread > 0 ? 'Thông báo · $unread mới' : 'Thông báo',
        ),
        actions: [
          if (unread > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Đánh dấu đã đọc'),
              style: TextButton.styleFrom(
                foregroundColor: RelaxTheme.lavender,
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: RelaxTheme.purple,
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 80),
          const Center(child: CatAvatar(size: 100)),
          const SizedBox(height: 20),
          Icon(
            Icons.mark_email_read_rounded,
            size: 38,
            color: RelaxTheme.lavender.withValues(alpha: .5),
          ),
          const SizedBox(height: 10),
          Text(
            'Hộp thư trống xíu ~',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Yên ổn rồi. Mình sẽ ping bạn khi có gì đáng để biết ✦',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
      itemCount: _items.length,
      itemBuilder: (_, i) => _NotificationCard(
        item: _items[i],
        onRead: () => _markRead(_items[i]),
        onAction: () {
          _markRead(_items[i]);
          final payload = _items[i].actionPayload;
          if (payload != null) widget.onAction?.call(payload);
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onRead,
    required this.onAction,
  });
  final NotificationItem item;
  final VoidCallback onRead;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final unreadDot = !item.read;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.read
            ? Theme.of(context).colorScheme.surface
            : item.color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.read
              ? context.relax.border
              : item.color.withValues(alpha: .35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onRead,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (unreadDot)
                                Container(
                                  width: 7,
                                  height: 7,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.relativeTime,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 10.5,
                                  color: context.relax.muted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Text(
                    item.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          fontSize: 12.5,
                        ),
                  ),
                ),
                if (item.actionLabel != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 52),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonalIcon(
                        onPressed: onAction,
                        style: FilledButton.styleFrom(
                          backgroundColor: item.color.withValues(alpha: .15),
                          foregroundColor: item.color,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text(item.actionLabel!),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
