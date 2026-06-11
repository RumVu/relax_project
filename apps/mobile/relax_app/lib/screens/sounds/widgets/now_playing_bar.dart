import 'package:flutter/material.dart';

import '../../../core/audio_controller.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../helpers/duration_format.dart';

// Full now-playing bar with progress, prev/play/next controls.
class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key, required this.audio});

  final AudioController audio;

  @override
  Widget build(BuildContext context) {
    final t = audio.current!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RelaxColors.violet, RelaxColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RelaxColors.violet.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.album, color: Colors.white70),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t((t['title'] as String?) ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      context.t((t['category'] as String?) ?? 'Đang phát'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<Duration>(
            stream: audio.positionStream,
            builder: (context, snap) {
              final pos = snap.data ?? Duration.zero;
              final dur = audio.duration;
              final value = dur.inMilliseconds == 0
                  ? 0.0
                  : pos.inMilliseconds / dur.inMilliseconds;
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: value.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDuration(pos),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      Text(formatDuration(dur),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: audio.hasPrev ? audio.prev : null,
                icon: const Icon(Icons.skip_previous, color: Colors.white),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: audio.toggle,
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    audio.playing ? Icons.pause : Icons.play_arrow,
                    color: RelaxColors.violet,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: audio.hasNext ? audio.next : null,
                icon: const Icon(Icons.skip_next, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
