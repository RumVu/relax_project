import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/services/journal_service.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../data/models/app_models.dart';

/// Journal history — list các entries đã lưu, group theo ngày.
/// Tap entry → mở detail dialog với full content + mood + tags.
class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  List<JournalEntry> _entries = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final session = context.sessionOrNull;
    if (session == null || !session.isLoggedIn) {
      setState(() {
        _loading = false;
        _error = 'Bạn cần đăng nhập để xem nhật ký.';
      });
      return;
    }
    try {
      final list = await JournalService().list(
        accessToken: session.accessToken!,
        limit: 60,
      );
      if (!mounted) return;
      setState(() {
        _entries = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không tải được nhật ký: $e';
      });
    }
  }

  Map<String, List<JournalEntry>> get _groupedByDate {
    final groups = <String, List<JournalEntry>>{};
    for (final e in _entries) {
      final key = _formatDay(e.createdAt);
      groups.putIfAbsent(key, () => []).add(e);
    }
    return groups;
  }

  String _formatDay(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entry = DateTime(d.year, d.month, d.day);
    if (entry == today) return 'Hôm nay';
    if (entry == today.subtract(const Duration(days: 1))) return 'Hôm qua';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatTime(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Nhật ký của bạn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: RelaxTheme.purple,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Có lỗi',
        body: _error!,
      );
    }
    if (_entries.isEmpty) {
      return _EmptyState(
        icon: Icons.menu_book_rounded,
        title: 'Chưa có nhật ký nào',
        body:
            'Khi bạn viết entry đầu tiên ở "Khu thư giãn → Viết nhật ký", nó sẽ xuất hiện ở đây ✦',
      );
    }
    final groups = _groupedByDate;
    final dayKeys = groups.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: dayKeys.length,
      itemBuilder: (_, i) {
        final day = dayKeys[i];
        final items = groups[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: RelaxTheme.lavender,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    day,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: RelaxTheme.lavender,
                        ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '· ${items.length} entry',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: context.relax.muted,
                        ),
                  ),
                ],
              ),
            ),
            for (final e in items) _EntryCard(entry: e, time: _formatTime(e.createdAt)),
          ],
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.time});
  final JournalEntry entry;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RelaxTheme.lavender.withValues(alpha: .18),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (entry.isFavorite)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: Color(0xFFE85A6A),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      entry.title?.isNotEmpty == true ? entry.title! : 'Nhật ký',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: context.relax.muted,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12.5,
                      height: 1.4,
                    ),
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: entry.tags
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: RelaxTheme.purple.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 10,
                              color: RelaxTheme.lavender,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => _EntryDetailSheet(entry: entry),
    );
  }
}

class _EntryDetailSheet extends StatelessWidget {
  const _EntryDetailSheet({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * .8;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: ListView(
          children: [
            if (entry.title?.isNotEmpty == true) ...[
              Text(
                entry.title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: RelaxTheme.lavender,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              '${entry.createdAt.day.toString().padLeft(2, '0')}/${entry.createdAt.month.toString().padLeft(2, '0')}/${entry.createdAt.year} '
              '· ${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: context.relax.muted,
                  ),
            ),
            const SizedBox(height: 14),
            Text(
              entry.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 18),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.tags
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: RelaxTheme.purple.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '#$t',
                          style: const TextStyle(
                            fontSize: 12,
                            color: RelaxTheme.lavender,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 80),
        const Center(child: CatAvatar(size: 100)),
        const SizedBox(height: 20),
        Icon(icon, size: 38, color: RelaxTheme.lavender.withValues(alpha: .5)),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
