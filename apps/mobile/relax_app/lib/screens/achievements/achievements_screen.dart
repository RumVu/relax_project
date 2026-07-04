import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _achievements = [];
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await RelaxApi.instance.get('/achievements/me');
      final data = res.data;
      final items = data is List ? data : (data is Map ? data['items'] : []);
      _achievements = (items as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      _totalPoints = _achievements
          .where((a) => a['unlocked'] == true)
          .fold(0, (sum, a) => sum + ((a['points'] as num?)?.toInt() ?? 0));
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _achievements.where((a) => a['unlocked'] == true).length;
    final total = _achievements.length;

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
          context.t('Thành tựu'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: RelaxColors.violet))
          : RefreshIndicator(
              color: RelaxColors.violet,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _SummaryCard(
                    unlocked: unlocked,
                    total: total,
                    points: _totalPoints,
                  ),
                  const SizedBox(height: 20),
                  ..._achievements.map((a) => _AchievementTile(achievement: a)),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.unlocked,
    required this.total,
    required this.points,
  });
  final int unlocked;
  final int total;
  final int points;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? unlocked / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RelaxColors.violet, RelaxColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlocked / $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.t('thành tựu đã mở'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      '$points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: Colors.white,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});
  final Map<String, dynamic> achievement;

  static const _typeEmoji = {
    'CONSISTENCY': '🔥',
    'WELLNESS': '🧘',
    'EXPLORATION': '🗺️',
    'MOOD_STREAK': '📊',
    'SESSION_MILESTONE': '🏅',
    'SOCIAL': '👥',
  };

  @override
  Widget build(BuildContext context) {
    final title = achievement['title'] as String? ?? '';
    final desc = achievement['description'] as String? ?? '';
    final type = achievement['type'] as String? ?? '';
    final points = (achievement['points'] as num?)?.toInt() ?? 0;
    final unlocked = achievement['unlocked'] == true;
    final emoji = achievement['icon'] as String? ?? _typeEmoji[type] ?? '🏆';
    final unlockedAt = achievement['unlockedAt'] as String?;

    return GestureDetector(
      onTap: unlocked
          ? () {
              HapticFeedback.lightImpact();
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unlocked
              ? RelaxColors.violet.withValues(alpha: 0.06)
              : context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: unlocked
                ? RelaxColors.violet.withValues(alpha: 0.3)
                : context.fieldBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: unlocked
                    ? RelaxColors.violet.withValues(alpha: 0.12)
                    : context.fieldBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                unlocked ? emoji : '🔒',
                style: TextStyle(
                  fontSize: 22,
                  color: unlocked ? null : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: unlocked
                          ? context.appText
                          : context.mutedText,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: TextStyle(
                      color: context.mutedText,
                      fontSize: 11,
                    ),
                  ),
                  if (unlocked && unlockedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(unlockedAt),
                      style: TextStyle(
                        color: RelaxColors.violet.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: unlocked
                    ? RelaxColors.mint.withValues(alpha: 0.15)
                    : context.fieldBorder.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+$points',
                style: TextStyle(
                  color:
                      unlocked ? RelaxColors.mint : context.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    return '${d.day}/${d.month}/${d.year}';
  }
}
