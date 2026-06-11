import '../models/breathing_phase.dart';

// Phase label mapping for display.
String phaseLabel(BreathingPhase phase) {
  switch (phase) {
    case BreathingPhase.inhale:
      return 'Hít vào';
    case BreathingPhase.hold:
      return 'Giữ';
    case BreathingPhase.exhale:
      return 'Thở ra';
    case BreathingPhase.holdAfter:
      return 'Nghỉ';
    case BreathingPhase.finished:
      return 'Hoàn thành';
    default:
      return 'Sẵn sàng';
  }
}
