/// Client-side crisis content detection utility.
///
/// Mirrors the backend keyword set so the app can perform an instant local
/// check before (or instead of) a network round-trip.
class CrisisDetector {
  CrisisDetector._();

  static const _highPatterns = [
    'tự tử',
    'muốn chết',
    'kết thúc cuộc sống',
    'tự hại',
    'kill myself',
    'end my life',
    'suicide',
    'self harm',
  ];

  static const _mediumPatterns = [
    'không muốn sống',
    'thế giới sẽ tốt hơn nếu không có mình',
    'muốn biến mất',
    'want to die',
    'better off dead',
    'no reason to live',
  ];

  static const _lowPatterns = [
    'không ai quan tâm',
    'chán sống',
    "can't go on",
    'cant go on',
  ];

  /// Returns `true` when [text] contains any known crisis keyword.
  static bool containsCrisisContent(String text) {
    final lower = text.toLowerCase();
    for (final p in _highPatterns) {
      if (lower.contains(p)) return true;
    }
    for (final p in _mediumPatterns) {
      if (lower.contains(p)) return true;
    }
    for (final p in _lowPatterns) {
      if (lower.contains(p)) return true;
    }
    return false;
  }

  /// A gentle Vietnamese message directing the user toward help.
  static String getSafeResponse() {
    return 'Mình hiểu bạn đang trải qua khoảng thời gian khó khăn. '
        'Bạn không đơn độc — hãy liên hệ đường dây hỗ trợ tâm lý '
        '1800 599 100 (miễn phí, 24/7) hoặc nói chuyện với người bạn tin tưởng.';
  }
}
