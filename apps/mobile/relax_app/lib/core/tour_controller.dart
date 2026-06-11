import 'package:flutter/material.dart';
import 'secure_storage.dart';

class TourController extends ChangeNotifier {
  static final TourController instance = TourController._internal();
  TourController._internal() {
    _loadTourStatus();
  }

  bool _isTourActive = false;
  bool get isTourActive => _isTourActive;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool _hasCompletedTour = false;
  bool get hasCompletedTour => _hasCompletedTour;

  final GlobalKey weatherKey = GlobalKey(debugLabel: 'weather');
  final GlobalKey moodCheckinKey = GlobalKey(debugLabel: 'mood_checkin');
  final GlobalKey mascotKey = GlobalKey(debugLabel: 'mascot');
  final GlobalKey musicKey = GlobalKey(debugLabel: 'music');
  final GlobalKey breathingKey = GlobalKey(debugLabel: 'breathing');
  final GlobalKey meditationKey = GlobalKey(debugLabel: 'meditation');
  final GlobalKey moodStatsKey = GlobalKey(debugLabel: 'mood_stats');
  final GlobalKey stressDeltaKey = GlobalKey(debugLabel: 'stress_delta');
  final GlobalKey notificationsKey = GlobalKey(debugLabel: 'notifications');
  final GlobalKey companionCustomizerKey = GlobalKey(debugLabel: 'companion_customizer');
  final GlobalKey languagePickerKey = GlobalKey(debugLabel: 'language_picker');

  // GlobalKeys for target widgets across all tabs
  late final Map<int, GlobalKey> targetKeys = {
    0: weatherKey,
    1: moodCheckinKey,
    2: mascotKey,
    3: musicKey,
    4: breathingKey,
    5: meditationKey,
    6: moodStatsKey,
    7: stressDeltaKey,
    8: notificationsKey,
    9: companionCustomizerKey,
    10: languagePickerKey,
  };

  // Titles & descriptions for each step in Vietnamese
  final Map<int, String> stepTitles = {
    0: 'Thời tiết & Lời khuyên',
    1: 'Ghi nhận Cảm xúc',
    2: 'Linh thú Đồng hành',
    3: 'Âm thanh êm dịu',
    4: 'Bài tập Hít thở',
    5: 'Bài thiền Hướng dẫn',
    6: 'Lịch sử & Số lượt ghi',
    7: 'Biểu đồ Cảm xúc',
    8: 'Thông báo nhắc nhở',
    9: 'Bạn đồng hành Linh thú',
    10: 'Lựa chọn Ngôn ngữ',
  };

  final Map<int, String> stepDescriptions = {
    0: 'Theo dõi thời tiết và nhận những lời khuyên phù hợp nhất cho ngày hôm nay.',
    1: 'Ghi chép nhanh cảm xúc hiện tại của bạn để lưu lịch sử theo dõi.',
    2: 'Mascot linh thú đáng yêu. Chạm vào đây để chăm sóc và trò chuyện cùng linh thú.',
    3: 'Nghe các âm thanh tự nhiên hoặc tiếng ồn trắng để tăng sự tập trung.',
    4: 'Luyện tập hít thở theo nhịp để cân bằng nhịp tim và thư giãn cơ thể.',
    5: 'Các bài thiền có hướng dẫn giúp xoa dịu tâm trí và giảm bớt lo âu.',
    6: 'Xem số lượt ghi nhận cảm xúc và số ngày hoạt động liên tục của bạn.',
    7: 'Theo dõi sự thay đổi và xu hướng cảm xúc của bạn qua biểu đồ trực quan.',
    8: 'Cài đặt khung giờ nhắc nhở viết nhật ký tự phản chiếu và lựa chọn âm báo dễ thương.',
    9: 'Truy cập vào trang linh thú để cho ăn, vuốt ve và cá nhân hóa bạn đồng hành.',
    10: 'Chuyển đổi ngôn ngữ hiển thị (Tiếng Việt / Tiếng Anh) nhanh chóng.',
  };

  Future<void> _loadTourStatus() async {
    try {
      final completed = await secureStorage.read(key: 'tour_completed');
      if (completed == 'true') {
        _hasCompletedTour = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  void startTour() {
    _isTourActive = true;
    _currentStep = 0;
    notifyListeners();
  }

  void stopTour() {
    _isTourActive = false;
    notifyListeners();
  }

  Future<void> completeTour() async {
    _isTourActive = false;
    _hasCompletedTour = true;
    try {
      await secureStorage.write(key: 'tour_completed', value: 'true');
    } catch (_) {}
    notifyListeners();
  }

  // Restarts tour but marks completed as false for testing/guide re-entry
  void restartTour() {
    _isTourActive = true;
    _currentStep = 0;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < targetKeys.length - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setStep(int step) {
    if (step >= 0 && step < targetKeys.length) {
      _currentStep = step;
      notifyListeners();
    }
  }
}
