import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

const _prompts = [
  'Hôm nay bạn biết ơn điều gì nhất?',
  'Ai đã khiến bạn mỉm cười hôm nay?',
  'Khoảnh khắc nào hôm nay bạn cảm thấy bình yên?',
  'Điều nhỏ bé nào đã làm ngày hôm nay tốt đẹp hơn?',
  'Bạn tự hào về bản thân ở điểm nào hôm nay?',
  'Một bữa ăn nào hôm nay khiến bạn hạnh phúc?',
  'Bạn biết ơn sức khỏe của mình ở mặt nào?',
  'Thiên nhiên mang lại cho bạn điều gì hôm nay?',
  'Kỹ năng nào bạn biết ơn vì đã có?',
  'Ai là người luôn ở bên bạn mà bạn muốn cảm ơn?',
  'Điều gì trong cuộc sống bạn dễ quên nhưng thật quý giá?',
  'Một ký ức đẹp nào bạn muốn nhớ mãi?',
  'Bạn biết ơn giấc ngủ/nghỉ ngơi ở điểm nào?',
  'Hôm nay bạn đã học được điều gì mới?',
];

class GratitudeJournalScreen extends StatefulWidget {
  const GratitudeJournalScreen({super.key});

  @override
  State<GratitudeJournalScreen> createState() => _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState extends State<GratitudeJournalScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
  bool _saving = false;
  late String _todayPrompt;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    _todayPrompt = _prompts[dayOfYear % _prompts.length];
    _loadEntries();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    try {
      final res = await RelaxApi.instance.get('/journals/me', query: {
        'tags': 'gratitude',
        'limit': '30',
      });
      if (!mounted) return;
      final items = res.data is Map
          ? ((res.data as Map)['items'] ?? res.data)
          : res.data;
      final list = (items is List)
          ? items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : <Map<String, dynamic>>[];

      int streak = 0;
      final now = DateTime.now();
      for (int i = 0; i < list.length; i++) {
        final created = DateTime.tryParse(list[i]['createdAt'] as String? ?? '');
        if (created == null) break;
        final diff = now.difference(created).inDays;
        if (diff <= i + 1) {
          streak++;
        } else {
          break;
        }
      }

      setState(() {
        _entries = list;
        _streak = streak;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    try {
      await RelaxApi.instance.post('/journals/me', body: {
        'title': _todayPrompt,
        'content': text,
        'tags': ['gratitude'],
        'mood': 'GRATEFUL',
      });
      _controller.clear();
      if (mounted) {
        showSoftToast(context,
            message: context.t('Đã lưu lòng biết ơn!'), tone: SoftToastTone.success);
      }
      await _loadEntries();
    } catch (e) {
      if (mounted) {
        showSoftToast(context, message: '${context.t('Lỗi:')} $e', tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Nhật ký biết ơn'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: RelaxColors.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                // Streak badge
                if (_streak > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Text(
                          '${context.t('Chuỗi biết ơn:')} $_streak ${context.t('ngày')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Today's prompt card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🙏', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Text(
                            context.t('Câu hỏi hôm nay'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _todayPrompt,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Text input
                Container(
                  decoration: BoxDecoration(
                    color: context.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.fieldBorder),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    style: TextStyle(color: context.appText, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: context.t('Viết lòng biết ơn của bạn...'),
                      hintStyle: TextStyle(color: context.mutedText),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RelaxColors.violet,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            context.t('Lưu'),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
                const SizedBox(height: 28),

                // Past entries
                if (_entries.isNotEmpty) ...[
                  Text(
                    context.t('Lòng biết ơn gần đây'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ..._entries.map((entry) {
                    final title = entry['title'] as String? ?? '';
                    final content = entry['content'] as String? ?? '';
                    final created = DateTime.tryParse(entry['createdAt'] as String? ?? '');
                    final dateStr = created != null
                        ? '${created.day}/${created.month}'
                        : '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.fieldBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🙏', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: context.mutedText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                dateStr,
                                style: TextStyle(color: context.mutedText, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            content,
                            style: TextStyle(
                              color: context.appText,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}
