import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_copy.dart';
import '../../core/session.dart';
import '../../data/models/app_models.dart';
import '../../data/models/backend_models.dart';
import '../../data/services/mobile_content_service.dart';
import '../../data/services/mood_service.dart';
import '../../data/services/relax_catalog_service.dart';
import '../../shared/widgets/navigation/pixel_bottom_nav.dart';
import '../auth/login_screen.dart';
import '../challenge/challenge_screen.dart';
import '../home/home_screen.dart';
import '../journey/journey_screen.dart';
import '../relax/relax_screen.dart';
import '../setup/setup_screen.dart';

class RelaxShell extends StatefulWidget {
  const RelaxShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    this.onAccentChanged,
    this.catalogRepository,
    this.contentRepository,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<Color>? onAccentChanged;
  final RelaxCatalogRepository? catalogRepository;
  final MobileContentRepository? contentRepository;

  @override
  State<RelaxShell> createState() => _RelaxShellState();
}

class _RelaxShellState extends State<RelaxShell> {
  int _tab = 0;

  late final RelaxCatalogRepository _catalogRepo =
      widget.catalogRepository ?? RelaxCatalogService();
  late final MobileContentRepository _contentRepo =
      widget.contentRepository ?? MobileContentService();
  final _moodSvc = MoodService();

  // ── Catalog ──────────────────────────────────────────────────────────────
  List<BackendRelaxActivity> _activities = const [];
  bool _catalogLoading = true;
  String? _catalogError;

  // ── Content ───────────────────────────────────────────────────────────────
  MobileContentSnapshot _content = const MobileContentSnapshot();
  bool _contentLoading = true;
  String? _contentError;

  // ── Mood history (real API, auth-gated) ──────────────────────────────────
  List<MoodCheckin> _moodHistory = const [];
  bool _moodHistoryLoading = false; // false until we know logged-in

  SessionState? _watchedSession;
  bool _wasLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    _loadContent();
    // Mood history needs token — defer until after first frame so session is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMoodHistory();
      _attachSessionListener();
    });
  }

  /// Subscribe vào SessionState — khi user logout (từ Setup, delete account,
  /// hoặc 401 force-logout từ ApiClient) → tự push LoginScreen replace Shell.
  /// Tránh user kẹt ở Shell với session rỗng (Home/Setup hiển thị empty state
  /// nhưng không có lối ra).
  void _attachSessionListener() {
    final session = context.sessionOrNull;
    if (session == null) return;
    _watchedSession = session;
    _wasLoggedIn = session.isLoggedIn;
    session.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    final session = _watchedSession;
    if (session == null || !mounted) return;
    final loggedIn = session.isLoggedIn;
    // Transition: logged-in → logged-out → kick về Login
    if (_wasLoggedIn && !loggedIn) {
      _wasLoggedIn = false;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            themeMode: widget.themeMode,
            onThemeChanged: widget.onThemeChanged,
            onLanguageChanged: widget.onLanguageChanged,
            catalogRepository: widget.catalogRepository,
            contentRepository: widget.contentRepository,
          ),
        ),
        (route) => false,
      );
    } else if (!_wasLoggedIn && loggedIn) {
      // Login lại trong app (hiếm) → reload data
      _wasLoggedIn = true;
      _loadMoodHistory();
    }
  }

  @override
  void dispose() {
    _watchedSession?.removeListener(_onSessionChanged);
    super.dispose();
  }

  // ── Loaders ───────────────────────────────────────────────────────────────

  Future<void> _loadCatalog() async {
    setState(() {
      _catalogLoading = true;
      _catalogError = null;
    });
    try {
      final acts = await _catalogRepo.fetchActivities();
      if (!mounted) return;
      setState(() {
        _activities = acts;
        _catalogLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _catalogLoading = false;
        _catalogError = e.toString();
      });
    }
  }

  Future<void> _loadContent() async {
    setState(() {
      _contentLoading = true;
      _contentError = null;
    });
    try {
      final snap = await _contentRepo.fetchSnapshot();
      if (!mounted) return;
      setState(() {
        _content = snap;
        _contentLoading = false;
        _contentError = snap.hasData ? null : 'Chưa lấy được dữ liệu mới.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contentLoading = false;
        _contentError = e.toString();
      });
    }
  }

  Future<void> _loadMoodHistory() async {
    final session = context.sessionOrNull;
    if (session == null || !session.isLoggedIn) return; // không auth → bỏ qua
    setState(() => _moodHistoryLoading = true);
    try {
      final history = await _moodSvc.history(
        accessToken: session.accessToken!,
        limit: 90, // ~3 tháng đủ để tính streak và chart 7 ngày
      );
      if (!mounted) return;
      setState(() {
        _moodHistory = history;
        _moodHistoryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _moodHistoryLoading = false);
    }
  }

  void _refresh() {
    _loadCatalog();
    _loadContent();
    _loadMoodHistory();
  }

  Activity _activityForMethod(MethodOption method) {
    for (final backendActivity in _activities) {
      if (backendActivity.type == method.type) {
        return Activity.fromBackend(backendActivity);
      }
    }

    final fallback = switch (method.type) {
      'MUSIC' => (
        title: '01. Nhạc',
        description: 'Nghe nhạc hoặc âm thanh nền để dịu nhịp cảm xúc.',
        duration: 25,
      ),
      'MEDITATION' => (
        title: '05. Thiền định',
        description: 'Một phiên thiền ngắn giúp hạ tải và quay về với mình.',
        duration: 12,
      ),
      'BREATHING' => (
        title: '04. Hít thở không khí',
        description: 'Một bài thở ngắn để giảm tải cơ thể.',
        duration: 10,
      ),
      'JOURNAL' => (
        title: '03. Viết nhật kí',
        description: 'Viết vài dòng để gọi tên điều đang diễn ra bên trong.',
        duration: 15,
      ),
      _ => (
        title: method.label,
        description: 'Chọn một nhịp nghỉ phù hợp với cảm xúc hiện tại.',
        duration: 12,
      ),
    };

    return Activity(
      fallback.title,
      fallback.description,
      method.icon,
      type: method.type,
      durationMinutes: fallback.duration,
      reliefPercent: 0,
    );
  }

  /// Danh sách tất cả Activity (đã merge từ backend) — dùng cho gợi ý
  /// "Tiếp theo bạn muốn làm gì?" trong recovery flow.
  List<Activity> get _allActivities {
    if (_activities.isNotEmpty) {
      return _activities.map(Activity.fromBackend).toList(growable: false);
    }
    // Fallback từ 4 methods cố định khi backend chưa trả catalog
    return [
      _activityForMethod(
        const MethodOption(
          'Thiền định',
          Icons.self_improvement_rounded,
          type: 'MEDITATION',
        ),
      ),
      _activityForMethod(
        const MethodOption(
          'Hít thở',
          Icons.cloud_queue_rounded,
          type: 'BREATHING',
        ),
      ),
      _activityForMethod(
        const MethodOption(
          'Viết nhật kí',
          Icons.edit_note_rounded,
          type: 'JOURNAL',
        ),
      ),
      _activityForMethod(
        const MethodOption(
          'Nghe nhạc',
          Icons.headphones_rounded,
          type: 'MUSIC',
        ),
      ),
    ];
  }

  void _openPractice(MethodOption method) {
    _pushPracticeFor(_activityForMethod(method));
  }

  /// Push 1 JourneyScreen mới — wrap PracticeScreen trong hành trình 5 chương:
  /// Threshold → Whisper → Immersion → Reflection → Healing.
  ///
  /// Khi user chain next activity ở chapter Healing → pop journey hiện tại +
  /// push journey MỚI (fresh state). Dùng UniqueKey để đảm bảo
  /// JourneyScreen.State được tạo lại từ đầu, không leak _rating / _moodBefore
  /// / _noteCtrl từ phiên trước.
  void _pushPracticeFor(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JourneyScreen(
          key: UniqueKey(),
          activity: activity,
          allActivities: _allActivities,
          onChainNext: (next) {
            Navigator.of(context).pop();
            _pushPracticeFor(next);
          },
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final session = context.sessionOrNull;

    final pages = [
      HomeScreen(
        content: _content,
        loadingContent: _contentLoading,
        contentError: _contentError,
        onRefreshContent: _refresh,
        session: session,
        onMethodSelected: _openPractice,
        moodHistory: _moodHistory,
        moodHistoryLoading: _moodHistoryLoading,
        onMoodLogged: _loadMoodHistory, // re-fetch ngay sau khi log mood
      ),
      RelaxScreen(
        backendActivities: _activities,
        loadingCatalog: _catalogLoading,
        catalogError: _catalogError,
        onRefreshCatalog: _refresh,
        onBack: () => setState(() => _tab = 0),
        onStartJourney: _pushPracticeFor,
      ),
      ChallengeScreen(onJumpToHome: () => setState(() => _tab = 0)),
      SetupScreen(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        onLanguageChanged: widget.onLanguageChanged,
        onAccentChanged: widget.onAccentChanged,
        content: _content,
        loadingContent: _contentLoading,
        contentError: _contentError,
        onRefreshContent: _refresh,
        moodHistory: _moodHistory,
      ),
    ];

    return PopScope(
      // Chỉ cho phép pop khi đang ở tab Home (_tab == 0). Khi đang ở
      // tab khác, intercept để chuyển về Home thay vì pop ra Login.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_tab != 0) {
          setState(() => _tab = 0);
          return;
        }
        // Đang ở Home → confirm trước khi cho thoát app
        _confirmExitApp();
      },
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: _tab, children: pages),
        ),
        bottomNavigationBar: PixelBottomNav(
          selectedIndex: _tab,
          onSelected: (index) => setState(() => _tab = index),
        ),
      ),
    );
  }

  Future<void> _confirmExitApp() async {
    final ctx = context;
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Thoát app?'),
        content: const Text('Hẹn gặp lại Thi Ái ở lần ghé sau nha 💜'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    // Đóng app — không pop Navigator vì Shell là route gốc duy nhất
    // (Login dùng pushAndRemoveUntil khi authenticate xong).
    // SystemNavigator.pop() chỉ work trên Android. iOS guidelines không
    // cho phép app tự đóng — user phải dùng home button.
    if (!mounted) return;
    // ignore: deprecated_member_use
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
