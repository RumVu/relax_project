import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_client.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

class MoodForecastWidget extends StatefulWidget {
  const MoodForecastWidget({super.key});

  @override
  State<MoodForecastWidget> createState() => _MoodForecastWidgetState();
}

class _MoodForecastWidgetState extends State<MoodForecastWidget> {
  List<Map<String, dynamic>> _forecast = [];
  String _trendDirection = 'stable';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await RelaxApi.instance.get('/mood-forecast/me/predictions?days=3');
      final data = res.data as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _forecast = (data['forecast'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          _trendDirection = (data['recentTrend'] as Map?)?['direction'] ?? 'stable';
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  static const _dayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => context.push('/mood-forecast'),
          child: Row(
            children: [
              const Icon(Icons.auto_graph, color: Color(0xFF6366F1), size: 18),
              const SizedBox(width: 6),
              Text(
                context.t('Dự báo cảm xúc'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: context.appText,
                ),
              ),
              const Spacer(),
              Text(
                context.t('Xem chi tiết ›'),
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (_forecast.isEmpty)
          _buildEmpty(context)
        else
          GestureDetector(
            onTap: () => context.push('/mood-forecast'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.fieldBorder),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _trendDirection == 'improving'
                            ? Icons.trending_up
                            : _trendDirection == 'declining'
                                ? Icons.trending_down
                                : Icons.trending_flat,
                        color: _trendDirection == 'improving'
                            ? RelaxColors.mint
                            : _trendDirection == 'declining'
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF6366F1),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _trendDirection == 'improving'
                            ? context.t('Đang tích cực')
                            : _trendDirection == 'declining'
                                ? context.t('Cần chú ý')
                                : context.t('Ổn định'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: context.appText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _forecast.map((f) {
                      final dow = f['dayOfWeek'] as int? ?? 0;
                      final risk = f['riskLevel'] as String? ?? 'LOW';
                      final score = f['predictedScore'] ?? 50;

                      final color = risk == 'HIGH'
                          ? const Color(0xFFEF4444)
                          : risk == 'MEDIUM'
                              ? const Color(0xFFF59E0B)
                              : RelaxColors.mint;

                      return Expanded(
                        child: Column(
                          children: [
                            Text(
                              _dayLabels[dow],
                              style: TextStyle(
                                fontSize: 11,
                                color: context.mutedText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.15),
                              ),
                              child: Center(
                                child: Text(
                                  '$score',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                risk,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/mood-forecast'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.fieldBorder),
        ),
        child: Row(
          children: [
            const Text('🔮', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.t('Check-in thường xuyên để có dự báo cảm xúc'),
                style: TextStyle(
                  color: context.mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
