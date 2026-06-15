import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';

class MoodForecastScreen extends StatefulWidget {
  const MoodForecastScreen({super.key});

  @override
  State<MoodForecastScreen> createState() => _MoodForecastScreenState();
}

class _MoodForecastScreenState extends State<MoodForecastScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _forecast = [];
  List<Map<String, dynamic>> _patterns = [];
  Map<String, dynamic>? _trend;
  List<Map<String, dynamic>> _triggers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await RelaxApi.instance.get('/mood-forecast/me/predictions?days=7');
      final data = res.data as Map<String, dynamic>;
      setState(() {
        _forecast = (data['forecast'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _patterns = (data['patterns'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _trend = data['recentTrend'] as Map<String, dynamic>?;
        _triggers = (data['topTriggers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  static const _dayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          context.isDark ? const Color(0xFF0d1117) : RelaxColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Dự báo cảm xúc'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: RelaxColors.violet,
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    _buildTrendCard(context),
                    const SizedBox(height: 16),
                    _buildForecastChart(context),
                    const SizedBox(height: 16),
                    if (_triggers.isNotEmpty) ...[
                      _buildTriggerWarnings(context),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      context.t('Chi tiết 7 ngày tới'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.appText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_forecast.isEmpty)
                      _buildEmptyState(context)
                    else
                      ..._forecast.map((f) => _buildDayCard(context, f)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTrendCard(BuildContext context) {
    final direction = _trend?['direction'] ?? 'stable';
    final magnitude = (_trend?['magnitude'] ?? 0).toDouble();

    Color gradStart, gradEnd;
    IconData icon;
    String label;

    if (direction == 'improving') {
      gradStart = const Color(0xFF10B981);
      gradEnd = const Color(0xFF059669);
      icon = Icons.trending_up;
      label = 'Xu hướng tích cực (+${magnitude.toStringAsFixed(1)})';
    } else if (direction == 'declining') {
      gradStart = const Color(0xFFEF4444);
      gradEnd = const Color(0xFFDC2626);
      icon = Icons.trending_down;
      label = 'Xu hướng giảm (-${magnitude.toStringAsFixed(1)})';
    } else {
      gradStart = const Color(0xFF6366F1);
      gradEnd = const Color(0xFF4F46E5);
      icon = Icons.trending_flat;
      label = 'Xu hướng ổn định';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradStart, gradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('Xu hướng gần đây'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.t(label),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastChart(BuildContext context) {
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
          Text(
            context.t('Biểu đồ dự báo'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _forecast.map((f) {
                final score = (f['predictedScore'] ?? 50).toDouble();
                final risk = f['riskLevel'] as String? ?? 'LOW';
                final dow = f['dayOfWeek'] as int? ?? 0;

                final barColor = risk == 'HIGH'
                    ? const Color(0xFFEF4444)
                    : risk == 'MEDIUM'
                        ? const Color(0xFFF59E0B)
                        : RelaxColors.mint;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${score.round()}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: barColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: score / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dayLabels[dow],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerWarnings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              Text(
                context.t('Yếu tố nguy cơ'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._triggers.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${t['trigger']} — ${t['negativeRate']}% tiêu cực (${t['count']} lần)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF78350F),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, Map<String, dynamic> day) {
    final date = day['date'] as String? ?? '';
    final mood = day['predictedMood'] as String? ?? '';
    final score = day['predictedScore'] ?? 0;
    final risk = day['riskLevel'] as String? ?? 'LOW';
    final confidence = day['confidence'] ?? 0;
    final suggestion = day['suggestion'] as String? ?? '';

    final riskColor = risk == 'HIGH'
        ? const Color(0xFFEF4444)
        : risk == 'MEDIUM'
            ? const Color(0xFFF59E0B)
            : RelaxColors.mint;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_moodEmoji(mood), style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        color: context.appText,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            risk,
                            style: TextStyle(
                              color: riskColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Score: $score',
                          style: TextStyle(
                            color: context.mutedText,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${context.t('Tin cậy')}: $confidence%',
                          style: TextStyle(
                            color: context.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (suggestion.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              suggestion,
              style: TextStyle(
                color: context.appText.withValues(alpha: 0.7),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text('🔮', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(context.t('Chưa đủ dữ liệu dự báo'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.appText,
              )),
          const SizedBox(height: 6),
          Text(
            context.t('Check-in thường xuyên để có dự báo chính xác hơn'),
            style: TextStyle(color: context.mutedText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'HAPPY': return '😊';
      case 'CALM': return '😌';
      case 'NEUTRAL': return '😐';
      case 'TIRED': return '🥱';
      case 'ANXIOUS': return '😰';
      case 'STRESSED': return '😫';
      default: return '😐';
    }
  }
}
