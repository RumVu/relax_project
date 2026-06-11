import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../cat_mascot.dart';
import '../soft_toast.dart';
import 'widgets/rating_selector.dart';

// Popup "Ban on chua?" — hien sau khi hoan thanh hoat dong de check-in cam xuc
// sau hoat dong + ghi chu, roi luu mood-checkin hoac cap nhat session.
Future<void> showCheckInSheet(BuildContext context, String activity,
    {String? sessionId}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CheckInSheet(activity: activity, sessionId: sessionId),
  );
}

class CheckInSheet extends StatefulWidget {
  const CheckInSheet({super.key, required this.activity, this.sessionId});

  final String activity;
  final String? sessionId;

  @override
  State<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<CheckInSheet> {
  int _rating = 4;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue({bool goToAnalytics = false}) async {
    final errorMsg = context.t('Không thể hoàn thành phiên thư giãn.');
    final successMsg = context.t('Cảm ơn bạn đã chia sẻ ❤');
    setState(() => _saving = true);
    try {
      if (widget.sessionId != null) {
        final auth = context.read<AuthState>();
        final ok = await auth.finishRelaxSession(
          widget.sessionId!,
          moodAfter: RatingSelector.moods[_rating],
          reliefLevel: _rating + 1,
          note:
              _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
        );
        if (!ok) {
          throw Exception(errorMsg);
        }
      } else {
        await RelaxApi.instance.post('/mood-checkins/me', body: {
          'mood': RatingSelector.moods[_rating],
          'intensity': _rating + 1,
          if (_noteCtrl.text.trim().isNotEmpty) 'note': _noteCtrl.text.trim(),
          'tags': ['after-activity', widget.activity],
        });
      }

      if (!mounted) return;
      Navigator.pop(context);
      showSoftToast(context,
          message: successMsg, tone: SoftToastTone.success);

      if (goToAnalytics && mounted) {
        context.go('/home?tab=2');
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: e.toString(), tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: context.fieldBorder),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                Text(
                  context.t('❤  Bạn ổn chứ?  ❤'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: context.appText,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: context.mutedText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const CatMascot(size: 80, emoji: '😺', glow: false),
            const SizedBox(height: 12),
            Text(
              context.t('Hoạt động vừa rồi giúp bạn thế nào?'),
              style: TextStyle(color: context.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 14),
            RatingSelector(
              rating: _rating,
              onChanged: (i) => setState(() => _rating = i),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              maxLength: 120,
              decoration: InputDecoration(
                hintText: context.t('Viết vài dòng cho linh thú nghe nè…'),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _saving ? null : () => _continue(goToAnalytics: false),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : Text(context.t('Tiếp tục')),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed:
                  _saving ? null : () => _continue(goToAnalytics: true),
              child: Text(
                context.t('Mình ổn, quay lại làm việc thôi'),
                style: const TextStyle(color: RelaxColors.violet),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
