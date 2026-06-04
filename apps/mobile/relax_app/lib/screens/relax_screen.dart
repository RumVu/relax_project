import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../widgets/cat_mascot.dart';

/// Khu thư giãn — dựng theo mockup: danh sách hoạt động (Nhạc / Podcast /
/// Viết nhật ký / Hít thở / Bí ẩn) với nút Play (mở hoạt động) và Finish
/// (mở popup check-in "Bạn ổn chứ?").
class RelaxScreen extends StatelessWidget {
  const RelaxScreen({super.key});

  static const _activities = [
    _Activity(
      no: '01',
      title: 'Nhạc',
      desc: 'Những giai điệu nhẹ nhàng giúp tâm trí bạn thư giãn.',
      icon: Icons.headphones,
      route: '/sounds',
    ),
    _Activity(
      no: '02',
      title: 'Podcast',
      desc: 'Lắng nghe những câu chuyện truyền cảm hứng mỗi ngày.',
      icon: Icons.mic_none,
      route: '/podcast',
    ),
    _Activity(
      no: '03',
      title: 'Viết nhật ký',
      desc: 'Ghi lại cảm xúc và suy nghĩ để nhẹ lòng hơn nhé.',
      icon: Icons.menu_book_outlined,
      route: '/journal',
    ),
    _Activity(
      no: '04',
      title: 'Hít thở không khí',
      desc: 'Hít thở sâu, thả lỏng cơ thể và sống chậm lại nào.',
      icon: Icons.cloud_outlined,
      route: '/breathing',
    ),
    _Activity(
      no: '05',
      title: 'Bí ẩn',
      desc: 'Để linh thú chọn một hoạt động bất ngờ phù hợp với bạn!',
      icon: Icons.help_outline,
      route: '__random__',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                      'Thư giãn ✨',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.appText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chọn một cách để thư giãn nhé ~',
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
  });
  final String no;
  final String title;
  final String desc;
  final IconData icon;
  final String route;
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});
  final _Activity activity;

  void _play(BuildContext context) {
    var route = activity.route;
    if (route == '__random__') {
      const pool = ['/sounds', '/journal', '/breathing'];
      route = pool[Random().nextInt(pool.length)];
    }
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: RelaxColors.violet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(activity.icon, color: RelaxColors.violet, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${activity.no}. ${activity.title}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: RelaxColors.violet,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.desc,
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
                icon: Icons.play_arrow,
                label: 'Play',
                filled: true,
                onTap: () => _play(context),
              ),
              const SizedBox(height: 8),
              _SmallButton(
                icon: Icons.flag_outlined,
                label: 'Finish',
                filled: false,
                onTap: () => showCheckInSheet(context, activity.title),
              ),
            ],
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
  });
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: filled ? RelaxColors.violet : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filled ? RelaxColors.violet : context.fieldBorder,
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

/// Popup "Bạn ổn chứ?" — hiện sau khi bấm Finish, cho user check-in cảm xúc
/// sau hoạt động + ghi chú, rồi lưu mood-checkin.
Future<void> showCheckInSheet(BuildContext context, String activity) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CheckInSheet(activity: activity),
  );
}

class _CheckInSheet extends StatefulWidget {
  const _CheckInSheet({required this.activity});
  final String activity;

  @override
  State<_CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<_CheckInSheet> {
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
      await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': _moods[_rating],
        'intensity': _rating + 1,
        if (_noteCtrl.text.trim().isNotEmpty) 'note': _noteCtrl.text.trim(),
        'tags': ['after-activity', widget.activity],
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: RelaxColors.mint,
        content: Text('Cảm ơn bạn đã chia sẻ ❤'),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: RelaxColors.coral,
          content: Text(e.toString()),
        ));
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
              child: Text(
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
