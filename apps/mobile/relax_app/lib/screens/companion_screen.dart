import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../widgets/soft_toast.dart';

/// Màn linh thú: xem trạng thái (level / độ thân thiết / năng lượng) và
/// tương tác (Vuốt ve / Cho ăn / Chơi) qua POST /user-companions/me/interactions.
/// Đồng thời cho phép đặt tên linh thú và thay đổi chế độ cá nhân hóa (Zodiac, Chinese Zodiac, Custom).
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
  Map<String, dynamic>? _personalizationOptions;
  List<Map<String, dynamic>> _customAssets = [];
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
      await _loadOptions();
      await _loadCustomAssets();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadOptions() async {
    try {
      final res = await RelaxApi.instance
          .get('/user-companions/me/personalization-options');
      if (res.statusCode == 200 && res.data is Map) {
        if (mounted) {
          setState(() {
            _personalizationOptions = Map<String, dynamic>.from(res.data);
          });
        }
      }
    } catch (e) {
      debugPrint('Load options failed: $e');
    }
  }

  Future<void> _loadCustomAssets() async {
    try {
      final res = await RelaxApi.instance.get('/companion-assets');
      if (res.statusCode == 200 && res.data is Map) {
        final items = res.data['items'] as List?;
        if (items != null) {
          final filtered = items
              .whereType<Map>()
              .where((a) =>
                  a['zodiacSign'] == null &&
                  a['chineseZodiac'] == null &&
                  a['isDefault'] != true &&
                  a['isActive'] == true)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          if (mounted) {
            setState(() {
              _customAssets = filtered;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Load custom assets failed: $e');
    }
  }

  Future<void> _interact(String type, String successMsg) async {
    HapticFeedback.mediumImpact();
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

  Future<void> _editCompanionName(String currentName) async {
    final ctrl = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi tên linh thú'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(hintText: 'Tên linh thú của bạn'),
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
    if (newName == null || newName.isEmpty || newName == currentName) return;

    if (!mounted) return;
    setState(() => _busy = true);
    try {
      final res = await RelaxApi.instance.patch(
        '/user-companions/me',
        body: {'name': newName},
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        showSoftToast(context,
            message: 'Đổi tên linh thú thành công!',
            tone: SoftToastTone.success);
        await _load();
      } else {
        showSoftToast(context,
            message: 'Đổi tên linh thú thất bại.',
            tone: SoftToastTone.error);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context, message: 'Lỗi: $e', tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changePersonalizationMode(String mode, {String? assetId}) async {
    HapticFeedback.selectionClick();
    final profile = _personalizationOptions?['profile'] as Map?;
    final birthday = profile?['birthday'] as String?;

    if ((mode == 'ZODIAC' || mode == 'CHINESE_ZODIAC') && birthday == null) {
      if (!mounted) return;
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        helpText: 'Chọn ngày sinh để tính Cung hoàng đạo & Con giáp',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: RelaxColors.violet,
                onPrimary: Colors.white,
                surface: context.surface,
                onSurface: context.appText,
              ),
            ),
            child: child!,
          );
        },
      );
      if (pickedDate == null) return;

      if (!mounted) return;
      setState(() => _busy = true);
      try {
        final res = await RelaxApi.instance.patch(
          '/user-profiles/me/profile',
          body: {'birthday': pickedDate.toUtc().toIso8601String()},
        );
        if (!mounted) return;
        if (res.statusCode != 200 && res.statusCode != 201) {
          showSoftToast(context,
              message: 'Cập nhật ngày sinh thất bại.',
              tone: SoftToastTone.error);
          setState(() => _busy = false);
          return;
        }
      } catch (e) {
        if (mounted) {
          showSoftToast(context, message: 'Lỗi: $e', tone: SoftToastTone.error);
          setState(() => _busy = false);
        }
        return;
      }
    }

    if (!mounted) return;
    setState(() => _busy = true);
    try {
      final body = <String, dynamic>{
        'personalizationMode': mode,
        'preserveProgress': true,
      };
      if (assetId != null) {
        body['assetId'] = assetId;
      }

      final res = await RelaxApi.instance.patch(
        '/user-companions/me/personalization-mode',
        body: body,
      );

      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        showSoftToast(context,
            message: 'Đổi chế độ linh thú thành công!',
            tone: SoftToastTone.success);
        await _load();
      } else {
        final msg = (res.data is Map ? res.data['message'] as String? : null) ?? 'Đổi chế độ linh thú thất bại.';
        showSoftToast(context,
            message: msg,
            tone: SoftToastTone.error);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context, message: 'Lỗi: $e', tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _fallbackEmoji(String? type) {
    switch (type?.toUpperCase()) {
      case 'CAT':
        return '🐱';
      case 'DOG':
        return '🐶';
      case 'PANDA':
        return '🐼';
      case 'DRAGON':
        return '🐉';
      case 'RABBIT':
        return '🐰';
      case 'FOX':
        return '🦊';
      case 'BEAR':
        return '🐻';
      default:
        return '🐾';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (_companion?['name'] as String?) ?? 'Linh thú';
    final level = (_companion?['level'] as num?)?.toInt() ?? 1;
    final affection = (_companion?['affection'] as num?)?.toInt() ?? 0;
    final energy = (_companion?['energy'] as num?)?.toInt() ?? 0;
    final mood = (_companion?['mood'] as String?) ?? 'CHILL';
    final companionType = (_companion?['type'] as String?) ?? 'CAT';

    final asset = _companion?['asset'] as Map?;
    final previewUrl = asset?['previewImageUrl'] as String?;
    final currentMode = (_companion?['personalizationMode'] as String?) ?? 'DEFAULT';
    final currentAssetId = _companion?['assetId'] as String?;

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
                                  child: previewUrl != null && previewUrl.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            previewUrl,
                                            height: 110,
                                            width: 110,
                                            fit: BoxFit.contain,
                                            errorBuilder: (ctx, err, stack) => Text(
                                              _fallbackEmoji(companionType),
                                              style: const TextStyle(fontSize: 56),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          _fallbackEmoji(companionType),
                                          style: const TextStyle(fontSize: 56),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _busy ? null : () => _editCompanionName(name),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                  ),
                                ],
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
                        const SizedBox(height: 32),
                        const Text(
                          'Chế độ hiển thị linh thú',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đồng bộ linh thú theo phong cách cá nhân của bạn.',
                          style: TextStyle(color: context.mutedText, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        _buildPersonalizationModes(currentMode),
                        if (currentMode == 'CUSTOM' && _customAssets.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Kho linh thú tự chọn',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildCustomAssetsGrid(currentAssetId),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPersonalizationModes(String currentMode) {
    final modesList = [
      {'mode': 'DEFAULT', 'label': 'Mặc định', 'icon': Icons.pets},
      {'mode': 'ZODIAC', 'label': 'Cung hoàng đạo', 'icon': Icons.star_border},
      {'mode': 'CHINESE_ZODIAC', 'label': '12 con giáp', 'icon': Icons.calendar_month},
      {'mode': 'CUSTOM', 'label': 'Tự chọn', 'icon': Icons.dashboard_customize},
    ];

    return Column(
      children: modesList.map((m) {
        final mode = m['mode'] as String;
        final label = m['label'] as String;
        final icon = m['icon'] as IconData;
        final isSelected = currentMode == mode;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: context.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? RelaxColors.violet : context.fieldBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: Icon(icon, color: isSelected ? RelaxColors.violet : context.mutedText),
            title: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isSelected ? RelaxColors.violet : context.appText,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: RelaxColors.violet)
                : null,
            onTap: _busy
                ? null
                : (isSelected && mode != 'CUSTOM')
                    ? null
                    : () {
                        if (mode == 'CUSTOM') {
                          if (_customAssets.isNotEmpty) {
                            final randomAsset = _customAssets[
                                Random().nextInt(_customAssets.length)];
                            _changePersonalizationMode('CUSTOM',
                                assetId: randomAsset['id'] as String);
                          } else {
                            showSoftToast(context,
                                message: 'Kho linh thú tự chọn trống.',
                                tone: SoftToastTone.info);
                          }
                        } else {
                          _changePersonalizationMode(mode);
                        }
                      },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomAssetsGrid(String? currentAssetId) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _customAssets.length,
      itemBuilder: (context, idx) {
        final asset = _customAssets[idx];
        final id = asset['id'] as String;
        final name = asset['name'] as String;
        final preview = asset['previewImageUrl'] as String?;
        final type = asset['type'] as String?;
        final isSelected = currentAssetId == id;

        return GestureDetector(
          onTap: _busy || isSelected
              ? null
              : () => _changePersonalizationMode('CUSTOM', assetId: id),
          child: Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? RelaxColors.violet : context.fieldBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  child: preview != null && preview.isNotEmpty
                      ? Image.network(
                          preview,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) => Text(
                            _fallbackEmoji(type),
                            style: const TextStyle(fontSize: 28),
                          ),
                        )
                      : Text(
                          _fallbackEmoji(type),
                          style: const TextStyle(fontSize: 28),
                        ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? RelaxColors.violet : context.appText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
