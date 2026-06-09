import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../core/locale_controller.dart';
import '../core/theme.dart';
import '../widgets/mood_line_chart.dart';

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

  static const _moodLabels = {
    'HAPPY': 'Vui vẻ',
    'SAD': 'Buồn',
    'STRESSED': 'Căng thẳng',
    'TIRED': 'Mệt mỏi',
    'ANXIOUS': 'Lo lắng',
    'NEUTRAL': 'Bình thường',
    'CALM': 'Bình yên',
    'EXCITED': 'Hào hứng',
    'LONELY': 'Cô đơn',
    'GRATEFUL': 'Biết ơn',
  };

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
      if (items is List) {
        for (final it in items.whereType<Map>()) {
          _total++;
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
          top = _moodLabels[k] ?? k;
        }
      });
      if (mounted) {
        setState(() {
          _daily = daily;
          _dist = dist;
          _topMood = top;
          _activeDays = days.length;
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
        leading: widget.embedded
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back, color: context.appText),
                onPressed: () => context.pop(),
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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    Row(
                      children: [
                        _statTile(context, '$_total', context.t('Lượt ghi'), Icons.edit_note),
                        const SizedBox(width: 12),
                        _statTile(context, '$_activeDays', context.t('Ngày hoạt động'),
                            Icons.calendar_today),
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
                    const SizedBox(height: 16),
                    _card(
                      context,
                      title: context.t('Biểu đồ cảm xúc 7 ngày qua'),
                      child: _total == 0
                          ? _empty(context)
                          : MoodLineChart(values: _daily),
                    ),
                    const SizedBox(height: 16),
                    _card(
                      context,
                      title: context.t('Phân bố cảm xúc'),
                      child: _dist.isEmpty
                          ? _empty(context)
                          : Column(
                              children: (_dist.entries.toList()
                                    ..sort((a, b) => b.value.compareTo(a.value)))
                                  .map((e) {
                                final pct = _total == 0 ? 0.0 : e.value / _total;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          context.t(_moodLabels[e.key] ?? e.key),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: context.appText),
                                        ),
                                      ),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: pct,
                                            minHeight: 8,
                                            backgroundColor: context.surfaceAlt,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(RelaxColors.violet),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 38,
                                        child: Text(
                                          '${(pct * 100).round()}%',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: context.appText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 24),
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
                  ],
                ),
              ),
      ),
    );
  }

  Widget _statTile(
      BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.fieldBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: RelaxColors.violet, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: context.appText,
              ),
            ),
            Text(label,
                style: TextStyle(color: context.mutedText, fontSize: 12)),
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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: context.appText,
            ),
          ),
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
