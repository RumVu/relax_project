import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const RelaxApp());
}

class RelaxApp extends StatefulWidget {
  const RelaxApp({super.key});

  @override
  State<RelaxApp> createState() => _RelaxAppState();
}

class _RelaxAppState extends State<RelaxApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thi Ai Chill',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: RelaxTheme.light(),
      darkTheme: RelaxTheme.dark(),
      builder: (context, child) {
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: OnboardingScreen(
        themeMode: _themeMode,
        onThemeChanged: _setThemeMode,
      ),
    );
  }
}

class RelaxTheme {
  static const purple = Color(0xFF6C4DE6);
  static const lavender = Color(0xFF9C86FF);
  static const ink = Color(0xFF28225B);
  static const night = Color(0xFF121728);
  static const nightCard = Color(0xFF1A2135);
  static const mist = Color(0xFFF7F5FF);
  static const line = Color(0xFFC9BFFF);

  static ThemeData light() {
    return _base(
      brightness: Brightness.light,
      scaffold: const Color(0xFFF8F6FF),
      surface: Colors.white,
      surfaceSoft: const Color(0xFFF0ECFF),
      text: ink,
      muted: const Color(0xFF746D9B),
    );
  }

  static ThemeData dark() {
    return _base(
      brightness: Brightness.dark,
      scaffold: night,
      surface: nightCard,
      surfaceSoft: const Color(0xFF222945),
      text: const Color(0xFFEDE8FF),
      muted: const Color(0xFFA8A2CA),
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color surfaceSoft,
    required Color text,
    required Color muted,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: purple,
      brightness: brightness,
      primary: purple,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: colorScheme,
      fontFamily: 'monospace',
      extensions: [
        RelaxColors(
          surfaceSoft: surfaceSoft,
          border: brightness == Brightness.dark
              ? const Color(0xFF343B63)
              : line,
          muted: muted,
          glow: brightness == Brightness.dark
              ? const Color(0xFF8E7BFF)
              : const Color(0xFFDED6FF),
          danger: const Color(0xFFE85A6A),
        ),
      ],
      textTheme: TextTheme(
        displaySmall: TextStyle(
          color: text,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          height: 1.05,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          height: 1.05,
        ),
        headlineSmall: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          height: 1.12,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(color: text, fontSize: 15, height: 1.45),
        bodyMedium: TextStyle(color: muted, fontSize: 13, height: 1.45),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class RelaxColors extends ThemeExtension<RelaxColors> {
  const RelaxColors({
    required this.surfaceSoft,
    required this.border,
    required this.muted,
    required this.glow,
    required this.danger,
  });

  final Color surfaceSoft;
  final Color border;
  final Color muted;
  final Color glow;
  final Color danger;

  @override
  RelaxColors copyWith({
    Color? surfaceSoft,
    Color? border,
    Color? muted,
    Color? glow,
    Color? danger,
  }) {
    return RelaxColors(
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      border: border ?? this.border,
      muted: muted ?? this.muted,
      glow: glow ?? this.glow,
      danger: danger ?? this.danger,
    );
  }

  @override
  RelaxColors lerp(ThemeExtension<RelaxColors>? other, double t) {
    if (other is! RelaxColors) return this;
    return RelaxColors(
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      border: Color.lerp(border, other.border, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension RelaxContext on BuildContext {
  RelaxColors get relax => Theme.of(this).extension<RelaxColors>()!;
  bool get dark => Theme.of(this).brightness == Brightness.dark;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const slides = [
    OnboardingSlide(
      title: 'Không gian chill dành cho bạn',
      body: 'Thư giãn, hít thở và tận hưởng những khoảnh khắc bình yên.',
      scene: CatScene.window,
    ),
    OnboardingSlide(
      title: 'Đồng hành mỗi ngày',
      body: 'Nhận lời nhắc, động viên và những gợi ý hữu ích cho bạn.',
      scene: CatScene.laptop,
    ),
    OnboardingSlide(
      title: 'Đơn giản và dễ dùng',
      body: 'Giao diện dễ thương, tối giản để bạn sử dụng mỗi ngày.',
      scene: CatScene.sleep,
    ),
  ];

  void _enterApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RelaxShell(
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Column(
            children: [
              ThemePill(
                themeMode: widget.themeMode,
                onChanged: widget.onThemeChanged,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PixelPanel(
                  padding: EdgeInsets.zero,
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (value) => setState(() => _page = value),
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxHeight < 620;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight - 38,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const PixelBadge(label: 'HomePage'),
                                  SizedBox(height: compact ? 20 : 42),
                                  Text(
                                    'welcome back, \${user_name}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  SizedBox(height: compact ? 18 : 42),
                                  Center(
                                    child: PixelCatScene(
                                      scene: slide.scene,
                                      height: compact ? 150 : 220,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 18 : 42),
                                  Center(
                                    child: Text(
                                      slide.title,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    slide.body,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: compact ? 18 : 28),
                                  PageDots(count: slides.length, active: _page),
                                  SizedBox(height: compact ? 16 : 24),
                                  PixelButton(
                                    icon: Icons.person_outline_rounded,
                                    label: 'Đăng nhập',
                                    filled: true,
                                    onPressed: _enterApp,
                                  ),
                                  const SizedBox(height: 10),
                                  PixelButton(
                                    icon: Icons.person_add_alt_1_outlined,
                                    label: 'Đăng kí',
                                    onPressed: _enterApp,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RelaxShell extends StatefulWidget {
  const RelaxShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<RelaxShell> createState() => _RelaxShellState();
}

class _RelaxShellState extends State<RelaxShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const RelaxScreen(),
      const ChallengeScreen(),
      SetupScreen(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _tab, children: pages),
      ),
      bottomNavigationBar: PixelBottomNav(
        selectedIndex: _tab,
        onSelected: (index) => setState(() => _tab = index),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const moods = [
    MoodOption('Vui vẻ', Icons.sentiment_very_satisfied_rounded, 70),
    MoodOption('Buồn', Icons.sentiment_dissatisfied_rounded, 25),
    MoodOption('Stress', Icons.psychology_alt_rounded, 65),
    MoodOption('Chán nản', Icons.cloudy_snowing, 40),
    MoodOption('Mất động lực', Icons.battery_1_bar_rounded, 30),
    MoodOption('Bình thường', Icons.sentiment_neutral_rounded, 50),
  ];

  static const methods = [
    MethodOption('Thiền định', Icons.self_improvement_rounded),
    MethodOption('Hít thở', Icons.cloud_queue_rounded),
    MethodOption('Viết nhật kí', Icons.edit_note_rounded),
    MethodOption('Nghe nhạc', Icons.headphones_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            icon: Icons.wb_sunny_outlined,
            title: 'Đã trở lại rồi nè, Thi Ái ~',
            subtitle: context.dark
                ? 'Đừng thức khuya quá đó nha ~'
                : 'Trời nắng đẹp ghê!',
          ),
          const SizedBox(height: 14),
          PixelPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SpeechBubble(
                  text:
                      'Stress quá mới tìm đến tôi hở?\nThì Ái nói cho tôi nghe đi nè!',
                ),
                const SizedBox(height: 12),
                const PixelCatScene(scene: CatScene.wave, height: 188),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionTitle(
            title: 'Hôm nay Thi Ái đang cảm thấy:',
            icon: Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moods.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .96,
            ),
            itemBuilder: (context, index) {
              final mood = moods[index];
              return MoodTile(mood: mood, selected: index == 0);
            },
          ),
          const SizedBox(height: 14),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'Theo dõi cảm xúc của Thi Ái',
                  icon: Icons.bar_chart_rounded,
                ),
                const SizedBox(height: 12),
                ...moods.map((mood) => MoodProgress(mood: mood)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'Phương thức phù hợp cho Thi Ái',
                  icon: Icons.favorite_border_rounded,
                ),
                const SizedBox(height: 12),
                Row(
                  children: methods
                      .map(
                        (method) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: MethodChip(method: method),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RelaxScreen extends StatelessWidget {
  const RelaxScreen({super.key});

  static const activities = [
    Activity(
      '01. Nhạc',
      'Những giai điệu nhẹ nhàng giúp tâm trí bạn thư giãn.',
      Icons.radio_rounded,
    ),
    Activity(
      '02. Podcast',
      'Lắng nghe những câu chuyện truyền cảm hứng mỗi ngày.',
      Icons.mic_external_on_rounded,
    ),
    Activity(
      '03. Viết nhật kí',
      'Ghi lại cảm xúc và suy nghĩ để nhẹ lòng hơn nhé.',
      Icons.menu_book_rounded,
    ),
    Activity(
      '04. Hít thở không khí',
      'Hít thở sâu, thả lỏng cơ thể và sống chậm lại nào.',
      Icons.cloud_rounded,
    ),
    Activity(
      '05. Bí ẩn',
      'Để Thi Ái chọn một hoạt động bất ngờ phù hợp với bạn!',
      Icons.inventory_2_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScroll(
      child: Column(
        children: [
          HeaderBar(
            icon: Icons.arrow_back_ios_new_rounded,
            title: 'Thư giãn ✦',
            subtitle: 'Chọn một cách để thư giãn nhé ~',
            trailing: const PixelCatScene(scene: CatScene.sleep, height: 66),
          ),
          const SizedBox(height: 12),
          ...activities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActivityCard(activity: activity),
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            icon: Icons.emoji_events_outlined,
            title: 'Challenger',
            subtitle: 'Thử thách nhỏ mỗi ngày để chăm sóc bản thân.',
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: StatCard(
                  title: 'Streak',
                  value: '12',
                  caption: 'ngày liên tiếp',
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: 'Tổng thời gian',
                  value: '8h 42m',
                  caption: 'thư giãn cùng Thi Ái',
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const StatCard(
            title: 'Hôm nay',
            value: '19:42',
            caption: '24/05/2024',
            icon: Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 14),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'Biểu đồ cảm xúc (7 ngày qua)',
                  icon: Icons.show_chart_rounded,
                ),
                const SizedBox(height: 12),
                const MoodLineChart(),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'Hoạt động yêu thích',
                  icon: Icons.star_border_rounded,
                ),
                const SizedBox(height: 12),
                const FavoriteActivity(
                  label: 'Nhạc',
                  value: '3h 20m',
                  amount: .82,
                ),
                const FavoriteActivity(
                  label: 'Podcast',
                  value: '2h 10m',
                  amount: .62,
                ),
                const FavoriteActivity(
                  label: 'Hít thở',
                  value: '1h 15m',
                  amount: .42,
                ),
                const FavoriteActivity(
                  label: 'Viết nhật kí',
                  value: '1h 00m',
                  amount: .36,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SectionTitle(
            title: 'Khoảnh khắc thư giãn gần đây',
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: MiniMoment(
                  title: 'Nhạc',
                  time: '24/05 · 22:15',
                  minutes: '25 phút',
                  icon: Icons.radio_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: MiniMoment(
                  title: 'Hít thở',
                  time: '24/05 · 21:30',
                  minutes: '10 phút',
                  icon: Icons.cloud_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return AppScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(
            icon: Icons.settings_outlined,
            title: 'Setup ✦',
            subtitle: 'Tùy chỉnh không gian của Thi Ái ~',
            trailing: const PixelCatScene(scene: CatScene.sleep, height: 64),
          ),
          const SizedBox(height: 14),
          PixelPanel(
            child: Row(
              children: [
                const CatAvatar(size: 94),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thi Ái ✎',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tuổi: 22   |   Nữ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '0123 456 789',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'thiai.chill@email.com',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.relax.muted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: 'Thông báo',
                  icon: Icons.notifications_none_rounded,
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(child: TimeChip(time: '17:00', selected: false)),
                    SizedBox(width: 8),
                    Expanded(child: TimeChip(time: '19:00', selected: false)),
                    SizedBox(width: 8),
                    Expanded(child: TimeChip(time: '21:00', selected: true)),
                  ],
                ),
                const SizedBox(height: 10),
                SettingRow(
                  icon: Icons.volume_up_outlined,
                  title: 'Âm báo: Tiếng mèo con kêu',
                  subtitle:
                      'Người dùng ≤ 32 tuổi nên có thể chọn khung giờ sau 21:00',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PixelPanel(
            child: Column(
              children: [
                SettingRow(
                  icon: Icons.rule_folder_outlined,
                  title: 'Quy định & sử dụng',
                  subtitle: 'Điều khoản, chính sách & giấy phép',
                ),
                const Divider(height: 20),
                SectionTitle(
                  title: 'Thống kê tình trạng',
                  icon: Icons.query_stats_rounded,
                ),
                const SizedBox(height: 12),
                const MoodLineChart(compact: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PixelPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title: 'Giao diện', icon: Icons.palette_outlined),
                const SizedBox(height: 10),
                ThemeSegmentedControl(
                  themeMode: themeMode,
                  onChanged: onThemeChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SettingAction(
            icon: Icons.credit_card_rounded,
            title: 'Nạp thẻ / Nâng cấp',
            subtitle: 'Mở khóa tính năng nâng cao',
            action: 'Nạp ngay',
          ),
          const SizedBox(height: 10),
          SettingAction(
            icon: Icons.delete_outline_rounded,
            title: 'Xóa tài khoản',
            subtitle: 'Xóa vĩnh viễn toàn bộ dữ liệu của Thi Ái',
            danger: true,
            onTap: () => showConfirmSheet(
              context,
              title: 'Xóa tài khoản?',
              body:
                  'Mọi dữ liệu sẽ biến mất và Thi Ái sẽ không thể quay lại đâu á.',
              action: 'Xóa vĩnh viễn',
              danger: true,
            ),
          ),
          const SizedBox(height: 10),
          SettingAction(
            icon: Icons.logout_rounded,
            title: 'Đăng xuất',
            subtitle: 'Đăng xuất khỏi tài khoản hiện tại',
            onTap: () => showConfirmSheet(
              context,
              title: 'Đăng xuất?',
              body: 'Hẹn gặp lại Thi Ái nhé. Thi Ái nhớ chăm sóc bản thân nha.',
              action: 'Đăng xuất',
            ),
          ),
        ],
      ),
    );
  }
}

class AppScroll extends StatelessWidget {
  const AppScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: context.dark
              ? const [Color(0xFF121728), Color(0xFF171B2C)]
              : const [Color(0xFFFDFBFF), Color(0xFFF1EDFF)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 96),
        child: child,
      ),
    );
  }
}

class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PixelIconBox(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null)
          SizedBox(width: 86, height: 70, child: trailing)
        else
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: context.relax.muted,
              ),
              Positioned(
                right: 1,
                top: 1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE85A6A),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class PixelBottomNav extends StatelessWidget {
  const PixelBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const items = [
    _NavItem('Trang chủ', Icons.home_rounded),
    _NavItem('Khu thư giãn', Icons.spa_rounded),
    _NavItem('Challenger', Icons.emoji_events_outlined),
    _NavItem('Setup', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: PixelPanel(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = selectedIndex == index;
              return Expanded(
                child: Tooltip(
                  message: item.label,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 58,
                      decoration: BoxDecoration(
                        color: selected
                            ? RelaxTheme.purple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: RelaxTheme.purple.withValues(
                                    alpha: .35,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: selected
                                ? Colors.white
                                : context.relax.muted,
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : context.relax.muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class PixelPanel extends StatelessWidget {
  const PixelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: context.dark ? .88 : .96),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.relax.border, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: context.relax.glow.withValues(
              alpha: context.dark ? .12 : .24,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PixelIconBox extends StatelessWidget {
  const PixelIconBox({super.key, required this.icon, this.size = 46});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.relax.border),
      ),
      child: Icon(icon, color: RelaxTheme.purple),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: RelaxTheme.lavender, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}

class PixelButton extends StatelessWidget {
  const PixelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: filled ? RelaxTheme.purple : Colors.transparent,
          foregroundColor: filled ? Colors.white : RelaxTheme.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: filled ? RelaxTheme.purple : context.relax.border,
              width: 1.2,
            ),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      child: Row(
        children: [
          PixelIconBox(icon: activity.icon, size: 74),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              SmallActionButton(
                icon: Icons.play_arrow_rounded,
                label: 'Play',
                onTap: () => showPlayerSheet(context, activity),
              ),
              const SizedBox(height: 8),
              SmallActionButton(
                icon: Icons.flag_rounded,
                label: 'Finish',
                onTap: () => showFeedbackSheet(context, activity),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SmallActionButton extends StatelessWidget {
  const SmallActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 94,
      height: 42,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: context.dark
              ? const Color(0xFFE6DFFF)
              : RelaxTheme.purple,
          side: BorderSide(color: context.relax.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: FittedBox(child: Text(label)),
      ),
    );
  }
}

class MoodTile extends StatelessWidget {
  const MoodTile({super.key, required this.mood, required this.selected});

  final MoodOption mood;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      padding: const EdgeInsets.all(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? RelaxTheme.purple.withValues(alpha: .12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mood.icon,
              size: 34,
              color: selected ? RelaxTheme.purple : context.relax.muted,
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                mood.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoodProgress extends StatelessWidget {
  const MoodProgress({super.key, required this.mood});

  final MoodOption mood;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(mood.icon, size: 18, color: context.relax.muted),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: Text(
              mood.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: mood.percent / 100,
                minHeight: 8,
                backgroundColor: context.relax.surfaceSoft,
                valueColor: AlwaysStoppedAnimation(
                  mood.label == 'Stress'
                      ? const Color(0xFFE971E5)
                      : RelaxTheme.lavender,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${mood.percent}%',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class MethodChip extends StatelessWidget {
  const MethodChip({super.key, required this.method});

  final MethodOption method;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.relax.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(method.icon, color: RelaxTheme.purple),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              method.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class ThemePill extends StatelessWidget {
  const ThemePill({
    super.key,
    required this.themeMode,
    required this.onChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.relax.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PillOption(
            icon: Icons.light_mode_rounded,
            label: 'LIGHT MODE',
            selected: themeMode != ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.light),
          ),
          PillOption(
            icon: Icons.dark_mode_rounded,
            label: 'DARK MODE',
            selected: themeMode == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class ThemeSegmentedControl extends StatelessWidget {
  const ThemeSegmentedControl({
    super.key,
    required this.themeMode,
    required this.onChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PillOption(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            selected: themeMode == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PillOption(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            selected: themeMode == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PillOption(
            icon: Icons.auto_awesome_rounded,
            label: 'Custom',
            selected: false,
            onTap: () => onChanged(themeMode),
          ),
        ),
      ],
    );
  }
}

class PillOption extends StatelessWidget {
  const PillOption({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? RelaxTheme.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : context.relax.muted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : context.relax.muted,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PixelBadge extends StatelessWidget {
  const PixelBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: RelaxTheme.purple,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: index == active ? 12 : 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: index == active ? RelaxTheme.purple : context.relax.border,
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }
}

class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: context.relax.surfaceSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.relax.border, width: 1.4),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: RelaxTheme.lavender),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: RelaxTheme.lavender),
          ),
          Text(caption, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class MoodLineChart extends StatelessWidget {
  const MoodLineChart({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 118 : 178,
      child: CustomPaint(
        painter: MoodLinePainter(
          dark: context.dark,
          border: context.relax.border,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class MoodLinePainter extends CustomPainter {
  const MoodLinePainter({required this.dark, required this.border});

  final bool dark;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = border.withValues(alpha: .55)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    const values = [.22, .32, .58, .38, .30, .62, .84];
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      points.add(
        Offset(
          size.width * i / (values.length - 1),
          size.height * (1 - values[i]),
        ),
      );
    }

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            RelaxTheme.purple.withValues(alpha: .24),
            RelaxTheme.purple.withValues(alpha: .02),
          ],
        ).createShader(Offset.zero & size),
    );

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final middle = Offset(
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
      path.quadraticBezierTo(previous.dx, previous.dy, middle.dx, middle.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = RelaxTheme.lavender
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final dot = Paint()
      ..color = dark ? const Color(0xFFEFE9FF) : RelaxTheme.purple;
    for (final point in points) {
      canvas.drawCircle(point, 4, dot);
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = RelaxTheme.purple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MoodLinePainter oldDelegate) {
    return oldDelegate.dark != dark || oldDelegate.border != border;
  }
}

class FavoriteActivity extends StatelessWidget {
  const FavoriteActivity({
    super.key,
    required this.label,
    required this.value,
    required this.amount,
  });

  final String label;
  final String value;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: amount,
                minHeight: 8,
                backgroundColor: context.relax.surfaceSoft,
                valueColor: const AlwaysStoppedAnimation(RelaxTheme.lavender),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class MiniMoment extends StatelessWidget {
  const MiniMoment({
    super.key,
    required this.title,
    required this.time,
    required this.minutes,
    required this.icon,
  });

  final String title;
  final String time;
  final String minutes;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PixelPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PixelIconBox(icon: icon, size: 52),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(time, style: Theme.of(context).textTheme.bodyMedium),
          Text(minutes, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: RelaxTheme.lavender),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        Icon(Icons.chevron_right_rounded, color: context.relax.muted),
      ],
    );
  }
}

class SettingAction extends StatelessWidget {
  const SettingAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? action;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = danger ? context.relax.danger : RelaxTheme.lavender;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: PixelPanel(
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: danger ? color : null,
                    ),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (action != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: RelaxTheme.purple,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  action!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right_rounded, color: context.relax.muted),
          ],
        ),
      ),
    );
  }
}

class TimeChip extends StatelessWidget {
  const TimeChip({super.key, required this.time, required this.selected});

  final String time;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: selected ? RelaxTheme.purple : context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? RelaxTheme.purple : context.relax.border,
        ),
      ),
      child: Center(
        child: Text(
          time,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).textTheme.titleMedium?.color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class CatAvatar extends StatelessWidget {
  const CatAvatar({super.key, this.size = 84});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.relax.border),
      ),
      child: CustomPaint(painter: PixelCatPainter(dark: context.dark)),
    );
  }
}

class PixelCatScene extends StatelessWidget {
  const PixelCatScene({super.key, required this.scene, this.height = 220});

  final CatScene scene;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: PixelScenePainter(scene: scene, dark: context.dark),
      ),
    );
  }
}

class PixelScenePainter extends CustomPainter {
  const PixelScenePainter({required this.scene, required this.dark});

  final CatScene scene;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final floor = Paint()
      ..color = const Color(0xFF7E67E8).withValues(alpha: dark ? .34 : .22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .14,
          size.height * .72,
          size.width * .72,
          size.height * .12,
        ),
        const Radius.circular(20),
      ),
      floor,
    );

    _stars(canvas, size);
    if (scene == CatScene.window || scene == CatScene.wave) {
      _window(canvas, size);
    }
    if (scene == CatScene.laptop) {
      _laptop(canvas, size);
    }
    if (scene == CatScene.sleep) {
      _sleepBubble(canvas, size);
    }

    final catRect = Rect.fromCenter(
      center: Offset(size.width * .5, size.height * .56),
      width: size.width * .48,
      height: size.height * .50,
    );
    PixelCatPainter(
      dark: dark,
      waving: scene == CatScene.wave,
      sleeping: scene == CatScene.sleep,
    ).paint(canvas, catRect.size, offset: catRect.topLeft);

    _plant(canvas, size);
  }

  void _stars(Canvas canvas, Size size) {
    final star = Paint()
      ..color = dark ? const Color(0xFFFFC96E) : RelaxTheme.purple;
    for (final point in [
      Offset(size.width * .2, size.height * .26),
      Offset(size.width * .78, size.height * .24),
      Offset(size.width * .68, size.height * .38),
      Offset(size.width * .26, size.height * .44),
    ]) {
      canvas.drawCircle(point, 2.5, star);
      canvas.drawLine(
        point.translate(-6, 0),
        point.translate(6, 0),
        star..strokeWidth = 1.4,
      );
      canvas.drawLine(point.translate(0, -6), point.translate(0, 6), star);
    }
  }

  void _window(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(size.width * .12, size.height * .18, 70, 78);
    final frame = Paint()..color = const Color(0xFF5D4DD2);
    final glass = Paint()
      ..color = dark ? const Color(0xFF222747) : const Color(0xFFE6E2FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      frame,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(6), const Radius.circular(5)),
      glass,
    );
    canvas.drawCircle(
      Offset(rect.left + 28, rect.top + 30),
      9,
      Paint()..color = const Color(0xFFFFD26B),
    );
  }

  void _laptop(Canvas canvas, Size size) {
    final body = Paint()
      ..color = dark ? const Color(0xFFC7C9D9) : const Color(0xFFB4B7C7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .25,
          size.height * .60,
          size.width * .5,
          size.height * .08,
        ),
        const Radius.circular(6),
      ),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .30,
          size.height * .40,
          size.width * .4,
          size.height * .22,
        ),
        const Radius.circular(8),
      ),
      body,
    );
  }

  void _sleepBubble(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dark ? const Color(0xFF242A44) : Colors.white
      ..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(size.width * .58, size.height * .2, 70, 46);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = RelaxTheme.lavender
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Zzz',
        style: TextStyle(
          color: RelaxTheme.lavender,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _plant(Canvas canvas, Size size) {
    final pot = Paint()..color = const Color(0xFF7358D6);
    final leaf = Paint()..color = const Color(0xFF8BCB96);
    final x = size.width * .74;
    final y = size.height * .66;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 28, 30),
        const Radius.circular(5),
      ),
      pot,
    );
    canvas.drawOval(Rect.fromLTWH(x + 5, y - 18, 10, 22), leaf);
    canvas.drawOval(Rect.fromLTWH(x + 15, y - 20, 10, 24), leaf);
  }

  @override
  bool shouldRepaint(covariant PixelScenePainter oldDelegate) {
    return oldDelegate.scene != scene || oldDelegate.dark != dark;
  }
}

class PixelCatPainter extends CustomPainter {
  const PixelCatPainter({
    this.dark = false,
    this.waving = false,
    this.sleeping = false,
  });

  final bool dark;
  final bool waving;
  final bool sleeping;

  @override
  void paint(Canvas canvas, Size size, {Offset offset = Offset.zero}) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final fur = Paint()..color = const Color(0xFFC2A08B);
    final stripe = Paint()..color = const Color(0xFF776151);
    final cream = Paint()..color = const Color(0xFFF7EEE7);
    final outline = Paint()
      ..color = dark ? const Color(0xFF090C18) : const Color(0xFF3C3159)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, size.shortestSide * .018);
    final blush = Paint()..color = const Color(0xFFFF8A9A);

    final body = Rect.fromLTWH(
      size.width * .22,
      size.height * .40,
      size.width * .56,
      size.height * .42,
    );
    canvas.drawOval(body, fur);
    canvas.drawOval(body, outline);

    final tailPath = Path()
      ..moveTo(size.width * .72, size.height * .62)
      ..quadraticBezierTo(
        size.width * .96,
        size.height * .50,
        size.width * .82,
        size.height * .30,
      );
    canvas.drawPath(
      tailPath,
      Paint()
        ..color = fur.color
        ..strokeWidth = size.width * .13
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      tailPath,
      outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, size.width * .018),
    );

    final head = Rect.fromLTWH(
      size.width * .18,
      size.height * .08,
      size.width * .64,
      size.height * .48,
    );
    final leftEar = Path()
      ..moveTo(size.width * .28, size.height * .15)
      ..lineTo(size.width * .18, size.height * .02)
      ..lineTo(size.width * .40, size.height * .08)
      ..close();
    final rightEar = Path()
      ..moveTo(size.width * .60, size.height * .08)
      ..lineTo(size.width * .82, size.height * .02)
      ..lineTo(size.width * .72, size.height * .15)
      ..close();
    canvas.drawPath(leftEar, fur);
    canvas.drawPath(rightEar, fur);
    canvas.drawPath(leftEar, outline);
    canvas.drawPath(rightEar, outline);
    canvas.drawOval(head, fur);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * .29,
        size.height * .30,
        size.width * .42,
        size.height * .26,
      ),
      cream,
    );
    canvas.drawOval(head, outline);

    for (final x in [.35, .50, .65]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * .12),
        Offset(size.width * (x - .06), size.height * .25),
        stripe
          ..strokeWidth = size.width * .025
          ..strokeCap = StrokeCap.round,
      );
    }

    if (sleeping) {
      final eyePaint = Paint()
        ..color = const Color(0xFF2E253E)
        ..strokeWidth = size.width * .018
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromLTWH(size.width * .33, size.height * .30, 16, 10),
        0,
        math.pi,
        false,
        eyePaint,
      );
      canvas.drawArc(
        Rect.fromLTWH(size.width * .58, size.height * .30, 16, 10),
        0,
        math.pi,
        false,
        eyePaint,
      );
    } else {
      canvas.drawCircle(
        Offset(size.width * .38, size.height * .33),
        size.width * .045,
        Paint()..color = const Color(0xFF221D2D),
      );
      canvas.drawCircle(
        Offset(size.width * .62, size.height * .33),
        size.width * .045,
        Paint()..color = const Color(0xFF221D2D),
      );
      canvas.drawCircle(
        Offset(size.width * .395, size.height * .315),
        size.width * .012,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(size.width * .635, size.height * .315),
        size.width * .012,
        Paint()..color = Colors.white,
      );
    }

    canvas.drawCircle(
      Offset(size.width * .50, size.height * .40),
      size.width * .018,
      Paint()..color = const Color(0xFF6D4B54),
    );
    canvas.drawCircle(
      Offset(size.width * .31, size.height * .42),
      size.width * .018,
      blush,
    );
    canvas.drawCircle(
      Offset(size.width * .69, size.height * .42),
      size.width * .018,
      blush,
    );

    final pawY = size.height * (waving ? .49 : .72);
    canvas.drawCircle(Offset(size.width * .31, pawY), size.width * .07, fur);
    canvas.drawCircle(
      Offset(size.width * .69, size.height * .72),
      size.width * .07,
      fur,
    );
    canvas.drawCircle(
      Offset(size.width * .31, pawY),
      size.width * .07,
      outline,
    );
    canvas.drawCircle(
      Offset(size.width * .69, size.height * .72),
      size.width * .07,
      outline,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PixelCatPainter oldDelegate) {
    return oldDelegate.dark != dark ||
        oldDelegate.waving != waving ||
        oldDelegate.sleeping != sleeping;
  }
}

void showPlayerSheet(BuildContext context, Activity activity) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PixelCatScene(scene: CatScene.laptop, height: 190),
            Text(
              'Đang nghe nhạc',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Lo-fi Chill · Pixel Beats',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Slider(value: .42, onChanged: (_) {}),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Icon(Icons.pause_rounded),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void showFeedbackSheet(BuildContext context, Activity activity) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '♥ Bạn ổn chứ? ♥',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const CatAvatar(size: 82),
            const SizedBox(height: 10),
            Text(
              'Hoạt động vừa rồi giúp bạn thế nào?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(child: RatingChip(label: 'Rất tệ', selected: false)),
                SizedBox(width: 6),
                Expanded(child: RatingChip(label: 'Tệ', selected: false)),
                SizedBox(width: 6),
                Expanded(
                  child: RatingChip(label: 'Bình thường', selected: false),
                ),
                SizedBox(width: 6),
                Expanded(child: RatingChip(label: 'Tốt', selected: false)),
                SizedBox(width: 6),
                Expanded(child: RatingChip(label: 'Rất tốt', selected: true)),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Viết vài dòng cho Thi Ái nghe nè...',
                filled: true,
                fillColor: context.relax.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 14),
            PixelButton(
              icon: Icons.arrow_forward_rounded,
              label: 'Continue',
              filled: true,
              onPressed: () {
                Navigator.of(context).pop();
                showEncourageSheet(context);
              },
            ),
            const SizedBox(height: 8),
            PixelButton(
              icon: Icons.work_outline_rounded,
              label: "I'm fine, I'm going back to my work",
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

void showEncourageSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mức độ giảm tải',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const PixelCatScene(scene: CatScene.wave, height: 160),
            Text(
              'Thi Ái thấy bạn đã giảm stress khoảng 27% rồi nè!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            PixelButton(
              icon: Icons.home_rounded,
              label: 'Quay về trang chủ',
              filled: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

void showConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  bool danger = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CatAvatar(size: 110),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: danger
                      ? context.relax.danger
                      : RelaxTheme.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(action),
              ),
            ),
            const SizedBox(height: 8),
            PixelButton(
              icon: Icons.close_rounded,
              label: 'Hủy bỏ',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

class RatingChip extends StatelessWidget {
  const RatingChip({super.key, required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: selected
            ? RelaxTheme.purple.withValues(alpha: .22)
            : context.relax.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? RelaxTheme.purple : context.relax.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets_rounded, color: RelaxTheme.lavender, size: 20),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.body,
    required this.scene,
  });

  final String title;
  final String body;
  final CatScene scene;
}

class Activity {
  const Activity(this.title, this.description, this.icon);

  final String title;
  final String description;
  final IconData icon;
}

class MoodOption {
  const MoodOption(this.label, this.icon, this.percent);

  final String label;
  final IconData icon;
  final int percent;
}

class MethodOption {
  const MethodOption(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum CatScene { window, laptop, sleep, wave }
