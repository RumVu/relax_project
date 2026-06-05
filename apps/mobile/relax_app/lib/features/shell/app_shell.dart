import 'package:flutter/material.dart';
import '../../../../core/session.dart';
import '../../app/app_copy.dart';
import '../../core/session.dart';
import '../../data/models/backend_models.dart';
import '../../data/services/mobile_content_service.dart';
import '../../data/services/relax_catalog_service.dart';
import '../../shared/widgets/navigation/pixel_bottom_nav.dart';
import '../challenge/challenge_screen.dart';
import '../home/home_screen.dart';
import '../relax/relax_screen.dart';
import '../setup/setup_screen.dart';

class RelaxShell extends StatefulWidget {
  const RelaxShell({
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
  State<RelaxShell> createState() => _RelaxShellState();
}

class _RelaxShellState extends State<RelaxShell> {
  int _tab = 0;
  late final RelaxCatalogRepository _catalogRepository =
      widget.catalogRepository ?? RelaxCatalogService();
  late final MobileContentRepository _contentRepository =
      widget.contentRepository ?? MobileContentService();
  List<BackendRelaxActivity> _backendActivities = const [];
  MobileContentSnapshot _contentSnapshot = const MobileContentSnapshot();
  bool _catalogLoading = true;
  bool _contentLoading = true;
  String? _catalogError;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    _loadContent();
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

  Future<void> _loadContent() async {
    setState(() {
      _contentLoading = true;
      _contentError = null;
    });

    try {
      final snapshot = await _contentRepository.fetchSnapshot();
      if (!mounted) return;
      setState(() {
        _contentSnapshot = snapshot;
        _contentLoading = false;
        _contentError = snapshot.hasData ? null : 'Backend chưa trả dữ liệu.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _contentLoading = false;
        _contentError = error.toString();
      });
    }
  }

  void _refreshBackendData() {
    _loadCatalog();
    _loadContent();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.sessionOrNull;
    final pages = [
      HomeScreen(
        content: _contentSnapshot,
        loadingContent: _contentLoading,
        contentError: _contentError,
        onRefreshContent: _refreshBackendData,
        session: session,
        // Bấm method chip → chuyển qua tab Khu thư giãn (index 1)
        onGoToRelax: () => setState(() => _tab = 1),
      ),
      RelaxScreen(
        backendActivities: _backendActivities,
        loadingCatalog: _catalogLoading,
        catalogError: _catalogError,
        onRefreshCatalog: _refreshBackendData,
      ),
      const ChallengeScreen(),
      SetupScreen(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        onLanguageChanged: widget.onLanguageChanged,
        content: _contentSnapshot,
        loadingContent: _contentLoading,
        contentError: _contentError,
        onRefreshContent: _refreshBackendData,
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
