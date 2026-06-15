import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';

class MoodRecoveryScreen extends StatefulWidget {
  const MoodRecoveryScreen({super.key});

  @override
  State<MoodRecoveryScreen> createState() => _MoodRecoveryScreenState();
}

class _MoodRecoveryScreenState extends State<MoodRecoveryScreen> {
  bool _loading = true;
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/mood-recovery/me/summary'),
        RelaxApi.instance.get('/mood-recovery/me/history'),
      ]);
      setState(() {
        _summary = results[0].data as Map<String, dynamic>?;
        _history = (results[1].data as List?)?.cast<Map<String, dynamic>>() ?? [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          context.t('Hồi phục cảm xúc'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: RelaxColors.violet,
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    if (_summary != null) ...[
                      _buildSummaryCard(context),
                      const SizedBox(height: 16),
                      if ((_summary!['byActivity'] as List?)?.isNotEmpty ?? false) ...[
                        _buildActivityBreakdown(context),
                        const SizedBox(height: 16),
                      ],
                    ],
                    Text(
                      context.t('Lịch sử phục hồi'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.appText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_history.isEmpty)
                      _buildEmptyState(context)
                    else
                      ..._history.take(20).map((s) => _buildSessionCard(context, s)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final totalSessions = _summary?['totalSessions'] ?? 0;
    final avgDelta = (_summary?['avgDelta'] ?? 0).toDouble();
    final recoveryRate = _summary?['recoveryRate'] ?? 0;
    final avgStressRelief = _summary?['avgStressRelief'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981),
            const Color(0xFF059669),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(context.t('Phiên'), '$totalSessions', Icons.spa),
              _statItem(context.t('Hồi phục'), '$recoveryRate%', Icons.trending_up),
              _statItem(context.t('Giảm stress'), '$avgStressRelief%', Icons.favorite),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  avgDelta > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${context.t('Điểm cảm xúc TB:')} ${avgDelta > 0 ? '+' : ''}${avgDelta.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildActivityBreakdown(BuildContext context) {
    final activities =
        (_summary!['byActivity'] as List).cast<Map<String, dynamic>>();

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
            context.t('Hiệu quả theo hoạt động'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 12),
          ...activities.map((a) {
            final type = a['activityType'] as String? ?? '';
            final avgDelta = (a['avgDelta'] ?? 0).toDouble();
            final sessions = a['sessions'] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(_activityIcon(type), size: 18, color: RelaxColors.violet),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _activityLabel(type),
                      style: TextStyle(color: context.appText, fontSize: 13),
                    ),
                  ),
                  Text(
                    '${avgDelta > 0 ? '+' : ''}${avgDelta.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: avgDelta > 0 ? RelaxColors.mint : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$sessions ${context.t('lần')}',
                    style: TextStyle(color: context.mutedText, fontSize: 11),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, Map<String, dynamic> session) {
    final moodBefore = session['moodBefore'] as String? ?? '';
    final moodAfter = session['moodAfter'] as String? ?? '';
    final delta = (session['delta'] ?? 0).toDouble();
    final title = session['title'] as String? ?? '';
    final relief = session['stressReliefPercent'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(_moodEmoji(moodBefore), style: const TextStyle(fontSize: 20)),
              Icon(Icons.arrow_downward, size: 12, color: context.mutedText),
              Text(_moodEmoji(moodAfter), style: const TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: context.appText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '$moodBefore → $moodAfter',
                  style: TextStyle(color: context.mutedText, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)}',
                style: TextStyle(
                  color: delta > 0
                      ? RelaxColors.mint
                      : delta < 0
                          ? const Color(0xFFEF4444)
                          : context.mutedText,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              if (relief != null)
                Text(
                  '${context.t('Giảm')} $relief%',
                  style: TextStyle(color: context.mutedText, fontSize: 10),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(context.t('Chưa có dữ liệu hồi phục'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.appText,
              )),
          const SizedBox(height: 6),
          Text(
            context.t('Hoàn thành phiên thư giãn với ghi nhận cảm xúc trước/sau'),
            style: TextStyle(color: context.mutedText, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _moodEmoji(String mood) {
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

  IconData _activityIcon(String type) {
    switch (type) {
      case 'BREATHING': return Icons.air;
      case 'MEDITATION': return Icons.self_improvement;
      case 'MUSIC': return Icons.headphones;
      case 'JOURNAL': return Icons.edit_note;
      case 'PODCAST': return Icons.podcasts;
      default: return Icons.spa;
    }
  }

  String _activityLabel(String type) {
    switch (type) {
      case 'BREATHING': return 'Hít thở';
      case 'MEDITATION': return 'Thiền';
      case 'MUSIC': return 'Âm nhạc';
      case 'JOURNAL': return 'Nhật ký';
      case 'PODCAST': return 'Podcast';
      case 'MYSTERY': return 'Khám phá';
      default: return type;
    }
  }
}
