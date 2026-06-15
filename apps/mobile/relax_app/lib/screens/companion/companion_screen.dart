import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';
import 'helpers/companion_helpers.dart';
import 'widgets/action_button.dart';
import 'widgets/companion_error_box.dart';
import 'widgets/custom_assets_grid.dart';
import 'widgets/personalization_modes.dart';
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
                                              fallbackEmoji(
                                                companionType,
                                                assetKey: asset?['key'] as String?,
                                                chineseZodiac: asset?['chineseZodiac'] as String?,
                                              ),
                                              style: const TextStyle(fontSize: 56),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          fallbackEmoji(
                                            companionType,
                                            assetKey: asset?['key'] as String?,
                                            chineseZodiac: asset?['chineseZodiac'] as String?,
                                          ),
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
                        const SizedBox(height: 24),
                        _CompanionMemoryCard(companionName: name),
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
                        PersonalizationModes(
                          currentMode: currentMode,
                          busy: _busy,
                          customAssets: _customAssets,
                          onChangeMode: _changePersonalizationMode,
                        ),
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
                          CustomAssetsGrid(
                            customAssets: _customAssets,
                            currentAssetId: currentAssetId,
                            busy: _busy,
                            onSelectAsset: (id) => _changePersonalizationMode('CUSTOM', assetId: id),
                          ),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _CompanionMemoryCard extends StatefulWidget {
  final String companionName;
  const _CompanionMemoryCard({required this.companionName});

  @override
  State<_CompanionMemoryCard> createState() => _CompanionMemoryCardState();
}

class _CompanionMemoryCardState extends State<_CompanionMemoryCard> {
  Map<String, dynamic>? _weekly;
  List<dynamic> _memories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Future.wait([
        RelaxApi.instance.get('/user-companions/me/memory/weekly'),
        RelaxApi.instance.get('/user-companions/me/memory'),
      ]);
      if (!mounted) return;
      setState(() {
        _weekly = res[0].data is Map ? Map<String, dynamic>.from(res[0].data as Map) : null;
        final memData = res[1].data is Map ? res[1].data as Map : {};
        _memories = (memData['memories'] as List?) ?? [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: RelaxColors.violet),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('Ký ức của ${widget.companionName}'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          context.t('Những gì linh thú nhớ về bạn'),
          style: TextStyle(color: context.mutedText, fontSize: 12),
        ),
        const SizedBox(height: 12),

        // Weekly memory card
        if (_weekly != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💌', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      context.t('Thư tuần này'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...(_weekly!['messages'] as List? ?? []).map((msg) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '$msg',
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                )),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _WeeklyStatChip(
                      label: 'Check-in',
                      value: '${(_weekly!['summary'] as Map?)?['checkinCount'] ?? 0}',
                    ),
                    const SizedBox(width: 8),
                    _WeeklyStatChip(
                      label: 'Hoạt động',
                      value: '${(_weekly!['summary'] as Map?)?['activityCount'] ?? 0}',
                    ),
                    const SizedBox(width: 8),
                    _WeeklyStatChip(
                      label: 'Stress TB',
                      value: '${(_weekly!['summary'] as Map?)?['avgScore'] ?? 50}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Memory insights
        if (_memories.isNotEmpty)
          ...(_memories).map((mem) {
            final m = mem is Map ? mem : {};
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.fieldBorder),
              ),
              child: Row(
                children: [
                  Text('${m['emoji'] ?? '💭'}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${m['text'] ?? ''}',
                      style: TextStyle(
                        color: context.appText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

        if (_memories.isEmpty && _weekly == null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                context.t('${widget.companionName} đang thu thập ký ức...hãy check-in thường xuyên nhé!'),
                style: TextStyle(color: context.mutedText, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _WeeklyStatChip extends StatelessWidget {
  final String label;
  final String value;
  const _WeeklyStatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}
