import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/session.dart';
import '../../../data/services/mood_service.dart';
import '../../../data/services/relax_session_service.dart';
import '../../../shared/widgets/charts/mood_line_chart.dart';
import '../../../shared/widgets/common/section_title.dart';
import '../../../shared/widgets/pixel/pixel_panel.dart';

/// Sheet "Thống kê tình trạng" — khớp đúng mockup trang 3:
/// - 3 metric chips: Streak / Tổng thời gian / Hôm nay
/// - Biểu đồ cảm xúc 7 ngày qua
/// - Hoạt động yêu thích (5 dòng)
/// - Khoảnh khắc thư giãn gần đây (3 cards)
///
/// Mở bằng [showStatsSheet] — tự fetch dữ liệu từ /relax-sessions/me +
/// /mood-checkins/me. Khi chưa đăng nhập hoặc backend lỗi, dùng dữ liệu
/// mẫu để vẫn show full mockup.
void showStatsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => const _StatsSheet(),
  );
}

class _StatsSheet extends StatefulWidget {
  const _StatsSheet();

  @override
  State<_StatsSheet> createState() => _StatsSheetState();
}

class _StatsSheetState extends State<_StatsSheet> {
  bool _loading = true;
  int _streakDays = 0;
  Duration _totalTime = Duration.zero;
  Duration _todayTime = Duration.zero;
  final List<_FavoriteActivityRow> _favorites = [];
  final List<_RecentMomentRow> _recent = [];
  final List<double> _moodChart = List<double>.filled(7, 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = context.sessionOrNull;
    if (session == null || !session.isLoggedIn) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final token = session.accessToken!;

    // Mỗi API có try/catch riêng — không để 1 lỗi làm spin mãi.
    List<RelaxSession> sessions = const [];
    List<MoodCheckin> checkins = const [];
    try {
      sessions = await RelaxSessionService()
          .recent(accessToken: token, limit: 60)
          .timeout(const Duration(seconds: 8));
    } catch (_) {/* ignore — empty stays empty */}
    try {
      checkins = await MoodService()
          .history(accessToken: token, limit: 90)
          .timeout(const Duration(seconds: 8));
    } catch (_) {/* ignore */}

    _compute(sessions, checkins);
    if (mounted) setState(() => _loading = false);
  }

  void _compute(List<RelaxSession> sessions, List<MoodCheckin> checkins) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ── Mood chart: 7 ngày từ checkin history ────────────────────────────
    final dayCounts = List<int>.filled(7, 0);
    for (final c in checkins) {
      final day = DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
      final diff = today.difference(day).inDays;
      if (diff >= 0 && diff < 7) dayCounts[6 - diff]++;
    }
    final maxDay = dayCounts.reduce((a, b) => a > b ? a : b);
    _moodChart
      ..clear()
      ..addAll(maxDay == 0
          ? List.filled(7, 0.0)
          : dayCounts.map((c) => c / maxDay).toList());

    Duration total = Duration.zero;
    Duration todaySpent = Duration.zero;
    final byActivity = <String, Duration>{};

    for (final s in sessions) {
      final end = s.finishedAt ?? s.startedAt;
      final dur = end.difference(s.startedAt);
      if (dur.isNegative) continue;
      total += dur;
      byActivity.update(s.activityCode, (v) => v + dur, ifAbsent: () => dur);
      final d = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
      if (d == today) todaySpent += dur;
    }

    // Streak — đếm ngược từ hôm nay, dừng ở ngày đầu tiên không có session.
    int streak = 0;
    final days = sessions
        .map(
          (s) => DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day),
        )
        .toSet();
    for (var i = 0; i < 365; i++) {
      final probe = today.subtract(Duration(days: i));
      if (days.contains(probe)) {
        streak++;
      } else {
        if (i != 0) break; // không tính hôm nay nếu chưa có session.
      }
    }

    _totalTime = total;
    _todayTime = todaySpent;
    _streakDays = streak;

    // Favorites: sort desc by duration.
    final sorted = byActivity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _favorites
      ..clear()
      ..addAll(
        sorted
            .take(5)
            .map(
              (e) => _FavoriteActivityRow(
                _labelFor(e.key),
                _iconFor(e.key),
                _formatDur(e.value),
              ),
            ),
      );

    // Recent moments: 3 phiên gần nhất đã finish.
    final recent = sessions.where((s) => s.finishedAt != null).take(3).toList();
    _recent
      ..clear()
      ..addAll(
        recent.map(
          (s) => _RecentMomentRow(
            _labelFor(s.activityCode),
            _iconFor(s.activityCode),
            _formatWhen(s.startedAt),
            s.finishedAt!.difference(s.startedAt).inMinutes,
          ),
        ),
      );
  }

  String _labelFor(String code) => switch (code) {
    'MUSIC' => 'Nhạc',
    'PODCAST' => 'Podcast',
    'BREATHING' => 'Hít thở',
    'JOURNAL' => 'Viết nhật ký',
    'MEDITATION' => 'Thiền',
    'MYSTERY' => 'Bí ẩn',
    _ => code,
  };

  IconData _iconFor(String code) => switch (code) {
    'MUSIC' => Icons.radio_rounded,
    'PODCAST' => Icons.mic_external_on_rounded,
    'BREATHING' => Icons.cloud_rounded,
    'JOURNAL' => Icons.menu_book_rounded,
    'MEDITATION' => Icons.self_improvement_rounded,
    'MYSTERY' => Icons.inventory_2_rounded,
    _ => Icons.spa_rounded,
  };

  String _formatDur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  String _formatWhen(DateTime t) {
    final d =
        '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}';
    final hm =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return '$d · $hm';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * .9;
    final session = context.sessionOrNull;
    final now = DateTime.now();
    final todayLabel =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Check if we have real data or just empty state
    final hasData = _favorites.isNotEmpty || _recent.isNotEmpty;

    return SizedBox(
      height: height,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : !hasData && (session == null || !session.isLoggedIn)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 64,
                          color: RelaxTheme.lavender.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có dữ liệu',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hãy bắt đầu phiên thư giãn đầu tiên để Thi Ái theo dõi tiến độ của bạn nha ✦',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: ListView(
                    children: [
                      Text(
                        'THỐNG KÊ TÌNH TRẠNG TÂM TRẠNG',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: RelaxTheme.lavender,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                    children: [
                      Expanded(
                        child: _MetricChip(
                          icon: '🔥',
                          label: 'Streak',
                          value: '$_streakDays',
                          unit: 'ngày liên tiếp',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricChip(
                          icon: '⏱',
                          label: 'Tổng thời gian',
                          value: _formatDur(_totalTime),
                          unit: 'Tổng thời gian thư giãn',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _MetricChip(
                          icon: '📅',
                          label: 'Hôm nay',
                          value: todayLabel,
                          unit: _formatDur(_todayTime),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PixelPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(
                          title: 'Biểu đồ cảm xúc (7 ngày qua)',
                          icon: Icons.show_chart_rounded,
                        ),
                        const SizedBox(height: 8),
                        // Dùng MoodLineChart — data thật từ /mood-checkins/me
                        MoodLineChart(
                          compact: true,
                          data: _moodChart.any((v) => v > 0) ? _moodChart : [],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _DayLabel('T2'),
                            _DayLabel('T3'),
                            _DayLabel('T4'),
                            _DayLabel('T5'),
                            _DayLabel('T6'),
                            _DayLabel('T7'),
                            _DayLabel('CN'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  PixelPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(
                          title: 'Hoạt động yêu thích',
                          icon: Icons.favorite_border_rounded,
                        ),
                        const SizedBox(height: 8),
                        for (final f in _favorites) _favoriteRow(context, f),
                        if (_favorites.isEmpty)
                          Text(
                            'Chưa có hoạt động nào — bấm Finish ở Khu thư giãn để Thi Ái nhớ nha ✦',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Khoảnh khắc thư giãn gần đây',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Xem tất cả ›',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: RelaxTheme.lavender,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_recent.isEmpty)
                    Text(
                      'Chưa có khoảnh khắc nào — thử nghe nhạc hoặc viết nhật ký nha 💜',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    Row(
                      children: [
                        for (var i = 0; i < _recent.length; i++) ...[
                          Expanded(child: _recentCard(context, _recent[i])),
                          if (i != _recent.length - 1) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _favoriteRow(BuildContext context, _FavoriteActivityRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(row.icon, size: 18, color: context.relax.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              row.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            row.duration,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: RelaxTheme.lavender,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentCard(BuildContext context, _RecentMomentRow row) {
    return PixelPanel(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(row.icon, size: 22, color: RelaxTheme.lavender),
          const SizedBox(height: 6),
          Text(
            row.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            row.when,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            '${row.minutes} phút',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: RelaxTheme.purple),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });
  final String icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 11,
                    color: context.relax.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: RelaxTheme.purple),
          ),
          Text(
            unit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
  );
}

class _MoodChartPainter extends CustomPainter {
  _MoodChartPainter({
    required this.points,
    required this.line,
    required this.dot,
    required this.grid,
  });
  final List<double> points; // 0..1
  final Color line;
  final Color dot;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paintGrid = Paint()
      ..color = grid
      ..strokeWidth = 1;
    // 4 grid lines.
    for (var i = 0; i < 5; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }
    final paintLine = Paint()
      ..color = line
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final paintDot = Paint()..color = dot;

    final path = Path();
    final spacing = points.length <= 1 ? 0.0 : size.width / (points.length - 1);
    for (var i = 0; i < points.length; i++) {
      final x = spacing * i;
      final y = size.height - points[i].clamp(0.0, 1.0) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paintLine);
    for (var i = 0; i < points.length; i++) {
      final x = spacing * i;
      final y = size.height - points[i].clamp(0.0, 1.0) * size.height;
      canvas.drawCircle(Offset(x, y), 3.5, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant _MoodChartPainter old) =>
      old.points != points || old.line != line || old.dot != dot;
}

class _FavoriteActivityRow {
  const _FavoriteActivityRow(this.label, this.icon, this.duration);
  final String label;
  final IconData icon;
  final String duration;
}

class _RecentMomentRow {
  const _RecentMomentRow(this.label, this.icon, this.when, this.minutes);
  final String label;
  final IconData icon;
  final String when;
  final int minutes;
}
