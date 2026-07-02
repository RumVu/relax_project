import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import '../../core/secure_storage.dart';
import '../../core/theme.dart';
import '../../widgets/cat_mascot.dart';
import 'models/onboarding_slide.dart';

// Carousel chao mung lan dau — 4 slide. Sau khi xem xong (hoac
// bam bo qua) luu co vao secure storage de khong hien lai, roi sang dang nhap.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const seenKey = 'relax_onboarding_done';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await secureStorage.write(key: OnboardingScreen.seenKey, value: '1');
    if (!mounted) return;
    context.read<AuthState>().markOnboardingSeen();
    context.go('/login');
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
                    context.t('Bỏ qua'),
                    style: TextStyle(color: context.mutedText),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: kOnboardingSlides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final s = kOnboardingSlides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CatMascot(size: 180, variant: s.variant),
                        const SizedBox(height: 40),
                        Text(
                          context.t(s.title),
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
                          context.t(s.body),
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
              children: List.generate(kOnboardingSlides.length, (i) {
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
                    if (_page == kOnboardingSlides.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(
                    _page == kOnboardingSlides.length - 1
                        ? context.t('Bắt đầu nào')
                        : context.t('Tiếp tục'),
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
