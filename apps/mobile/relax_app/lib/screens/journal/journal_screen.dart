import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import '../../core/safety_detector.dart';
import '../../core/theme.dart';
import '../../widgets/checkin_sheet/checkin_sheet.dart';
import '../../widgets/journey_prompt/journey_prompt.dart';
import '../../widgets/soft_toast.dart';
import 'widgets/journal_composer.dart';
import 'widgets/journal_entry_card.dart';

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
        auth.startRelaxSession('JOURNAL', context.t('Viết nhật ký'));
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

    // Safety check — show SOS if crisis keywords detected.
    final fullText = '${_titleCtrl.text} ${_bodyCtrl.text}';
    if (SafetyDetector.containsCrisisKeywords(fullText)) {
      SafetyDetector.showSafetyDialog(context);
    }

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
          message: context.t('Đã lưu nhật ký 🌿'),
          tone: SoftToastTone.success,
        );
        await _load();
        if (!mounted) return;
        final auth = context.read<AuthState>();
        final activeId = auth.activeSessionId;
        showCheckInSheet(context, context.t('Viết nhật ký'), sessionId: activeId).then((_) {
          if (!mounted) return;
          showJourneyPrompt(
            context,
            title: context.t('Đã trút bỏ rồi 🌿'),
            subtitle:
                context.t('Giờ là lúc khép lại nhẹ nhàng. Mình đi tiếp một bước êm nhé?'),
            suggestions: [
              JourneySuggestion(
                icon: Icons.air,
                label: context.t('Hít thở 3 phút để khoá lại'),
                route: '/breathing',
              ),
              JourneySuggestion(
                icon: Icons.headphones,
                label: context.t('Nghe nhạc êm'),
                route: '/sounds',
              ),
              JourneySuggestion(
                icon: Icons.insights,
                label: context.t('Xem nhịp tuần này'),
                route: '/home?tab=2',
              ),
            ],
          );
        });
      } else {
        final msg = context.t((res.data?['message'] as String?) ?? 'Không lưu được nhật ký');
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
        title: Text(context.t('Xoá nhật ký?')),
        content: Text(context.t('Hành động này không thể hoàn tác.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t('Hủy')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RelaxColors.coral),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.t('Xoá')),
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
            Text(
              context.t('Nhật ký của bạn'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              context.t('Viết vài dòng để sau này nhìn lại.'),
              style: const TextStyle(color: RelaxColors.slate),
            ),
            const SizedBox(height: 20),
            JournalComposer(
              titleController: _titleCtrl,
              bodyController: _bodyCtrl,
              saving: _saving,
              onSave: _save,
            ),
            const SizedBox(height: 24),
            Text(
              context.t('Gần đây'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  context.t('Chưa có nhật ký nào. Viết dòng đầu tiên đi nào!'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: RelaxColors.slate),
                ),
              )
            else
              ..._entries.map((e) => JournalEntryCard(
                    entry: e,
                    onToggleFavorite: () => _toggleFavorite(e),
                    onDelete: () => _delete(e),
                  )),
          ],
        ),
      ),
    );
  }
}
