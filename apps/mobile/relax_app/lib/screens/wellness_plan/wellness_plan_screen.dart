import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';

/// Personal Wellness Plan — 7-day suggestion dựa trên mood history.
class WellnessPlanScreen extends StatefulWidget {
  const WellnessPlanScreen({super.key});

  @override
  State<WellnessPlanScreen> createState() => _WellnessPlanScreenState();
}

class _WellnessPlanScreenState extends State<WellnessPlanScreen> {
  bool _loading = true;
  List<_DayPlan> _plan = [];
  String _insight = '';

  @override
  void initState() {
    super.initState();
    _generatePlan();
  }

  Future<void> _generatePlan() async {
    setState(() => _loading = true);
    try {
      // Fetch mood analytics to determine patterns.
      final res = await RelaxApi.instance
          .get('/mood-checkins/me/analytics', query: {'period': 'WEEK'});
      final data = res.data;
      String topMood = 'NEUTRAL';
      if (data is Map) {
        final summary = data['summary'] as Map?;
        topMood = (summary?['topMood'] as String?) ?? 'NEUTRAL';
        final avgScore = (summary?['averageMoodScore'] as num?)?.toDouble();
        if (avgScore != null) {
          if (avgScore >= 3.5) {
            _insight = 'Tuần qua bạn khá ổn! Duy trì nhịp sinh hoạt lành mạnh nhé.';
          } else if (avgScore >= 2.5) {
            _insight = 'Cảm xúc tuần qua hơi lên xuống. Thử thêm hít thở và nhật ký.';
          } else {
            _insight = 'Tuần qua có vẻ khó khăn. Ưu tiên nghỉ ngơi và kết nối người thân.';
          }
        }
      }

      _plan = _buildPlan(topMood);
    } catch (_) {
      _plan = _buildPlan('NEUTRAL');
      _insight = 'Bắt đầu tuần mới với những bước nhỏ nhé!';
    }
    if (mounted) setState(() => _loading = false);
  }

  List<_DayPlan> _buildPlan(String topMood) {
    final now = DateTime.now();
    final days = <_DayPlan>[];

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final dayName = _dayNames[date.weekday - 1];
      days.add(_DayPlan(
        day: dayName,
        date: '${date.day}/${date.month}',
        activities: _activitiesForDay(date.weekday, topMood),
      ));
    }
    return days;
  }

  static const _dayNames = [
    'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm',
    'Thứ sáu', 'Thứ bảy', 'Chủ nhật',
  ];

  List<_Activity> _activitiesForDay(int weekday, String topMood) {
    final activities = <_Activity>[
      _Activity('🌤️', 'Ghi cảm xúc sáng', '/mood', '2 phút'),
    ];

    if (weekday <= 5) {
      // Weekday.
      activities.add(_Activity('🌬️', 'Hít thở giữa ngày', '/breathing', '3 phút'));
      if (topMood == 'STRESSED' || topMood == 'ANXIOUS') {
        activities.add(_Activity('🧘', 'Thiền 5 phút', '/meditation', '5 phút'));
      } else {
        activities.add(_Activity('🎵', 'Nghe nhạc thư giãn', '/sounds', '10 phút'));
      }
    } else {
      // Weekend.
      activities.add(_Activity('✍️', 'Viết nhật ký', '/journal', '10 phút'));
      activities.add(_Activity('🧘', 'Thiền sâu', '/meditation', '15 phút'));
    }

    activities.add(_Activity('🌙', 'Ghi cảm xúc tối', '/mood', '2 phút'));
    return activities;
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
          context.t('Kế hoạch tuần'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: RelaxColors.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (_insight.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: RelaxColors.violet.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Text('🔮', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.t(_insight),
                            style: TextStyle(
                              color: context.appText,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/routine-builder'),
                          icon: const Icon(Icons.tune, size: 18),
                          label: Text(context.t('Thiết lập Routine'), maxLines: 1, overflow: TextOverflow.ellipsis),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/habit-stacking'),
                          icon: const Icon(Icons.layers_outlined, size: 18),
                          label: Text(context.t('Habit Stacking'), maxLines: 1, overflow: TextOverflow.ellipsis),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ..._plan.map((day) => _DayCard(day: day)),
              ],
            ),
    );
  }
}

class _DayPlan {
  _DayPlan({required this.day, required this.date, required this.activities});
  final String day;
  final String date;
  final List<_Activity> activities;
}

class _Activity {
  _Activity(this.emoji, this.label, this.route, this.duration);
  final String emoji;
  final String label;
  final String route;
  final String duration;
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});
  final _DayPlan day;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(
                context.t(day.day),
                style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                day.date,
                style: TextStyle(color: context.mutedText, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...day.activities.map((a) => _ActivityRow(activity: a)),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});
  final _Activity activity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(activity.route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(activity.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.t(activity.label),
                style: TextStyle(
                  color: context.appText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: context.fieldBorder,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                activity.duration,
                style: TextStyle(
                  color: context.mutedText,
                  fontSize: 10,
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
