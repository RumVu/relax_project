import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/auth_state.dart';
import '../core/theme.dart';
import 'cat_mascot.dart';
import 'soft_toast.dart';

/// Popup "Bạn ổn chứ?" — hiện sau khi hoàn thành hoạt động để check-in cảm xúc
/// sau hoạt động + ghi chú, rồi lưu mood-checkin hoặc cập nhật session.
Future<void> showCheckInSheet(BuildContext context, String activity, {String? sessionId}) {
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
  // 0..4 → Rất tệ / Tệ / Bình thường / Tốt / Rất tốt
  int _rating = 4;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  static const _labels = ['Rất tệ', 'Tệ', 'Bình thường', 'Tốt', 'Rất tốt'];
  static const _emojis = ['😿', '😾', '😐', '😺', '😻'];
  // Map rating → mood gửi backend.
  static const _moods = ['SAD', 'STRESSED', 'NEUTRAL', 'CALM', 'HAPPY'];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() => _saving = true);
    try {
      if (widget.sessionId != null) {
        // Complete the relax session on backend
        final auth = context.read<AuthState>();
        final ok = await auth.finishRelaxSession(
          widget.sessionId!,
          moodAfter: _moods[_rating],
          reliefLevel: _rating + 1,
          note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
        );
        if (!ok) {
          throw Exception('Không thể hoàn thành phiên thư giãn.');
        }
      } else {
        // Fallback: direct mood check-in
        await RelaxApi.instance.post('/mood-checkins/me', body: {
          'mood': _moods[_rating],
          'intensity': _rating + 1,
          if (_noteCtrl.text.trim().isNotEmpty) 'note': _noteCtrl.text.trim(),
          'tags': ['after-activity', widget.activity],
        });
      }
      
      if (!mounted) return;
      Navigator.pop(context);
      showSoftToast(context,
          message: 'Cảm ơn bạn đã chia sẻ ❤',
          tone: SoftToastTone.success);
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  '❤  Bạn ổn chứ?  ❤',
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
              'Hoạt động vừa rồi giúp bạn thế nào?',
              style: TextStyle(color: context.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final sel = _rating == i;
                return GestureDetector(
                  onTap: () => setState(() => _rating = i),
                  child: Container(
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? RelaxColors.violet.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? RelaxColors.violet : context.fieldBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(_emojis[i], style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 2),
                        Text(
                          _labels[i],
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: context.appText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              maxLength: 120,
              decoration: const InputDecoration(
                hintText: 'Viết vài dòng cho linh thú nghe nè…',
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _continue,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Text('Tiếp tục'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Mình ổn, quay lại làm việc thôi',
                style: TextStyle(color: RelaxColors.violet),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
