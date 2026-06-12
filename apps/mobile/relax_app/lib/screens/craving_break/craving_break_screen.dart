import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import 'widgets/break_reason_picker.dart';
import 'widgets/break_ritual.dart';
import 'widgets/break_complete.dart';

/// "I Need a Break" — Digital Cigarette Break.
///
/// Flow signature:
///   1. Chọn lý do cần nghỉ (stress, buồn ngủ, chán, overthink, craving, né xã hội)
///   2. Ritual 3-5 phút: breathing + ambient + quote + mini journal
///   3. Kết thúc: "Bạn đã vượt qua 1 break 🌿" + mood after
///
/// Đây là identity feature — "Digital Cigarette Break".
class CravingBreakScreen extends StatefulWidget {
  const CravingBreakScreen({super.key});

  @override
  State<CravingBreakScreen> createState() => _CravingBreakScreenState();
}

enum _BreakPhase { reason, ritual, complete }

class _CravingBreakScreenState extends State<CravingBreakScreen>
    with TickerProviderStateMixin {
  _BreakPhase _phase = _BreakPhase.reason;
  String? _reason;
  String? _sessionId;
  DateTime? _startTime;

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

  Future<void> _transitionTo(_BreakPhase next) async {
    await _fadeCtrl.animateTo(0.0,
        duration: const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _phase = next);
    await _fadeCtrl.animateTo(1.0,
        duration: const Duration(milliseconds: 300));
  }

  void _onReasonSelected(String reason) {
    HapticFeedback.mediumImpact();
    _reason = reason;
    _startTime = DateTime.now();

    // Start session.
    final auth = context.read<AuthState>();
    auth
        .startRelaxSession('CRAVING_BREAK', 'Break — $reason')
        .then((id) => _sessionId = id);

    // Log mood before.
    _logMood(reason, ['craving_break', 'before']);

    _transitionTo(_BreakPhase.ritual);
  }

  Future<void> _logMood(String mood, List<String> tags) async {
    // Map reason → closest mood code.
    final moodCode = _reasonToMood(mood);
    try {
      await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': moodCode,
        'intensity': 4,
        'tags': tags,
      });
    } catch (_) {}
  }

  String _reasonToMood(String reason) {
    switch (reason) {
      case 'STRESS':
        return 'STRESSED';
      case 'SLEEPY':
        return 'TIRED';
      case 'BORED':
        return 'NEUTRAL';
      case 'OVERTHINKING':
        return 'ANXIOUS';
      case 'CRAVING':
        return 'STRESSED';
      case 'SOCIAL_ESCAPE':
        return 'STRESSED';
      default:
        return 'NEUTRAL';
    }
  }

  void _onRitualDone() {
    HapticFeedback.lightImpact();
    _transitionTo(_BreakPhase.complete);
  }

  Future<void> _onComplete(String moodAfter, int relief) async {
    // Finish session.
    if (_sessionId != null) {
      final auth = context.read<AuthState>();
      await auth.finishRelaxSession(
        _sessionId!,
        moodAfter: moodAfter,
        reliefLevel: relief,
      );
    }

    // Log mood after.
    try {
      await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': moodAfter,
        'intensity': relief,
        'tags': ['craving_break', 'after'],
      });
    } catch (_) {}

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1117),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.7)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('I Need a Break'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0d1117), Color(0xFF161b22), Color(0xFF1a2332)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
      case _BreakPhase.reason:
        return BreakReasonPicker(onSelect: _onReasonSelected);
      case _BreakPhase.ritual:
        return BreakRitual(
          reason: _reason ?? 'STRESS',
          onDone: _onRitualDone,
        );
      case _BreakPhase.complete:
        final duration = _startTime != null
            ? DateTime.now().difference(_startTime!)
            : const Duration(minutes: 3);
        return BreakComplete(
          reason: _reason ?? 'STRESS',
          duration: duration,
          onSubmit: _onComplete,
        );
    }
  }
}
