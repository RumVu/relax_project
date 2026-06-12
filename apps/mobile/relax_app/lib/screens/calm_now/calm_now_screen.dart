import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import 'widgets/calm_breathing.dart';
import 'widgets/calm_grounding.dart';
import 'widgets/calm_mood_picker.dart';
import 'widgets/calm_result.dart';

/// "Calm Now" — nút thoát hiểm cảm xúc.
///
/// Flow:
///   1. Chọn cảm xúc hiện tại (Stressed / Angry / Sad / Tired / Anxious / Overwhelmed)
///   2. App gợi ý hoạt động phù hợp (breathing 60s / grounding 3 phút / sound / journal)
///   3. Thực hiện hoạt động ngay trong screen
///   4. Hỏi lại "Đỡ hơn chưa?" + ghi mood after
///
/// Tất cả diễn ra TRONG 1 screen — không navigate đi đâu cả.
/// User cần 1 nút bấm, không cần suy nghĩ.
class CalmNowScreen extends StatefulWidget {
  const CalmNowScreen({super.key});

  @override
  State<CalmNowScreen> createState() => _CalmNowScreenState();
}

enum _CalmPhase { pickMood, activity, result }

class _CalmNowScreenState extends State<CalmNowScreen>
    with TickerProviderStateMixin {
  _CalmPhase _phase = _CalmPhase.pickMood;
  String? _selectedMood;
  String? _activityType; // 'breathing' | 'grounding' | 'sound' | 'journal'
  String? _sessionId;

  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  /// Chuyển phase với fade transition mượt.
  Future<void> _transitionTo(_CalmPhase next) async {
    await _fadeCtrl.animateTo(0.0,
        duration: const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _phase = next);
    await _fadeCtrl.animateTo(1.0,
        duration: const Duration(milliseconds: 300));
  }

  /// Khi user chọn mood → quyết định activity phù hợp.
  void _onMoodSelected(String mood) {
    HapticFeedback.mediumImpact();
    _selectedMood = mood;

    // Map mood → activity type phù hợp nhất.
    switch (mood) {
      case 'STRESSED':
      case 'ANXIOUS':
        _activityType = 'breathing';
        break;
      case 'ANGRY':
      case 'OVERWHELMED':
        _activityType = 'grounding';
        break;
      case 'SAD':
        _activityType = 'breathing'; // nhẹ nhàng hơn grounding
        break;
      case 'TIRED':
        _activityType = 'breathing';
        break;
      default:
        _activityType = 'breathing';
    }

    // Start relax session trên backend.
    final auth = context.read<AuthState>();
    auth
        .startRelaxSession('CALM_NOW', 'Calm Now — $mood')
        .then((id) => _sessionId = id);

    // Log mood before.
    _logMoodBefore(mood);

    _transitionTo(_CalmPhase.activity);
  }

  Future<void> _logMoodBefore(String mood) async {
    try {
      await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': mood,
        'intensity': 4,
        'tags': ['calm_now', 'before'],
      });
    } catch (_) {}
  }

  void _onActivityDone() {
    HapticFeedback.lightImpact();
    _transitionTo(_CalmPhase.result);
  }

  /// User đánh giá "đỡ hơn chưa" rồi đóng.
  Future<void> _onResult(String moodAfter, int reliefLevel) async {
    // Finish session.
    if (_sessionId != null) {
      final auth = context.read<AuthState>();
      await auth.finishRelaxSession(
        _sessionId!,
        moodAfter: moodAfter,
        reliefLevel: reliefLevel,
      );
    }

    // Log mood after.
    try {
      await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': moodAfter,
        'intensity': reliefLevel,
        'tags': ['calm_now', 'after'],
      });
    } catch (_) {}

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.8)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Calm Now'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeCtrl,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_phase),
                child: _buildPhase(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case _CalmPhase.pickMood:
        return CalmMoodPicker(onSelect: _onMoodSelected);
      case _CalmPhase.activity:
        if (_activityType == 'grounding') {
          return CalmGrounding(onDone: _onActivityDone);
        }
        return CalmBreathing(onDone: _onActivityDone);
      case _CalmPhase.result:
        return CalmResult(
          moodBefore: _selectedMood ?? 'STRESSED',
          onSubmit: _onResult,
        );
    }
  }

  Color get _bgColor {
    switch (_phase) {
      case _CalmPhase.pickMood:
        return const Color(0xFF1a1030);
      case _CalmPhase.activity:
        return const Color(0xFF0f1a2e);
      case _CalmPhase.result:
        return const Color(0xFF152030);
    }
  }

  List<Color> get _gradientColors {
    switch (_phase) {
      case _CalmPhase.pickMood:
        return const [Color(0xFF1a1030), Color(0xFF2d1b69)];
      case _CalmPhase.activity:
        return const [Color(0xFF0f1a2e), Color(0xFF1a2d5e)];
      case _CalmPhase.result:
        return const [Color(0xFF152030), Color(0xFF1e3a5f)];
    }
  }
}
