import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/services/journal_service.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';
import 'journal_write_screen.dart';

/// Journal history — list các entries đã lưu, group theo ngày.
/// Tap entry → mở detail sheet với edit + delete + favorite toggle + full
/// content.
///
/// Pagination: load 30 entries lần đầu. Khi user kéo gần cuối list hoặc tap
/// "Tải thêm" → fetch tiếp 30 cái cũ hơn via offset.
class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  static const _pageSize = 30;
  final _scrollCtrl = ScrollController();

  List<JournalEntry> _entries = const [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    if (_scrollCtrl.position.pixels >
        _scrollCtrl.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _load({bool reset = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (reset) _entries = const [];
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
      final page = await JournalService().list(
        accessToken: session.accessToken!,
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _entries = page.entries;
        _hasMore = page.hasMore;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(e);
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    final session = context.sessionOrNull;
    if (session == null) {
      setState(() => _loadingMore = false);
      return;
    }
    try {
      final page = await JournalService().list(
        accessToken: session.accessToken!,
        limit: _pageSize,
        offset: _entries.length,
      );
      if (!mounted) return;
      setState(() {
        _entries = [..._entries, ...page.entries];
        _hasMore = page.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  String _friendlyError(Object e) {
    final raw = e.toString();
    if (raw.contains('Socket') ||
        raw.contains('Timeout') ||
        raw.contains('TimeoutException')) {
      return 'Mạng yếu quá hoặc server chưa phản hồi. Kéo xuống làm mới nha ~';
    }
    if (raw.contains('404')) {
      return 'Endpoint nhật ký chưa được wire. Báo dev hỗ trợ giúp.';
    }
    if (raw.contains('401') || raw.contains('Unauthorized')) {
      return 'Phiên đăng nhập hết hạn. Đăng nhập lại rồi quay lại nha.';
    }
    return raw.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _onEntryDeleted(JournalEntry entry) async {
    setState(() => _entries = _entries.where((e) => e.id != entry.id).toList());
  }

  Future<void> _onEntryUpdated(JournalEntry updated) async {
    setState(() {
      _entries = _entries
          .map((e) => e.id == updated.id ? updated : e)
          .toList(growable: false);
    });
  }

  /// Mở màn viết nhật ký mới. Khi lưu thành công → insert entry vào đầu list.
  Future<void> _openWrite() async {
    final entry = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute(builder: (_) => const JournalWriteScreen()),
    );
    if (entry == null || !mounted) return;
    setState(() {
      _entries = [entry, ..._entries];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu nhật ký mới ✦')),
    );
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
        title: Text('Nhật ký · ${_entries.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : () => _load(reset: true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWrite,
        backgroundColor: RelaxTheme.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text(
          'Viết mới',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        color: RelaxTheme.purple,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _entries.isEmpty) {
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
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: dayKeys.length + 1, // +1 cho footer "Tải thêm"
      itemBuilder: (_, i) {
        if (i == dayKeys.length) return _buildFooter();
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
            for (final e in items)
              _EntryCard(
                entry: e,
                time: _formatTime(e.createdAt),
                onDeleted: _onEntryDeleted,
                onUpdated: _onEntryUpdated,
              ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_hasMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        child: PixelButton(
          icon: Icons.expand_more_rounded,
          label: 'Tải thêm bài cũ',
          onPressed: _loadMore,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          '✦ Đã xem hết — đẹp lắm rồi ~',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.relax.muted,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.time,
    required this.onDeleted,
    required this.onUpdated,
  });
  final JournalEntry entry;
  final String time;
  final ValueChanged<JournalEntry> onDeleted;
  final ValueChanged<JournalEntry> onUpdated;

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
      builder: (_) => _EntryDetailSheet(
        entry: entry,
        onDeleted: onDeleted,
        onUpdated: onUpdated,
      ),
    );
  }
}

class _EntryDetailSheet extends StatefulWidget {
  const _EntryDetailSheet({
    required this.entry,
    required this.onDeleted,
    required this.onUpdated,
  });
  final JournalEntry entry;
  final ValueChanged<JournalEntry> onDeleted;
  final ValueChanged<JournalEntry> onUpdated;

  @override
  State<_EntryDetailSheet> createState() => _EntryDetailSheetState();
}

class _EntryDetailSheetState extends State<_EntryDetailSheet> {
  late JournalEntry _current = widget.entry;
  bool _busy = false;

  Future<void> _toggleFavorite() async {
    final session = context.sessionOrNull;
    if (session == null) return;
    final next = !_current.isFavorite;
    // Optimistic update — UI flip ngay
    setState(() => _current = JournalEntry(
      id: _current.id,
      content: _current.content,
      createdAt: _current.createdAt,
      title: _current.title,
      mood: _current.mood,
      tags: _current.tags,
      isFavorite: next,
    ));
    widget.onUpdated(_current);
    try {
      final updated = await JournalService().update(
        accessToken: session.accessToken!,
        id: _current.id,
        isFavorite: next,
      );
      if (!mounted) return;
      setState(() => _current = updated);
      widget.onUpdated(updated);
    } catch (_) {
      // Revert nếu API fail
      if (!mounted) return;
      setState(() => _current = JournalEntry(
        id: _current.id,
        content: _current.content,
        createdAt: _current.createdAt,
        title: _current.title,
        mood: _current.mood,
        tags: _current.tags,
        isFavorite: !next,
      ));
      widget.onUpdated(_current);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không lưu được — thử lại nha ~')),
      );
    }
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute(builder: (_) => _EntryEditorScreen(entry: _current)),
    );
    if (!mounted || updated == null) return;
    setState(() => _current = updated);
    widget.onUpdated(updated);
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa entry này?'),
        content: const Text(
          'Sau khi xóa sẽ không thể khôi phục. Bạn chắc chứ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Giữ lại'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE85A6A),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final session = context.sessionOrNull;
    if (session == null) return;
    setState(() => _busy = true);
    try {
      await JournalService().delete(
        accessToken: session.accessToken!,
        id: _current.id,
      );
      if (!mounted) return;
      widget.onDeleted(_current);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * .82;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          // Action bar: favorite / edit / delete
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Row(
              children: [
                IconButton(
                  tooltip: _current.isFavorite
                      ? 'Bỏ yêu thích'
                      : 'Đánh dấu yêu thích',
                  onPressed: _busy ? null : _toggleFavorite,
                  icon: Icon(
                    _current.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _current.isFavorite
                        ? const Color(0xFFE85A6A)
                        : context.relax.muted,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Sửa',
                  onPressed: _busy ? null : _openEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Xóa',
                  onPressed: _busy ? null : _confirmDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE85A6A),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: ListView(
                children: [
                  if (_current.title?.isNotEmpty == true) ...[
                    Text(
                      _current.title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: RelaxTheme.lavender,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    '${_current.createdAt.day.toString().padLeft(2, '0')}/${_current.createdAt.month.toString().padLeft(2, '0')}/${_current.createdAt.year} '
                    '· ${_current.createdAt.hour.toString().padLeft(2, '0')}:${_current.createdAt.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                          color: context.relax.muted,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _current.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  if (_current.tags.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _current.tags
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
          ),
        ],
      ),
    );
  }
}

/// Màn editor cho entry — title + content text fields, save về.
class _EntryEditorScreen extends StatefulWidget {
  const _EntryEditorScreen({required this.entry});
  final JournalEntry entry;

  @override
  State<_EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<_EntryEditorScreen> {
  late final _titleCtrl = TextEditingController(text: widget.entry.title ?? '');
  late final _contentCtrl = TextEditingController(text: widget.entry.content);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      setState(() => _error = 'Viết vài dòng nha — chưa lưu được entry trống.');
      return;
    }
    final session = context.sessionOrNull;
    if (session == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await JournalService().update(
        accessToken: session.accessToken!,
        id: widget.entry.id,
        title: _titleCtrl.text.trim(),
        content: content,
      );
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Không lưu được: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Sửa nhật ký'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving ? 'Đang lưu...' : 'Lưu',
              style: TextStyle(
                color: RelaxTheme.lavender,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleCtrl,
              enabled: !_saving,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề (không bắt buộc)',
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                enabled: !_saving,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Viết thêm gì đó nha...',
                  filled: true,
                  fillColor: context.relax.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.relax.border),
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.relax.danger,
                      fontWeight: FontWeight.w800,
                    ),
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
