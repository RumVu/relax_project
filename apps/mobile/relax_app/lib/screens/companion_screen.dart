import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../widgets/soft_toast.dart';

/// Màn linh thú: xem trạng thái (level / độ thân thiết / năng lượng) và
/// tương tác (Vuốt ve / Cho ăn / Chơi) qua POST /user-companions/me/interactions.
class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  Map<String, dynamic>? _companion;
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _load();
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await RelaxApi.instance.get('/user-companions/me');
      _companion = res.data is Map ? Map<String, dynamic>.from(res.data) : null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _interact(String type, String successMsg) async {
    setState(() => _busy = true);
    _bounce.reverse().then((_) => _bounce.forward());
    try {
      final res = await RelaxApi.instance
          .post('/user-companions/me/interactions', body: {'type': type});
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        showSoftToast(context,
            message: successMsg, tone: SoftToastTone.success);
        await _load();
      } else {
        showSoftToast(context,
            message: (res.data?['message'] as String?) ?? 'Có lỗi xảy ra',
            tone: SoftToastTone.error);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: e.toString(), tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (_companion?['name'] as String?) ?? 'Linh thú';
    final level = (_companion?['level'] as num?)?.toInt() ?? 1;
    final affection = (_companion?['affection'] as num?)?.toInt() ?? 0;
    final energy = (_companion?['energy'] as num?)?.toInt() ?? 0;
    final mood = (_companion?['mood'] as String?) ?? 'CHILL';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Linh thú của bạn',
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: RelaxColors.violet))
            : _error != null
                ? _ErrorBox(message: _error!, onRetry: _load)
                : RefreshIndicator(
                    color: RelaxColors.violet,
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        // Companion hero
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [RelaxColors.violet, RelaxColors.plum],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              ScaleTransition(
                                scale: _bounce,
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('🐾',
                                      style: TextStyle(fontSize: 56)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Cấp $level · $mood',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _StatBar(
                          label: 'Độ thân thiết',
                          value: affection,
                          color: RelaxColors.coral,
                          icon: Icons.favorite,
                        ),
                        const SizedBox(height: 14),
                        _StatBar(
                          label: 'Năng lượng',
                          value: energy,
                          color: RelaxColors.mint,
                          icon: Icons.bolt,
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Tương tác',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.pan_tool_alt_outlined,
                                label: 'Vuốt ve',
                                onTap: _busy
                                    ? null
                                    : () => _interact('PET', 'Linh thú thích lắm!'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.restaurant,
                                label: 'Cho ăn',
                                onTap: _busy
                                    ? null
                                    : () => _interact('FEED', 'Đã cho ăn ngon lành!'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.sports_esports_outlined,
                                label: 'Chơi',
                                onTap: _busy
                                    ? null
                                    : () => _interact('PLAY', 'Chơi vui quá!'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: context.appText,
              ),
            ),
            const Spacer(),
            Text(
              '$value%',
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: RelaxColors.lilac,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.fieldBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: RelaxColors.violet),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: context.appText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: RelaxColors.coral, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: RelaxColors.coral, fontSize: 13),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
