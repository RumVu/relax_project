import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../app/theme.dart';
import '../../../core/session.dart';
import '../../../data/models/app_models.dart';
import '../../../data/models/backend_models.dart';
import '../../../data/services/relax_session_service.dart';
import '../../../shared/widgets/pixel/cat_widgets.dart';
import '../../../shared/widgets/pixel/pixel_button.dart';
import '../../../shared/widgets/pixel/pixel_panel.dart';

void showPlayerSheet(BuildContext context, Activity activity) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return switch (activity.type) {
        'BREATHING' => BreathingPracticeSheet(activity: activity),
        'JOURNAL' => JournalPracticeSheet(activity: activity),
        _ => BackendAudioPlayerSheet(activity: activity),
      };
    },
  );
}

class BackendAudioPlayerSheet extends StatefulWidget {
  const BackendAudioPlayerSheet({super.key, required this.activity});

  final Activity activity;

  @override
  State<BackendAudioPlayerSheet> createState() =>
      _BackendAudioPlayerSheetState();
}

class _BackendAudioPlayerSheetState extends State<BackendAudioPlayerSheet> {
  final _player = AudioPlayer();
  BackendResource? _selected;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(BackendResource resource) async {
    setState(() {
      _selected = resource;
      _error = null;
      _loading = true;
    });

    final url = resource.soundUrl;
    if (url == null) {
      setState(() {
        _loading = false;
        _error = 'Nội dung này chưa có file âm thanh.';
      });
      return;
    }

    try {
      await _player.setUrl(url);
      await _player.play();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Không phát được file này. Kiểm tra URL Supabase.';
      });
    }
  }

  Future<void> _toggle() async {
    if (_player.playing) {
      await _player.pause();
      return;
    }
    if (_selected == null && widget.activity.resources.isNotEmpty) {
      await _play(widget.activity.resources.first);
      return;
    }
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    final resources = widget.activity.resources;
    final selected =
        _selected ?? (resources.isNotEmpty ? resources.first : null);
    final height = math.min(MediaQuery.of(context).size.height * .86, 700.0);
    final isMeditation = widget.activity.type == 'MEDITATION';
    final eyebrow = switch (widget.activity.type) {
      'PODCAST' => 'PODCAST THƯ GIÃN',
      'MEDITATION' => 'KHÔNG GIAN THIỀN',
      'MUSIC' => 'DÀN ÂM THANH',
      _ => 'NỘI DUNG ĐI KÈM',
    };

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SheetBackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.activity.compactTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        resources.isEmpty
                            ? 'Chọn một nhịp nghỉ nhẹ nhàng.'
                            : '${resources.length} nội dung sẵn sàng để nghe',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                PixelIconBox(icon: widget.activity.icon, size: 46),
              ],
            ),
            const SizedBox(height: 14),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.relax.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            Expanded(
              child: resources.isEmpty
                  ? Center(
                      child: PixelPanel(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isMeditation
                                  ? Icons.self_improvement_rounded
                                  : Icons.music_off_rounded,
                              color: RelaxTheme.lavender,
                              size: 42,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Chưa có file để phát',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Bấm làm mới ở Khu thư giãn hoặc nạp thêm nội dung trong trang quản trị.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: resources.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final resource = resources[index];
                        final active = selected?.id == resource.id;
                        return Material(
                          color: active
                              ? RelaxTheme.purple.withValues(alpha: .22)
                              : context.relax.surfaceSoft,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _play(resource),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? RelaxTheme.purple
                                          : Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: context.relax.border,
                                      ),
                                    ),
                                    child: Icon(
                                      active
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: active
                                          ? Colors.white
                                          : RelaxTheme.lavender,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resource.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        Text(
                                          '${resource.category} · ${resource.durationLabel}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            PixelPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eyebrow, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    selected?.title ?? 'Chọn một nội dung để nghe',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = _player.duration ?? Duration.zero;
                      final maxSeconds = math.max(
                        duration.inMilliseconds / 1000,
                        1.0,
                      );
                      final seconds = math.min(
                        position.inMilliseconds / 1000,
                        maxSeconds,
                      );
                      return Column(
                        children: [
                          Slider(
                            value: seconds,
                            min: 0,
                            max: maxSeconds,
                            onChanged: duration == Duration.zero
                                ? null
                                : (value) => _player.seek(
                                    Duration(
                                      milliseconds: (value * 1000).round(),
                                    ),
                                  ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                _formatDuration(duration),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: StreamBuilder<PlayerState>(
                      stream: _player.playerStateStream,
                      builder: (context, snapshot) {
                        final playing = snapshot.data?.playing ?? false;
                        return FilledButton.icon(
                          onPressed: resources.isEmpty || _loading
                              ? null
                              : _toggle,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                          label: Text(playing ? 'Tạm dừng' : 'Phát'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreathingPracticeSheet extends StatefulWidget {
  const BreathingPracticeSheet({super.key, required this.activity});

  final Activity activity;

  @override
  State<BreathingPracticeSheet> createState() => _BreathingPracticeSheetState();
}

class _BreathingPracticeSheetState extends State<BreathingPracticeSheet> {
  static const _steps = [
    (label: 'Hít vào', seconds: 4, scale: 1.0),
    (label: 'Giữ hơi', seconds: 4, scale: 1.18),
    (label: 'Thở ra', seconds: 6, scale: .78),
  ];

  Timer? _timer;
  bool _running = false;
  int _stepIndex = 0;
  int _remaining = _steps.first.seconds;
  int _cycle = 1;
  final int _totalCycles = 5;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!_running) return;
    if (_remaining > 1) {
      setState(() => _remaining--);
      return;
    }
    final nextStep = (_stepIndex + 1) % _steps.length;
    final nextCycle = nextStep == 0 ? _cycle + 1 : _cycle;
    if (nextCycle > _totalCycles) {
      _timer?.cancel();
      setState(() {
        _running = false;
        _stepIndex = 0;
        _remaining = _steps.first.seconds;
        _cycle = 1;
      });
      showEncourageSheet(context, reductionPercent: 32);
      return;
    }
    setState(() {
      _stepIndex = nextStep;
      _cycle = nextCycle;
      _remaining = _steps[nextStep].seconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_stepIndex];
    final progress =
        ((_cycle - 1) * _steps.length + _stepIndex + 1) /
        (_steps.length * _totalCycles);
    final height = math.min(MediaQuery.of(context).size.height * .84, 660.0);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(
              icon: Icons.cloud_queue_rounded,
              title: widget.activity.compactTitle,
              subtitle:
                  'Theo nhịp ${_steps.map((s) => s.seconds).join('-')} · $_totalCycles vòng',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PixelPanel(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      step.label,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Vòng $_cycle/$_totalCycles · còn $_remaining giây',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    AnimatedScale(
                      scale: _running ? step.scale : .88,
                      duration: Duration(milliseconds: step.seconds * 900),
                      curve: Curves.easeInOutCubic,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              RelaxTheme.lavender.withValues(alpha: .92),
                              RelaxTheme.purple.withValues(alpha: .55),
                              context.relax.surfaceSoft,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: RelaxTheme.purple.withValues(alpha: .35),
                              blurRadius: 34,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$_remaining',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(color: Colors.white, fontSize: 48),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            PixelButton(
              icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
              label: _running ? 'Tạm dừng nhịp thở' : 'Bắt đầu hít thở',
              filled: true,
              onPressed: _toggle,
            ),
            const SizedBox(height: 8),
            PixelButton(
              icon: Icons.flag_rounded,
              label: 'Finish',
              onPressed: () {
                _timer?.cancel();
                Navigator.of(context).pop();
                showFeedbackSheet(context, widget.activity);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class JournalPracticeSheet extends StatefulWidget {
  const JournalPracticeSheet({super.key, required this.activity});

  final Activity activity;

  @override
  State<JournalPracticeSheet> createState() => _JournalPracticeSheetState();
}

class _JournalPracticeSheetState extends State<JournalPracticeSheet> {
  final _controller = TextEditingController();
  String _prompt = 'Điều gì đang làm bạn nặng lòng nhất lúc này?';

  static const _prompts = [
    'Điều gì đang làm bạn nặng lòng nhất lúc này?',
    'Một chuyện nhỏ hôm nay khiến bạn thấy biết ơn là gì?',
    'Nếu dịu dàng với bản thân hơn, bạn sẽ nói gì?',
    'Bạn muốn buông xuống điều gì trước khi ngủ?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viết vài dòng trước đã nha.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã giữ lại ghi chú trong phiên này.'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
    showFeedbackSheet(context, widget.activity);
  }

  @override
  Widget build(BuildContext context) {
    final height = math.min(MediaQuery.of(context).size.height * .86, 700.0);
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          14,
          18,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(
              icon: Icons.edit_note_rounded,
              title: widget.activity.compactTitle,
              subtitle: 'Ghi lại cảm xúc để nhẹ lòng hơn một chút.',
            ),
            const SizedBox(height: 14),
            PixelPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GỢI Ý VIẾT',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(_prompt, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _prompts.map((prompt) {
                      final selected = prompt == _prompt;
                      return ChoiceChip(
                        label: Text(prompt.split(' ').take(3).join(' ')),
                        selected: selected,
                        onSelected: (_) => setState(() => _prompt = prompt),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Viết cho Thi Ái nghe nè...',
                  filled: true,
                  fillColor: context.relax.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.relax.border),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            PixelButton(
              icon: Icons.save_rounded,
              label: 'Lưu nhật ký',
              filled: true,
              onPressed: _save,
            ),
            const SizedBox(height: 8),
            PixelButton(
              icon: Icons.flag_rounded,
              label: 'Finish',
              onPressed: () {
                Navigator.of(context).pop();
                showFeedbackSheet(context, widget.activity);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SheetBackButton(onTap: () => Navigator.of(context).pop()),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        PixelIconBox(icon: icon, size: 46),
      ],
    );
  }
}

class _SheetBackButton extends StatelessWidget {
  const _SheetBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.relax.border),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: RelaxTheme.lavender,
          size: 18,
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Callback khi user bấm "Continue" trong recovery flow.
/// [nextActivity] do `showNextStepSheet` chọn từ danh sách [allActivities].
typedef NextStepHandler = void Function(Activity nextActivity);

void showFeedbackSheet(
  BuildContext context,
  Activity activity, {
  List<Activity> allActivities = const [],
  NextStepHandler? onContinueNext,
}) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => _FeedbackSheet(
      activity: activity,
      allActivities: allActivities,
      onContinueNext: onContinueNext,
    ),
  );
}

/// Sheet "Bạn ổn chứ?" — rating 1..5 (1 = rất tệ, 5 = rất tốt) + note.
/// Bấm Continue: nếu đã login + backend đã trả `sessionId` cho activity này
/// thì POST `/relax-sessions/me/:id/finish`. Backend trả `stressDelta` →
/// truyền sang [showEncourageSheet] để hiển thị "Đã giảm X% rồi nè".
class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet({
    required this.activity,
    this.allActivities = const [],
    this.onContinueNext,
  });
  final Activity activity;
  final List<Activity> allActivities;
  final NextStepHandler? onContinueNext;

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  static const _labels = [
    (label: 'Rất tệ', rating: 1),
    (label: 'Tệ', rating: 2),
    (label: 'Bình thường', rating: 3),
    (label: 'Tốt', rating: 4),
    (label: 'Rất tốt', rating: 5),
  ];

  int _rating = 5; // mặc định "Rất tốt" như mockup.
  final _noteCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    // Mặc định 'reliefLevel * 15%' khi backend chưa trả số cụ thể —
    // rating 5 → 75%, rating 1 → 15%.
    int reduction = _rating * 15;
    try {
      final session = context.sessionOrNull;
      if (session != null && session.isLoggedIn) {
        final svc = RelaxSessionService();
        // Mở phiên rồi đóng luôn — chỉ cần ghi chú lại trải nghiệm.
        final started = await svc.start(
          accessToken: session.accessToken!,
          activityType: widget.activity.type,
          title: widget.activity.compactTitle,
        );
        await svc.finish(
          accessToken: session.accessToken!,
          sessionId: started.id,
          reliefLevel: _rating,
          note: _noteCtrl.text,
        );
      }
    } catch (e) {
      _error = e.toString();
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    if (_error != null) return; // giữ sheet để user thấy lỗi.
    final navContext = context;
    Navigator.of(navContext).pop();
    showEncourageSheet(
      navContext,
      reductionPercent: reduction.clamp(5, 80),
      currentActivity: widget.activity,
      allActivities: widget.allActivities,
      onContinueNext: widget.onContinueNext,
      rating: _rating,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '♥ Bạn ổn chứ? ♥',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const CatAvatar(size: 82),
          const SizedBox(height: 10),
          Text(
            'Hoạt động vừa rồi giúp bạn thế nào?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < _labels.length; i++) ...[
                Expanded(
                  child: RatingChip(
                    label: _labels[i].label,
                    selected: _labels[i].rating == _rating,
                    onTap: _submitting
                        ? null
                        : () => setState(() => _rating = _labels[i].rating),
                  ),
                ),
                if (i != _labels.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            enabled: !_submitting,
            decoration: InputDecoration(
              hintText: 'Viết vài dòng cho Thi Ái nghe nè...',
              filled: true,
              fillColor: context.relax.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.relax.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 14),
          PixelButton(
            icon: Icons.arrow_forward_rounded,
            label: _submitting ? 'Đang gửi…' : 'Continue',
            filled: true,
            onPressed: _submitting ? () {} : () => _submit(),
          ),
          const SizedBox(height: 8),
          PixelButton(
            icon: Icons.work_outline_rounded,
            label: "I'm fine, I'm going back to my work",
            onPressed: _submitting ? () {} : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Sheet "Mức độ giảm tải" — bước 2 của recovery flow.
/// - Hiện reduction% + lời động viên
/// - 2 buttons: "Tiếp tục với hoạt động khác" → mở [showNextStepSheet]
///                "Quay về trang chủ" → pop hết về root
void showEncourageSheet(
  BuildContext context, {
  int reductionPercent = 27,
  Activity? currentActivity,
  List<Activity> allActivities = const [],
  NextStepHandler? onContinueNext,
  int rating = 4,
}) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (sheetCtx) {
      // Lời nhắn tự sinh theo rating
      final praise = switch (rating) {
        5 => 'Tuyệt vời! Bạn đã làm rất tốt ✦',
        4 => 'Bạn đã rất chăm chút bản thân rồi nè 💜',
        3 => 'Một bước nhỏ vẫn là tiến lên ~',
        2 => 'Không sao đâu, chúng ta thử cách khác nhé 🌿',
        _ => 'Cảm xúc cũng cần được nghe. Mình cùng đi tiếp nhé.',
      };

      // Có activities khác → cho phép "Tiếp tục"
      final hasNext = allActivities.length > 1 && onContinueNext != null;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mức độ giảm tải',
              style: Theme.of(sheetCtx).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const PixelCatScene(scene: CatScene.wave, height: 150),
            const SizedBox(height: 10),
            // Big % chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: RelaxTheme.purple,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '✦ Giảm $reductionPercent% stress ✦',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              praise,
              textAlign: TextAlign.center,
              style: Theme.of(
                sheetCtx,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            if (hasNext)
              PixelButton(
                icon: Icons.auto_awesome_rounded,
                label: 'Tiếp tục với hoạt động khác',
                filled: true,
                onPressed: () {
                  Navigator.of(sheetCtx).pop();
                  showNextStepSheet(
                    context,
                    currentActivity: currentActivity,
                    allActivities: allActivities,
                    onContinue: onContinueNext,
                  );
                },
              )
            else
              PixelButton(
                icon: Icons.spa_rounded,
                label: 'Hoàn tất phiên này',
                filled: true,
                onPressed: () => Navigator.of(sheetCtx).pop(),
              ),
            const SizedBox(height: 8),
            PixelButton(
              icon: Icons.home_rounded,
              label: 'Quay về trang chủ',
              onPressed: () {
                Navigator.of(sheetCtx).pop();
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
          ],
        ),
      );
    },
  );
}

/// Bước 3 — "Tiếp theo bạn muốn làm gì?"
/// Đưa ra 2-3 gợi ý hoạt động khác (loại trừ activity vừa làm).
/// Sắp xếp theo `reliefPercent` giảm dần để gợi ý cái hiệu quả nhất trước.
void showNextStepSheet(
  BuildContext context, {
  Activity? currentActivity,
  required List<Activity> allActivities,
  required NextStepHandler? onContinue,
}) {
  // Lọc: bỏ activity vừa làm
  final candidates =
      allActivities.where((a) => a.type != currentActivity?.type).toList()
        ..sort(
          (a, b) => (b.reliefPercent ?? 0).compareTo(a.reliefPercent ?? 0),
        );
  final suggestions = candidates.take(3).toList();

  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (sheetCtx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiếp theo bạn muốn làm gì? ✦',
              style: Theme.of(sheetCtx).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Mình gợi ý vài hoạt động khác để bạn tiếp tục dịu lại nha ~',
              style: Theme.of(sheetCtx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (suggestions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'Bạn đã thử hết các hoạt động hiện có rồi. Hẹn lần sau nhé!',
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetCtx).textTheme.bodyMedium,
                ),
              )
            else
              for (var i = 0; i < suggestions.length; i++) ...[
                _NextStepTile(
                  activity: suggestions[i],
                  isBest: i == 0,
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    onContinue?.call(suggestions[i]);
                  },
                ),
                if (i != suggestions.length - 1) const SizedBox(height: 8),
              ],
            const SizedBox(height: 14),
            PixelButton(
              icon: Icons.home_rounded,
              label: 'Quay về trang chủ',
              onPressed: () {
                Navigator.of(sheetCtx).pop();
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
          ],
        ),
      );
    },
  );
}

class _NextStepTile extends StatelessWidget {
  const _NextStepTile({
    required this.activity,
    required this.isBest,
    required this.onTap,
  });

  final Activity activity;
  final bool isBest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isBest
                ? RelaxTheme.purple.withValues(alpha: .12)
                : context.relax.surfaceSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isBest
                  ? RelaxTheme.purple
                  : RelaxTheme.lavender.withValues(alpha: .2),
              width: isBest ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: RelaxTheme.purple.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  activity.icon,
                  color: RelaxTheme.lavender,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.compactTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (isBest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: RelaxTheme.purple,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '★ Tốt nhất',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 11.5),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: context.relax.muted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${activity.durationMinutes ?? 12} phút',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 10,
                                color: context.relax.muted,
                              ),
                        ),
                        if ((activity.reliefPercent ?? 0) > 0) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.spa_rounded,
                            size: 11,
                            color: context.relax.muted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'relief ${activity.reliefPercent}%',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 10,
                                  color: context.relax.muted,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: RelaxTheme.lavender,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  bool danger = false,
  Future<void> Function()? onConfirm,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CatAvatar(size: 110),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: danger
                      ? context.relax.danger
                      : RelaxTheme.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  if (onConfirm != null) await onConfirm();
                  if (navigator.canPop()) navigator.pop();
                },
                child: Text(action),
              ),
            ),
            const SizedBox(height: 8),
            PixelButton(
              icon: Icons.close_rounded,
              label: 'Hủy bỏ',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

class RatingChip extends StatelessWidget {
  const RatingChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 72,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected
                ? RelaxTheme.purple.withValues(alpha: .22)
                : context.relax.surfaceSoft,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? RelaxTheme.purple : context.relax.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets_rounded,
                color: selected ? RelaxTheme.purple : RelaxTheme.lavender,
                size: 20,
              ),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
