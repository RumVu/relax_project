import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/auth_state.dart';
import '../core/locale_controller.dart';
import '../core/theme.dart';
import '../widgets/cat_mascot.dart';
import '../widgets/checkin_sheet.dart';
import '../widgets/relax_intro.dart';


/// Khu thư giãn — dựng theo mockup: danh sách hoạt động (Nhạc / Podcast /
/// Viết nhật ký / Hít thở / Bí ẩn) với nút Play (mở hoạt động) và Finish
/// (mở popup check-in "Bạn ổn chứ?").
///
/// Lần đầu user vào tab trong session sẽ chạy [RelaxIntro] flow:
/// thở dịu → chọn mood → đề xuất hoạt động. Static flag để intro chỉ
/// chạy 1 lần/session, không ép user mỗi lần ghé.
class RelaxScreen extends StatefulWidget {
  const RelaxScreen({super.key});

  /// Reset khi app restart — đảm bảo intro chỉ hiện lần đầu mỗi session.
  static bool _introSeenThisSession = false;

  /// Reset từ ngoài (vd auth_state.logout()) — user kế tiếp sẽ thấy
  /// intro lại từ đầu, không kế thừa state user cũ.
  static void resetIntroForLogout() {
    _introSeenThisSession = false;
  }

  @override
  State<RelaxScreen> createState() => _RelaxScreenState();
}

class _RelaxScreenState extends State<RelaxScreen> {
  late bool _showIntro = !RelaxScreen._introSeenThisSession;

  static const _activities = [
    _Activity(
      no: '01',
      title: 'Nhạc',
      desc: 'Những giai điệu nhẹ nhàng giúp tâm trí bạn thư giãn.',
      icon: Icons.headphones,
      route: '/sounds',
      type: 'MUSIC',
    ),
    _Activity(
      no: '02',
      title: 'Podcast',
      desc: 'Lắng nghe những câu chuyện truyền cảm hứng mỗi ngày.',
      icon: Icons.mic_none,
      route: '/podcast',
      type: 'PODCAST',
    ),
    _Activity(
      no: '03',
      title: 'Viết nhật ký',
      desc: 'Ghi lại cảm xúc và suy nghĩ để nhẹ lòng hơn nhé.',
      icon: Icons.menu_book_outlined,
      route: '/journal',
      type: 'JOURNAL',
    ),
    _Activity(
      no: '04',
      title: 'Hít thở không khí',
      desc: 'Hít thở sâu, thả lỏng cơ thể và sống chậm lại nào.',
      icon: Icons.cloud_outlined,
      route: '/breathing',
      type: 'BREATHING',
    ),
    _Activity(
      no: '05',
      title: 'Bí ẩn',
      desc: 'Để linh thú chọn một hoạt động bất ngờ phù hợp với bạn!',
      icon: Icons.help_outline,
      route: '__random__',
      type: 'MYSTERY',
    ),
  ];

  void _dismissIntro() {
    RelaxScreen._introSeenThisSession = true;
    if (mounted) setState(() => _showIntro = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return RelaxIntro(
        onDone: _dismissIntro,
        onPick: (route) {
          _dismissIntro();
          context.push(route);
        },
      );
    }
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('Thư giãn ✨'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.appText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.t('Chọn một cách để thư giãn nhé ~'),
                      style: TextStyle(color: context.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const CatMascot(size: 64, emoji: '🐈', glow: false),
            ],
          ),
          const SizedBox(height: 20),
          ..._activities.map((a) => _ActivityCard(activity: a)),
        ],
      ),
    );
  }
}

class _Activity {
  const _Activity({
    required this.no,
    required this.title,
    required this.desc,
    required this.icon,
    required this.route,
    required this.type,
  });
  final String no;
  final String title;
  final String desc;
  final IconData icon;
  final String route;
  final String type;
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});
  final _Activity activity;

  void _play(BuildContext context) {
    final auth = context.read<AuthState>();
    // Start session in background (best effort)
    auth.startRelaxSession(activity.type, activity.title);

    var route = activity.route;
    if (route == '__random__') {
      const pool = ['/sounds', '/journal', '/breathing'];
      route = pool[Random().nextInt(pool.length)];
    }
    context.push(route);
  }

  void _showPreActivityCheckIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PreActivitySheet(
        activity: activity,
        onConfirmed: (mood) async {
          final auth = context.read<AuthState>();
          try {
            await RelaxApi.instance.post('/mood-checkins/me', body: {
              'mood': mood,
              'intensity': 3,
              'tags': ['pre-activity', activity.title],
            });
          } catch (_) {}

          await auth.startRelaxSession(activity.type, activity.title);

          var route = activity.route;
          if (route == '__random__') {
            const pool = ['/sounds', '/journal', '/breathing'];
            route = pool[Random().nextInt(pool.length)];
          }
          if (ctx.mounted) {
            Navigator.pop(ctx);
            context.push(route);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final isRunning = auth.activeSessionId != null && auth.activeActivityType == activity.type;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (isRunning) {
          _play(context);
        } else {
          _showPreActivityCheckIn(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRunning ? RelaxColors.mint : context.fieldBorder,
            width: isRunning ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: isRunning
                    ? RelaxColors.mint.withValues(alpha: 0.12)
                    : RelaxColors.violet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                activity.icon,
                color: isRunning ? RelaxColors.mint : RelaxColors.violet,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${activity.no}. ${context.t(activity.title)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isRunning ? RelaxColors.mint : RelaxColors.violet,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.t(activity.desc),
                    style: TextStyle(
                      color: context.mutedText,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                _SmallButton(
                  icon: isRunning ? Icons.arrow_forward : Icons.play_arrow,
                  label: isRunning ? context.t('Chạy tiếp') : context.t('Bắt đầu'),
                  filled: true,
                  color: isRunning ? RelaxColors.mint : RelaxColors.violet,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (isRunning) {
                      _play(context);
                    } else {
                      _showPreActivityCheckIn(context);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _SmallButton(
                  icon: Icons.flag_outlined,
                  label: context.t('Hoàn thành'),
                  filled: isRunning,
                  color: isRunning ? RelaxColors.coral : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    final activeId = isRunning ? auth.activeSessionId : null;
                    showCheckInSheet(context, context.t(activity.title), sessionId: activeId);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreActivitySheet extends StatelessWidget {
  const _PreActivitySheet({
    required this.activity,
    required this.onConfirmed,
  });

  final _Activity activity;
  final ValueChanged<String> onConfirmed;

  static const _moods = [
    {'mood': 'HAPPY', 'label': 'Vui', 'emoji': '😺'},
    {'mood': 'SAD', 'label': 'Buồn', 'emoji': '😿'},
    {'mood': 'STRESSED', 'label': 'Stress', 'emoji': '🙀'},
    {'mood': 'TIRED', 'label': 'Chán', 'emoji': '😾'},
    {'mood': 'ANXIOUS', 'label': 'Lo', 'emoji': '😼'},
    {'mood': 'NEUTRAL', 'label': 'Ổn', 'emoji': '😐'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.fieldBorder),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.fieldBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${context.t('Bắt đầu')} ${context.t(activity.title)} ✨',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('Hãy xác nhận cảm xúc lúc này của bạn nhé ~'),
            style: TextStyle(color: context.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
            children: _moods.map((m) {
              final mood = m['mood']!;
              final label = context.t(m['label']!);
              final emoji = m['emoji']!;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onConfirmed(mood);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.fieldBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: context.appText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.t('Đóng'),
              style: TextStyle(color: context.mutedText, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? RelaxColors.violet;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: filled ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filled ? activeColor : context.fieldBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: filled ? Colors.white : context.appText,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : context.appText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

