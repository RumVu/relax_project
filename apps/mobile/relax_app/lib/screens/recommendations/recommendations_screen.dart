import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/content_rating_sheet.dart';

/// Màn gợi ý nội dung hằng ngày — fetch từ /recommendations/me/today,
/// hiển thị 3 card với icon, lý do, và link điều hướng.
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await RelaxApi.instance.get('/recommendations/me/today');
      final data = res.data;
      final list = data is List
          ? data
          : (data is Map ? (data['items'] ?? data['recommendations'] ?? []) : []);
      _items = (list as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Gợi ý cho bạn hôm nay'),
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: context.appText),
            onPressed: _loading ? null : _fetch,
            tooltip: context.t('Làm mới'),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: RelaxColors.violet),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: context.mutedText),
              const SizedBox(height: 12),
              Text(
                context.t('Không tải được gợi ý'),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.appText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: context.mutedText),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _fetch,
                icon: const Icon(Icons.refresh),
                label: Text(context.t('Thử lại')),
              ),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            context.t('Chưa có gợi ý nào cho hôm nay.'),
            style: TextStyle(color: context.mutedText),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        ..._items.map((item) => _RecommendationCard(item: item)),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(
            onPressed: _showRatingFlow,
            icon: const Icon(Icons.star_border_rounded),
            label: Text(context.t('Đánh giá nội dung')),
          ),
        ),
      ],
    );
  }

  void _showRatingFlow() {
    // Pick the first item as default content to rate; user can change later.
    final first = _items.isNotEmpty ? _items.first : null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ContentRatingSheet(
        contentType: (first?['type'] as String?) ?? 'BREATHING',
        contentId: (first?['contentId'] as String?) ?? '',
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.item});
  final Map<String, dynamic> item;

  static const _typeConfig = <String, _TypeStyle>{
    'BREATHING': _TypeStyle(Icons.air_rounded, RelaxColors.mint, '/breathing'),
    'MEDITATION': _TypeStyle(Icons.self_improvement_rounded, RelaxColors.violet, '/meditation'),
    'JOURNAL': _TypeStyle(Icons.edit_note_rounded, RelaxColors.plum, '/journal'),
    'MUSIC': _TypeStyle(Icons.music_note_rounded, Color(0xFF5B8DEF), '/sounds'),
  };

  @override
  Widget build(BuildContext context) {
    final type = (item['type'] as String?) ?? '';
    final cfg = _typeConfig[type] ?? _typeConfig['BREATHING']!;
    final title = (item['title'] as String?) ?? type;
    final reason = (item['reason'] as String?) ?? '';

    return GestureDetector(
      onTap: () => context.push(cfg.route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(color: cfg.color, width: 4),
            top: BorderSide(color: context.fieldBorder),
            right: BorderSide(color: context.fieldBorder),
            bottom: BorderSide(color: context.fieldBorder),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: cfg.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(cfg.icon, color: cfg.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t(title),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: context.appText,
                      ),
                    ),
                    if (reason.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        context.t(reason),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: context.mutedText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeStyle {
  const _TypeStyle(this.icon, this.color, this.route);
  final IconData icon;
  final Color color;
  final String route;
}
