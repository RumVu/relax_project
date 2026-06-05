part of 'package:relax_app/main.dart';

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
    final copy = context.copy;
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
            label: copy.lightMode,
            selected: themeMode != ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.light),
          ),
          PillOption(
            icon: Icons.dark_mode_rounded,
            label: copy.darkMode,
            selected: themeMode == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class LanguagePill extends StatelessWidget {
  const LanguagePill({
    super.key,
    required this.language,
    required this.onChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final copy = context.copy;
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
            icon: Icons.translate_rounded,
            label: copy.languageVi,
            selected: language == AppLanguage.vi,
            onTap: () => onChanged(AppLanguage.vi),
          ),
          PillOption(
            icon: Icons.language_rounded,
            label: copy.languageEn,
            selected: language == AppLanguage.en,
            onTap: () => onChanged(AppLanguage.en),
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

class LanguageSegmentedControl extends StatelessWidget {
  const LanguageSegmentedControl({
    super.key,
    required this.language,
    required this.onChanged,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final copy = context.copy;
    return Row(
      children: [
        Expanded(
          child: PillOption(
            icon: Icons.translate_rounded,
            label: copy.languageVi,
            selected: language == AppLanguage.vi,
            onTap: () => onChanged(AppLanguage.vi),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PillOption(
            icon: Icons.language_rounded,
            label: copy.languageEn,
            selected: language == AppLanguage.en,
            onTap: () => onChanged(AppLanguage.en),
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
