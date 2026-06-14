import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api_client.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

/// Burnout Signal Widget - Hiển thị banner cảnh báo wellbeing khi phát hiện stress tích tụ.
class BurnoutSignalWidget extends StatefulWidget {
  const BurnoutSignalWidget({super.key});

  @override
  State<BurnoutSignalWidget> createState() => _BurnoutSignalWidgetState();
}

class _BurnoutSignalWidgetState extends State<BurnoutSignalWidget> {
  bool _loading = true;
  Map<String, dynamic>? _signal;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await RelaxApi.instance.get('/analytics/me/burnout-signal');
      if (res.data is Map && res.data['hasSignal'] == true) {
        setState(() {
          _signal = res.data as Map<String, dynamic>;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Color _getBannerColor(String level) {
    switch (level) {
      case 'SEVERE':
        return RelaxColors.coral.withValues(alpha: 0.12);
      case 'MODERATE':
        return Colors.orange.withValues(alpha: 0.12);
      case 'LIGHT':
      default:
        return RelaxColors.violet.withValues(alpha: 0.12);
    }
  }

  Color _getTextColor(String level) {
    switch (level) {
      case 'SEVERE':
        return RelaxColors.coral;
      case 'MODERATE':
        return Colors.orange[800]!;
      case 'LIGHT':
      default:
        return RelaxColors.violet;
    }
  }

  IconData _getIcon(String level) {
    switch (level) {
      case 'SEVERE':
        return Icons.gpp_bad_outlined;
      case 'MODERATE':
        return Icons.warning_amber_rounded;
      case 'LIGHT':
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _signal == null) return const SizedBox.shrink();

    final level = _signal!['level'] as String? ?? 'LIGHT';
    final message = _signal!['message'] as String? ?? '';
    final bannerColor = _getBannerColor(level);
    final textColor = _getTextColor(level);
    final icon = _getIcon(level);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t(level == 'SEVERE' ? 'BÁO ĐỘNG QUÁ TẢI' : level == 'MODERATE' ? 'CẢNH BÁO WELLBEING' : 'NHẮC NHỞ WELLBEING'),
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.t(message),
                  style: TextStyle(
                    color: context.appText,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.push('/breathing');
                  },
                  icon: Icon(Icons.spa_outlined, color: textColor, size: 16),
                  label: Text(
                    context.t('Thư giãn ngay ➜'),
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

/// Mood Toolkit Widget - Hiển thị bộ công cụ xoa dịu nhanh cho mood hiện tại.
class MoodToolkitWidget extends StatefulWidget {
  const MoodToolkitWidget({super.key});

  @override
  State<MoodToolkitWidget> createState() => _MoodToolkitWidgetState();
}

class _MoodToolkitWidgetState extends State<MoodToolkitWidget> {
  bool _loading = true;
  Map<String, dynamic>? _toolkit;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await RelaxApi.instance.get('/recommendations/toolkit');
      if (res.data is Map) {
        setState(() {
          _toolkit = res.data as Map<String, dynamic>;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _handleDeepLink(BuildContext context, String deepLink) {
    if (deepLink.startsWith('relax://')) {
      final path = deepLink.replaceAll('relax://', '/');
      var finalPath = path;

      if (path == '/breathing-exercises') {
        finalPath = '/breathing';
      } else if (path.startsWith('/ambient-sounds')) {
        finalPath = path.replaceAll('/ambient-sounds', '/soundscape');
      } else if (path == '/journals/new') {
        finalPath = '/journal';
      }

      context.push(finalPath);
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'BREATHING':
        return Icons.spa_outlined;
      case 'MUSIC':
        return Icons.music_note_outlined;
      case 'MEDITATION':
        return Icons.self_improvement_outlined;
      case 'JOURNAL':
        return Icons.edit_note_outlined;
      case 'COMPANION':
        return Icons.pets_outlined;
      case 'BUDDY':
        return Icons.people_outline;
      case 'QUOTE':
      default:
        return Icons.format_quote_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _toolkit == null) return const SizedBox.shrink();

    final title = _toolkit!['title'] as String? ?? 'Mood Toolkit';
    final description = _toolkit!['description'] as String? ?? '';
    final activities = _toolkit!['activities'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.build_circle_outlined, color: RelaxColors.violet, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.t(title),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.appText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RelaxColors.violet.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.t('Gợi ý'),
                  style: const TextStyle(
                    color: RelaxColors.violet,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.t(description),
            style: TextStyle(
              color: context.mutedText,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: activities.map<Widget>((act) {
              final type = act['type'] as String? ?? '';
              final actTitle = act['title'] as String? ?? '';
              final deepLink = act['deepLink'] as String? ?? '';
              final icon = _getActivityIcon(type);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _handleDeepLink(context, deepLink);
                    },
                    icon: Icon(icon, size: 16),
                    label: Text(
                      context.t(actTitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RelaxColors.violet,
                      side: const BorderSide(color: RelaxColors.violet),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
}
