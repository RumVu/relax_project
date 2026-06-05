import '../../../../core/session.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../app/app_copy.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/mobile_content_service.dart';
import '../../data/services/relax_catalog_service.dart';
import '../../shared/widgets/buttons/pill_controls.dart';
import '../../shared/widgets/common/page_dots.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_badge.dart';
import '../../shared/widgets/pixel/pixel_button.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    this.catalogRepository,
    this.contentRepository,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final RelaxCatalogRepository? catalogRepository;
  final MobileContentRepository? contentRepository;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _goLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
          onLanguageChanged: widget.onLanguageChanged,
          catalogRepository: widget.catalogRepository,
          contentRepository: widget.contentRepository,
        ),
      ),
    );
  }

  void _goRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterScreen(
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
          onLanguageChanged: widget.onLanguageChanged,
          catalogRepository: widget.catalogRepository,
          contentRepository: widget.contentRepository,
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
    final copy = context.copy;
    final slides = copy.onboardingSlides;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 8,
                spacing: 8,
                children: [
                  ThemePill(
                    themeMode: widget.themeMode,
                    onChanged: widget.onThemeChanged,
                  ),
                  LanguagePill(
                    language: copy.language,
                    onChanged: widget.onLanguageChanged,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: LayoutBuilder(
                  builder: (context, outerConstraints) {
                    final panelHeight = math.min(
                      outerConstraints.maxHeight,
                      560.0,
                    );
                    return SizedBox(
                      height: panelHeight,
                      child: PixelPanel(
                        padding: EdgeInsets.zero,
                        child: PageView.builder(
                          controller: _controller,
                          onPageChanged: (value) =>
                              setState(() => _page = value),
                          itemCount: slides.length,
                          itemBuilder: (context, index) {
                            final slide = slides[index];
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final compact = constraints.maxHeight < 500;
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    20,
                                    20,
                                    18,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight - 38,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            PixelBadge(label: copy.homeBadge),
                                            SizedBox(height: compact ? 18 : 30),
                                            Text(
                                              copy.onboardingWelcome,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleLarge,
                                            ),
                                          ],
                                        ),
                                        Center(
                                          child: PixelCatScene(
                                            scene: slide.scene,
                                            height: compact ? 140 : 190,
                                          ),
                                        ),
                                        Column(
                                          children: [
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
                                            const SizedBox(height: 6),
                                          ],
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              PageDots(count: slides.length, active: _page),
              const SizedBox(height: 14),
              PixelButton(
                icon: Icons.person_outline_rounded,
                label: copy.signIn,
                filled: true,
                onPressed: _goLogin,
              ),
              const SizedBox(height: 10),
              PixelButton(
                icon: Icons.person_add_alt_1_outlined,
                label: copy.signUp,
                onPressed: _goRegister,
              ),
              const SizedBox(height: 8),
              const SizedBox(
                height: 64,
                child: PixelCatScene(scene: CatScene.sleep),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
