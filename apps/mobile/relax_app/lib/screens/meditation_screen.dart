import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../core/locale_controller.dart';
import '../core/theme.dart';
import '../widgets/soft_toast.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  List<Map<String, dynamic>> _guides = [];
  bool _loading = true;
  String? _error;

  // Active Session state
  Map<String, dynamic>? _activeGuide;
  bool _isPlaying = false;
  int _secondsRemaining = 0;
  int _totalDurationSeconds = 0;
  Timer? _timer;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadGuides() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await RelaxApi.instance.get('/meditations/guides');
      if (res.data is List) {
        _guides = (res.data as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  void _startMeditation(Map<String, dynamic> guide) {
    _timer?.cancel();
    final durationMinutes = (guide['duration'] as num?)?.toInt() ?? 10;
    _totalDurationSeconds = durationMinutes * 60;
    _startedAt = DateTime.now();

    setState(() {
      _activeGuide = guide;
      _secondsRemaining = _totalDurationSeconds;
      _isPlaying = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _finishMeditation();
      }
    });
  }

  Future<void> _finishMeditation() async {
    _timer?.cancel();
    if (_activeGuide == null || _startedAt == null) return;

    final guide = _activeGuide!;
    final startedStr = _startedAt!.toUtc().toIso8601String();
    final endedStr = DateTime.now().toUtc().toIso8601String();
    final actualDurationMinutes = ((_totalDurationSeconds - _secondsRemaining) / 60).ceil().clamp(1, 60);

    setState(() {
      _isPlaying = false;
      _activeGuide = null;
    });

    try {
      await RelaxApi.instance.post(
        '/meditations/sessions',
        body: {
          'guideId': guide['id'] as String,
          'duration': actualDurationMinutes,
          'startedAt': startedStr,
          'endedAt': endedStr,
          'focusArea': guide['focusArea'] as String?,
          'mood': 'CALM',
          'quality': 8,
          'notes': 'Hoàn thành bài thiền di động.',
        },
      );
      if (mounted) {
        showSoftToast(context, message: context.t('Chúc mừng bạn đã hoàn thành bài thiền!'), tone: SoftToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context, message: e.toString(), tone: SoftToastTone.error);
      }
    }
  }

  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_activeGuide != null) {
      return _buildActiveSessionView();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Thiền định có hướng dẫn'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, style: const TextStyle(color: RelaxColors.coral)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _loadGuides, child: Text(context.t('Thử lại'))),
                      ],
                    ),
                  )
                : _guides.isEmpty
                    ? Center(
                        child: Text(
                          context.t('Không có bài thiền nào khả dụng.'),
                          style: TextStyle(color: context.mutedText, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _guides.length,
                        itemBuilder: (context, i) {
                          final g = _guides[i];
                          final title = g['title'] as String? ?? '';
                          final desc = g['description'] as String? ?? '';
                          final minutes = g['duration'] as num? ?? 10;
                          final instructor = g['instructor'] as String? ?? 'Chưa rõ';
                          final area = g['focusArea'] as String? ?? 'Mindfulness';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            color: context.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(color: context.fieldBorder),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: RelaxColors.violet.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.spa, color: RelaxColors.violet),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: context.appText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          desc,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: context.mutedText, fontSize: 11),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${context.t('Instructor:')} $instructor · $area · $minutes ${context.t('phút')}',
                                          style: TextStyle(color: context.mutedText, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: RelaxColors.violet,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      _startMeditation(g);
                                    },
                                    child: Text(
                                      context.t('Bắt đầu'),
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildActiveSessionView() {
    final title = _activeGuide?['title'] as String? ?? '';
    final progress = 1.0 - (_secondsRemaining / _totalDurationSeconds);

    return Scaffold(
      backgroundColor: RelaxColors.violet,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.t('Thiền định có hướng dẫn'),
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 60),
              // Breathing visual circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text(
                    _formatDuration(_secondsRemaining),
                    style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              const Text(
                'Hít vào... thở ra nhẹ nhàng...',
                style: TextStyle(color: Colors.white70, fontSize: 15, fontStyle: FontStyle.italic),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 64, color: Colors.white),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (_isPlaying) {
                        _timer?.cancel();
                        setState(() => _isPlaying = false);
                      } else {
                        _startMeditation(_activeGuide!);
                      }
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.stop_circle_outlined, size: 64, color: Colors.white70),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _finishMeditation();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
