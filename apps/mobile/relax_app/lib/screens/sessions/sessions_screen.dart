import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

/// Quản lý phiên đăng nhập — xem devices, revoke sessions.
class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await RelaxApi.instance.get('/sessions/me');
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      _sessions = (items is List)
          ? items
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _revoke(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t('Thu hồi phiên?')),
        content:
            Text(context.t('Thiết bị này sẽ bị đăng xuất.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t('Hủy')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RelaxColors.coral),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.t('Thu hồi')),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await RelaxApi.instance.delete('/sessions/$id');
      if (mounted) {
        showSoftToast(context,
            message: context.t('Đã thu hồi phiên'),
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
          context.t('Phiên đăng nhập'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: RelaxColors.violet))
          : RefreshIndicator(
              color: RelaxColors.violet,
              onRefresh: _load,
              child: _sessions.isEmpty
                  ? ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            context.t('Không có phiên nào.'),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: context.mutedText),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      itemCount: _sessions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) =>
                          _SessionCard(session: _sessions[i], onRevoke: _revoke),
                    ),
            ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onRevoke});
  final Map<String, dynamic> session;
  final void Function(String id) onRevoke;

  @override
  Widget build(BuildContext context) {
    final id = session['id'] as String? ?? '';
    final device = session['deviceName'] as String? ??
        session['userAgent'] as String? ??
        context.t('Không rõ');
    final ip = session['ipAddress'] as String? ?? '';
    final createdAt = session['createdAt'] as String? ?? '';
    final isCurrent = session['isCurrent'] == true;

    String timeAgo = '';
    final parsed = DateTime.tryParse(createdAt);
    if (parsed != null) {
      final diff = DateTime.now().difference(parsed);
      if (diff.inDays > 0) {
        timeAgo = '${diff.inDays} ${context.t('ngày trước')}';
      } else if (diff.inHours > 0) {
        timeAgo = '${diff.inHours} ${context.t('giờ trước')}';
      } else {
        timeAgo = context.t('Vừa xong');
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? RelaxColors.violet : context.fieldBorder,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone_iphone,
            color: isCurrent ? RelaxColors.violet : context.mutedText,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.length > 40 ? '${device.substring(0, 40)}…' : device,
                        style: TextStyle(
                          color: context.appText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: RelaxColors.violet.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          context.t('Hiện tại'),
                          style: const TextStyle(
                            color: RelaxColors.violet,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$timeAgo${ip.isNotEmpty ? ' · $ip' : ''}',
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              icon: const Icon(Icons.logout, color: RelaxColors.coral, size: 20),
              onPressed: () => onRevoke(id),
            ),
        ],
      ),
    );
  }
}
