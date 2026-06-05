part of 'package:relax_app/main.dart';

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

class NavItem {
  const NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

enum CatScene { window, laptop, sleep, wave }
