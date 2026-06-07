import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/services/mood_service.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';

/// Lịch cảm xúc — hiển thị mood mỗi ngày trong tháng dưới dạng grid heatmap.
///
/// Mỗi ô:
///   - Empty: chưa check-in
///   - Có mood: emoji + màu pastel theo dominant mood của ngày đó
/// Tap ô → bottom sheet liệt kê check-ins ngày đó
class CalendarMoodScreen extends StatefulWidget {
  const CalendarMoodScreen({super.key, required this.moodHistory});

  final List<MoodCheckin> moodHistory;

  @override
  State<CalendarMoodScreen> createState() => _CalendarMoodScreenState();
}

class _CalendarMoodScreenState extends State<CalendarMoodScreen> {
  late DateTime _focusMonth;

  static const _moodMeta = <String, _MoodMeta>{
    'HAPPY': _MoodMeta('😊', Color(0xFFFFC96E)),
    'SAD': _MoodMeta('🌧️', Color(0xFF5DB1FF)),
    'STRESSED': _MoodMeta('🌪️', Color(0xFFE85A6A)),
    'TIRED': _MoodMeta('😴', Color(0xFF9C86FF)),
    'NEUTRAL': _MoodMeta('😶', Color(0xFFA8A2CA)),
    'CALM': _MoodMeta('🌿', Color(0xFF48D3A8)),
    'ANXIOUS': _MoodMeta('😰', Color(0xFFFF7A5C)),
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusMonth = DateTime(now.year, now.month);
  }

  /// Map ngày trong tháng → mood dominant.
  Map<int, _DayInfo> get _dayMoods {
    final result = <int, List<String>>{};
    for (final c in widget.moodHistory) {
      if (c.createdAt.year == _focusMonth.year &&
          c.createdAt.month == _focusMonth.month) {
        result.putIfAbsent(c.createdAt.day, () => []).add(c.mood);
      }
    }
    return result.map((day, moods) {
      // Dominant mood = most frequent
      final counts = <String, int>{};
      for (final m in moods) {
        counts[m] = (counts[m] ?? 0) + 1;
      }
      final dominant = counts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      return MapEntry(day, _DayInfo(dominant: dominant, total: moods.length));
    });
  }

  void _prevMonth() {
    setState(() => _focusMonth =
        DateTime(_focusMonth.year, _focusMonth.month - 1));
  }

  void _nextMonth() {
    final next = DateTime(_focusMonth.year, _focusMonth.month + 1);
    final now = DateTime.now();
    if (next.isAfter(DateTime(now.year, now.month))) return;
    setState(() => _focusMonth = next);
  }

  void _showDay(int day) {
    final dt = DateTime(_focusMonth.year, _focusMonth.month, day);
    final entries = widget.moodHistory.where((c) =>
        c.createdAt.year == dt.year &&
        c.createdAt.month == dt.month &&
        c.createdAt.day == day).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              Text(
                entries.isEmpty
                    ? 'Chưa có check-in nào'
                    : '${entries.length} check-in',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: context.relax.muted,
                ),
              ),
              const SizedBox(height: 16),
              if (entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.spa_outlined,
                          size: 36,
                          color: RelaxTheme.lavender.withValues(alpha: .5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Một ngày trống cũng OK ~',
                          style: Theme.of(ctx).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...entries.map((c) {
                  final meta = _moodMeta[c.mood] ??
                      const _MoodMeta('💫', Color(0xFF9C86FF));
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: meta.color.withValues(alpha: .2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              meta.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.mood,
                                style: Theme.of(ctx).textTheme.titleMedium,
                              ),
                              Text(
                                '${c.createdAt.hour.toString().padLeft(2, '0')}:${c.createdAt.minute.toString().padLeft(2, '0')} · Intensity ${c.intensity}',
                                style: Theme.of(ctx).textTheme.bodyMedium
                                    ?.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel =
        '${_monthName(_focusMonth.month)} ${_focusMonth.year}';
    final daysInMonth = DateTime(
      _focusMonth.year,
      _focusMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(_focusMonth.year, _focusMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // T2=1..CN=7→0
    final today = DateTime.now();
    final dayMoods = _dayMoods;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Lịch cảm xúc'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Month nav
          Row(
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    monthLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Weekday labels
          Row(
            children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            color: RelaxTheme.lavender,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grid 6 weeks × 7 days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 42,
            itemBuilder: (_, i) {
              final dayNum = i - firstWeekday + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox.shrink();
              }
              final info = dayMoods[dayNum];
              final isToday = today.year == _focusMonth.year &&
                  today.month == _focusMonth.month &&
                  today.day == dayNum;
              final meta = info != null ? _moodMeta[info.dominant] : null;
              return _DayCell(
                day: dayNum,
                isToday: isToday,
                meta: meta,
                count: info?.total ?? 0,
                onTap: () => _showDay(dayNum),
              );
            },
          ),
          const SizedBox(height: 20),
          // Legend
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.relax.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHÚ THÍCH',
                  style: TextStyle(
                    color: RelaxTheme.lavender,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: _moodMeta.entries.map((e) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: e.value.color.withValues(alpha: .35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              e.value.emoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          e.key,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 10),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          if (widget.moodHistory.isEmpty) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const CatAvatar(size: 80),
                  const SizedBox(height: 10),
                  Text(
                    'Lịch sẽ dần xuất hiện khi bạn check-in ~',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];
    return names[m];
  }
}

class _DayInfo {
  const _DayInfo({required this.dominant, required this.total});
  final String dominant;
  final int total;
}

class _MoodMeta {
  const _MoodMeta(this.emoji, this.color);
  final String emoji;
  final Color color;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.meta,
    required this.count,
    required this.onTap,
  });
  final int day;
  final bool isToday;
  final _MoodMeta? meta;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: meta?.color.withValues(alpha: .25) ?? context.relax.surfaceSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isToday
                  ? RelaxTheme.purple
                  : (meta?.color ?? context.relax.border)
                      .withValues(alpha: meta == null ? 1 : .6),
              width: isToday ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  color: isToday ? RelaxTheme.purple : null,
                  fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (meta != null)
                Text(
                  meta!.emoji,
                  style: const TextStyle(fontSize: 14),
                ),
              if (count > 1)
                Text(
                  '·$count',
                  style: TextStyle(
                    color: context.relax.muted,
                    fontSize: 8,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
