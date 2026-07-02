import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/tour_controller.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/cat_mascot.dart';
import '../../widgets/relax_intro/relax_intro.dart';
import 'models/relax_activity.dart';
import 'widgets/activity_card.dart';

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

  void _dismissIntro() {
    RelaxScreen._introSeenThisSession = true;
    if (mounted) setState(() => _showIntro = false);
  }

  @override
  Widget build(BuildContext context) {
    final tour = context.watch<TourController>();
    if (tour.isTourActive) {
      RelaxScreen._introSeenThisSession = true;
      _showIntro = false;
    }
    if (_showIntro) {
      return RelaxIntro(
        onDone: _dismissIntro,
        onPick: (route) {
          _dismissIntro();
          context.push(route);
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home?tab=0');
            }
          },
        ),
        title: Text(
          context.t('Thư giãn ✨'),
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CatMascot(size: 44, variant: CatVariant.stand, glow: false),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          cacheExtent: 9999,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              context.t('Chọn một cách để thư giãn nhé ~'),
              style: TextStyle(color: context.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ...relaxActivities.map((a) => ActivityCard(activity: a)),
          ],
        ),
      ),
    );
  }
}
