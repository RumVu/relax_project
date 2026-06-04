import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../widgets/cat_mascot.dart';

/// Carousel chào mừng lần đầu — 3 slide như mockup. Sau khi xem xong (hoặc
/// bấm bỏ qua) lưu cờ vào secure storage để không hiện lại, rồi sang đăng nhập.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const seenKey = 'relax_onboarding_done';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      emoji: '🌙',
      title: 'Không gian chill\ndành cho bạn',
      body: 'Thư giãn, hít thở và tận hưởng những khoảnh khắc bình yên.',
    ),
    _Slide(
      emoji: '💗',
      title: 'Đồng hành mỗi ngày',
      body: 'Nhận lời nhắc, động viên và những gợi ý hữu ích cho bạn.',
    ),
    _Slide(
      emoji: '🎵',
      title: 'Đơn giản và dễ dùng',
      body: 'Giao diện dễ thương, tối giản để bạn sử dụng mỗi ngày.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await const FlutterSecureStorage()
        .write(key: OnboardingScreen.seenKey, value: '1');
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 4),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Bỏ qua',
                    style: TextStyle(color: context.mutedText),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CatMascot(size: 180, emoji: s.emoji),
                        const SizedBox(height: 40),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: context.appText,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.mutedText,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: active ? 24 : 8,
                  decoration: BoxDecoration(
                    color: active
                        ? RelaxColors.violet
                        : RelaxColors.violet.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_page == _slides.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(
                    _page == _slides.length - 1 ? 'Bắt đầu nào' : 'Tiếp tục',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({required this.emoji, required this.title, required this.body});
  final String emoji;
  final String title;
  final String body;
}
