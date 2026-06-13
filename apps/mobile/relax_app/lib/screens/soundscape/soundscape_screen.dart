import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';

/// Adaptive Soundscape — layer multiple ambient sounds with individual volume.
class SoundscapeScreen extends StatefulWidget {
  const SoundscapeScreen({super.key});

  @override
  State<SoundscapeScreen> createState() => _SoundscapeScreenState();
}

class _SoundscapeScreenState extends State<SoundscapeScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _sounds = [];
  final Map<String, double> _volumes = {};
  final Map<String, bool> _active = {};

  static const _moodPresets = <String, List<String>>{
    'Thư giãn': ['RAIN', 'NATURE', 'AMBIENT'],
    'Tập trung': ['WHITE_NOISE', 'CAFE', 'AMBIENT'],
    'Ngủ sâu': ['RAIN', 'OCEAN', 'NATURE'],
    'Năng lượng': ['CAFE', 'MUSIC', 'NATURE'],
  };

  static const _categoryEmoji = <String, String>{
    'RAIN': '🌧️',
    'NATURE': '🌿',
    'OCEAN': '🌊',
    'AMBIENT': '✨',
    'WHITE_NOISE': '📻',
    'CAFE': '☕',
    'MUSIC': '🎵',
    'MEDITATION': '🧘',
    'SLEEP': '🌙',
    'PODCAST': '🎙️',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await RelaxApi.instance.get('/ambient-sounds?limit=50');
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      _sounds = (items is List)
          ? items
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  void _applyPreset(String presetName) {
    final categories = _moodPresets[presetName] ?? [];
    HapticFeedback.mediumImpact();
    setState(() {
      _active.clear();
      _volumes.clear();
      for (final sound in _sounds) {
        final id = sound['id'] as String? ?? '';
        final cat = sound['category'] as String? ?? '';
        if (categories.contains(cat)) {
          _active[id] = true;
          _volumes[id] = 0.6;
        }
      }
    });
  }

  int get _activeCount => _active.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () {
            if (context.canPop()) context.pop();
            else context.go('/home');
          },
        ),
        title: Text(
          context.t('Soundscape'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: RelaxColors.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(
                  context.t('Mood Presets'),
                  style: TextStyle(
                    color: context.appText,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _moodPresets.keys.map((name) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _applyPreset(name),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [RelaxColors.violet, RelaxColors.plum],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              context.t(name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      context.t('Âm thanh'),
                      style: TextStyle(
                        color: context.appText,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (_activeCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: RelaxColors.mint.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_activeCount ${context.t('đang phát')}',
                          style: const TextStyle(
                            color: RelaxColors.mint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._sounds.map((sound) {
                  final id = sound['id'] as String? ?? '';
                  final title = sound['title'] as String? ?? '';
                  final cat = sound['category'] as String? ?? '';
                  final isActive = _active[id] == true;
                  final volume = _volumes[id] ?? 0.5;
                  final emoji = _categoryEmoji[cat] ?? '🎵';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? RelaxColors.violet.withValues(alpha: 0.06)
                          : context.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? RelaxColors.violet.withValues(alpha: 0.3)
                            : context.fieldBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      color: context.appText,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      color: context.mutedText,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: isActive,
                              activeTrackColor: RelaxColors.violet,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _active[id] = val;
                                  if (val && !_volumes.containsKey(id)) {
                                    _volumes[id] = 0.5;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        if (isActive)
                          Slider(
                            value: volume,
                            onChanged: (v) =>
                                setState(() => _volumes[id] = v),
                            activeColor: RelaxColors.violet,
                            inactiveColor: context.fieldBorder,
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
