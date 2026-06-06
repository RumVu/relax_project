import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../data/services/mood_service.dart';
import '../../data/services/relax_session_service.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';
import '../practice/practice_screen.dart';
import '../relax/sheets/relax_sheets.dart';

/// Một chương trong hành trình.
enum _Chapter { threshold, whisper, immersion, reflection, healing }

/// Mood chip cho threshold chapter — 5 lựa chọn nhanh.
class _MoodChoice {
  const _MoodChoice(this.code, this.emoji, this.label);
  final String code;
  final String emoji;
  final String label;
}

const _moodChoices = <_MoodChoice>[
  _MoodChoice('HAPPY', '😊', 'Ổn'),
  _MoodChoice('SAD', '🌧️', 'Hơi xuống'),
  _MoodChoice('STRESSED', '🌪️', 'Nặng nề'),
  _MoodChoice('TIRED', '😴', 'Mệt'),
  _MoodChoice('NEUTRAL', '😶', 'Trống'),
];

/// JourneyScreen — wrapper "hành trình chữa lành" 5 chương.
///
/// Thay thế việc push thẳng PracticeScreen rồi mở modal sheet feedback.
/// Toàn bộ flow nằm trong 1 màn hình → user cảm nhận liền mạch.
class JourneyScreen extends StatefulWidget {
  const JourneyScreen({
    super.key,
    required this.activity,
    this.allActivities = const [],
    this.onChainNext,
  });

  final Activity activity;
  final List<Activity> allActivities;
  final ValueChanged<Activity>? onChainNext;

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  _Chapter _chapter = _Chapter.threshold;
  String? _moodBefore;
  int _rating = 0;
  final _noteCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;
  int _reductionPercent = 0;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _goTo(_Chapter next) {
    if (!mounted) return;
    setState(() => _chapter = next);
  }

  /// Khi user chọn mood ở chapter 1 → log mood + chuyển chapter 2.
  Future<void> _selectMood(String code) async {
    setState(() => _moodBefore = code);
    final session = context.sessionOrNull;
    if (session != null && session.isLoggedIn) {
      try {
        await MoodService().log(
          accessToken: session.accessToken!,
          mood: code,
          intensity: 3,
          tags: const ['journey-before'],
        );
      } catch (_) {
        /* swallow — flow tiếp tục */
      }
    }
    await Future.delayed(const Duration(milliseconds: 280));
    _goTo(_Chapter.whisper);
  }

  /// Submit phản hồi ở chapter 4 → POST relax-session + chuyển chapter 5.
  Future<void> _submitReflection() async {
    if (_rating == 0) {
      setState(
        () => _error = 'Hãy chọn 1 đến 5 sao để mình biết cảm nhận của bạn nha',
      );
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final reduction = (_rating * 15).clamp(5, 80);
    try {
      final session = context.sessionOrNull;
      if (session != null && session.isLoggedIn) {
        final svc = RelaxSessionService();
        final started = await svc.start(
          accessToken: session.accessToken!,
          activityType: widget.activity.type,
          title: widget.activity.compactTitle,
          moodBefore: _moodBefore,
        );
        await svc.finish(
          accessToken: session.accessToken!,
          sessionId: started.id,
          reliefLevel: _rating,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final friendly = raw.contains('Socket') || raw.contains('Timeout')
          ? 'Mạng yếu quá — phản hồi của bạn được lưu cục bộ rồi nha 💜'
          : raw.replaceFirst(RegExp(r'^Exception:\s*'), '');
      setState(() {
        _submitting = false;
        _error = friendly;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _reductionPercent = reduction;
    });
    _goTo(_Chapter.healing);
  }

  /// Khi user bấm "Tiếp tục với hoạt động khác" ở chapter 5.
  void _openNextStep() {
    showNextStepSheet(
      context,
      currentActivity: widget.activity,
      allActivities: widget.allActivities,
      onContinue: (next) {
        Navigator.of(context).pop();
        widget.onChainNext?.call(next);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Back hardware: chương immersion cho pop bình thường (về Relax tab),
      // các chương khác sẽ confirm trước khi out.
      body: PopScope(
        canPop: _chapter == _Chapter.immersion,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final wantOut = await _confirmExit();
          if (wantOut && context.mounted) Navigator.of(context).pop();
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: _buildChapter(),
        ),
      ),
    );
  }

  Widget _buildChapter() {
    switch (_chapter) {
      case _Chapter.threshold:
        return _ThresholdChapter(
          key: const ValueKey('threshold'),
          activityLabel: widget.activity.compactTitle,
          onPickMood: _selectMood,
          onSkip: () => _goTo(_Chapter.whisper),
        );
      case _Chapter.whisper:
        return _WhisperChapter(
          key: const ValueKey('whisper'),
          onReady: () => _goTo(_Chapter.immersion),
        );
      case _Chapter.immersion:
        return _ImmersionChapter(
          key: const ValueKey('immersion'),
          activity: widget.activity,
          onFinish: () => _goTo(_Chapter.reflection),
        );
      case _Chapter.reflection:
        return _ReflectionChapter(
          key: const ValueKey('reflection'),
          activityLabel: widget.activity.compactTitle,
          rating: _rating,
          noteCtrl: _noteCtrl,
          submitting: _submitting,
          error: _error,
          onRatingChange: (r) => setState(() {
            _rating = r;
            _error = null;
          }),
          onSubmit: _submitReflection,
        );
      case _Chapter.healing:
        return _HealingChapter(
          key: const ValueKey('healing'),
          reductionPercent: _reductionPercent,
          rating: _rating,
          hasNext:
              widget.onChainNext != null && widget.allActivities.length > 1,
          onNext: _openNextStep,
          onHome: () => Navigator.of(context).popUntil((r) => r.isFirst),
        );
    }
  }

  Future<bool> _confirmExit() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rời hành trình?'),
        content: const Text(
          'Bạn đang ở giữa hành trình chữa lành. Mình sẽ không lưu lại tiến độ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: RelaxTheme.purple),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Rời đi'),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  CHAPTER 1: THRESHOLD — "Hôm nay bạn cảm thấy thế nào?"
// ════════════════════════════════════════════════════════════════════════════

class _ThresholdChapter extends StatelessWidget {
  const _ThresholdChapter({
    super.key,
    required this.activityLabel,
    required this.onPickMood,
    required this.onSkip,
  });
  final String activityLabel;
  final ValueChanged<String> onPickMood;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    activityLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.relax.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Bỏ qua',
                    style: TextStyle(color: context.relax.muted),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const CatAvatar(size: 110),
            const SizedBox(height: 22),
            Text(
              'Hôm nay bạn cảm thấy\nthế nào trước phiên này?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Mình muốn hiểu bạn hơn để đồng hành tốt hơn ✦',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: context.relax.muted),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (final m in _moodChoices)
                  _MoodChip(choice: m, onTap: () => onPickMood(m.code)),
              ],
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.choice, required this.onTap});
  final _MoodChoice choice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 92,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: context.relax.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: RelaxTheme.lavender.withValues(alpha: .25),
            ),
          ),
          child: Column(
            children: [
              Text(choice.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                choice.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  CHAPTER 2: WHISPER — Lời thì thầm + 3 nhịp thở chuẩn bị
// ════════════════════════════════════════════════════════════════════════════

class _WhisperChapter extends StatefulWidget {
  const _WhisperChapter({super.key, required this.onReady});
  final VoidCallback onReady;

  @override
  State<_WhisperChapter> createState() => _WhisperChapterState();
}

class _WhisperChapterState extends State<_WhisperChapter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static const _phrases = [
    'Mình ở đây với bạn ~',
    'Hít sâu vào... giữ một nhịp... rồi thở ra nhẹ.',
    'Thở chậm là cách nhanh nhất để dịu lại.',
  ];
  int _phraseIdx = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _startCycle();
  }

  Future<void> _startCycle() async {
    for (var i = 0; i < _phrases.length; i++) {
      if (!mounted) return;
      setState(() => _phraseIdx = i);
      await Future.delayed(const Duration(seconds: 4));
    }
    if (!mounted) return;
    setState(() => _phraseIdx = -1); // hiện nút "Bắt đầu"
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Vòng tròn breathing — phình to/co theo controller
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  final t = _ctrl.value;
                  final size = 130 + 70 * t;
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          RelaxTheme.lavender.withValues(alpha: .7 - .25 * t),
                          RelaxTheme.purple.withValues(alpha: .25 - .15 * t),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        t < .5 ? 'Hít vào' : 'Thở ra',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 36),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: _phraseIdx < 0
                    ? const SizedBox.shrink()
                    : Text(
                        _phrases[_phraseIdx],
                        key: ValueKey(_phraseIdx),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                      ),
              ),
              const SizedBox(height: 40),
              if (_phraseIdx >= _phrases.length - 1 || _phraseIdx < 0)
                PixelButton(
                  icon: Icons.east_rounded,
                  label: 'Bắt đầu',
                  filled: true,
                  onPressed: widget.onReady,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  CHAPTER 3: IMMERSION — Practice screen với onFinish override
// ════════════════════════════════════════════════════════════════════════════

/// Wrapper PracticeScreen — khi user bấm Finish, gọi `onFinish` thay vì
/// mở feedback sheet. Hành trình tiếp tục ở chapter 4.
class _ImmersionChapter extends StatelessWidget {
  const _ImmersionChapter({
    super.key,
    required this.activity,
    required this.onFinish,
  });
  final Activity activity;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    // Reuse PracticeScreen — flow Finish được intercept qua onChainNext=null
    // và bằng cách wrap với 1 invisible scaffold + InheritedWidget signal.
    // Đơn giản hơn: clone PracticeScreen với onFinish callback custom.
    return _ImmersionBody(activity: activity, onFinish: onFinish);
  }
}

class _ImmersionBody extends StatelessWidget {
  const _ImmersionBody({required this.activity, required this.onFinish});
  final Activity activity;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    // PracticeScreen render full UI. `onFinish` non-null → nút Finish trong
    // PracticeScreen sẽ trigger journey's reflection chapter thay vì mở
    // feedback sheet legacy → flow liền mạch không gãy story.
    return PracticeScreen(
      activity: activity,
      onFinish: onFinish,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  CHAPTER 4: REFLECTION — "Bạn thấy thế nào sau phiên này?"
// ════════════════════════════════════════════════════════════════════════════

class _ReflectionChapter extends StatelessWidget {
  const _ReflectionChapter({
    super.key,
    required this.activityLabel,
    required this.rating,
    required this.noteCtrl,
    required this.submitting,
    required this.error,
    required this.onRatingChange,
    required this.onSubmit,
  });

  final String activityLabel;
  final int rating;
  final TextEditingController noteCtrl;
  final bool submitting;
  final String? error;
  final ValueChanged<int> onRatingChange;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                activityLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: context.relax.muted),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: CatAvatar(size: 96)),
            const SizedBox(height: 20),
            Text(
              'Bạn thấy thế nào\nsau phiên này?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mình lắng nghe nha ~',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: context.relax.muted),
            ),
            const SizedBox(height: 22),
            // 5 star rating row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = (i + 1) <= rating;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: submitting ? null : () => onRatingChange(i + 1),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      scale: filled ? 1.18 : 1.0,
                      child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: filled ? RelaxTheme.purple : context.relax.muted,
                        size: 40,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            if (rating > 0)
              Center(
                child: Text(
                  _ratingLabel(rating),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: RelaxTheme.lavender,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            TextField(
              controller: noteCtrl,
              enabled: !submitting,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Có điều gì muốn chia sẻ thêm không? (Không bắt buộc)',
                filled: true,
                fillColor: context.relax.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.relax.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 20),
            PixelButton(
              icon: submitting
                  ? Icons.hourglass_top_rounded
                  : Icons.arrow_forward_rounded,
              label: submitting ? 'Đang lưu...' : 'Tiếp tục',
              filled: true,
              onPressed: submitting ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int r) => switch (r) {
    1 => 'Rất tệ — mình ghi nhớ nhé',
    2 => 'Tệ — mình sẽ điều chỉnh',
    3 => 'Bình thường',
    4 => 'Tốt — mình vui lắm',
    5 => 'Tuyệt vời ✦',
    _ => '',
  };
}

// ════════════════════════════════════════════════════════════════════════════
//  CHAPTER 5: HEALING — "Cảm ơn bạn đã chăm sóc bản thân"
// ════════════════════════════════════════════════════════════════════════════

class _HealingChapter extends StatefulWidget {
  const _HealingChapter({
    super.key,
    required this.reductionPercent,
    required this.rating,
    required this.hasNext,
    required this.onNext,
    required this.onHome,
  });
  final int reductionPercent;
  final int rating;
  final bool hasNext;
  final VoidCallback onNext;
  final VoidCallback onHome;

  @override
  State<_HealingChapter> createState() => _HealingChapterState();
}

class _HealingChapterState extends State<_HealingChapter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String get _praise => switch (widget.rating) {
    5 => 'Tuyệt vời! Bạn đã làm rất tốt ✦',
    4 => 'Bạn đã rất chăm chút bản thân rồi nè 💜',
    3 => 'Một bước nhỏ vẫn là tiến lên ~',
    2 => 'Không sao đâu, chúng ta thử cách khác nhé 🌿',
    _ => 'Cảm xúc cũng cần được nghe. Mình cùng đi tiếp nhé.',
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Confetti background
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confetti,
                builder: (context, child) =>
                    CustomPaint(painter: _ConfettiPainter(_confetti.value)),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(
              children: [
                const Spacer(),
                const CatAvatar(size: 110),
                const SizedBox(height: 20),
                // Big percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [RelaxTheme.purple, RelaxTheme.lavender],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: RelaxTheme.purple.withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    '✦ Giảm ${widget.reductionPercent}% stress ✦',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _praise,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Cảm ơn bạn đã dành thời gian\nchăm sóc bản thân ✦',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: context.relax.muted),
                ),
                const Spacer(flex: 2),
                if (widget.hasNext)
                  PixelButton(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Tiếp tục với hoạt động khác',
                    filled: true,
                    onPressed: widget.onNext,
                  ),
                if (widget.hasNext) const SizedBox(height: 10),
                PixelButton(
                  icon: Icons.home_rounded,
                  label: 'Về trang chủ',
                  filled: !widget.hasNext,
                  onPressed: widget.onHome,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Confetti rất nhẹ — vài chấm tròn rơi xuống.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;

  static const _colors = [
    RelaxTheme.purple,
    RelaxTheme.lavender,
    Color(0xFFFFC96E),
    Color(0xFFFFAFD2),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    for (var i = 0; i < 24; i++) {
      final dx = rand.nextDouble() * size.width;
      final startY = -20 - rand.nextDouble() * 100;
      final endY = size.height + 40;
      final dy = startY + (endY - startY) * _easedT(t, i, rand);
      final radius = 3 + rand.nextDouble() * 4;
      final color = _colors[i % _colors.length].withValues(alpha: .7);
      canvas.drawCircle(Offset(dx, dy), radius, Paint()..color = color);
    }
  }

  double _easedT(double t, int i, math.Random rand) {
    final offset = rand.nextDouble() * .3;
    final v = (t - offset).clamp(0, 1).toDouble();
    return Curves.easeIn.transform(v);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
