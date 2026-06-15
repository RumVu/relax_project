import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';
import 'widgets/active_session_view.dart';
import 'widgets/guide_card.dart';

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
        _guides = (res.data as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
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
        setState(() => _secondsRemaining--);
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
    final actualDurationMinutes =
        ((_totalDurationSeconds - _secondsRemaining) / 60).ceil().clamp(1, 60);

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
        showSoftToast(context,
            message: context.t('Chúc mừng bạn đã hoàn thành bài thiền!'),
            tone: SoftToastTone.success);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: e.toString(), tone: SoftToastTone.error);
      }
    }
  }

  void _togglePlay() {
    if (_isPlaying) {
      _timer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      if (_activeGuide != null) _startMeditation(_activeGuide!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeGuide != null) {
      return ActiveSessionView(
        guide: _activeGuide!,
        secondsRemaining: _secondsRemaining,
        totalDurationSeconds: _totalDurationSeconds,
        isPlaying: _isPlaying,
        onTogglePlay: _togglePlay,
        onStop: _finishMeditation,
      );
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
          style:
              TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(color: RelaxColors.violet))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!,
                            style: const TextStyle(
                                color: RelaxColors.coral)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _loadGuides,
                            child: Text(context.t('Thử lại'))),
                      ],
                    ),
                  )
                : _guides.isEmpty
                    ? Center(
                        child: Text(
                          context.t('Không có bài thiền nào khả dụng.'),
                          style: TextStyle(
                              color: context.mutedText, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _guides.length,
                        itemBuilder: (context, i) => GuideCard(
                          guide: _guides[i],
                          onStart: () => _startMeditation(_guides[i]),
                        ),
                      ),
      ),
    );
  }
}
