import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../core/auth_state.dart';
import '../core/theme.dart';
import '../widgets/checkin_sheet.dart';
import '../widgets/journey_prompt.dart';
import '../widgets/soft_toast.dart';

/// Màn nhật ký: viết entry mới (POST /journals/me) + xem danh sách gần đây
/// (GET /journals/me). Cho phép đánh dấu yêu thích và xoá entry.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<Map<String, dynamic>> _entries = [];
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthState>();
      if (auth.activeSessionId == null) {
        auth.startRelaxSession('JOURNAL', 'Viết nhật ký');
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res =
          await RelaxApi.instance.get('/journals/me', query: {'limit': 20});
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      _entries = (items is List)
          ? items
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_bodyCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final res = await RelaxApi.instance.post('/journals/me', body: {
        'title': _titleCtrl.text.trim().isNotEmpty
            ? _titleCtrl.text.trim()
            : _bodyCtrl.text.trim().substring(
                0,
                _bodyCtrl.text.trim().length > 60
                    ? 60
                    : _bodyCtrl.text.trim().length),
        'content': _bodyCtrl.text.trim(),
        'mood': 'NEUTRAL',
        'tags': ['mobile'],
        'isPrivate': true,
      });
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        _titleCtrl.clear();
        _bodyCtrl.clear();
        FocusScope.of(context).unfocus();
        showSoftToast(
          context,
          message: 'Đã lưu nhật ký 🌿',
          tone: SoftToastTone.success,
        );
        await _load();
        if (!mounted) return;
        final auth = context.read<AuthState>();
        final activeId = auth.activeSessionId;
        showCheckInSheet(context, 'Viết nhật ký', sessionId: activeId).then((_) {
          if (!mounted) return;
          showJourneyPrompt(
            context,
            title: 'Đã trút bỏ rồi 🌿',
            subtitle:
                'Giờ là lúc khép lại nhẹ nhàng. Mình đi tiếp một bước êm nhé?',
            suggestions: const [
              JourneySuggestion(
                icon: Icons.air,
                label: 'Hít thở 3 phút để khoá lại',
                route: '/breathing',
              ),
              JourneySuggestion(
                icon: Icons.headphones,
                label: 'Nghe nhạc êm',
                route: '/sounds',
              ),
              JourneySuggestion(
                icon: Icons.insights,
                label: 'Xem nhịp tuần này',
                route: '/home?tab=2',
              ),
            ],
          );
        });
      } else {
        final msg = (res.data?['message'] as String?) ?? 'Không lưu được nhật ký';
        showSoftToast(context, message: msg, tone: SoftToastTone.error);
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

  Future<void> _toggleFavorite(Map<String, dynamic> entry) async {
    final id = entry['id'] as String?;
    if (id == null) return;
    final fav = entry['isFavorite'] == true || entry['favorite'] == true;
    try {
      await RelaxApi.instance.patch('/journals/$id', body: {'isFavorite': !fav});
      await _load();
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: e.toString(), tone: SoftToastTone.error);
      }
    }
  }

  Future<void> _delete(Map<String, dynamic> entry) async {
    final id = entry['id'] as String?;
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá nhật ký?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RelaxColors.coral),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await RelaxApi.instance.delete('/journals/$id');
      await _load();
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: e.toString(), tone: SoftToastTone.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: RelaxColors.violet,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const Text(
              'Nhật ký của bạn',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Viết vài dòng để sau này nhìn lại.',
              style: TextStyle(color: RelaxColors.slate),
            ),
            const SizedBox(height: 20),
            // Composer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.fieldBorder),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Tiêu đề (không bắt buộc)',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(color: RelaxColors.lilac),
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: 4,
                    maxLength: 600,
                    decoration: const InputDecoration(
                      hintText: 'Hôm nay có gì đáng nhớ?',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.edit, size: 18),
                      label: Text(_saving ? 'Đang lưu…' : 'Lưu nhật ký'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gần đây',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: RelaxColors.violet),
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RelaxColors.coral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: RelaxColors.coral),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: RelaxColors.coral, fontSize: 12),
                ),
              )
            else if (_entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Chưa có nhật ký nào. Viết dòng đầu tiên đi nào!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: RelaxColors.slate),
                ),
              )
            else
              ..._entries.map(_buildEntry),
          ],
        ),
      ),
    );
  }

  Widget _buildEntry(Map<String, dynamic> e) {
    final fav = e['isFavorite'] == true || e['favorite'] == true;
    final title = (e['title'] as String?) ?? '';
    final content = (e['content'] as String?) ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: context.appText,
                fontSize: 15,
              ),
            ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: RelaxColors.plum, fontSize: 13, height: 1.4),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () => _toggleFavorite(e),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    fav ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: fav ? RelaxColors.coral : RelaxColors.slate,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _delete(e),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline,
                      size: 20, color: RelaxColors.slate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
