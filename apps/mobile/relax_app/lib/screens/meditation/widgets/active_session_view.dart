import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../helpers/meditation_helpers.dart';

/// Full-screen meditation playback view with timer, progress ring,
/// play/pause, and stop controls.
class ActiveSessionView extends StatelessWidget {
  const ActiveSessionView({
    super.key,
    required this.guide,
    required this.secondsRemaining,
    required this.totalDurationSeconds,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onStop,
  });

  final Map<String, dynamic> guide;
  final int secondsRemaining;
  final int totalDurationSeconds;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final title = guide['title'] as String? ?? '';
    final progress = 1.0 - (secondsRemaining / totalDurationSeconds);

    return Scaffold(
      backgroundColor: RelaxColors.violet,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.t('Thiền định có hướng dẫn'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 60),
              // Progress ring
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text(
                    formatDuration(secondsRemaining),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              const Text(
                'Hít vào... thở ra nhẹ nhàng...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 64,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onTogglePlay();
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.stop_circle_outlined,
                        size: 64, color: Colors.white70),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onStop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
