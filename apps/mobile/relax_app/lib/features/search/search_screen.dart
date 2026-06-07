import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../data/models/backend_models.dart';
import '../../data/services/journal_service.dart';
import '../../data/services/mobile_content_service.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';

/// Trang tìm kiếm xuyên app — activity, journal entry, quote, companion line.
///
/// Strategy:
///   1. Index local từ `MobileContentSnapshot` + `List<BackendRelaxActivity>`
///   2. Journal entries → fetch on-demand khi đã login
///   3. Debounce 280ms khi user gõ
///   4. Group kết quả theo loại: Hoạt động / Lời nhắn / Câu trích / Nhật ký
///
/// Tap result:
///   - Activity → onActivityTap(activity) — shell push Journey
///   - Journal → mở entry detail (sau)
///   - Quote/Message → copy to clipboard
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.content,
    required this.activities,
    this.onActivityTap,
  });

  final MobileContentSnapshot content;
  final List<BackendRelaxActivity> activities;
  final ValueChanged<Activity>? onActivityTap;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  String _query = '';
  List<JournalEntry> _journals = const [];
  bool _searchingJournals = false;

  static const _recentSearchesKey = '__local__'; // reserved for future

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
    // Auto focus sau frame để keyboard pop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() {
    final q = _ctrl.text.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() => _query = q);
      if (q.length >= 2) _searchJournals(q);
    });
  }

  Future<void> _searchJournals(String q) async {
    final session = context.sessionOrNull;
    if (session == null || !session.isLoggedIn) {
      setState(() => _journals = const []);
      return;
    }
    setState(() => _searchingJournals = true);
    try {
      // Backend chưa có search endpoint riêng → fetch latest 60 entries
      // rồi filter client-side. Trade-off OK cho dataset nhỏ.
      final page = await JournalService().list(
        accessToken: session.accessToken!,
        limit: 60,
      );
      if (!mounted) return;
      final lower = q.toLowerCase();
      final filtered = page.entries
          .where((e) =>
              e.content.toLowerCase().contains(lower) ||
              (e.title ?? '').toLowerCase().contains(lower) ||
              e.tags.any((t) => t.toLowerCase().contains(lower)))
          .toList(growable: false);
      setState(() {
        _journals = filtered;
        _searchingJournals = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _journals = const [];
        _searchingJournals = false;
      });
    }
  }

  // ── Local filters ──────────────────────────────────────────────────

  List<Activity> get _matchedActivities {
    if (_query.length < 2) return const [];
    final lower = _query.toLowerCase();
    return widget.activities
        .map(Activity.fromBackend)
        .where((a) =>
            a.title.toLowerCase().contains(lower) ||
            a.description.toLowerCase().contains(lower) ||
            a.type.toLowerCase().contains(lower))
        .toList(growable: false);
  }

  List<String> get _matchedQuotes {
    if (_query.length < 2) return const [];
    final lower = _query.toLowerCase();
    final q = widget.content.quote?.content;
    return [
      if (q != null && q.toLowerCase().contains(lower)) q,
    ];
  }

  List<String> get _matchedCompanionLines {
    if (_query.length < 2) return const [];
    final lower = _query.toLowerCase();
    final all = <String>{};
    final cm = widget.content.companionMessage?.content;
    if (cm != null) all.add(cm);
    for (final m in widget.content.moodOptions) {
      if (m.companionLine.isNotEmpty) all.add(m.companionLine);
    }
    return all
        .where((s) => s.toLowerCase().contains(lower))
        .toList(growable: false);
  }

  bool get _hasAnyResult =>
      _matchedActivities.isNotEmpty ||
      _matchedQuotes.isNotEmpty ||
      _matchedCompanionLines.isNotEmpty ||
      _journals.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Tìm hoạt động, nhật ký, lời nhắn...',
            border: InputBorder.none,
            suffixIcon: _ctrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() {
                        _query = '';
                        _journals = const [];
                      });
                    },
                  ),
          ),
        ),
      ),
      body: _query.length < 2
          ? _buildHints()
          : !_hasAnyResult && !_searchingJournals
              ? _buildEmpty()
              : _buildResults(),
    );
  }

  // ── Builders ───────────────────────────────────────────────────────

  Widget _buildHints() {
    const suggestions = [
      'hít thở',
      'thiền',
      'nhạc nhẹ',
      'biết ơn',
      'lo lắng',
      'nghỉ ngơi',
      'cảm xúc',
      'ngày mới',
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Center(child: CatAvatar(size: 80)),
        const SizedBox(height: 16),
        Text(
          'Tìm gì mình giúp với? ✦',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Gõ ít nhất 2 ký tự — mình sẽ tìm trong hoạt động thư giãn, lời '
          'nhắn, câu trích, và nhật ký của bạn.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: context.relax.muted,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'GỢI Ý',
          style: TextStyle(
            color: RelaxTheme.lavender,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in suggestions)
              ActionChip(
                label: Text(s),
                onPressed: () {
                  _ctrl.text = s;
                  _ctrl.selection = TextSelection.collapsed(
                    offset: s.length,
                  );
                },
                backgroundColor: RelaxTheme.purple.withValues(alpha: .08),
                side: BorderSide(
                  color: RelaxTheme.lavender.withValues(alpha: .3),
                ),
                labelStyle: TextStyle(
                  color: RelaxTheme.lavender,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 60),
        const Center(child: CatAvatar(size: 80)),
        const SizedBox(height: 16),
        Icon(
          Icons.search_off_rounded,
          size: 38,
          color: RelaxTheme.lavender.withValues(alpha: .5),
        ),
        const SizedBox(height: 10),
        Text(
          'Không có kết quả cho "$_query" ~',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Thử từ khoá khác, hoặc kéo gợi ý phía dưới nha ✦',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildResults() {
    final acts = _matchedActivities;
    final quotes = _matchedQuotes;
    final companions = _matchedCompanionLines;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (acts.isNotEmpty) ...[
          _SectionHeader(
            label: 'Hoạt động · ${acts.length}',
            icon: Icons.spa_rounded,
          ),
          for (final a in acts) _ActivityResult(activity: a, onTap: () {
            Navigator.of(context).pop();
            widget.onActivityTap?.call(a);
          }),
          const SizedBox(height: 16),
        ],
        if (quotes.isNotEmpty) ...[
          _SectionHeader(
            label: 'Câu trích',
            icon: Icons.format_quote_rounded,
          ),
          for (final q in quotes) _TextResult(text: q, icon: Icons.format_quote_rounded),
          const SizedBox(height: 16),
        ],
        if (companions.isNotEmpty) ...[
          _SectionHeader(
            label: 'Lời nhắn từ Thi Ái',
            icon: Icons.favorite_rounded,
          ),
          for (final c in companions) _TextResult(text: c, icon: Icons.chat_bubble_rounded),
          const SizedBox(height: 16),
        ],
        _SectionHeader(
          label: _searchingJournals
              ? 'Nhật ký · đang tìm...'
              : 'Nhật ký · ${_journals.length}',
          icon: Icons.menu_book_rounded,
        ),
        if (_searchingJournals)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_journals.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              context.sessionOrNull?.isLoggedIn != true
                  ? 'Đăng nhập để tìm trong nhật ký của bạn ~'
                  : 'Không tìm thấy entry nào khớp.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: context.relax.muted,
              ),
            ),
          )
        else
          for (final j in _journals) _JournalResult(entry: j, query: _query),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: RelaxTheme.lavender),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: RelaxTheme.lavender,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityResult extends StatelessWidget {
  const _ActivityResult({required this.activity, required this.onTap});
  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RelaxTheme.lavender.withValues(alpha: .2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: RelaxTheme.purple.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(activity.icon, color: RelaxTheme.lavender),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.compactTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        activity.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: RelaxTheme.lavender,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextResult extends StatelessWidget {
  const _TextResult({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: RelaxTheme.lavender.withValues(alpha: .15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: RelaxTheme.lavender),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalResult extends StatelessWidget {
  const _JournalResult({required this.entry, required this.query});
  final JournalEntry entry;
  final String query;

  @override
  Widget build(BuildContext context) {
    final d = entry.createdAt;
    final dateLabel =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.relax.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateLabel,
                style: TextStyle(
                  color: RelaxTheme.lavender,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              if (entry.isFavorite)
                const Icon(
                  Icons.favorite_rounded,
                  size: 12,
                  color: Color(0xFFE85A6A),
                ),
            ],
          ),
          if (entry.title?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              entry.title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            entry.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
