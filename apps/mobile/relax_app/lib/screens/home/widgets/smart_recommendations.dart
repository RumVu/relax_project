import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_client.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

/// "Gợi ý cho bạn" — smart recommendations dựa trên mood gần nhất.
/// Fetch từ /mood-checkins/me/recommendations + /weather (nếu có).
class SmartRecommendations extends StatefulWidget {
  const SmartRecommendations({super.key});

  @override
  State<SmartRecommendations> createState() => _SmartRecommendationsState();
}

class _SmartRecommendationsState extends State<SmartRecommendations> {
  List<Map<String, dynamic>> _recs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Get latest mood to personalize.
      String? currentMood;
      try {
        final latestRes =
            await RelaxApi.instance.get('/mood-checkins/me/latest');
        if (latestRes.data is Map) {
          currentMood = latestRes.data['mood'] as String?;
        }
      } catch (_) {}

      final query = <String, dynamic>{};
      if (currentMood != null) query['mood'] = currentMood;

      final res = await RelaxApi.instance
          .get('/mood-checkins/me/recommendations', query: query);
      final data = res.data;
      if (data is List) {
        _recs = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _recs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Row(
            children: [
              const Text('✦ ', style: TextStyle(color: RelaxColors.violet)),
              Text(
                context.t('Gợi ý cho bạn'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: context.appText,
                ),
              ),
              const Text(' ✦', style: TextStyle(color: RelaxColors.violet)),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _recs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) => _RecCard(rec: _recs[i]),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _RecCard extends StatelessWidget {
  const _RecCard({required this.rec});
  final Map<String, dynamic> rec;

  static const _actionRoutes = {
    'BREATHING': '/breathing',
    'LISTEN_MUSIC': '/sounds',
    'JOURNAL': '/journal',
    'MEDITATION': '/meditation',
    'PODCAST': '/podcast',
    'SLEEP': '/sleep',
  };

  static const _actionEmoji = {
    'BREATHING': '🌬️',
    'LISTEN_MUSIC': '🎵',
    'JOURNAL': '✍️',
    'MEDITATION': '🧘',
    'PODCAST': '🎙️',
    'SLEEP': '🌙',
  };

  @override
  Widget build(BuildContext context) {
    final action = rec['action'] as String? ?? '';
    final title = rec['title'] as String? ?? action;
    final subtitle = rec['subtitle'] as String? ?? '';
    final emoji = _actionEmoji[action] ?? '🌿';
    final route = _actionRoutes[action] ?? '/relax';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(route);
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 140, maxWidth: 170),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.fieldBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const Spacer(),
            Text(
              context.t(title),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                context.t(subtitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.mutedText,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
