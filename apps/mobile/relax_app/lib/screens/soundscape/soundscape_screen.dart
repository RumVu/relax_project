import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

/// Adaptive Soundscape — layer multiple ambient sounds with individual volume.
class SoundscapeScreen extends StatefulWidget {
  const SoundscapeScreen({super.key, this.preset});
  final String? preset;

  @override
  State<SoundscapeScreen> createState() => _SoundscapeScreenState();
}

class _SoundscapeScreenState extends State<SoundscapeScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _sounds = [];
  final Map<String, double> _volumes = {};
  final Map<String, bool> _active = {};
  final Map<String, AudioPlayer> _players = {};

  Timer? _localSleepTimer;
  int _sleepTimeRemaining = 0; // seconds

  // ── Mood presets ───────────────────────────────────────────────────
  // Each preset maps a display name to a list of (category, volume) pairs.
  static const _moodPresets = <String, Map<String, double>>{
    'Lo âu': {'RAIN': 0.6, 'MUSIC': 0.4},
    'Căng thẳng': {'WHITE_NOISE': 0.5, 'AMBIENT': 0.5},
    'U sầu': {'MUSIC': 0.6, 'AMBIENT': 0.4},
    'Mệt mỏi': {'NATURE': 0.6, 'OCEAN': 0.3},
    'Tập trung': {'WHITE_NOISE': 0.4, 'MUSIC': 0.5},
    'Buồn ngủ': {'OCEAN': 0.7, 'RAIN': 0.3},
  };

  static const _presetEmoji = <String, String>{
    'Lo âu': '😰',
    'Căng thẳng': '🤯',
    'U sầu': '😢',
    'Mệt mỏi': '🥱',
    'Tập trung': '🎯',
    'Buồn ngủ': '😴',
  };

  static const _categoryEmoji = <String, String>{
    'RAIN': '🌧️',
    'NATURE': '🌿',
    'NATURE_BIRDS': '🐦',
    'OCEAN': '🌊',
    'AMBIENT': '✨',
    'WHITE_NOISE': '📻',
    'CAFE': '☕',
    'MUSIC': '🎵',
    'MEDITATION': '🧘',
    'SLEEP': '🌙',
    'PODCAST': '🎙️',
  };

  String? _activePreset;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _localSleepTimer?.cancel();
    for (final p in _players.values) {
      p.dispose();
    }
    super.dispose();
  }

  void _startSleepTimer(int minutes) {
    _localSleepTimer?.cancel();
    setState(() {
      _sleepTimeRemaining = minutes * 60;
    });
    _localSleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_sleepTimeRemaining <= 1) {
        _stopAllSounds();
        _localSleepTimer?.cancel();
        setState(() {
          _localSleepTimer = null;
          _sleepTimeRemaining = 0;
        });
        showSoftToast(context, message: context.t('Hết giờ! Đã tắt nhạc tự động 🌙'), tone: SoftToastTone.success);
      } else {
        setState(() {
          _sleepTimeRemaining--;
        });
      }
    });
  }

  void _stopAllSounds() {
    for (final id in _active.keys.toList()) {
      if (_active[id] == true) _stopSound(id);
    }
    setState(() {
      _active.clear();
      _volumes.clear();
      _activePreset = null;
    });
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
    if (mounted) {
      setState(() {
        _loading = false;
        if (widget.preset != null) {
          _applyPreset(widget.preset!);
        }
      });
    }
  }

  // ── Audio helpers ──────────────────────────────────────────────────

  AudioPlayer _playerFor(String id) {
    return _players.putIfAbsent(id, () => AudioPlayer());
  }

  Future<void> _startSound(String id) async {
    final sound = _sounds.firstWhere((s) => s['id'] == id,
        orElse: () => <String, dynamic>{});
    final url = sound['soundUrl'] as String?;
    if (url == null || url.isEmpty) return;

    final player = _playerFor(id);
    try {
      await player.setUrl(url);
      await player.setLoopMode(LoopMode.all);
      await player.setVolume(_volumes[id] ?? 0.5);
      player.play();
    } catch (_) {
      // Audio might not be reachable – the UI toggles still work.
    }
  }

  Future<void> _stopSound(String id) async {
    final player = _players[id];
    if (player != null) {
      await player.stop();
    }
  }

  void _setVolume(String id, double vol) {
    setState(() => _volumes[id] = vol);
    _players[id]?.setVolume(vol);
  }

  void _toggle(String id, bool on) {
    HapticFeedback.selectionClick();
    setState(() {
      _active[id] = on;
      _activePreset = null;
      if (on && !_volumes.containsKey(id)) {
        _volumes[id] = 0.5;
      }
    });
    if (on) {
      _startSound(id);
    } else {
      _stopSound(id);
    }
  }

  void _applyPreset(String presetName) {
    final categoryVolumes = _moodPresets[presetName] ?? {};
    HapticFeedback.mediumImpact();

    // Stop all currently playing sounds.
    for (final id in _active.keys.toList()) {
      if (_active[id] == true) _stopSound(id);
    }

    setState(() {
      _active.clear();
      _volumes.clear();
      _activePreset = presetName;

      for (final sound in _sounds) {
        final id = sound['id'] as String? ?? '';
        final cat = sound['category'] as String? ?? '';
        final vol = categoryVolumes[cat];
        if (vol != null) {
          _active[id] = true;
          _volumes[id] = vol;
        }
      }
    });

    // Start the newly activated sounds.
    for (final id in _active.keys) {
      if (_active[id] == true) _startSound(id);
    }
  }

  int get _activeCount => _active.values.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    final isPlaying = _activeCount > 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () {
            // Stop all sounds when leaving.
            for (final id in _active.keys) {
              if (_active[id] == true) _stopSound(id);
            }
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
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
          : Container(
              decoration: isPlaying
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          RelaxColors.violet.withValues(alpha: 0.05),
                          Theme.of(context)
                              .scaffoldBackgroundColor,
                        ],
                      ),
                    )
                  : null,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  // ── Playing counter ────────────────────────
                  if (isPlaying) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: RelaxColors.mint.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.graphic_eq,
                              color: RelaxColors.mint, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            context.t('Đang phát {n} âm thanh',
                                {'n': _activeCount.toString()}),
                            style: const TextStyle(
                              color: RelaxColors.mint,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Mood presets ───────────────────────────
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
                        final isSelected = _activePreset == name;
                        final emoji = _presetEmoji[name] ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _applyPreset(name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          RelaxColors.violet,
                                          RelaxColors.plum
                                        ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : context.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? null
                                    : Border.all(color: context.fieldBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(emoji,
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.t(name),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : context.appText,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
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
                        context.t('Hẹn giờ ngủ'),
                        style: TextStyle(
                          color: context.appText,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_localSleepTimer != null)
                        Text(
                          '(${_sleepTimeRemaining ~/ 60}:${(_sleepTimeRemaining % 60).toString().padLeft(2, '0')})',
                          style: const TextStyle(
                            color: RelaxColors.violet,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      const Spacer(),
                      DropdownButton<int>(
                        value: _localSleepTimer == null ? null : (_sleepTimeRemaining > 1800 ? 60 : (_sleepTimeRemaining > 900 ? 30 : 15)),
                        hint: Text(context.t('Tắt')),
                        underline: const SizedBox(),
                        style: TextStyle(color: context.appText, fontSize: 13),
                        onChanged: (val) {
                          if (val == null) {
                            _localSleepTimer?.cancel();
                            setState(() {
                              _localSleepTimer = null;
                              _sleepTimeRemaining = 0;
                            });
                          } else {
                            _startSleepTimer(val);
                          }
                        },
                        items: [
                          DropdownMenuItem<int>(value: 15, child: Text('15 ${context.t("phút")}')),
                          DropdownMenuItem<int>(value: 30, child: Text('30 ${context.t("phút")}')),
                          DropdownMenuItem<int>(value: 60, child: Text('60 ${context.t("phút")}')),
                        ],
                      ),
                    ],
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
                      if (isPlaying)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            for (final id in _active.keys.toList()) {
                              if (_active[id] == true) _stopSound(id);
                            }
                            setState(() {
                              _active.clear();
                              _volumes.clear();
                              _activePreset = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  RelaxColors.coral.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              context.t('Tắt hết'),
                              style: const TextStyle(
                                color: RelaxColors.coral,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Sound grid ─────────────────────────────
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
                              Text(emoji,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                onChanged: (val) => _toggle(id, val),
                              ),
                            ],
                          ),
                          if (isActive)
                            Row(
                              children: [
                                Icon(Icons.volume_down,
                                    color: context.mutedText, size: 16),
                                Expanded(
                                  child: Slider(
                                    value: volume,
                                    min: 0.0,
                                    max: 1.0,
                                    onChanged: (v) => _setVolume(id, v),
                                    activeColor: RelaxColors.violet,
                                    inactiveColor: context.fieldBorder,
                                  ),
                                ),
                                Icon(Icons.volume_up,
                                    color: context.mutedText, size: 16),
                              ],
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
