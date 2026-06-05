part of 'package:relax_app/main.dart';

class RelaxApp extends StatefulWidget {
  const RelaxApp({super.key, this.catalogRepository, this.contentRepository});

  final RelaxCatalogRepository? catalogRepository;
  final MobileContentRepository? contentRepository;

  @override
  State<RelaxApp> createState() => _RelaxAppState();
}

class _RelaxAppState extends State<RelaxApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  AppLanguage _language = AppLanguage.vi;
  final SessionState _session = SessionState();

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  void _setLanguage(AppLanguage language) {
    setState(() => _language = language);
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
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
        return AppCopyScope(
          copy: AppCopy(_language),
          child: SessionScope(
            session: _session,
            child: ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
      },
      home: SplashGate(
        child: OnboardingScreen(
          themeMode: _themeMode,
          onThemeChanged: _setThemeMode,
          onLanguageChanged: _setLanguage,
          catalogRepository: widget.catalogRepository,
          contentRepository: widget.contentRepository,
        ),
      ),
    );
  }
}

/// InheritedWidget mỏng để widget bất kỳ đọc `SessionState` qua
/// `context.session` mà không cần Provider/Riverpod.
class SessionScope extends InheritedNotifier<SessionState> {
  const SessionScope({
    super.key,
    required SessionState session,
    required super.child,
  }) : super(notifier: session);

  static SessionState? maybeOf(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<SessionScope>()?.notifier;

  static SessionState of(BuildContext c) {
    final s = maybeOf(c);
    assert(s != null, 'SessionScope chưa được mount ở trên cây widget.');
    return s!;
  }
}

extension SessionContextX on BuildContext {
  SessionState get session => SessionScope.of(this);
  SessionState? get sessionOrNull => SessionScope.maybeOf(this);
}
