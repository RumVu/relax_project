import 'package:flutter/material.dart';

/// Phase của intro: 3 nhịp thở → chọn cảm xúc → gợi ý hoạt động.
enum IntroPhase { breathing, moodPick, suggest }

/// Bảng cảm xúc cho intro — short list, mỗi chip có icon + label vi.
const moods = <(String, String, IconData, Color)>[
  ('HAPPY', 'Vui', Icons.sentiment_very_satisfied, Color(0xFFFFC857)),
  ('CALM', 'Bình yên', Icons.spa, Color(0xFF9DD9D2)),
  ('STRESSED', 'Căng thẳng', Icons.bolt, Color(0xFFE48586)),
  ('SAD', 'Buồn', Icons.cloud, Color(0xFF8FA7DF)),
  ('TIRED', 'Mệt mỏi', Icons.bedtime, Color(0xFFB497BD)),
  ('ANXIOUS', 'Lo lắng', Icons.waves, Color(0xFFD8A0DF)),
];
