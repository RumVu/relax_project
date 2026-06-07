import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/services/mood_service.dart';
import '../../shared/widgets/charts/mood_line_chart.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';

/// Insights — analytics sâu về hành trình cảm xúc.
///
/// Khác Stats sheet (chỉ tổng quan): màn này tách thành sections rõ ràng:
///   1. Streak hero — số ngày liên tiếp + lời chúc
///   2. Mood breakdown — % từng mood + bar chart
///   3. 7/30 ngày trend — line chart + so sánh
///   4. Insights gợi ý — pattern detection (hay buồn ngày nào, etc.)
///   5. Achievements — badges đã đạt
///
/// Data từ moodHistory (đã fetch ở shell). Nếu chưa login → CTA login.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({
    super.key,
    required this.moodHistory,
  });

  final List<MoodCheckin> moodHistory;

  @override
  Widget build(BuildContext context) {
    final session = context.sessionOrNull;
    final loggedIn = session?.isLoggedIn ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Hành trình của bạn'),
      ),
      body: !loggedIn
          ? _LoginPrompt()
          : moodHistory.isEmpty
              ? _EmptyState()
              : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final stats = _Stats.from(moodHistory);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // ── Streak hero
        _StreakHero(streak: stats.streakDays),
        const SizedBox(height: 16),
        // ── Quick metrics row
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                emoji: '📊',
                value: '${moodHistory.length}',
                label: 'Tổng check-in',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                emoji: '📅',
                value: '${stats.activeDays}',
                label: 'Ngày hoạt động',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                emoji: '✨',
                value: '${stats.thisWeekCount}',
                label: '7 ngày qua',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // ── 7-day trend
        _SectionLabel(title: '7 NGÀY QUA', icon: Icons.timeline_rounded),
        PixelPanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stats.trendLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: stats.trendUp == null
                      ? null
                      : stats.trendUp == true
                          ? const Color(0xFF48D3A8)
                          : const Color(0xFFE85A6A),
                ),
              ),
              const SizedBox(height: 10),
              MoodLineChart(compact: false, data: stats.weeklyChart),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tuần trước: ${stats.prevWeekCount}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      color: context.relax.muted,
                    ),
                  ),
                  Text(
                    'Tuần này: ${stats.thisWeekCount}',
                    style: TextStyle(
                      color: RelaxTheme.lavender,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // ── Mood breakdown
        _SectionLabel(title: 'CẢM XÚC NỔI BẬT', icon: Icons.palette_rounded),
        PixelPanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              for (final entry in stats.moodBreakdown.entries)
                _MoodBar(
                  mood: entry.key,
                  percent: entry.value,
                ),
              if (stats.dominantMood != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: RelaxTheme.purple.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 14,
                        color: RelaxTheme.lavender,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _dominantTip(stats.dominantMood!),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 11.5, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        // ── Pattern insights
        if (stats.insights.isNotEmpty) ...[
          _SectionLabel(
            title: 'PATTERN MÌNH NHẬN RA',
            icon: Icons.auto_awesome_rounded,
          ),
          PixelPanel(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (var i = 0; i < stats.insights.length; i++) ...[
                  if (i > 0) const Divider(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats.insights[i].emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          stats.insights[i].text,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.5, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        // ── Achievements
        _SectionLabel(
          title: 'HUY HIỆU ĐÃ ĐẠT',
          icon: Icons.workspace_premium_rounded,
        ),
        _AchievementGrid(stats: stats),
        const SizedBox(height: 22),
        Center(
          child: Text(
            '✦ Mỗi check-in là một bước nhỏ trên hành trình ✦',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: RelaxTheme.lavender,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  String _dominantTip(String moodCode) {
    return switch (moodCode) {
      'HAPPY' => 'Tuyệt vời — bạn đang trong giai đoạn ổn. Nhớ ghi lại '
          'những điều đã giúp bạn ổn để dùng lại sau nha 💜',
      'SAD' => 'Buồn là cảm xúc bình thường. Nếu kéo dài > 2 tuần, '
          'cân nhắc tâm sự với người thân hoặc chuyên gia.',
      'STRESSED' => 'Stress nhiều cảnh báo cơ thể cần nghỉ. Thử bài thở '
          '4-4-6 hoặc một phiên thiền 10 phút.',
      'TIRED' => 'Mệt liên tục có thể là dấu hiệu thiếu ngủ hoặc burnout. '
          'Ưu tiên 1 giấc ngủ đủ giấc tối nay nha ~',
      _ => 'Cảm xúc trống đôi khi là cách tâm trí tự bảo vệ. Một phiên '
          'journaling ngắn có thể giúp gọi tên điều bạn đang cảm.',
    };
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Stats compute
// ════════════════════════════════════════════════════════════════════════════

class _Stats {
  _Stats({
    required this.streakDays,
    required this.activeDays,
    required this.thisWeekCount,
    required this.prevWeekCount,
    required this.weeklyChart,
    required this.moodBreakdown,
    required this.dominantMood,
    required this.trendLabel,
    required this.trendUp,
    required this.insights,
  });

  final int streakDays;
  final int activeDays;
  final int thisWeekCount;
  final int prevWeekCount;
  final List<double> weeklyChart;
  final Map<String, int> moodBreakdown; // % per mood code
  final String? dominantMood;
  final String trendLabel;
  final bool? trendUp;
  final List<_Insight> insights;

  factory _Stats.from(List<MoodCheckin> history) {
    if (history.isEmpty) {
      return _Stats(
        streakDays: 0,
        activeDays: 0,
        thisWeekCount: 0,
        prevWeekCount: 0,
        weeklyChart: List.filled(7, 0.0),
        moodBreakdown: const {},
        dominantMood: null,
        trendLabel: 'Chưa có dữ liệu',
        trendUp: null,
        insights: const [],
      );
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Active days (unique day count)
    final dayKeys = history
        .map((c) => DateTime(
              c.createdAt.year,
              c.createdAt.month,
              c.createdAt.day,
            ))
        .toSet();
    final activeDays = dayKeys.length;

    // Streak: count consecutive days back from today (or yesterday)
    int streak = 0;
    var cursor = today;
    while (dayKeys.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    // Cho phép miss hôm nay nếu có hôm qua
    if (streak == 0 && dayKeys.contains(today.subtract(const Duration(days: 1)))) {
      cursor = today.subtract(const Duration(days: 1));
      while (dayKeys.contains(cursor)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      }
    }

    // 7-day chart counts
    final counts = List<int>.filled(7, 0);
    for (final c in history) {
      final day = DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
      final diff = today.difference(day).inDays;
      if (diff >= 0 && diff < 7) counts[6 - diff]++;
    }
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final weeklyChart = maxCount == 0
        ? List<double>.filled(7, 0.0)
        : counts.map((c) => c / maxCount).toList();

    final thisWeekCount = counts.fold<int>(0, (s, v) => s + v);

    // Prev week count (8-14 days ago)
    int prevWeek = 0;
    for (final c in history) {
      final day = DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
      final diff = today.difference(day).inDays;
      if (diff >= 7 && diff < 14) prevWeek++;
    }

    // Trend
    bool? trendUp;
    String trendLabel;
    if (prevWeek == 0 && thisWeekCount > 0) {
      trendLabel = '🌱 Bạn vừa bắt đầu — tuyệt!';
      trendUp = true;
    } else if (thisWeekCount > prevWeek) {
      trendLabel = '📈 Tăng ${thisWeekCount - prevWeek} so với tuần trước';
      trendUp = true;
    } else if (thisWeekCount < prevWeek) {
      trendLabel = '📉 Giảm ${prevWeek - thisWeekCount} so với tuần trước';
      trendUp = false;
    } else {
      trendLabel = '✨ Ổn định — như tuần trước';
      trendUp = null;
    }

    // Mood breakdown
    final moodCounts = <String, int>{};
    for (final c in history) {
      moodCounts[c.mood] = (moodCounts[c.mood] ?? 0) + 1;
    }
    final total = history.length;
    final breakdown = <String, int>{};
    var sortedEntries = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final e in sortedEntries) {
      breakdown[e.key] = (e.value / total * 100).round();
    }
    final dominant = sortedEntries.isEmpty ? null : sortedEntries.first.key;

    // Insights
    final insights = <_Insight>[];
    // Pattern: most active day of week
    final byDow = <int, int>{};
    for (final c in history) {
      byDow[c.createdAt.weekday] = (byDow[c.createdAt.weekday] ?? 0) + 1;
    }
    if (byDow.isNotEmpty) {
      final topDow = byDow.entries.reduce((a, b) => a.value > b.value ? a : b);
      const dows = ['', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
      insights.add(_Insight(
        emoji: '📅',
        text: 'Bạn check-in nhiều nhất vào ${dows[topDow.key]} '
            '(${topDow.value} lần). Có thể đây là ngày bạn cần dịu lại nhất.',
      ));
    }
    if (streak >= 7) {
      insights.add(_Insight(
        emoji: '🔥',
        text: 'Streak $streak ngày — bạn đã có thói quen check-in. '
            'Đây là nền tảng để chăm sóc tinh thần lâu dài 💜',
      ));
    }
    if (breakdown.containsKey('STRESSED') &&
        (breakdown['STRESSED'] ?? 0) >= 40) {
      insights.add(_Insight(
        emoji: '🌪️',
        text: 'Stress chiếm > 40% — nhiều hơn bình thường. Cân nhắc tăng '
            'phiên hít thở hoặc journaling trong tuần này nha.',
      ));
    }
    if (breakdown.containsKey('HAPPY') &&
        (breakdown['HAPPY'] ?? 0) >= 50) {
      insights.add(_Insight(
        emoji: '☀️',
        text: 'Hơn nửa số check-in là cảm xúc tích cực. Ghi lại những '
            'thói quen giúp bạn ổn để duy trì nha ✦',
      ));
    }

    return _Stats(
      streakDays: streak,
      activeDays: activeDays,
      thisWeekCount: thisWeekCount,
      prevWeekCount: prevWeek,
      weeklyChart: weeklyChart,
      moodBreakdown: breakdown,
      dominantMood: dominant,
      trendLabel: trendLabel,
      trendUp: trendUp,
      insights: insights,
    );
  }
}

class _Insight {
  const _Insight({required this.emoji, required this.text});
  final String emoji;
  final String text;
}

// ════════════════════════════════════════════════════════════════════════════
//  UI parts
// ════════════════════════════════════════════════════════════════════════════

class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.streak});
  final int streak;

  String get _msg {
    if (streak == 0) return 'Bắt đầu check-in cảm xúc đầu tiên của bạn nha ✦';
    if (streak < 3) return 'Tuyệt! Tiếp tục để mở khoá huy hiệu Streak 3.';
    if (streak < 7) return 'Đang tới Streak 7 rồi! Cố lên 💪';
    if (streak < 14) return 'Bạn đang xây thói quen tuyệt vời 💜';
    if (streak < 30) return 'Một tháng đang trong tầm tay — bạn xứng đáng!';
    return 'Bạn là legend ✦ Hành trình của bạn đang truyền cảm hứng.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: streak > 0
              ? const [Color(0xFFE85A6A), Color(0xFFFFC96E)]
              : [
                  RelaxTheme.purple.withValues(alpha: .7),
                  RelaxTheme.lavender.withValues(alpha: .7),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (streak > 0 ? const Color(0xFFE85A6A) : RelaxTheme.purple)
                .withValues(alpha: .25),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                streak > 0 ? '🔥' : '✨',
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak > 0 ? '$streak ngày liên tiếp' : 'Streak: 0',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _msg,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .92),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.emoji,
    required this.value,
    required this.label,
  });
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RelaxTheme.lavender.withValues(alpha: .2),
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: RelaxTheme.lavender,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 9.5,
              color: context.relax.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: RelaxTheme.lavender),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: RelaxTheme.lavender,
              fontWeight: FontWeight.w900,
              fontSize: 10.5,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodBar extends StatelessWidget {
  const _MoodBar({required this.mood, required this.percent});
  final String mood;
  final int percent;

  static const _emojis = {
    'HAPPY': '😊',
    'SAD': '🌧️',
    'STRESSED': '🌪️',
    'TIRED': '😴',
    'NEUTRAL': '😶',
    'CALM': '🌿',
    'ANXIOUS': '😰',
  };

  static const _labels = {
    'HAPPY': 'Vui',
    'SAD': 'Buồn',
    'STRESSED': 'Căng',
    'TIRED': 'Mệt',
    'NEUTRAL': 'Bình',
    'CALM': 'Yên',
    'ANXIOUS': 'Lo',
  };

  @override
  Widget build(BuildContext context) {
    final emoji = _emojis[mood] ?? '💫';
    final label = _labels[mood] ?? mood;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 10,
                backgroundColor: context.relax.surfaceSoft,
                valueColor: AlwaysStoppedAnimation(RelaxTheme.lavender),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              '$percent%',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: RelaxTheme.lavender,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementGrid extends StatelessWidget {
  const _AchievementGrid({required this.stats});
  final _Stats stats;

  @override
  Widget build(BuildContext context) {
    final badges = <_Badge>[
      _Badge(
        emoji: '🌱',
        name: 'Bắt đầu',
        desc: 'Check-in đầu tiên',
        unlocked: stats.activeDays >= 1,
      ),
      _Badge(
        emoji: '🔥',
        name: 'Streak 3',
        desc: '3 ngày liên tiếp',
        unlocked: stats.streakDays >= 3,
      ),
      _Badge(
        emoji: '💪',
        name: 'Streak 7',
        desc: 'Cả tuần liền',
        unlocked: stats.streakDays >= 7,
      ),
      _Badge(
        emoji: '🌟',
        name: 'Streak 30',
        desc: 'Một tháng đầy',
        unlocked: stats.streakDays >= 30,
      ),
      _Badge(
        emoji: '📊',
        name: '10 check-in',
        desc: 'Tích cực ghi nhận',
        unlocked: stats.thisWeekCount + stats.prevWeekCount >= 10,
      ),
      _Badge(
        emoji: '🌸',
        name: 'Tự lắng nghe',
        desc: 'Đã ghi nhật ký',
        unlocked: false, // wire khi có journal count
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .9,
      ),
      itemCount: badges.length,
      itemBuilder: (_, i) => _BadgeCard(badge: badges[i]),
    );
  }
}

class _Badge {
  const _Badge({
    required this.emoji,
    required this.name,
    required this.desc,
    required this.unlocked,
  });
  final String emoji;
  final String name;
  final String desc;
  final bool unlocked;
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: badge.unlocked
            ? RelaxTheme.purple.withValues(alpha: .1)
            : context.relax.surfaceSoft.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badge.unlocked
              ? RelaxTheme.lavender.withValues(alpha: .5)
              : context.relax.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: badge.unlocked ? 1 : .35,
            child: Text(
              badge.emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: badge.unlocked ? null : context.relax.muted,
            ),
          ),
          Text(
            badge.desc,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 8.5,
              color: context.relax.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 60),
        const Center(child: CatAvatar(size: 100)),
        const SizedBox(height: 20),
        Icon(
          Icons.lock_outline_rounded,
          size: 38,
          color: RelaxTheme.lavender.withValues(alpha: .5),
        ),
        const SizedBox(height: 10),
        Text(
          'Đăng nhập để mở khóa hành trình',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Streak, badges, pattern insights, mood breakdown — tất cả '
          'cá nhân hóa cho bạn sau khi đăng nhập ✦',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 60),
        const Center(child: CatAvatar(size: 100)),
        const SizedBox(height: 20),
        Text(
          'Hành trình của bạn sẽ bắt đầu sớm ✦',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Check-in cảm xúc đầu tiên ở Home — sau đó mỗi ngày qua, '
          'streak + insights sẽ dần xuất hiện ở đây.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
