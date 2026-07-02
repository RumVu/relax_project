import 'package:flutter/material.dart';

/// Phase của intro: 3 nhịp thở → chọn cảm xúc → gợi ý hoạt động.
enum IntroPhase { breathing, moodPick, suggest }

/// Bảng cảm xúc cho intro — short list, mỗi chip có icon + label vi + hình mèo + nền pastel.
/// Tuple: (code, label, icon, iconColor, image, bgColor)
const moods = <(String, String, IconData, Color, String, Color)>[
  ('HAPPY', 'Vui', Icons.sentiment_very_satisfied, Color(0xFFFFC857), 'assets/hinh_fill_cam_xuc_truoc/hinh-vui-truoc.png', Color(0xFFFFF5E0)),
  ('CALM', 'Bình yên', Icons.spa, Color(0xFF9DD9D2), 'assets/hinh_fill_cam_xuc_truoc/hinh-yen-truoc.png', Color(0xFFE5F5F1)),
  ('STRESSED', 'Căng thẳng', Icons.bolt, Color(0xFFE48586), 'assets/hinh_fill_cam_xuc_truoc/hinh-stress-truoc.png', Color(0xFFFDE8E8)),
  ('SAD', 'Buồn', Icons.cloud, Color(0xFF8FA7DF), 'assets/hinh_fill_cam_xuc_truoc/hinh-buon-truoc.png', Color(0xFFE5ECF8)),
  ('TIRED', 'Mệt mỏi', Icons.bedtime, Color(0xFFB497BD), 'assets/hinh_fill_cam_xuc_truoc/hinh-chan-truoc.png', Color(0xFFF0E8F5)),
  ('ANXIOUS', 'Lo lắng', Icons.waves, Color(0xFFD8A0DF), 'assets/hinh_fill_cam_xuc_truoc/hinh-lo-truoc.png', Color(0xFFF3E8F5)),
];
