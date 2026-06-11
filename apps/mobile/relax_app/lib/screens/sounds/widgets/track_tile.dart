import 'package:flutter/material.dart';

import '../../../core/audio_controller.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import 'download_button.dart';

// List tile for a single audio track.
class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.playing,
    required this.audio,
    required this.onTap,
  });

  final Map<String, dynamic> track;
  final bool playing;
  final AudioController audio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final soundId = track['id'] as String?;
    final soundUrl = track['soundUrl'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: playing
            ? RelaxColors.violet.withValues(alpha: 0.12)
            : context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: playing ? RelaxColors.violet : context.fieldBorder,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: RelaxColors.violet.withValues(alpha: 0.15),
          child: Icon(
            playing && audio.playing ? Icons.graphic_eq : Icons.music_note,
            color: RelaxColors.violet,
          ),
        ),
        title: Text(
          context.t((track['title'] as String?) ?? 'Không tên'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: context.appText,
          ),
        ),
        subtitle: Text(
          context.t((track['category'] as String?) ?? ''),
          style: TextStyle(color: context.mutedText, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (soundId != null && soundUrl != null)
              DownloadButton(
                soundId: soundId,
                soundUrl: soundUrl,
                audio: audio,
              ),
            const SizedBox(width: 8),
            Icon(
              playing ? Icons.equalizer : Icons.play_arrow,
              color: RelaxColors.violet,
            ),
          ],
        ),
      ),
    );
  }
}
