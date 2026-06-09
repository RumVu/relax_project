import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/auth_state.dart';
import '../core/theme.dart';
import '../widgets/cat_mascot.dart';
import '../widgets/journey_prompt.dart';
import '../widgets/notification_sheet.dart';
import '../widgets/soft_toast.dart';

/// Trang chủ — dựng theo mockup: lời chào theo thời tiết, mèo + bong bóng
/// thoại, lưới cảm xúc, thanh theo dõi cảm xúc, và các phương thức phù hợp.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _greeting;
  Map<String, dynamic>? _quote;
  List<Map<String, dynamic>> _moodOptions = [];
  Map<String, int> _moodCounts = {};
  int _moodTotal = 0;
  String? _savingMood;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/weather/me/current'),
        RelaxApi.instance.get('/cozy-quotes/random'),
        RelaxApi.instance.get('/mood-checkins/options'),
        RelaxApi.instance.get('/mood-checkins/me', query: {'limit': 60}),
        RelaxApi.instance.get('/notifications/me/unread-count'),
      ]);
      final w = results[0].data;
      _greeting = (w is Map && w['greeting'] is Map)
          ? Map<String, dynamic>.from(w['greeting'])
          : null;
      _quote = results[1].data is Map
          ? Map<String, dynamic>.from(results[1].data)
          : null;
      final opts = results[2].data;
      _moodOptions = (opts is List)
          ? opts
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .take(6)
              .toList()
          : [];
      final hist = results[3].data;
      final items = hist is Map ? hist['items'] : hist;
      _moodCounts = {};
      _moodTotal = 0;
      if (items is List) {
        for (final it in items.whereType<Map>()) {
          final m = it['mood'] as String?;
          if (m == null) continue;
          _moodCounts[m] = (_moodCounts[m] ?? 0) + 1;
          _moodTotal++;
        }
      }
      final unreadRes = results[4].data;
      _unreadCount = (unreadRes is Map && unreadRes['count'] is num)
          ? (unreadRes['count'] as num).toInt()
          : 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logMood(String mood, String label) async {
    HapticFeedback.lightImpact();
    setState(() => _savingMood = mood);
    try {
      final res = await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': mood,
        'intensity': 3,
        'tags': ['home'],
      });
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        showSoftToast(context,
            message: 'Đã ghi cảm xúc: $label',
            tone: SoftToastTone.success);
        await _loadAll();
        if (!mounted) return;
        await showJourneyPrompt(
          context,
          title: 'Đã ghi nhận cảm xúc 🌸',
          subtitle: subtitleForMood(mood),
          suggestions: suggestionsForMood(mood),
        );
      }
    } catch (_) {
      // ignore — snackbar đủ
    } finally {
      if (mounted) setState(() => _savingMood = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    final name = (user?['name'] as String?) ??
        (user?['email'] as String?)?.split('@').first ??
        'bạn';

    return SafeArea(
      child: RefreshIndicator(
        color: RelaxColors.violet,
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _header(context, name),
            const SizedBox(height: 16),
            _speechBubble(context, name),
            const SizedBox(height: 20),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(color: RelaxColors.violet),
                ),
              )
            else ...[
              _sectionTitle('Hôm nay $name đang cảm thấy:'),
              const SizedBox(height: 12),
              _moodGrid(),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.push('/mood'),
                child: const Text(
                  'Chi tiết hơn với ghi chú & cường độ ➜',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RelaxColors.violet,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _trackingCard(context, name),
              const SizedBox(height: 24),
              _methodsCard(context, name),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: RelaxColors.coral, fontSize: 12),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final res = await RelaxApi.instance.get('/notifications/me/unread-count');
      final unreadRes = res.data;
      if (unreadRes is Map && unreadRes['count'] is num) {
        setState(() {
          _unreadCount = (unreadRes['count'] as num).toInt();
        });
      }
    } catch (_) {}
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationSheet(
        onRefreshCount: () {
          _refreshUnreadCount();
        },
      ),
    );
  }

  IconData _getWeatherIcon(String? iconKey) {
    switch (iconKey) {
      case 'weather-sunny':
        return Icons.wb_sunny_outlined;
      case 'weather-night':
        return Icons.nightlight_round_outlined;
      case 'weather-rain':
        return Icons.umbrella_outlined;
      case 'weather-storm':
        return Icons.thunderstorm_outlined;
      case 'weather-cloudy':
        return Icons.cloud_outlined;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  Color _getWeatherIconColor(String? iconKey) {
    switch (iconKey) {
      case 'weather-sunny':
        return RelaxColors.sun;
      case 'weather-night':
        return RelaxColors.lilac;
      case 'weather-rain':
      case 'weather-storm':
        return RelaxColors.violet;
      case 'weather-cloudy':
        return RelaxColors.slate;
      default:
        return RelaxColors.sun;
    }
  }

  Widget _header(BuildContext context, String name) {
    final title = (_greeting?['title'] as String?) ?? 'Đã trở lại rồi nè ~';
    final subtitle = (_greeting?['subtitle'] as String?) ?? 'Chúc bạn một ngày nhẹ nhàng.';
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/weather'),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(
                  _getWeatherIcon(_greeting?['iconKey']),
                  color: _getWeatherIconColor(_greeting?['iconKey']),
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: context.appText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: context.mutedText, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Stack(
          children: [
            IconButton(
              onPressed: _showNotifications,
              icon: Icon(Icons.notifications_outlined, color: context.appText),
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: RelaxColors.coral,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _speechBubble(BuildContext context, String name) {
    final line = (_quote?['content'] as String?) ??
        'Stress quá mới tìm đến toi hở? $name nói cho toi nghe đi nè!';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: RelaxColors.violet.withValues(alpha: context.isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              line,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Tap vào mascot để mở màn linh thú — biến mascot từ trang
          // trí thành cổng vào /companion (vốn là dead route).
          GestureDetector(
            onTap: () => context.push('/companion'),
            child: const CatMascot(size: 130, emoji: '😺'),
          ),
          const SizedBox(height: 4),
          Text(
            'Chạm vào mèo để thăm linh thú ✦',
            style: TextStyle(
              color: context.mutedText,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('✦ ', style: TextStyle(color: RelaxColors.violet)),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: context.appText,
            ),
          ),
        ),
        const Text(' ✦', style: TextStyle(color: RelaxColors.violet)),
      ],
    );
  }

  Widget _moodGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: _moodOptions.map((o) {
        final mood = o['mood'] as String;
        final label = (o['shortLabel'] as String?) ?? (o['label'] as String?) ?? mood;
        final saving = _savingMood == mood;
        return GestureDetector(
          onTap: saving ? null : () => _logMood(mood, label),
          child: Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.fieldBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_moodEmoji(mood), style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 6),
                saving
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: RelaxColors.violet),
                      )
                    : Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: context.appText,
                        ),
                      ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _trackingCard(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Theo dõi cảm xúc của $name',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: context.appText,
                  ),
                ),
              ),
              const Icon(Icons.bar_chart, color: RelaxColors.violet, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          if (_moodOptions.isEmpty)
            Text('Chưa có dữ liệu cảm xúc.',
                style: TextStyle(color: context.mutedText, fontSize: 12))
          else
            ..._moodOptions.map((o) {
              final mood = o['mood'] as String;
              final label = (o['label'] as String?) ?? mood;
              final pct = _moodTotal == 0
                  ? 0.0
                  : (_moodCounts[mood] ?? 0) / _moodTotal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 12, color: context.appText),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: context.surfaceAlt,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _moodColor(mood),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 38,
                      child: Text(
                        '${(pct * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: context.appText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _methodsCard(BuildContext context, String name) {
    final methods = [
      ('Thiền định', Icons.self_improvement, '/meditation'),
      ('Hít thở', Icons.air, '/breathing'),
      ('Nhật ký', Icons.edit_note, '/journal'),
      ('Nhạc', Icons.headphones, '/sounds'),
      ('Podcast', Icons.mic_none, '/podcast'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phương thức phù hợp cho $name',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: methods.map((m) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push(m.$3);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: context.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.fieldBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(m.$2, color: RelaxColors.violet),
                        const SizedBox(height: 6),
                        Text(
                          m.$1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: context.appText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'HAPPY':
        return '😺';
      case 'SAD':
        return '😿';
      case 'STRESSED':
        return '🙀';
      case 'TIRED':
        return '😾';
      case 'ANXIOUS':
        return '😼';
      case 'NEUTRAL':
        return '😐';
      case 'CALM':
        return '😌';
      case 'EXCITED':
        return '😸';
      case 'LONELY':
        return '🐱';
      case 'GRATEFUL':
        return '😻';
      default:
        return '🐱';
    }
  }

  Color _moodColor(String mood) {
    switch (mood) {
      case 'HAPPY':
      case 'GRATEFUL':
        return RelaxColors.sun;
      case 'STRESSED':
      case 'ANXIOUS':
        return RelaxColors.coral;
      case 'CALM':
      case 'EXCITED':
        return RelaxColors.mint;
      default:
        return RelaxColors.violet;
    }
  }
}
