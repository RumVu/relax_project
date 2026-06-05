part of 'package:relax_app/main.dart';

class RelaxShell extends StatefulWidget {
  const RelaxShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    this.catalogRepository,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final RelaxCatalogRepository? catalogRepository;

  @override
  State<RelaxShell> createState() => _RelaxShellState();
}

class _RelaxShellState extends State<RelaxShell> {
  int _tab = 0;
  late final RelaxCatalogRepository _catalogRepository =
      widget.catalogRepository ?? RelaxCatalogService();
  List<BackendRelaxActivity> _backendActivities = const [];
  bool _catalogLoading = true;
  String? _catalogError;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _catalogLoading = true;
      _catalogError = null;
    });

    try {
      final activities = await _catalogRepository.fetchActivities();
      if (!mounted) return;
      setState(() {
        _backendActivities = activities;
        _catalogLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _catalogLoading = false;
        _catalogError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      RelaxScreen(
        backendActivities: _backendActivities,
        loadingCatalog: _catalogLoading,
        catalogError: _catalogError,
        onRefreshCatalog: _loadCatalog,
      ),
      const ChallengeScreen(),
      SetupScreen(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        onLanguageChanged: widget.onLanguageChanged,
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
