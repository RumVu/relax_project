import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/api_client.dart';
import '../../../core/locale_controller.dart';
import '../../../widgets/mood_line_chart/mood_line_chart.dart';
import '../../../widgets/premium_blur.dart';

/// Thống kê tình trạng — biểu đồ cảm xúc 7 ngày + ước lượng giảm stress,
/// tính từ check-in cảm xúc gần nhất.
class StatsCard extends StatefulWidget {
  const StatsCard({super.key});

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  bool _loading = true;
  List<double?> _daily = List.filled(7, null);
  int _stressDelta = 0; // % giảm stress (dương = giảm)
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res =
          await RelaxApi.instance.get('/mood-checkins/me', query: {'limit': 100});
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // 7 ngày gần nhất: index 0 = 6 ngày trước … 6 = hôm nay.
      final sums = List<double>.filled(7, 0);
      final counts = List<int>.filled(7, 0);
      int stressEarly = 0, stressLate = 0, earlyN = 0, lateN = 0;
      if (items is List) {
        for (final it in items.whereType<Map>()) {
          _total++;
          final createdRaw = it['createdAt'] as String?;
          final intensity = (it['intensity'] as num?)?.toDouble() ?? 3;
          final mood = it['mood'] as String?;
          if (createdRaw == null) continue;
          final created = DateTime.tryParse(createdRaw);
          if (created == null) continue;
          final day = DateTime(created.year, created.month, created.day);
          final diff = today.difference(day).inDays;
          if (diff >= 0 && diff < 7) {
            final idx = 6 - diff;
            sums[idx] += intensity;
            counts[idx] += 1;
          }
          // Stress đầu kỳ (3-7 ngày trước) vs cuối kỳ (0-3 ngày).
          final isStress = mood == 'STRESSED' || mood == 'ANXIOUS';
          if (diff >= 3 && diff < 7) {
            earlyN++;
            if (isStress) stressEarly++;
          } else if (diff >= 0 && diff < 3) {
            lateN++;
            if (isStress) stressLate++;
          }
        }
      }
      final daily = List<double?>.generate(7, (i) {
        if (counts[i] == 0) return null;
        // intensity 1..5 → 0..1.
        return ((sums[i] / counts[i]) - 1) / 4;
      });
      final earlyRate = earlyN == 0 ? 0.0 : stressEarly / earlyN;
      final lateRate = lateN == 0 ? 0.0 : stressLate / lateN;
      final delta = ((earlyRate - lateRate) * 100).round();
      if (mounted) {
        setState(() {
          _daily = daily;
          _stressDelta = delta;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBlur(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t('Xem lại hành trình cảm xúc của bạn'),
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.t('Theo tuần'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.appText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const SizedBox(
              height: 130,
              child: Center(
                child: CircularProgressIndicator(color: RelaxColors.violet),
              ),
            )
          else if (_total == 0)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  context.t('Chưa có dữ liệu cảm xúc.\nGhi vài lần để xem biểu đồ nhé!'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
              ),
            )
          else ...[
            MoodLineChart(values: _daily),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _stressDelta >= 0
                        ? Icons.trending_down
                        : Icons.trending_up,
                    color:
                        _stressDelta >= 0 ? RelaxColors.mint : RelaxColors.coral,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _stressDelta >= 0
                          ? context.t('Giảm stress {percent}% so với đầu tuần', {'percent': '$_stressDelta'})
                          : context.t('Stress tăng {percent}% — nhớ nghỉ ngơi nhé', {'percent': '${-_stressDelta}'}),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.appText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }
}
