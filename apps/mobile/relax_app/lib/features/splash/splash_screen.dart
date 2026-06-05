import 'package:flutter/material.dart';
import '../../../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_panel.dart';

class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1250), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showSplash ? const SplashScreen() : widget.child,
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final copy = context.copy;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0).toDouble(),
                  child: Transform.scale(
                    scale: .86 + value * .14,
                    child: child,
                  ),
                );
              },
              child: PixelPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PixelCatScene(scene: CatScene.sleep, height: 190),
                    const SizedBox(height: 10),
                    Text(
                      copy.splashTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      copy.splashSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(minHeight: 6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
