import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/auth_state.dart';
import '../core/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  Map<String, dynamic>? _quote;
  List<Map<String, dynamic>> _quests = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/cozy-quotes/random'),
        RelaxApi.instance.get('/quests/me', query: {'locale': 'vi'}),
      ]);
      final quoteData = results[0].data;
      final questsData = results[1].data;
      _quote = quoteData is Map ? Map<String, dynamic>.from(quoteData) : null;
      _quests = (questsData is List)
          ? questsData
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    final displayName = (user?['name'] as String?) ??
        (user?['email'] as String?)?.split('@').first ??
        'bạn';
    // Trả về body-only (không Scaffold) vì AppShell đã bọc Scaffold + bottom
    // nav rồi.
    return SafeArea(
        child: RefreshIndicator(
          color: RelaxColors.violet,
          onRefresh: _loadAll,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        name: displayName,
                        avatarUrl: user?['avatar'] as String?,
                        onSettings: () => context.push('/settings'),
                      ),
                      const SizedBox(height: 20),
                      if (_loading) ...[
                        const _Skeleton(),
                        const SizedBox(height: 16),
                        const _Skeleton(height: 200),
                      ] else if (_error != null)
                        _ErrorBanner(message: _error!, onRetry: _loadAll)
                      else ...[
                        _QuoteCard(quote: _quote),
                        const SizedBox(height: 20),
                        _SectionTitle(
                          title: 'Nhiệm vụ hôm nay',
                          trailing:
                              '${_quests.where((q) => q['completed'] == true).length}/${_quests.length}',
                        ),
                        const SizedBox(height: 12),
                        if (_quests.isEmpty)
                          const _EmptyHint(
                            text: 'Chưa có nhiệm vụ. Kéo xuống để làm mới.',
                          )
                        else
                          ..._quests.map(_buildQuestCard),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildQuestCard(Map<String, dynamic> q) {
    final completed = q['completed'] == true;
    final progress = (q['progress'] as num?)?.toDouble() ?? 0;
    final target = (q['target'] as num?)?.toDouble() ?? 1;
    final pct = (progress / target).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: completed ? RelaxColors.mint.withValues(alpha: 0.10) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: completed ? RelaxColors.mint : RelaxColors.lilac,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: completed
                  ? RelaxColors.mint.withValues(alpha: 0.2)
                  : RelaxColors.violet.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              completed ? Icons.check_circle : _iconForCategory(q['category']),
              color: completed ? RelaxColors.mint : RelaxColors.violet,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (q['title'] as String?) ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: completed ? RelaxColors.mint : RelaxColors.ink,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (q['description'] as String?) ?? '',
                  style: const TextStyle(color: RelaxColors.slate, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: RelaxColors.lilac,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completed ? RelaxColors.mint : RelaxColors.violet,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${progress.toInt()} / ${target.toInt()}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: RelaxColors.slate,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(dynamic c) {
    switch (c) {
      case 'journal':
        return Icons.book_outlined;
      case 'mood':
        return Icons.favorite_outline;
      case 'breathing':
        return Icons.air;
      case 'sound':
        return Icons.music_note_outlined;
      case 'companion':
        return Icons.pets_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.onSettings,
    this.avatarUrl,
  });

  final String name;
  final String? avatarUrl;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greet = hour < 11
        ? 'Chào buổi sáng'
        : hour < 17
            ? 'Chào buổi trưa'
            : hour < 21
                ? 'Chào buổi tối'
                : 'Khuya rồi nè';
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: RelaxColors.lilac,
          foregroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: RelaxColors.violet,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greet,
                style: const TextStyle(
                  color: RelaxColors.slate,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  color: RelaxColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
          color: RelaxColors.ink,
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({this.quote});
  final Map<String, dynamic>? quote;

  @override
  Widget build(BuildContext context) {
    final content = (quote?['content'] as String?) ??
        'Hôm nay không cần phải hoàn hảo. Bạn đang ở đây là đủ rồi.';
    final author = quote?['author'] as String?;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RelaxColors.violet, RelaxColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RelaxColors.violet.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'LỜI NHẮN HÔM NAY',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '“$content”',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          if (author != null) ...[
            const SizedBox(height: 12),
            Text(
              '— $author',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.trailing});
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: RelaxColors.ink,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: RelaxColors.violet.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            trailing,
            style: const TextStyle(
              color: RelaxColors.violet,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({this.height = 100});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: RelaxColors.mist,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RelaxColors.lilac,
          style: BorderStyle.solid,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: RelaxColors.slate),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RelaxColors.coral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RelaxColors.coral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Không tải được dữ liệu',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: RelaxColors.coral,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(color: RelaxColors.coral, fontSize: 12),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
