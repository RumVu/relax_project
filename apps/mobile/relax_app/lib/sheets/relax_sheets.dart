part of 'package:relax_app/main.dart';

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
    builder: (context) {
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
              children: const [
                Expanded(child: RatingChip(label: 'Rất tệ', selected: false)),
                SizedBox(width: 6),
                Expanded(child: RatingChip(label: 'Tệ', selected: false)),
                SizedBox(width: 6),
                Expanded(
                  child: RatingChip(label: 'Bình thường', selected: false),
                ),
                SizedBox(width: 6),
                Expanded(child: RatingChip(label: 'Tốt', selected: false)),
                SizedBox(width: 6),
                Expanded(child: RatingChip(label: 'Rất tốt', selected: true)),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Viết vài dòng cho Thi Ái nghe nè...',
                filled: true,
                fillColor: context.relax.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 14),
            PixelButton(
              icon: Icons.arrow_forward_rounded,
              label: 'Continue',
              filled: true,
              onPressed: () {
                Navigator.of(context).pop();
                showEncourageSheet(context);
              },
            ),
            const SizedBox(height: 8),
            PixelButton(
              icon: Icons.work_outline_rounded,
              label: "I'm fine, I'm going back to my work",
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

void showEncourageSheet(BuildContext context) {
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
              'Thi Ái thấy bạn đã giảm stress khoảng 27% rồi nè!',
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

void showConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  bool danger = false,
}) {
  showModalBottomSheet<void>(
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
                onPressed: () => Navigator.of(context).pop(),
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
  const RatingChip({super.key, required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: selected
            ? RelaxTheme.purple.withValues(alpha: .22)
            : context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? RelaxTheme.purple : context.relax.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets_rounded, color: RelaxTheme.lavender, size: 20),
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
    );
  }
}
