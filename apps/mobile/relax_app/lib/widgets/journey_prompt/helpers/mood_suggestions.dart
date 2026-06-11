// Mood-based suggestion mappings for the journey prompt.

import 'package:flutter/material.dart';

import '../journey_prompt.dart';

/// Map từ mood code → gợi ý nhánh tiếp theo phù hợp.
List<JourneySuggestion> suggestionsForMood(String mood) {
  switch (mood.toUpperCase()) {
    case 'HAPPY':
    case 'EXCITED':
    case 'GRATEFUL':
      return const [
        JourneySuggestion(
          icon: Icons.edit_note,
          label: 'Ghi lại khoảnh khắc này',
          route: '/journal',
        ),
        JourneySuggestion(
          icon: Icons.headphones,
          label: 'Nghe nhạc',
          route: '/sounds',
        ),
      ];
    case 'STRESSED':
    case 'ANXIOUS':
      return const [
        JourneySuggestion(
          icon: Icons.air,
          label: 'Hít thở 3 phút để dịu lại',
          route: '/breathing',
        ),
        JourneySuggestion(
          icon: Icons.self_improvement,
          label: 'Thiền dẫn dắt',
          route: '/meditation',
        ),
        JourneySuggestion(
          icon: Icons.edit_note,
          label: 'Viết ra để trút bỏ',
          route: '/journal',
        ),
      ];
    case 'SAD':
    case 'LONELY':
      return const [
        JourneySuggestion(
          icon: Icons.edit_note,
          label: 'Trút lòng vào nhật ký',
          route: '/journal',
        ),
        JourneySuggestion(
          icon: Icons.headphones,
          label: 'Một bản nhạc xoa dịu',
          route: '/sounds',
        ),
        JourneySuggestion(
          icon: Icons.air,
          label: 'Vài nhịp thở chậm',
          route: '/breathing',
        ),
      ];
    case 'TIRED':
      return const [
        JourneySuggestion(
          icon: Icons.headphones,
          label: 'Âm thanh êm để nghỉ ngơi',
          route: '/sounds',
        ),
        JourneySuggestion(
          icon: Icons.self_improvement,
          label: 'Thiền thư giãn',
          route: '/meditation',
        ),
      ];
    case 'CALM':
    case 'NEUTRAL':
    default:
      return const [
        JourneySuggestion(
          icon: Icons.self_improvement,
          label: 'Thiền 5 phút',
          route: '/meditation',
        ),
        JourneySuggestion(
          icon: Icons.edit_note,
          label: 'Viết một dòng cho hôm nay',
          route: '/journal',
        ),
        JourneySuggestion(
          icon: Icons.insights,
          label: 'Xem nhịp cảm xúc tuần này',
          route: '/home?tab=2',
        ),
      ];
  }
}

/// Câu phụ đề mềm theo mood — short, soothing.
String subtitleForMood(String mood) {
  switch (mood.toUpperCase()) {
    case 'HAPPY':
    case 'EXCITED':
    case 'GRATEFUL':
      return 'Niềm vui nho nhỏ này đáng được giữ lại nha ✦';
    case 'STRESSED':
    case 'ANXIOUS':
      return 'Hơi căng nhỉ. Để Thi Ái cùng bạn hạ nhịp lại một chút.';
    case 'SAD':
    case 'LONELY':
      return 'Buồn cũng được. Mình ngồi lại với cảm xúc một chút nha.';
    case 'TIRED':
      return 'Mệt rồi đó. Nghỉ một nhịp đã, mọi thứ đợi được mà.';
    case 'CALM':
    case 'NEUTRAL':
    default:
      return 'Giữ nhịp bình yên này, mình đi tiếp một bước nhẹ nhé.';
  }
}
