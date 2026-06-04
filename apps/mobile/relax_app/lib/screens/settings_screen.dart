import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/auth_state.dart';
import '../core/theme.dart';
import '../core/api_client.dart';
import '../core/theme_controller.dart';
import '../widgets/cat_mascot.dart';
import '../widgets/mood_line_chart.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final user = auth.user;
    final name = (user?['name'] as String?) ?? 'Người dùng';
    final email = (user?['email'] as String?) ?? '';
    final avatar = user?['avatar'] as String?;
    final role = (user?['role'] as String?) ?? 'USER';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Setup ✨',
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            // Header có mascot như mockup.
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tùy chỉnh không gian của $name ~',
                    style: TextStyle(color: context.mutedText, fontSize: 13),
                  ),
                ),
                const CatMascot(size: 56, emoji: '😺', glow: false),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileHero(name: name, email: email, avatar: avatar, role: role),
            const SizedBox(height: 24),
            const _SectionLabel('Thông báo'),
            const _NotificationCard(),
            const SizedBox(height: 24),
            const _SectionLabel('Khám phá'),
            _Card(
              children: [
                _Row(
                  icon: Icons.insights_outlined,
                  title: 'Phân tích cảm xúc',
                  subtitle: 'Biểu đồ & phân bố cảm xúc của bạn',
                  onTap: () => context.push('/analytics'),
                ),
                const _Divider(),
                _Row(
                  icon: Icons.cloud_outlined,
                  title: 'Thời tiết',
                  subtitle: 'Theo dõi thời tiết & dự báo',
                  onTap: () => context.push('/weather'),
                ),
                const _Divider(),
                _Row(
                  icon: Icons.pets_outlined,
                  title: 'Linh thú',
                  subtitle: 'Nuôi và tương tác với bạn đồng hành',
                  onTap: () => context.push('/companion'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Quy định & sử dụng'),
            _Card(
              children: [
                _Row(
                  icon: Icons.description_outlined,
                  title: 'Điều khoản, bản quyền & giấy phép',
                  subtitle: 'Đọc trước khi sử dụng',
                  onTap: () => context.push('/legal'),
                ),
                const _Divider(),
                _Row(
                  icon: Icons.info_outline,
                  title: 'Giới thiệu',
                  subtitle: 'Phiên bản 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Thống kê tình trạng'),
            const _StatsCard(),
            const SizedBox(height: 24),
            const _SectionLabel('Giao diện'),
            const _ThemeToggleCard(),
            const SizedBox(height: 24),
            const _SectionLabel('Nạp thẻ / Nâng cấp'),
            _Card(
              children: [
                _Row(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Mở khóa tính năng nâng cao',
                  subtitle: 'Phân tích sâu, companion theo cung & con giáp',
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: RelaxColors.violet,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Nạp ngay',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => _showNotImplemented(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Tài khoản'),
            _Card(
              children: [
                _Row(
                  icon: Icons.delete_outline,
                  title: 'Xóa tài khoản',
                  subtitle: 'Xóa vĩnh viễn toàn bộ dữ liệu của bạn',
                  trailing: const Icon(Icons.chevron_right,
                      color: RelaxColors.coral),
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _LogoutButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: RelaxColors.violet,
      content: Text('Tính năng đang được hoàn thiện ở phiên bản kế.'),
    ));
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Relax',
      applicationVersion: '1.0.0',
      applicationLegalese:
          'Theo dõi cảm xúc, hít thở và nhật ký mỗi ngày — phần thưởng nhỏ cho người chịu khó chăm sóc bản thân.',
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: const Text(
          'Bạn chắc chứ…? Mọi dữ liệu sẽ biến mất và sẽ không quay lại được đâu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: RelaxColors.coral),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      // Backend chưa mở endpoint self-delete cho mobile — báo rõ thay vì
      // giả vờ xóa.
      _showNotImplemented(context);
    }
  }
}

/// Khung giờ nhận nhắc nhở — chip 17:00 / 19:00 / 21:00 + "Mở rộng" + âm báo,
/// dựng theo mockup. Lựa chọn hiện lưu tại chỗ (chưa đẩy backend reminder).
class _NotificationCard extends StatefulWidget {
  const _NotificationCard();

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  final _times = ['17:00', '19:00', '21:00'];
  String _selected = '21:00';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn khung giờ muốn nhận thông báo nhé ~',
            style: TextStyle(color: context.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ..._times.map((t) {
                final sel = _selected == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? RelaxColors.violet : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? RelaxColors.violet : context.fieldBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            t,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: sel ? Colors.white : context.appText,
                            ),
                          ),
                          if (sel)
                            const Icon(Icons.check_circle,
                                size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.fieldBorder),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.add, color: context.mutedText, size: 18),
                      Text(
                        'Mở rộng',
                        style:
                            TextStyle(fontSize: 11, color: context.mutedText),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: context.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.volume_up_outlined,
                    color: RelaxColors.violet, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Âm báo: Tiếng mèo con kêu 🐱',
                    style: TextStyle(
                      color: context.appText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: context.mutedText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thống kê tình trạng — biểu đồ cảm xúc 7 ngày + ước lượng giảm stress,
/// tính từ check-in cảm xúc gần nhất.
class _StatsCard extends StatefulWidget {
  const _StatsCard();

  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard> {
  bool _loading = true;
  List<double?> _daily = List.filled(7, null);
  int _stressDelta = 0; // % giảm stress (dương = giảm)
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res =
          await RelaxApi.instance.get('/mood-checkins/me', query: {'limit': 100});
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // 7 ngày gần nhất: index 0 = 6 ngày trước … 6 = hôm nay.
      final sums = List<double>.filled(7, 0);
      final counts = List<int>.filled(7, 0);
      int stressEarly = 0, stressLate = 0, earlyN = 0, lateN = 0;
      if (items is List) {
        for (final it in items.whereType<Map>()) {
          _total++;
          final createdRaw = it['createdAt'] as String?;
          final intensity = (it['intensity'] as num?)?.toDouble() ?? 3;
          final mood = it['mood'] as String?;
          if (createdRaw == null) continue;
          final created = DateTime.tryParse(createdRaw);
          if (created == null) continue;
          final day = DateTime(created.year, created.month, created.day);
          final diff = today.difference(day).inDays;
          if (diff >= 0 && diff < 7) {
            final idx = 6 - diff;
            sums[idx] += intensity;
            counts[idx] += 1;
          }
          // Stress đầu kỳ (3-7 ngày trước) vs cuối kỳ (0-3 ngày).
          final isStress = mood == 'STRESSED' || mood == 'ANXIOUS';
          if (diff >= 3 && diff < 7) {
            earlyN++;
            if (isStress) stressEarly++;
          } else if (diff >= 0 && diff < 3) {
            lateN++;
            if (isStress) stressLate++;
          }
        }
      }
      final daily = List<double?>.generate(7, (i) {
        if (counts[i] == 0) return null;
        // intensity 1..5 → 0..1.
        return ((sums[i] / counts[i]) - 1) / 4;
      });
      final earlyRate = earlyN == 0 ? 0.0 : stressEarly / earlyN;
      final lateRate = lateN == 0 ? 0.0 : stressLate / lateN;
      final delta = ((earlyRate - lateRate) * 100).round();
      if (mounted) {
        setState(() {
          _daily = daily;
          _stressDelta = delta;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Xem lại hành trình cảm xúc của bạn',
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Theo tuần',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.appText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const SizedBox(
              height: 130,
              child: Center(
                child: CircularProgressIndicator(color: RelaxColors.violet),
              ),
            )
          else if (_total == 0)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Chưa có dữ liệu cảm xúc.\nGhi vài lần để xem biểu đồ nhé!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.mutedText, fontSize: 12),
                ),
              ),
            )
          else ...[
            MoodLineChart(values: _daily),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _stressDelta >= 0
                        ? Icons.trending_down
                        : Icons.trending_up,
                    color:
                        _stressDelta >= 0 ? RelaxColors.mint : RelaxColors.coral,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _stressDelta >= 0
                          ? 'Giảm stress $_stressDelta% so với đầu tuần'
                          : 'Stress tăng ${-_stressDelta}% — nhớ nghỉ ngơi nhé',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.appText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
  });
  final String name;
  final String email;
  final String? avatar;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RelaxColors.violet, RelaxColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: RelaxColors.violet.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            foregroundImage:
                avatar != null ? NetworkImage(avatar!) : null,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: RelaxColors.violet,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _editName(context, name),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.white70, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, String current) async {
    final ctrl = TextEditingController(text: current);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên hiển thị'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(hintText: 'Tên hiển thị'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == current) return;
    if (!context.mounted) return;
    final ok = await context.read<AuthState>().updateDisplayName(newName);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: ok ? RelaxColors.mint : RelaxColors.coral,
      content: Text(ok ? 'Đã đổi tên hiển thị' : 'Không đổi được tên'),
    ));
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: RelaxColors.slate,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(children: children),
    );
  }
}

/// Bộ chọn giao diện Sáng / Tối / Hệ thống — lưu ngay qua ThemeController.
class _ThemeToggleCard extends StatelessWidget {
  const _ThemeToggleCard();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final mode = controller.mode;
    Widget option(ThemeMode m, IconData icon, String label) {
      final selected = mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.setMode(m),
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? RelaxColors.violet : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : context.mutedText,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : context.mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: [
          option(ThemeMode.light, Icons.light_mode_outlined, 'Sáng'),
          option(ThemeMode.dark, Icons.dark_mode_outlined, 'Tối'),
          option(ThemeMode.system, Icons.brightness_auto_outlined, 'Hệ thống'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: RelaxColors.violet.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: RelaxColors.violet, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(Icons.chevron_right, color: context.mutedText)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      color: context.fieldBorder,
      indent: 64,
      endIndent: 14,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: RelaxColors.coral.withValues(alpha: 0.1),
          foregroundColor: RelaxColors.coral,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: RelaxColors.coral),
          ),
        ),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Đăng xuất?'),
              content: const Text(
                'Bạn sẽ phải đăng nhập lại để dùng app.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            await context.read<AuthState>().logout();
            if (context.mounted) context.go('/login');
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
