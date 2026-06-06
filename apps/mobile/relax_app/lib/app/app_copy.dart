import 'package:flutter/material.dart';
import '../data/models/app_models.dart';

enum AppLanguage { vi, en }

class AppCopyScope extends InheritedWidget {
  const AppCopyScope({super.key, required this.copy, required super.child});

  final AppCopy copy;

  static AppCopy of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppCopyScope>();
    return scope?.copy ?? const AppCopy(AppLanguage.vi);
  }

  @override
  bool updateShouldNotify(AppCopyScope oldWidget) {
    return oldWidget.copy.language != copy.language;
  }
}

class AppCopy {
  const AppCopy(this.language, {this.userName = ''});

  final AppLanguage language;

  /// Tên hiển thị của user — nếu trống thì fallback về "bạn".
  final String userName;

  String get _name => userName.trim().isEmpty ? 'bạn' : userName.trim();

  bool get en => language == AppLanguage.en;

  String get splashTitle => 'Thi Ai Chill';
  String get splashSubtitle => en
      ? 'A soft pause before the world gets loud.'
      : 'Một nhịp nghỉ mềm trước khi ngày trở nên ồn ào.';
  String get homeBadge => 'HomePage';
  String get onboardingWelcome =>
      en ? 'welcome back, \${user_name}' : 'chào mừng trở lại, \${user_name}';
  String get signIn => en ? 'Login' : 'Đăng nhập';
  String get signUp => en ? 'Register' : 'Đăng kí';
  String get lightMode => en ? 'LIGHT MODE' : 'SÁNG';
  String get darkMode => en ? 'DARK MODE' : 'TỐI';
  String get languageVi => 'VI';
  String get languageEn => 'EN';

  List<OnboardingSlide> get onboardingSlides => en
      ? const [
          OnboardingSlide(
            title: 'A chill corner made for you',
            body: 'Relax, breathe and enjoy a few peaceful moments.',
            scene: CatScene.window,
          ),
          OnboardingSlide(
            title: 'Track how you feel',
            body: 'Tap a mood, write a line — see your week unfold.',
            scene: CatScene.wave,
          ),
          OnboardingSlide(
            title: 'Your daily companion',
            body: 'Get reminders, encouragement and tiny suggestions.',
            scene: CatScene.laptop,
          ),
          OnboardingSlide(
            title: 'Sleep well, start fresh',
            body: 'A cute, minimal interface for everyday self-care.',
            scene: CatScene.sleep,
          ),
        ]
      : const [
          OnboardingSlide(
            title: 'Không gian chill dành cho bạn',
            body: 'Thư giãn, hít thở và tận hưởng khoảnh khắc bình yên.',
            scene: CatScene.window,
          ),
          OnboardingSlide(
            title: 'Theo dõi cảm xúc mỗi ngày',
            body: 'Bấm 1 mood, viết vài dòng — nhìn lại cả tuần dễ thương.',
            scene: CatScene.wave,
          ),
          OnboardingSlide(
            title: 'Đồng hành cùng bạn',
            body: 'Nhận lời nhắc, động viên và gợi ý nhỏ vào đúng lúc cần.',
            scene: CatScene.laptop,
          ),
          OnboardingSlide(
            title: 'Ngủ ngon, thức dậy nhẹ tênh',
            body: 'Giao diện tối giản, dễ thương để bạn dùng mỗi ngày.',
            scene: CatScene.sleep,
          ),
        ];

  String get homeTitle =>
      en ? 'Welcome back, $_name ~' : 'Chào mừng trở lại, $_name ~';
  String get homeDaySubtitle =>
      en ? 'Such a bright sunny day!' : 'Trời nắng đẹp ghê!';
  String get homeNightSubtitle =>
      en ? 'Do not stay up too late, okay ~' : 'Đừng thức khuya quá đó nha ~';
  String get homeSpeech => en
      ? 'Feeling stressed? I am here for you, $_name.'
      : 'Stress quá rồi hả $_name?\nNói cho tôi nghe đi nè!';
  String get moodPrompt => en
      ? 'How are you feeling today, $_name?'
      : '$_name đang cảm thấy thế nào?';
  String get moodChartTitle => en ? 'Mood tracker' : 'Theo dõi cảm xúc';
  String get methodTitle =>
      en ? 'Methods that fit you' : 'Phương thức phù hợp cho $_name';

  List<MoodOption> get moods => en
      ? const [
          MoodOption('Happy', Icons.sentiment_very_satisfied_rounded, 70),
          MoodOption('Sad', Icons.sentiment_dissatisfied_rounded, 25),
          MoodOption('Stress', Icons.psychology_alt_rounded, 65),
          MoodOption('Bored', Icons.cloudy_snowing, 40),
          MoodOption('Unmotivated', Icons.battery_1_bar_rounded, 30),
          MoodOption('Normal', Icons.sentiment_neutral_rounded, 50),
        ]
      : const [
          MoodOption('Vui vẻ', Icons.sentiment_very_satisfied_rounded, 70),
          MoodOption('Buồn', Icons.sentiment_dissatisfied_rounded, 25),
          MoodOption('Stress', Icons.psychology_alt_rounded, 65),
          MoodOption('Chán nản', Icons.cloudy_snowing, 40),
          MoodOption('Mất động lực', Icons.battery_1_bar_rounded, 30),
          MoodOption('Bình thường', Icons.sentiment_neutral_rounded, 50),
        ];

  List<MethodOption> get methods => en
      ? const [
          MethodOption(
            'Meditate',
            Icons.self_improvement_rounded,
            type: 'MEDITATION',
          ),
          MethodOption('Breathe', Icons.cloud_queue_rounded, type: 'BREATHING'),
          MethodOption('Journal', Icons.edit_note_rounded, type: 'JOURNAL'),
          MethodOption('Music', Icons.headphones_rounded, type: 'MUSIC'),
        ]
      : const [
          MethodOption(
            'Thiền định',
            Icons.self_improvement_rounded,
            type: 'MEDITATION',
          ),
          MethodOption('Hít thở', Icons.cloud_queue_rounded, type: 'BREATHING'),
          MethodOption(
            'Viết nhật kí',
            Icons.edit_note_rounded,
            type: 'JOURNAL',
          ),
          MethodOption('Nghe nhạc', Icons.headphones_rounded, type: 'MUSIC'),
        ];

  List<NavItem> get navItems => en
      ? const [
          NavItem('Home', Icons.home_rounded),
          NavItem('Relax', Icons.spa_rounded),
          NavItem('Challenge', Icons.emoji_events_outlined),
          NavItem('Setup', Icons.settings_outlined),
        ]
      : const [
          NavItem('Trang chủ', Icons.home_rounded),
          NavItem('Khu thư giãn', Icons.spa_rounded),
          NavItem('Challenger', Icons.emoji_events_outlined),
          NavItem('Setup', Icons.settings_outlined),
        ];
}
