import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';
import 'buddy_checkin_sheet.dart';

/// Buddy system — add friends, see their streaks, gentle nudges.
class BuddiesScreen extends StatefulWidget {
  const BuddiesScreen({super.key});

  @override
  State<BuddiesScreen> createState() => _BuddiesScreenState();
}

class _BuddiesScreenState extends State<BuddiesScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pending = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        RelaxApi.instance.get('/friends/me'),
        RelaxApi.instance.get('/friends/pending'),
      ]);

      _friends = _extractList(results[0].data);
      _pending = _extractList(results[1].data);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    final items = data is Map ? data['items'] : data;
    if (items is List) {
      return items
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  Future<void> _acceptRequest(String requesterId) async {
    try {
      await RelaxApi.instance.post('/friends/accept/$requesterId');
      if (mounted) {
        showSoftToast(context,
            message: context.t('Đã chấp nhận lời mời!'),
            tone: SoftToastTone.success);
      }
      await _load();
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: e.toString(), tone: SoftToastTone.error);
      }
    }
  }

  void _showAddDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t('Thêm bạn đồng hành')),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: context.t('Email hoặc ID của bạn bè'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t('Hủy')),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = ctrl.text.trim();
              if (id.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await RelaxApi.instance.post('/friends/request/$id');
                if (mounted) {
                  showSoftToast(context,
                      message: context.t('Đã gửi lời mời!'),
                      tone: SoftToastTone.success);
                }
              } catch (e) {
                if (mounted) {
                  showSoftToast(context,
                      message: e.toString(), tone: SoftToastTone.error);
                }
              }
            },
            child: Text(context.t('Gửi lời mời')),
          ),
        ],
      ),
    );
  }

  void _showCheckinPicker() {
    if (_friends.length == 1) {
      BuddyCheckinSheet.show(context, _friends.first);
      return;
    }
    // Multiple friends — let the user pick one first.
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: ctx.fieldBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.t('Gửi cho ai?'),
              style: TextStyle(
                color: ctx.appText,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ..._friends.map((f) {
              final user = f['friend'] as Map? ?? f;
              final name = user['name'] as String? ??
                  (user['email'] as String?)?.split('@').first ??
                  '?';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      RelaxColors.violet.withValues(alpha: 0.12),
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      color: RelaxColors.violet,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(name,
                    style: TextStyle(
                        color: ctx.appText, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  BuddyCheckinSheet.show(context, f);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          context.t('Bạn đồng hành'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1, color: context.appText),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      floatingActionButton: _friends.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: RelaxColors.violet,
              onPressed: () => _showCheckinPicker(),
              icon: const Icon(Icons.favorite_outline, color: Colors.white),
              label: Text(
                context.t('Check on me'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: RelaxColors.violet))
          : RefreshIndicator(
              color: RelaxColors.violet,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  if (_pending.isNotEmpty) ...[
                    _sectionTitle(context.t('Lời mời đang chờ')),
                    const SizedBox(height: 8),
                    ..._pending.map((p) => _PendingCard(
                          request: p,
                          onAccept: _acceptRequest,
                        )),
                    const SizedBox(height: 20),
                  ],
                  _sectionTitle(context.t('Bạn bè')),
                  const SizedBox(height: 8),
                  if (_friends.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          const Text('👥', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            context.t('Chưa có bạn đồng hành nào.'),
                            style: TextStyle(color: context.mutedText),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.t('Mời bạn bè để cùng theo dõi sức khỏe tinh thần!'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: context.mutedText, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RelaxColors.violet,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _showAddDialog,
                            icon: const Icon(Icons.person_add,
                                color: Colors.white, size: 18),
                            label: Text(
                              context.t('Thêm bạn'),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._friends.map((f) => _FriendCard(friend: f)),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        const Text('✦ ', style: TextStyle(color: RelaxColors.violet)),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: context.appText,
          ),
        ),
      ],
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend});
  final Map<String, dynamic> friend;

  @override
  Widget build(BuildContext context) {
    final user = friend['friend'] as Map? ?? friend;
    final name = user['name'] as String? ??
        (user['email'] as String?)?.split('@').first ??
        '?';
    final avatar = user['avatar'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: RelaxColors.violet.withValues(alpha: 0.12),
            backgroundImage:
                avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      color: RelaxColors.violet,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              showSoftToast(context,
                  message: context.t('Đã gửi lời nhắc nhẹ 💜'),
                  tone: SoftToastTone.success);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: RelaxColors.violet.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.t('Nhắc nhẹ'),
                style: const TextStyle(
                  color: RelaxColors.violet,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.request, required this.onAccept});
  final Map<String, dynamic> request;
  final void Function(String id) onAccept;

  @override
  Widget build(BuildContext context) {
    final requester = request['requester'] as Map? ?? request;
    final name = requester['name'] as String? ??
        (requester['email'] as String?)?.split('@').first ??
        '?';
    final requesterId = requester['id'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RelaxColors.violet.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RelaxColors.violet.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: RelaxColors.violet.withValues(alpha: 0.12),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                color: RelaxColors.violet,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: context.appText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  context.t('Muốn trở thành bạn đồng hành'),
                  style: TextStyle(color: context.mutedText, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RelaxColors.violet,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () => onAccept(requesterId),
            child: Text(
              context.t('Chấp nhận'),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
