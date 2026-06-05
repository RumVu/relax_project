import '../../../../../core/session.dart';
import 'dart:math' as math;
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
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => BackendAudioPlayerSheet(activity: activity),
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
    final height = math.min(MediaQuery.of(context).size.height * .82, 640.0);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PixelIconBox(icon: widget.activity.icon, size: 54),
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
                            ? 'Chưa có nội dung từ backend.'
                            : '${resources.length} nội dung từ backend deploy',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
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
                  ? const Center(
                      child: Text('Backend chưa trả file cho mục này.'),
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
                                  Icon(
                                    active
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_outline_rounded,
                                    color: RelaxTheme.lavender,
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
                  Text(
                    'TRÌNH PHÁT',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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

String _formatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

void showFeedbackSheet(BuildContext context, Activity activity) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => _FeedbackSheet(activity: activity),
  );
}

/// Sheet "Bạn ổn chứ?" — rating 1..5 (1 = rất tệ, 5 = rất tốt) + note.
/// Bấm Continue: nếu đã login + backend đã trả `sessionId` cho activity này
/// thì POST `/relax-sessions/me/:id/finish`. Backend trả `stressDelta` →
/// truyền sang [showEncourageSheet] để hiển thị "Đã giảm X% rồi nè".
class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet({required this.activity});
  final Activity activity;

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
    Navigator.of(context).pop();
    showEncourageSheet(context, reductionPercent: reduction.clamp(5, 80));
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

void showEncourageSheet(BuildContext context, {int reductionPercent = 27}) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mức độ giảm tải',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const PixelCatScene(scene: CatScene.wave, height: 160),
            Text(
              'Thi Ái thấy bạn đã giảm stress khoảng $reductionPercent% rồi nè!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            PixelButton(
              icon: Icons.home_rounded,
              label: 'Quay về trang chủ',
              filled: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
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
