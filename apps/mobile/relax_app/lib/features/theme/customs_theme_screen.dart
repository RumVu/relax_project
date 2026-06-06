import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/preferences.dart';

/// Customs theme — chọn accent color cá nhân.
/// Lưu vào AppPreferences, áp dụng cho toàn app sau khi save.
class CustomsThemeScreen extends StatefulWidget {
  const CustomsThemeScreen({super.key, this.onAccentChanged});

  /// Khi non-null: lưu màu xong → invoke để app_root live-apply theme
  /// ngay (không cần restart).
  final ValueChanged<Color>? onAccentChanged;

  @override
  State<CustomsThemeScreen> createState() => _CustomsThemeScreenState();
}

class _CustomsThemeScreenState extends State<CustomsThemeScreen> {
  Color _accent = RelaxTheme.purple;
  AppPreferences? _prefs;

  static const _palette = [
    Color(0xFF6C4DE6), // purple (default)
    Color(0xFFE85A6A), // coral
    Color(0xFF48D3A8), // mint
    Color(0xFFFFC96E), // amber
    Color(0xFFE971E5), // pink
    Color(0xFF5DB1FF), // sky
    Color(0xFFFF7A5C), // peach
    Color(0xFF9C86FF), // lavender
    Color(0xFF6BD4D4), // teal
    Color(0xFFF59E0B), // honey
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await AppPreferences.instance();
    if (!mounted) return;
    setState(() {
      _prefs = p;
      _accent = Color(p.accentColorValue);
    });
  }

  Future<void> _save() async {
    await _prefs?.setAccentColorValue(_accent.toARGB32());
    // Live-apply: callback đẩy lên app_root → MaterialApp rebuild với accent
    // mới ngay → không cần restart app nữa.
    widget.onAccentChanged?.call(_accent);
    if (!mounted) return;
    final msg = widget.onAccentChanged != null
        ? 'Đã đổi màu nhấn ✦'
        : 'Đã lưu màu — restart app để áp dụng ✦';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.of(context).pop(_accent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tùy chỉnh màu'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Lưu'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accent, _accent.withValues(alpha: .6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.palette_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Màu nhấn',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '#${_accent.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chọn một màu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final c in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _accent = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _accent == c
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: c.withValues(alpha: _accent == c ? .6 : .25),
                            blurRadius: _accent == c ? 16 : 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _accent == c
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 26,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.relax.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: RelaxTheme.lavender,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.onAccentChanged != null
                          ? 'Bấm "Lưu" để đổi màu nhấn toàn app ngay lập tức.'
                          : 'Bấm "Lưu" + restart app để áp dụng màu mới.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11.5,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
