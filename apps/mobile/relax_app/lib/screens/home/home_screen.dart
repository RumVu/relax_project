import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../core/theme_controller.dart';
import '../../widgets/journey_prompt/journey_prompt.dart';
import '../../widgets/mood_background/mood_background.dart';
import '../../widgets/notification_sheet/notification_sheet.dart';
import '../../widgets/soft_toast.dart';
import 'helpers/home_data_loader.dart';
import 'helpers/home_ui_helpers.dart';
import 'widgets/home_header.dart';
import 'widgets/home_mood_grid.dart';
import 'widgets/methods_card.dart';
import 'widgets/mood_tracking_card.dart';
import 'widgets/smart_recommendations.dart';
import 'widgets/speech_bubble.dart';
import 'widgets/mood_toolkit_widget.dart';
import 'widgets/mood_budget_widget.dart';
import 'widgets/mood_goals_widget.dart';
import 'widgets/mood_forecast_widget.dart';

// Trang chu — loi chao theo thoi tiet, meo + bong bong
// thoai, luoi cam xuc, thanh theo doi cam xuc, va cac phuong thuc phu hop.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _greeting;
  Map<String, dynamic>? _quote;
  List<Map<String, dynamic>> _moodOptions = [];
  Map<String, int> _moodCounts = {};
  int _moodTotal = 0;
  String? _savingMood;
  int _unreadCount = 0;

  String? _lastLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      final lang = LocaleScope.of(context);
      if (lang != _lastLang) {
        _lastLang = lang;
        _loadAll();
      }
    }
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final lang = _lastLang ?? 'vi';
      final data = await HomeDataLoader.loadAll(lang);
      _greeting = data.greeting;
      _quote = data.quote;
      _moodOptions = data.moodOptions;
      _moodCounts = data.moodCounts;
      _moodTotal = data.moodTotal;
      _unreadCount = data.unreadCount;

      final dominant = dominantMood(_moodCounts);
      Color? moodColor;
      switch (dominant) {
        case 'HAPPY':
          moodColor = RelaxColors.sun;
          break;
        case 'CALM':
          moodColor = RelaxColors.mint;
          break;
        case 'STRESSED':
        case 'ANGRY':
          moodColor = RelaxColors.coral;
          break;
        case 'SAD':
          moodColor = const Color(0xFFB084EE);
          break;
        case 'TIRED':
          moodColor = const Color(0xFF6B7280);
          break;
        case 'ANXIOUS':
          moodColor = RelaxColors.violet;
          break;
        case 'POOPING':
          moodColor = const Color(0xFF8B4513);
          break;
      }
      if (moodColor != null && mounted) {
        try {
          context.read<ThemeController>().setAccent(moodColor);
        } catch (_) {}
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logMood(String mood, String label) async {
    HapticFeedback.lightImpact();
    setState(() => _savingMood = mood);
    try {
      final res = await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': mood,
        'intensity': 3,
        'tags': ['home'],
      });
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        showSoftToast(context,
            message: '${context.t('Đã ghi cảm xúc:')} ${context.t(label)}',
            tone: SoftToastTone.success);
        await _loadAll();
        if (!mounted) return;
        await showJourneyPrompt(
          context,
          title: context.t('Đã ghi nhận cảm xúc 🌸'),
          subtitle: subtitleForMood(mood),
          suggestions: suggestionsForMood(mood),
        );
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _savingMood = null);
    }
  }

  Future<void> _refreshUnreadCount() async {
    try {
      final count = await HomeDataLoader.fetchUnreadCount();
      setState(() => _unreadCount = count);
    } catch (_) {}
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationSheet(
        onRefreshCount: _refreshUnreadCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    final name = (user?['name'] as String?) ??
        (user?['email'] as String?)?.split('@').first ??
        context.t('bạn');

    return MoodBackground(
      mood: dominantMood(_moodCounts),
      child: SafeArea(
        child: RefreshIndicator(
          color: RelaxColors.violet,
          onRefresh: _loadAll,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              HomeHeader(
                name: name,
                greeting: _greeting,
                unreadCount: _unreadCount,
                onNotifications: _showNotifications,
              ),
              const SizedBox(height: 8),
              const BurnoutSignalWidget(),
              const SizedBox(height: 16),
              SpeechBubble(quote: _quote, name: name),
              const SizedBox(height: 40),
              // ===== Nút "Calm Now" + "I Need a Break" — nổi bật nhất trên Home =====
              _CalmNowButton(),
              const SizedBox(height: 10),
              _BreakButton(),
              const SizedBox(height: 10),
              _FocusTimerButton(),
              const SizedBox(height: 16),
              const MoodBudgetWidget(),
              const SizedBox(height: 16),
              const MoodGoalsWidget(),
              const MoodForecastWidget(),
              const SmartRecommendations(),
              const MoodToolkitWidget(),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child:
                        CircularProgressIndicator(color: RelaxColors.violet),
                  ),
                )
              else ...[
                _sectionTitle(
                    '${context.t('Hôm nay')} $name ${context.t('đang cảm thấy:')}'),
                const SizedBox(height: 12),
                HomeMoodGrid(
                  moodOptions: _moodOptions,
                  savingMood: _savingMood,
                  onLogMood: _logMood,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/mood'),
                      child: Text(
                        context.t('Chi tiết hơn ➜'),
                        style: const TextStyle(
                          color: RelaxColors.violet,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => context.push('/voice-checkin'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic, color: RelaxColors.coral, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            context.t('Nói để check-in'),
                            style: const TextStyle(
                              color: RelaxColors.coral,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                MoodTrackingCard(
                  name: name,
                  moodOptions: _moodOptions,
                  moodCounts: _moodCounts,
                  moodTotal: _moodTotal,
                ),
                const SizedBox(height: 24),
                MethodsCard(name: name),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(
                        color: RelaxColors.coral, fontSize: 12),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('✦ ', style: TextStyle(color: RelaxColors.violet)),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: context.appText,
            ),
          ),
        ),
        const Text(' ✦', style: TextStyle(color: RelaxColors.violet)),
      ],
    );
  }
}

/// Nút "I Need a Break" — Relax Before Stress Comes. Nhỏ hơn Calm Now,
/// nhưng nổi bật với style riêng.
class _BreakButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/break');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.fieldBorder),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2d6a4f).withValues(alpha: 0.15),
              ),
              child: const Center(
                child: Text('🚬', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('Nghỉ một chút'),
                    style: TextStyle(
                      color: context.appText,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    context.t('3 phút nghỉ lành mạnh — như hút thuốc, nhưng tốt hơn.'),
                    style: TextStyle(
                      color: context.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.mutedText,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// Nút "Calm Now" — nổi bật, gradient, lớn, dễ bấm khi đang stress.
/// Đây là USP của app: "Một nút nhấn — bình tĩnh ngay".
class _CalmNowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/calm-now');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6c63ff), Color(0xFF9c27b0)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6c63ff).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: const Center(
                child: Text('🫂', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('Dịu lại ngay'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.t('Cần dịu lại ngay? Bấm vào đây.'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusTimerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/focus-timer');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.fieldBorder),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RelaxColors.violet.withValues(alpha: 0.12),
              ),
              child: const Center(
                child: Text('⏱️', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('Focus Timer'),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.t('Pomodoro — tập trung rồi nghỉ, lặp lại.'),
                    style: TextStyle(color: context.mutedText, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: context.mutedText, size: 14),
          ],
        ),
      ),
    );
  }
}
