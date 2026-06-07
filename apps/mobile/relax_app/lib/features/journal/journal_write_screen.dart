import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/session.dart';
import '../../data/services/journal_service.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';
import '../../shared/widgets/pixel/pixel_button.dart';

/// Màn viết nhật ký mới — entry point độc lập (không phụ thuộc Journey flow).
///
/// Cung cấp:
///   - Trường tiêu đề (tùy chọn)
///   - Prompt gợi ý có thể đổi bằng chip
///   - TextField tự mở rộng để viết thoải mái
///   - Nút lưu → POST `/v1/journals/me` → trả về [JournalEntry] khi navigate pop
///
/// Dùng ở:
///   - FAB trong [JournalHistoryScreen]
///   - Có thể dùng bất kỳ đâu cần viết nhật ký nhanh
class JournalWriteScreen extends StatefulWidget {
  const JournalWriteScreen({super.key, this.initialPrompt});

  /// Nếu truyền prompt, text field hint sẽ dùng prompt đó.
  final String? initialPrompt;

  @override
  State<JournalWriteScreen> createState() => _JournalWriteScreenState();
}

class _JournalWriteScreenState extends State<JournalWriteScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _saving = false;
  String? _error;
  String _selectedMood = '';

  String _prompt = 'Điều gì đang làm bạn nặng lòng nhất lúc này?';

  static const _prompts = [
    'Điều gì đang làm bạn nặng lòng nhất lúc này?',
    'Một chuyện nhỏ hôm nay khiến bạn biết ơn là gì?',
    'Nếu dịu dàng với bản thân hơn, bạn sẽ nói gì?',
    'Bạn muốn buông xuống điều gì trước khi ngủ?',
    'Cảm xúc nổi bật nhất của bạn hôm nay là gì?',
  ];

  static const _moods = [
    ('😊', 'HAPPY'),
    ('🌧️', 'SAD'),
    ('🌪️', 'STRESSED'),
    ('😴', 'TIRED'),
    ('🌿', 'CALM'),
    ('😶', 'NEUTRAL'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null) {
      _prompt = widget.initialPrompt!;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      setState(() => _error = 'Viết vài dòng nha — chưa lưu được entry trống.');
      return;
    }
    final session = context.sessionOrNull;
    if (session == null || !session.isLoggedIn) {
      setState(() => _error = 'Bạn cần đăng nhập để lưu nhật ký.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final entry = await JournalService().create(
        accessToken: session.accessToken!,
        content: content,
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        mood: _selectedMood.isEmpty ? null : _selectedMood,
        tags: const ['mobile'],
        isPrivate: true,
      );
      if (!mounted) return;
      Navigator.of(context).pop(entry);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Không lưu được: ${e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Huỷ',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Viết nhật ký ✦'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving ? 'Đang lưu...' : 'Lưu',
                style: TextStyle(
                  color: _saving ? context.relax.muted : RelaxTheme.lavender,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Prompt picker
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: RelaxTheme.purple.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: RelaxTheme.lavender.withValues(alpha: .2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CatAvatar(size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _prompt,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Prompt chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _prompts.map((p) {
                      final selected = p == _prompt;
                      return GestureDetector(
                        onTap: () => setState(() => _prompt = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? RelaxTheme.purple
                                : context.relax.surfaceSoft,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: selected
                                  ? RelaxTheme.purple
                                  : context.relax.border,
                            ),
                          ),
                          child: Text(
                            p.split(' ').take(3).join(' ') + '...',
                            style: TextStyle(
                              fontSize: 10,
                              color: selected ? Colors.white : null,
                              fontWeight: selected
                                  ? FontWeight.w900
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Tiêu đề
            TextField(
              controller: _titleCtrl,
              enabled: !_saving,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề (không bắt buộc)',
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),

            const SizedBox(height: 10),

            // ── Mood pick row
            Row(
              children: [
                Text(
                  'Mood:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.relax.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                ..._moods.map((m) {
                  final (emoji, code) = m;
                  final selected = _selectedMood == code;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedMood = selected ? '' : code;
                      }),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: selected
                              ? RelaxTheme.purple.withValues(alpha: .18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? RelaxTheme.lavender
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 10),

            // ── Content field
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                enabled: !_saving,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: _prompt,
                  filled: true,
                  fillColor: context.relax.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.relax.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.relax.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: RelaxTheme.lavender.withValues(alpha: .6),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.relax.danger,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Save button (bottom)
            PixelButton(
              icon: _saving
                  ? Icons.hourglass_top_rounded
                  : Icons.save_rounded,
              label: _saving ? 'Đang lưu...' : 'Lưu nhật ký ✦',
              filled: true,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
