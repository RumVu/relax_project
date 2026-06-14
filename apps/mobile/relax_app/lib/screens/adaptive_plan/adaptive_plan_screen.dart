import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';

class AdaptivePlanScreen extends StatefulWidget {
  const AdaptivePlanScreen({super.key});

  @override
  State<AdaptivePlanScreen> createState() => _AdaptivePlanScreenState();
}

class _AdaptivePlanScreenState extends State<AdaptivePlanScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _plan;
  List<String> _insights = [];

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
    try {
      final resPlan = await RelaxApi.instance.get('/adaptive-plan');
      _plan = resPlan.data is Map
          ? Map<String, dynamic>.from(resPlan.data as Map)
          : null;

      final resInsights = await RelaxApi.instance.get('/adaptive-plan/insights');
      final insightsData = resInsights.data;
      _insights = (insightsData is List)
          ? insightsData.map((e) => e.toString()).toList()
          : [];
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
          context.t('Ke hoach thich ung'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: RelaxColors.violet))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: RelaxColors.coral, size: 48),
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: TextStyle(color: context.mutedText)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _load,
                          child: Text(context.t('Thu lai')),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: RelaxColors.violet,
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        // Insights section
                        if (_insights.isNotEmpty) ...[
                          _SectionHeader(
                            icon: Icons.lightbulb_outline,
                            title: context.t('Phat hien'),
                            color: RelaxColors.sun,
                          ),
                          const SizedBox(height: 8),
                          ..._insights.map((insight) => _InsightCard(
                                text: insight,
                              )),
                          const SizedBox(height: 24),
                        ],

                        // Timing suggestions
                        if (_timingSuggestions.isNotEmpty) ...[
                          _SectionHeader(
                            icon: Icons.schedule_outlined,
                            title: context.t('Goi y theo thoi gian'),
                            color: RelaxColors.violet,
                          ),
                          const SizedBox(height: 8),
                          ..._timingSuggestions.map(
                            (s) => _SuggestionCard(
                              title: s['suggestion'] as String? ?? '',
                              reason: s['reason'] as String? ?? '',
                              period: s['period'] as String? ?? '',
                              icon: Icons.schedule,
                              color: RelaxColors.violet,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Activity priorities
                        if (_activityPriorities.isNotEmpty) ...[
                          _SectionHeader(
                            icon: Icons.star_outline,
                            title: context.t('Hoat dong hieu qua nhat'),
                            color: RelaxColors.mint,
                          ),
                          const SizedBox(height: 8),
                          ..._activityPriorities.map(
                            (a) => _SuggestionCard(
                              title:
                                  '${a['label'] ?? a['activityType']}',
                              reason: a['reason'] as String? ?? '',
                              period:
                                  '${a['avgRelief'] ?? 0}% | ${a['sessionCount'] ?? 0} ${context.t('lan')}',
                              icon: _activityIcon(
                                  a['activityType'] as String? ?? ''),
                              color: RelaxColors.mint,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Breathing vs Music
                        if (_plan?['breathingVsMusic'] != null) ...[
                          _SectionHeader(
                            icon: Icons.compare_arrows,
                            title: context.t('Hit tho vs Nghe nhac'),
                            color: const Color(0xFF0EA5E9),
                          ),
                          const SizedBox(height: 8),
                          _SuggestionCard(
                            title: (_plan!['breathingVsMusic']
                                    as Map)['recommendation'] as String? ??
                                '',
                            reason: (_plan!['breathingVsMusic']
                                    as Map)['reason'] as String? ??
                                '',
                            period: '',
                            icon: Icons.compare_arrows,
                            color: const Color(0xFF0EA5E9),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Notification adjustments
                        if (_notificationAdjustments.isNotEmpty) ...[
                          _SectionHeader(
                            icon: Icons.notifications_outlined,
                            title: context.t('Dieu chinh thong bao'),
                            color: RelaxColors.coral,
                          ),
                          const SizedBox(height: 8),
                          ..._notificationAdjustments.map(
                            (n) => _SuggestionCard(
                              title: n['suggestion'] as String? ?? '',
                              reason: n['reason'] as String? ?? '',
                              period: n['period'] as String? ?? '',
                              icon: Icons.notifications_active_outlined,
                              color: RelaxColors.coral,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }

  List<Map<String, dynamic>> get _timingSuggestions {
    final raw = _plan?['timingSuggestions'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> get _activityPriorities {
    final raw = _plan?['activityPriorities'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  List<Map<String, dynamic>> get _notificationAdjustments {
    final raw = _plan?['notificationAdjustments'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  IconData _activityIcon(String type) {
    switch (type) {
      case 'BREATHING':
        return Icons.air;
      case 'MEDITATION':
        return Icons.self_improvement;
      case 'MUSIC':
        return Icons.music_note;
      case 'JOURNAL':
        return Icons.edit_note;
      case 'PODCAST':
        return Icons.podcasts;
      default:
        return Icons.explore;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: context.appText,
          ),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final String reason;
  final String period;
  final IconData icon;
  final Color color;

  const _SuggestionCard({
    required this.title,
    required this.reason,
    required this.period,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: context.appText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.mutedText,
                  ),
                ),
                if (period.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String text;

  const _InsightCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RelaxColors.sun.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: RelaxColors.sun.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: context.appText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
