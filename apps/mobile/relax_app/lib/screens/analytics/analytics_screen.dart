import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/tour_controller.dart';
import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/mood_line_chart/mood_line_chart.dart';
import '../../widgets/premium_blur.dart';
import '../../widgets/cat_mascot.dart';
import '../../widgets/soft_toast.dart';
import 'models/mood_labels.dart';
import 'widgets/activity_effectiveness.dart';
import 'widgets/mood_distribution.dart';
import 'widgets/stat_tile.dart';

/// Màn phân tích cảm xúc: biểu đồ 7 ngày, phân bố theo loại cảm xúc, và vài
/// chỉ số tổng quan — tính từ check-in cảm xúc.
class AnalyticsScreen extends StatefulWidget {
  /// [embedded] = true → screen này nằm trong AppShell IndexedStack (tab
  /// Insights), ẩn nút back vì đã có bottom nav.
  const AnalyticsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _loading = true;
  List<double?> _daily = List.filled(7, null);
  Map<String, int> _dist = {};
  int _total = 0;
  String _topMood = '—';
  int _activeDays = 0;

  // Activity effectiveness.
  List<Map<String, dynamic>> _favoriteActivities = [];
  int _averageRelief = 0;
  Map<String, dynamic>? _forecast;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await RelaxApi.instance
          .get('/mood-checkins/me', query: {'limit': 150});
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sums = List<double>.filled(7, 0);
      final counts = List<int>.filled(7, 0);
      final dist = <String, int>{};
      final days = <String>{};
      int total = 0;
      if (items is List) {
        for (final it in items.whereType<Map>()) {
          total++;
          final mood = it['mood'] as String?;
          if (mood != null) dist[mood] = (dist[mood] ?? 0) + 1;
          final createdRaw = it['createdAt'] as String?;
          final intensity = (it['intensity'] as num?)?.toDouble() ?? 3;
          if (createdRaw == null) continue;
          final created = DateTime.tryParse(createdRaw);
          if (created == null) continue;
          final day = DateTime(created.year, created.month, created.day);
          days.add('${day.year}-${day.month}-${day.day}');
          final diff = today.difference(day).inDays;
          if (diff >= 0 && diff < 7) {
            final idx = 6 - diff;
            sums[idx] += intensity;
            counts[idx] += 1;
          }
        }
      }
      final daily = List<double?>.generate(
          7, (i) => counts[i] == 0 ? null : ((sums[i] / counts[i]) - 1) / 4);
      String top = '—';
      int topN = 0;
      dist.forEach((k, v) {
        if (v > topN) {
          topN = v;
          top = kMoodLabels[k] ?? k;
        }
      });

      var favActivities = <Map<String, dynamic>>[];
      var avgRelief = 0;
      try {
        final statsRes =
            await RelaxApi.instance.get('/relax-sessions/me/stats');
        final statsData = statsRes.data;
        if (statsData is Map) {
          final favs = statsData['favoriteActivities'];
          if (favs is List) {
            favActivities =
                favs.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
          final relief = statsData['relief'];
          if (relief is Map) {
            avgRelief =
                (relief['averageStressRelief'] as num?)?.toInt() ?? 0;
          }
        }
      } catch (_) {}

      try {
        final forecastRes = await RelaxApi.instance.get('/analytics/me/mood-forecast');
        if (forecastRes.statusCode == 200) {
          _forecast = Map<String, dynamic>.from(forecastRes.data);
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _daily = daily;
          _dist = dist;
          _total = total;
          _topMood = top;
          _activeDays = days.length;
          _favoriteActivities = favActivities;
          _averageRelief = avgRelief;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home?tab=0');
            }
          },
        ),
        title: Text(
          context.t('Phân tích cảm xúc'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: RelaxColors.violet))
            : RefreshIndicator(
                color: RelaxColors.violet,
                onRefresh: _load,
                child: ListView(
                  addRepaintBoundaries: false,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    Row(
                      key: widget.embedded ? TourController.instance.targetKeys[6] : null,
                      children: [
                        StatTile(
                            value: '$_total',
                            label: context.t('Lượt ghi'),
                            icon: Icons.edit_note),
                        const SizedBox(width: 12),
                        StatTile(
                            value: '$_activeDays',
                            label: context.t('Ngày hoạt động'),
                            icon: Icons.calendar_today),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _card(
                      context,
                      title: context.t('Cảm xúc nổi bật'),
                      child: Text(
                        context.t(_topMood),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: RelaxColors.violet,
                        ),
                      ),
                    ),
                    PremiumBlur(
                      child: Column(
                        children: [
                    if (_forecast != null) ...[
                      const SizedBox(height: 16),
                      _card(
                        context,
                        title: context.t('Dự báo tâm trạng 🔮'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t(_forecast!['message'] ?? ''),
                              style: TextStyle(color: context.appText, fontSize: 13, height: 1.4),
                            ),
                            if (_forecast!['suggestedTime'] != null) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showSoftToast(
                                    context,
                                    message: '${context.t("Đã lên lịch routine vào lúc")} ${_forecast!['suggestedTime']} ⏰',
                                    tone: SoftToastTone.success,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: RelaxColors.violet.withValues(alpha: 0.1),
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: RelaxColors.violet),
                                  ),
                                ),
                                icon: const Icon(Icons.alarm, color: RelaxColors.violet, size: 16),
                                label: Text(
                                  '${context.t("Đặt routine lúc")} ${_forecast!['suggestedTime']}',
                                  style: const TextStyle(color: RelaxColors.violet, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      key: widget.embedded ? TourController.instance.targetKeys[7] : null,
                      child: _card(
                        context,
                        title: context.t('Biểu đồ cảm xúc 7 ngày qua'),
                        child: _total == 0
                            ? _empty(context)
                            : MoodLineChart(values: _daily),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _card(
                      context,
                      title: context.t('Phân bố cảm xúc'),
                      child: _dist.isEmpty
                          ? _empty(context)
                          : MoodDistribution(
                              distribution: _dist, total: _total),
                    ),
                    const SizedBox(height: 16),
                    _card(
                      context,
                      title: context.t('Hiệu quả hoạt động'),
                      child: ActivityEffectiveness(
                        activities: _favoriteActivities,
                        averageRelief: _averageRelief,
                      ),
                    ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => context.push('/mood-calendar'),
                        icon: const Icon(Icons.calendar_today, color: Colors.white),
                        label: Text(
                          context.t('Xem lịch cảm xúc 30 ngày qua ➜'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RelaxColors.violet,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => context.push('/mood'),
                        icon: const Icon(Icons.edit_note, color: Colors.white),
                        label: Text(
                          context.t('Ghi chép cảm xúc chi tiết ➜'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RelaxColors.plum,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => context.push('/mood-capsule'),
                        icon: const Icon(Icons.archive_outlined, color: Colors.white),
                        label: Text(
                          context.t('Hộp ký ức cảm xúc (Capsule) ➜'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(child: CatMascot(size: 60, variant: CatVariant.sleep, glow: false, opacity: 0.7)),
                  ],
                ),
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
          context.t('Chưa có dữ liệu. Ghi cảm xúc vài lần nhé!'),
          style: TextStyle(color: context.mutedText, fontSize: 12),
        ),
      );
}
