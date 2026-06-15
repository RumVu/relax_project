import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  bool _loading = true;
  List<dynamic> _calendarData = [];
  Map<String, dynamic>? _selectedDay;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await RelaxApi.instance.get('/analytics/me/mood-calendar');
      if (res.data is List) {
        setState(() {
          _calendarData = res.data as List;
          _loading = false;
          if (_calendarData.isNotEmpty) {
            _selectedDay = _calendarData.last as Map<String, dynamic>;
          }
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'HAPPY':
        return RelaxColors.mint;
      case 'CALM':
        return const Color(0xFF10B981);
      case 'TIRED':
        return const Color(0xFF6B7280);
      case 'SAD':
        return const Color(0xFF3B82F6);
      case 'ANXIOUS':
        return RelaxColors.violet;
      case 'STRESSED':
        return RelaxColors.plum;
      case 'ANGRY':
        return const Color(0xFFEF4444);
      case 'POOPING':
        return const Color(0xFF8B4513);
      default:
        return Colors.transparent;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'HAPPY':
        return '😊';
      case 'CALM':
        return '😌';
      case 'TIRED':
        return '🥱';
      case 'SAD':
        return '😢';
      case 'ANXIOUS':
        return '😰';
      case 'STRESSED':
        return '😫';
      case 'ANGRY':
        return '😠';
      case 'POOPING':
        return '💩';
      default:
        return '😐';
    }
  }

  String _getMoodLabel(BuildContext context, String mood) {
    const labels = {
      'HAPPY': 'Vui vẻ',
      'CALM': 'Bình yên',
      'TIRED': 'Mệt mỏi',
      'SAD': 'Buồn bã',
      'ANXIOUS': 'Lo âu',
      'STRESSED': 'Căng thẳng',
      'ANGRY': 'Giận dữ',
    };
    return context.t(labels[mood] ?? mood);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? const Color(0xFF0d1117) : RelaxColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Lịch cảm xúc 🗓️'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
            : RefreshIndicator(
                color: RelaxColors.violet,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    Text(
                      context.t('Trạng thái 30 ngày qua'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.appText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.t('Nhấn vào mỗi ngày để xem chi tiết các hoạt động.'),
                      style: TextStyle(color: context.mutedText, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Calendar Grid
                    if (_calendarData.isEmpty)
                      Container(
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
                      )
                    else
                      _buildCalendarGrid(context),

                    const SizedBox(height: 24),
                    // Selected Day Detail
                    if (_selectedDay != null) _buildDayDetail(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.fieldBorder),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.9,
        ),
        itemCount: _calendarData.length,
        itemBuilder: (context, idx) {
          final day = _calendarData[idx] as Map<String, dynamic>;
          final dateStr = day['date'] as String;
          final date = DateTime.tryParse(dateStr);
          final dayNum = date?.day ?? 0;

          final moods = day['moods'] as List<dynamic>? ?? [];
          final hasJournal = day['hasJournal'] as bool? ?? false;
          final hasRelax = day['hasRelaxSession'] as bool? ?? false;
          final hasSleep = day['avgSleepQuality'] != null;

          final isSelected = _selectedDay != null && _selectedDay!['date'] == dateStr;

          Color dayColor = Colors.transparent;
          if (moods.isNotEmpty) {
            dayColor = _getMoodColor(moods.first as String);
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? RelaxColors.violet.withValues(alpha: 0.1)
                    : context.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? RelaxColors.violet
                      : dayColor.withValues(alpha: 0.6),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNum',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasJournal)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (hasRelax) ...[
                        const SizedBox(width: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: RelaxColors.violet,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      if (hasSleep) ...[
                        const SizedBox(width: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
                'Chi tiết ngày $dateFormatted',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.appText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _detailRow(
            context,
            'Cảm xúc chính',
            moods.isNotEmpty
                ? Row(
                    children: [
                      Text(_getMoodEmoji(moods.first as String), style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        _getMoodLabel(context, moods.first as String),
                        style: TextStyle(
                          color: _getMoodColor(moods.first as String),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(context.t('Chưa ghi nhận'), style: TextStyle(color: context.mutedText)),
          ),
          const Divider(),
          _detailRow(
            context,
            'Mức độ căng thẳng',
            stressLevel != null
                ? Text('$stressLevel/10', style: TextStyle(color: context.appText, fontWeight: FontWeight.bold))
                : Text(context.t('Chưa ghi nhận'), style: TextStyle(color: context.mutedText)),
          ),
          const Divider(),
          _detailRow(
            context,
            'Nhật ký tinh thần',
            Text(
              hasJournal ? 'Đã viết nhật ký 📝' : 'Không có ghi chép',
              style: TextStyle(color: hasJournal ? RelaxColors.mint : context.mutedText, fontWeight: hasJournal ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          const Divider(),
          _detailRow(
            context,
            'Buổi thư giãn',
            Text(
              hasRelax ? 'Đã thực hiện thư giãn 🌸' : 'Không có hoạt động',
              style: TextStyle(color: hasRelax ? RelaxColors.violet : context.mutedText, fontWeight: hasRelax ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          const Divider(),
          _detailRow(
            context,
            'Chất lượng giấc ngủ',
            sleepQuality != null
                ? Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('$sleepQuality/5', style: TextStyle(color: context.appText, fontWeight: FontWeight.bold)),
                    ],
                  )
                : Text(context.t('Không có dữ liệu'), style: TextStyle(color: context.mutedText)),
          ),
        ],
      ),
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
