// Helper utilities for the Meditation screen.

/// Format total seconds into MM:SS display string.
String formatDuration(int totalSeconds) {
  final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final s = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
