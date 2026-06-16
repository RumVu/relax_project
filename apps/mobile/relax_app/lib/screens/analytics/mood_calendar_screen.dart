import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/premium_blur.dart';

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  bool _loading = true;
  List<dynamic> _calendarData = [];
  Map<String, dynamic>? _selectedDay;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final y = _currentMonth.year;
      final m = _currentMonth.month.toString().padLeft(2, '0');
      final res = await RelaxApi.instance
          .get('/analytics/me/mood-calendar?month=$y-$m');
      if (res.data is List) {
        setState(() {
          _calendarData = res.data as List;
          _loading = false;
          _selectedDay = null;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _prevMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _load();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    if (next.isAfter(DateTime(now.year, now.month + 1))) return;
    setState(() => _currentMonth = next);
    _load();
  }

  Map<String, dynamic> _monthSummary() {
    final moodCounts = <String, int>{};
    int totalDays = 0;
    int journalDays = 0;
    int relaxDays = 0;

    for (final item in _calendarData) {
      final day = item as Map<String, dynamic>;
      final moods = day['moods'] as List<dynamic>? ?? [];
      if (moods.isNotEmpty) {
        totalDays++;
        for (final m in moods) {
          moodCounts[m as String] = (moodCounts[m] ?? 0) + 1;
        }
      }
      if (day['hasJournal'] == true) journalDays++;
      if (day['hasRelaxSession'] == true) relaxDays++;
    }

    String dominant = '';
    int maxCount = 0;
    for (final e in moodCounts.entries) {
      if (e.value > maxCount) {
        maxCount = e.value;
        dominant = e.key;
      }
    }

    return {
      'totalDays': totalDays,
      'journalDays': journalDays,
      'relaxDays': relaxDays,
      'dominant': dominant,
      'moodCounts': moodCounts,
    };
  }

  static const _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  static const _monthNames = [
    '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
    'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
  ];

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'HAPPY': return RelaxColors.mint;
      case 'CALM': return const Color(0xFF10B981);
      case 'TIRED': return const Color(0xFF6B7280);
      case 'SAD': return const Color(0xFF3B82F6);
      case 'ANXIOUS': return RelaxColors.violet;
      case 'STRESSED': return RelaxColors.plum;
      case 'ANGRY': return const Color(0xFFEF4444);
      case 'POOPING': return const Color(0xFF8B4513);
      default: return Colors.transparent;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'HAPPY': return '😊';
      case 'CALM': return '😌';
      case 'TIRED': return '🥱';
      case 'SAD': return '😢';
      case 'ANXIOUS': return '😰';
      case 'STRESSED': return '😫';
      case 'ANGRY': return '😠';
      case 'POOPING': return '💩';
      default: return '😐';
    }
  }

  String _getMoodLabel(String mood) {
    const labels = {
      'HAPPY': 'Vui vẻ',
      'CALM': 'Bình yên',
      'TIRED': 'Mệt mỏi',
      'SAD': 'Buồn bã',
      'ANXIOUS': 'Lo âu',
      'STRESSED': 'Căng thẳng',
      'ANGRY': 'Giận dữ',
      'POOPING': 'Mắc ỉa',
    };
    return labels[mood] ?? mood;
  }

  @override
  Widget build(BuildContext context) {
    final summary = _monthSummary();

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
          context.t('Lịch cảm xúc'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: RelaxColors.violet,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              PremiumBlur(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Month nav
              _buildMonthNav(context),
              const SizedBox(height: 16),

              // Monthly summary
              if (!_loading && _calendarData.isNotEmpty)
                _buildMonthlySummary(context, summary),
              const SizedBox(height: 16),

              // Calendar grid
              if (_loading)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(40),
                  child:
                      CircularProgressIndicator(color: RelaxColors.violet),
                ))
              else if (_calendarData.isEmpty)
                _buildEmptyState(context)
              else
                _buildCalendarGrid(context),

              const SizedBox(height: 16),

              // Mood legend
              if (!_loading && _calendarData.isNotEmpty) _buildLegend(context),

              const SizedBox(height: 16),

              // Day detail
              if (_selectedDay != null) _buildDayDetail(context),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthNav(BuildContext context) {
    final now = DateTime.now();
    final canNext = DateTime(_currentMonth.year, _currentMonth.month + 1)
        .isBefore(DateTime(now.year, now.month + 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _prevMonth,
          icon: Icon(Icons.chevron_left, color: context.appText),
        ),
        Text(
          '${context.t(_monthNames[_currentMonth.month])} ${_currentMonth.year}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: context.appText,
          ),
        ),
        IconButton(
          onPressed: canNext ? _nextMonth : null,
          icon: Icon(Icons.chevron_right,
              color: canNext ? context.appText : context.mutedText),
        ),
      ],
    );
  }

  Widget _buildMonthlySummary(
      BuildContext context, Map<String, dynamic> summary) {
    final dominant = summary['dominant'] as String;
    final totalDays = summary['totalDays'] as int;
    final journalDays = summary['journalDays'] as int;
    final relaxDays = summary['relaxDays'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dominant.isNotEmpty
              ? [
                  _getMoodColor(dominant).withValues(alpha: 0.8),
                  _getMoodColor(dominant).withValues(alpha: 0.5),
                ]
              : [RelaxColors.violet, RelaxColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (dominant.isNotEmpty) ...[
            Text(_getMoodEmoji(dominant),
                style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              '${context.t('Cảm xúc chủ đạo:')} ${context.t(_getMoodLabel(dominant))}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _summaryBadge(context.t('Ngày ghi'), '$totalDays', Icons.edit_calendar),
              _summaryBadge(context.t('Nhật ký'), '$journalDays', Icons.menu_book),
              _summaryBadge(context.t('Thư giãn'), '$relaxDays', Icons.spa),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBadge(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final dataByDate = <String, Map<String, dynamic>>{};
    for (final item in _calendarData) {
      final day = item as Map<String, dynamic>;
      dataByDate[day['date'] as String] = day;
    }

    final firstDay =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    int startWeekday = firstDay.weekday; // 1=Mon

    final cells = <Widget>[];

    // Empty cells before first day
    for (int i = 1; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final dateStr =
          '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
      final dayData = dataByDate[dateStr];
      cells.add(_buildDayCell(context, d, dateStr, dayData));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        children: [
          // Week day headers
          Row(
            children: _weekDays
                .map((w) => Expanded(
                      child: Center(
                        child: Text(
                          w,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: context.mutedText,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            children: cells,
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, int day, String dateStr,
      Map<String, dynamic>? data) {
    final moods = (data?['moods'] as List<dynamic>?) ?? [];
    final hasJournal = data?['hasJournal'] as bool? ?? false;
    final hasRelax = data?['hasRelaxSession'] as bool? ?? false;
    final isSelected =
        _selectedDay != null && _selectedDay!['date'] == dateStr;
    final isToday = dateStr ==
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

    Color bgColor;
    if (moods.isNotEmpty) {
      bgColor = _getMoodColor(moods.first as String).withValues(alpha: 0.25);
    } else {
      bgColor = context.surfaceAlt;
    }

    return GestureDetector(
      onTap: data != null
          ? () => setState(() => _selectedDay = data)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? RelaxColors.violet
                : isToday
                    ? RelaxColors.coral.withValues(alpha: 0.6)
                    : Colors.transparent,
            width: isSelected ? 2 : isToday ? 1.5 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (moods.isNotEmpty)
              Text(
                _getMoodEmoji(moods.first as String),
                style: const TextStyle(fontSize: 14),
              )
            else
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isToday ? FontWeight.w800 : FontWeight.w500,
                  color: isToday ? RelaxColors.coral : context.appText,
                ),
              ),
            if (moods.isNotEmpty)
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 9,
                  color: context.mutedText,
                ),
              ),
            // Activity dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasJournal)
                  Container(
                    width: 3, height: 3, margin: const EdgeInsets.only(right: 1),
                    decoration: const BoxDecoration(
                        color: Colors.amber, shape: BoxShape.circle),
                  ),
                if (hasRelax)
                  Container(
                    width: 3, height: 3,
                    decoration: const BoxDecoration(
                        color: RelaxColors.violet, shape: BoxShape.circle),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final moods = ['HAPPY', 'CALM', 'TIRED', 'SAD', 'ANXIOUS', 'STRESSED', 'ANGRY', 'POOPING'];

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: moods.map((m) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _getMoodColor(m),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${_getMoodEmoji(m)} ${context.t(_getMoodLabel(m))}',
              style: TextStyle(fontSize: 11, color: context.mutedText),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        children: [
          const Text('📅', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            context.t('Chưa có dữ liệu cảm xúc'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('Hãy ghi nhận cảm xúc hàng ngày để xem lịch của bạn.'),
            style: TextStyle(color: context.mutedText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetail(BuildContext context) {
    final day = _selectedDay!;
    final dateStr = day['date'] as String;
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final dateFormatted = '${date.day}/${date.month}/${date.year}';

    final moods = day['moods'] as List<dynamic>? ?? [];
    final hasJournal = day['hasJournal'] as bool? ?? false;
    final hasRelax = day['hasRelaxSession'] as bool? ?? false;
    final sleepQuality = day['avgSleepQuality'] as int?;
    final stressLevel = day['stressLevel'] as int?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, color: RelaxColors.violet, size: 20),
              const SizedBox(width: 8),
              Text(
                '${context.t('Chi tiết ngày')} $dateFormatted',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.appText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // All moods for the day
          if (moods.isNotEmpty) ...[
            Text(context.t('Cảm xúc trong ngày'),
                style: TextStyle(
                    color: context.mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: moods.map((m) {
                final mood = m as String;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getMoodColor(mood).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _getMoodColor(mood).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getMoodEmoji(mood),
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        context.t(_getMoodLabel(mood)),
                        style: TextStyle(
                          color: _getMoodColor(mood),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const Divider(height: 24),
          ],

          _detailRow(
            context,
            'Mức độ căng thẳng',
            stressLevel != null
                ? _stressBar(context, stressLevel)
                : Text(context.t('Chưa ghi nhận'),
                    style: TextStyle(color: context.mutedText)),
          ),
          const Divider(),
          _detailRow(
            context,
            'Nhật ký tinh thần',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasJournal ? Icons.check_circle : Icons.remove_circle_outline,
                  color: hasJournal ? RelaxColors.mint : context.mutedText,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  hasJournal ? context.t('Đã viết') : context.t('Chưa viết'),
                  style: TextStyle(
                    color: hasJournal ? RelaxColors.mint : context.mutedText,
                    fontWeight: hasJournal ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _detailRow(
            context,
            'Buổi thư giãn',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasRelax ? Icons.check_circle : Icons.remove_circle_outline,
                  color: hasRelax ? RelaxColors.violet : context.mutedText,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  hasRelax ? context.t('Đã thực hiện') : context.t('Chưa có'),
                  style: TextStyle(
                    color: hasRelax ? RelaxColors.violet : context.mutedText,
                    fontWeight: hasRelax ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          _detailRow(
            context,
            'Chất lượng giấc ngủ',
            sleepQuality != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < sleepQuality ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  )
                : Text(context.t('Không có dữ liệu'),
                    style: TextStyle(color: context.mutedText)),
          ),
        ],
      ),
    );
  }

  Widget _stressBar(BuildContext context, int level) {
    final color = level <= 3
        ? RelaxColors.mint
        : level <= 6
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: level / 10,
              backgroundColor: context.fieldBorder,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('$level/10',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  Widget _detailRow(BuildContext context, String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.t(label),
            style: TextStyle(color: context.mutedText, fontSize: 14),
          ),
          value,
        ],
      ),
    );
  }
}
