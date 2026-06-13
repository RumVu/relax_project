import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/locale_controller.dart';
import '../../core/theme.dart';

/// "I Need Help Now" — crisis support screen.
///
/// Shows hotlines, a safety disclaimer, emergency-contact quick-dial,
/// and a breathing exercise shortcut. Designed to be maximally accessible
/// under duress: large tap targets, high contrast, minimal cognitive load.
class CrisisHelpScreen extends StatelessWidget {
  const CrisisHelpScreen({super.key});

  // ── Hotline data ──────────────────────────────────────────────────────
  static const _hotlines = [
    _Hotline(
      name: 'Tổng đài Tư vấn Sức khỏe Tâm thần Quốc gia',
      phone: '1800 599 100',
      hours: 'Miễn phí — 24/7',
    ),
    _Hotline(
      name: 'Đường dây nóng Hỗ trợ Tâm lý',
      phone: '1800 599 920',
      hours: 'Miễn phí — 24/7',
    ),
    _Hotline(
      name: '988 Suicide & Crisis Lifeline (US)',
      phone: '988',
      hours: '24/7',
    ),
    _Hotline(
      name: 'Samaritans (UK)',
      phone: '116 123',
      hours: '24/7',
    ),
  ];

  Future<void> _callPhone(BuildContext context, String phone) async {
    // Strip spaces for the tel: URI.
    final cleaned = phone.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleaned');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {
      // Fallback: copy to clipboard.
      await Clipboard.setData(ClipboardData(text: phone));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('Đã sao chép số điện thoại'))),
        );
      }
    }
  }

  Future<void> _callEmergencyContact(BuildContext context) async {
    String? phone;
    try {
      final box = Hive.box('emergency_contact');
      phone = box.get('phone') as String?;
    } catch (_) {}

    if (phone == null || phone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context
                .t('Chưa có liên hệ khẩn cấp. Vui lòng cài đặt trong phần Cài đặt.')),
          ),
        );
      }
      return;
    }

    await _callPhone(context, phone);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Hỗ trợ khẩn cấp'),
          style: TextStyle(
            color: context.appText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // ── Header ──────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [RelaxColors.coral, RelaxColors.violet],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.t('Bạn không đơn độc'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: context.appText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.t('Có người sẵn sàng lắng nghe bạn'),
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appText.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Safety disclaimer ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? RelaxColors.surfaceDark
                  : RelaxColors.sun.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: RelaxColors.sun.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    color: RelaxColors.sun, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.t(
                      'App này không thay thế chuyên gia tâm lý/y tế. '
                      'Nếu bạn đang trong tình trạng nguy hiểm, '
                      'hãy gọi ngay cho đường dây hỗ trợ hoặc cấp cứu 115.',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: context.appText.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Hotline cards ───────────────────────────────────────────
          Text(
            context.t('Đường dây hỗ trợ'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 12),
          ..._hotlines.map((h) => _HotlineCard(
                hotline: h,
                onCall: () => _callPhone(context, h.phone),
              )),

          const SizedBox(height: 20),

          // ── Emergency contact ───────────────────────────────────────
          _ActionButton(
            icon: Icons.person,
            label: context.t('Gọi người thân tin tưởng'),
            color: RelaxColors.coral,
            onTap: () => _callEmergencyContact(context),
          ),

          const SizedBox(height: 12),

          // ── Breathing shortcut ──────────────────────────────────────
          _ActionButton(
            icon: Icons.air,
            label: context.t('Hít thở để bình tĩnh hơn'),
            color: RelaxColors.mint,
            onTap: () => context.push('/breathing'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Private helpers ─────────────────────────────────────────────────────────

class _Hotline {
  const _Hotline({
    required this.name,
    required this.phone,
    required this.hours,
  });
  final String name;
  final String phone;
  final String hours;
}

class _HotlineCard extends StatelessWidget {
  const _HotlineCard({required this.hotline, required this.onCall});
  final _Hotline hotline;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? RelaxColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onCall,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: RelaxColors.violet.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone, color: RelaxColors.violet),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotline.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: context.appText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hotline.phone,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: RelaxColors.violet,
                        ),
                      ),
                      Text(
                        hotline.hours,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appText.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.call,
                  color: RelaxColors.mint,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(label, style: const TextStyle(fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
