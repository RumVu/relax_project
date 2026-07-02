import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/tour_controller.dart';
import '../../../core/api_client.dart';
import '../../../core/auth_state.dart';
import '../../../core/locale_controller.dart';
import '../../../core/theme.dart';
import '../../../widgets/checkin_sheet/checkin_sheet.dart';
import '../models/relax_activity.dart';
import 'pre_activity_sheet.dart';
import 'small_button.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity});
  final RelaxActivity activity;

  void _play(BuildContext context) {
    final auth = context.read<AuthState>();
    // Start session in background (best effort)
    auth.startRelaxSession(activity.type, activity.title);

    var route = activity.route;
    if (route == '__random__') {
      const pool = ['/sounds', '/journal', '/breathing', '/meditation', '/sleep'];
      route = pool[Random().nextInt(pool.length)];
    }
    context.push(route);
  }

  void _showPreActivityCheckIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PreActivitySheet(
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
            const pool = ['/sounds', '/journal', '/breathing', '/meditation', '/sleep'];
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

    Key? targetKey;
    if (activity.type == 'MUSIC') {
      targetKey = TourController.instance.targetKeys[3];
    } else if (activity.type == 'BREATHING') {
      targetKey = TourController.instance.targetKeys[4];
    } else if (activity.type == 'MEDITATION') {
      targetKey = TourController.instance.targetKeys[5];
    }

    return GestureDetector(
      key: targetKey,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  activity.image,
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                ),
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
                SmallButton(
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
                SmallButton(
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
