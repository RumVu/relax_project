/// Một nhịp thở: bao nhiêu giây cho từng pha + số chu kỳ.
class BreathingPattern {
  const BreathingPattern({
    required this.code,
    required this.label,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.holdAfter,
    required this.cycles,
  });

  final String code;
  final String label;
  final int inhale;
  final int hold;
  final int exhale;
  final int holdAfter;
  final int cycles;
}

const breathingPatterns = <BreathingPattern>[
  BreathingPattern(
    code: 'box',
    label: 'Box 4-4-4-4 · cân bằng',
    inhale: 4,
    hold: 4,
    exhale: 4,
    holdAfter: 4,
    cycles: 6,
  ),
  BreathingPattern(
    code: 'relax',
    label: '4-7-8 · ngủ ngon',
    inhale: 4,
    hold: 7,
    exhale: 8,
    holdAfter: 0,
    cycles: 5,
  ),
  BreathingPattern(
    code: 'natural',
    label: '4-0-4-0 · tự nhiên',
    inhale: 4,
    hold: 0,
    exhale: 4,
    holdAfter: 0,
    cycles: 8,
  ),
];
