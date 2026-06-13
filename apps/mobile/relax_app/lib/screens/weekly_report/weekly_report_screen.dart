import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';

/// Weekly wellness report — summary tuần: mood trend, activities, streak.
/// Data từ /mood-checkins/me/weekly-stats + /relax-sessions/me/stats.
class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _weeklyStats = [];
  Map<String, dynamic> _sessionStats = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/mood-checkins/me/weekly-stats'),
        RelaxApi.instance.get('/relax-sessions/me/stats',
            query: {'period': 'WEEK'}),
      ]);

      final weeklyData = results[0].data;
      if (weeklyData is List) {
        _weeklyStats = weeklyData
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      final sessionData = results[1].data;
      if (sessionData is Map) {
        _sessionStats = Map<String, dynamic>.from(sessionData);
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          context.t('Báo cáo tuần'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: RelaxColors.violet))
          : RefreshIndicator(
              color: RelaxColors.violet,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  // Session summary.
                  _SummaryCard(stats: _sessionStats),
                  const SizedBox(height: 16),
                  // Weekly mood trend.
                  _card(
                    context,
                    title: context.t('Xu hướng cảm xúc theo tuần'),
                    child: _weeklyStats.isEmpty
                        ? _empty(context)
                        : _WeeklyMoodList(weeks: _weeklyStats),
                  ),
                  const SizedBox(height: 16),
                  // Favorite activities.
                  _card(
                    context,
                    title: context.t('Hoạt động yêu thích'),
                    child: _FavoriteActivities(stats: _sessionStats),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _card(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  TextStyle(fontWeight: FontWeight.w800, color: context.appText)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          context.t('Chưa đủ dữ liệu cho báo cáo tuần.'),
          style: TextStyle(color: context.mutedText, fontSize: 12),
        ),
      );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stats});
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final totalSessions = (stats['totalSessions'] as num?)?.toInt() ?? 0;
    final durationLabel = stats['totalDurationLabel'] as String? ?? '0s';
    final streak = stats['streak'] as Map?;
    final currentStreak = (streak?['current'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6c63ff), Color(0xFF9c27b0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('Tuần này'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _stat(context, '$totalSessions', context.t('phiên')),
              const SizedBox(width: 24),
              _stat(context, durationLabel, context.t('tổng thời gian')),
              const SizedBox(width: 24),
              _stat(context, '$currentStreak', context.t('ngày liên tục')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _WeeklyMoodList extends StatelessWidget {
  const _WeeklyMoodList({required this.weeks});
  final List<Map<String, dynamic>> weeks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: weeks.take(4).map((w) {
        final weekStart = w['weekStart'] as String? ?? '';
        final avgScore = (w['averageMoodScore'] as num?)?.toDouble() ?? 0;
        final total = (w['totalCheckins'] as num?)?.toInt() ?? 0;
        final topMood = w['topMood'] as String? ?? '—';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  weekStart.length >= 10 ? weekStart.substring(5, 10) : weekStart,
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (avgScore / 5).clamp(0.0, 1.0),
                    backgroundColor: context.fieldBorder,
                    color: RelaxColors.violet,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${avgScore.toStringAsFixed(1)} · $total · $topMood',
                style: TextStyle(
                  color: context.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _FavoriteActivities extends StatelessWidget {
  const _FavoriteActivities({required this.stats});
  final Map<String, dynamic> stats;

  static const _emoji = {
    'BREATHING': '🌬️',
    'MEDITATION': '🧘',
    'MUSIC': '🎵',
    'PODCAST': '🎙️',
    'JOURNAL': '✍️',
    'MYSTERY': '🎲',
  };

  @override
  Widget build(BuildContext context) {
    final favs = stats['favoriteActivities'] as List?;
    if (favs == null || favs.isEmpty) {
      return Text(
        context.t('Chưa có hoạt động nào tuần này.'),
        style: TextStyle(color: context.mutedText, fontSize: 12),
      );
    }

    return Column(
      children: favs.take(5).map((f) {
        final m = f as Map;
        final type = m['activityType'] as String? ?? '';
        final count = (m['count'] as num?)?.toInt() ?? 0;
        final emoji = _emoji[type] ?? '🌿';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  type,
                  style: TextStyle(
                    color: context.appText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '$count ${context.t('lần')}',
                style: TextStyle(
                  color: context.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
