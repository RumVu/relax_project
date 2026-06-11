import 'package:flutter/material.dart';

import '../../../core/audio_controller.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    super.key,
    required this.soundId,
    required this.soundUrl,
    required this.audio,
  });

  final String soundId;
  final String soundUrl;
  final AudioController audio;

  @override
  Widget build(BuildContext context) {
    final progress = audio.downloadProgress[soundId];
    if (progress != null) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          value: progress == 0.0 ? null : progress,
          strokeWidth: 2,
          color: RelaxColors.violet,
        ),
      );
    }

    return FutureBuilder<bool>(
      future: audio.isDownloaded(soundId),
      builder: (context, snapshot) {
        final downloaded = snapshot.data ?? false;
        if (downloaded) {
          return const Icon(
            Icons.cloud_done_outlined,
            color: RelaxColors.mint,
            size: 20,
          );
        }
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.cloud_download_outlined,
            color: RelaxColors.violet,
            size: 20,
          ),
          onPressed: () async {
            try {
              await audio.download(soundId, soundUrl);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.t('Đã tải thành công tệp âm thanh ngoại tuyến!')),
                    backgroundColor: RelaxColors.mint,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${context.t('Lỗi tải tệp âm thanh:')} $e'),
                    backgroundColor: RelaxColors.coral,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}
