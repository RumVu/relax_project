import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';
import 'widgets/action_button.dart';
import 'widgets/companion_error_box.dart';
import 'widgets/stat_bar.dart';

/// Companion screen: view status (level / affection / energy) and
/// interact (Pet / Feed / Play) via POST /user-companions/me/interactions.
/// Also allows naming the companion and changing personalization mode
/// (Zodiac, Chinese Zodiac, Custom).
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
      duration: const Duration(milliseconds: 320),
      lowerBound: 0.9,
      upperBound: 1.1,
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
      _companion = res.data is Map ? Map<String, dynamic>.from(res.data as Map) : null;

      final resOpts = await RelaxApi.instance.get('/user-companions/me/personalization-options');
      _personalizationOptions = resOpts.data is Map ? Map<String, dynamic>.from(resOpts.data as Map) : null;

      final resAssets = await RelaxApi.instance.get('/ambient-sounds/companion-assets');
      final assetData = resAssets.data;
      final assetList = assetData is Map ? assetData['items'] : assetData;
      _customAssets = (assetList is List)
          ? assetList
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

  Future<void> _interact(String type, String successMsg) async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    unawaited(_bounce.forward().then((_) => _bounce.reverse()));

    try {
      final res = await RelaxApi.instance.post(
        '/user-companions/me/interactions',
        body: {'type': type},
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        showSoftToast(context,
            message: successMsg, tone: SoftToastTone.success);
        await _load();
      } else {
        showSoftToast(context,
            message: context.t((res.data?['message'] as String?) ?? 'Có lỗi xảy ra'),
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
        title: Text(context.t('Đổi tên linh thú')),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 30,
          decoration: InputDecoration(hintText: context.t('Tên linh thú của bạn')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t('Hủy')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(context.t('Lưu')),
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
            message: context.t('Đổi tên linh thú thành công!'),
            tone: SoftToastTone.success);
        await _load();
      } else {
        showSoftToast(context,
            message: context.t('Đổi tên linh thú thất bại.'),
            tone: SoftToastTone.error);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context, message: '${context.t('Lỗi:')} $e', tone: SoftToastTone.error);
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
        helpText: context.t('Chọn ngày sinh để tính Cung hoàng đạo & Con giáp'),
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
              message: context.t('Cập nhật ngày sinh thất bại.'),
              tone: SoftToastTone.error);
          setState(() => _busy = false);
          return;
        }
      } catch (e) {
        if (mounted) {
          showSoftToast(context, message: '${context.t('Lỗi:')} $e', tone: SoftToastTone.error);
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
            message: context.t('Đổi chế độ linh thú thành công!'),
            tone: SoftToastTone.success);
        await _load();
      } else {
        final msg = context.t((res.data is Map ? res.data['message'] as String? : null) ?? 'Đổi chế độ linh thú thất bại.');
        showSoftToast(context,
            message: msg,
            tone: SoftToastTone.error);
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context, message: '${context.t('Lỗi:')} $e', tone: SoftToastTone.error);
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
    final name = (_companion?['name'] as String?) ?? context.t('Linh thú');
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
          context.t('Linh thú của bạn'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: RelaxColors.violet))
            : _error != null
                ? CompanionErrorBox(message: _error!, onRetry: _load)
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
                                  '${context.t('Cấp')} $level · ${context.t(mood)}',
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
                        StatBar(
                          label: context.t('Độ thân thiết'),
                          value: affection,
                          color: RelaxColors.coral,
                          icon: Icons.favorite,
                        ),
                        const SizedBox(height: 14),
                        StatBar(
                          label: context.t('Năng lượng'),
                          value: energy,
                          color: RelaxColors.mint,
                          icon: Icons.bolt,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          context.t('Tương tác'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ActionButton(
                                    icon: Icons.pan_tool_alt_outlined,
                                    label: context.t('Vuốt ve'),
                                    onTap: _busy
                                        ? null
                                        : () => _interact('PET', context.t('Linh thú thích lắm!')),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ActionButton(
                                    icon: Icons.restaurant,
                                    label: context.t('Cho ăn'),
                                    onTap: _busy
                                        ? null
                                        : () => _interact('FEED', context.t('Đã cho ăn ngon lành!')),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ActionButton(
                                    icon: Icons.sports_esports_outlined,
                                    label: context.t('Chơi'),
                                    onTap: _busy
                                        ? null
                                        : () => _interact('PLAY', context.t('Chơi vui quá!')),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ActionButton(
                                    icon: Icons.chat_bubble_outline,
                                    label: context.t('Trò chuyện'),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      context.push('/companion-chat');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          context.t('Chế độ hiển thị linh thú'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.t('Đồng bộ linh thú theo phong cách cá nhân của bạn.'),
                          style: TextStyle(color: context.mutedText, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        _buildPersonalizationModes(currentMode),
                        if (currentMode == 'CUSTOM' && _customAssets.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            context.t('Kho linh thú tự chọn'),
                            style: const TextStyle(
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
        final label = context.t(m['label'] as String);
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
                                message: context.t('Kho linh thú tự chọn trống.'),
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
