import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/api_client.dart';
import '../../../core/locale_controller.dart';
import '../../../core/secure_storage.dart';
import '../../../core/theme.dart';
import '../../../widgets/soft_toast.dart';

// Bottom sheet for selecting reminder notification sound with live preview.
void showSoundSelectorSheet(
  BuildContext context, {
  required String selectedSound,
  required ValueChanged<String> onSoundChanged,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => _SoundSelectorBody(
      parentContext: context,
      selectedSound: selectedSound,
      onSoundChanged: onSoundChanged,
    ),
  );
}

class _SoundSelectorBody extends StatefulWidget {
  const _SoundSelectorBody({
    required this.parentContext,
    required this.selectedSound,
    required this.onSoundChanged,
  });

  final BuildContext parentContext;
  final String selectedSound;
  final ValueChanged<String> onSoundChanged;

  @override
  State<_SoundSelectorBody> createState() => _SoundSelectorBodyState();
}

class _SoundSelectorBodyState extends State<_SoundSelectorBody> {
  final AudioPlayer _preview = AudioPlayer();
  List<Map<String, dynamic>> _sounds = [];
  bool _loading = true;
  String? _playingKey;
  late String _currentSelected;

  static const _assetBase =
      'https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets/ambient-sounds';

  // Fallback khi API khong tra duoc — dung URL Supabase that de van nghe thu duoc.
  static const _fallbackSounds = [
    {
      'title': 'Chuông dịu nhẹ 🔔',
      'key': 'gentle-chime',
      'soundUrl': '$_assetBase/notification-gentle-chime.mp3',
    },
    {
      'title': 'Tiếng mèo con kêu 🐱',
      'key': 'cat-purr-bell',
      'soundUrl': '$_assetBase/notification-cat-purr-bell.mp3',
    },
    {
      'title': 'Chuông gió mùa xuân 🎐',
      'key': 'spring-wind-chime',
      'soundUrl': '$_assetBase/notification-spring-wind-chime.mp3',
    },
    {
      'title': 'Tiếng mưa rơi tí tách 🌧️',
      'key': 'rain-tap',
      'soundUrl': '$_assetBase/notification-rain-tap.mp3',
    },
    {
      'title': 'Sóng biển rì rào 🌊',
      'key': 'ocean-whisper',
      'soundUrl': '$_assetBase/notification-ocean-whisper.mp3',
    },
    {
      'title': 'Tiếng chuông thiền 🔔',
      'key': 'zen-bell',
      'soundUrl': '$_assetBase/notification-zen-bell.mp3',
    },
    {
      'title': 'Hạc cầm dịu êm 🎵',
      'key': 'soft-harp',
      'soundUrl': '$_assetBase/notification-soft-harp.mp3',
    },
    {
      'title': 'Giọt pha lê ✨',
      'key': 'crystal-drop',
      'soundUrl': '$_assetBase/notification-crystal-drop.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentSelected = widget.selectedSound;
    _fetchSounds();

    _preview.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) setState(() => _playingKey = null);
      }
    });
  }

  Future<void> _fetchSounds() async {
    try {
      final res = await RelaxApi.instance
          .get('/ambient-sounds/category/NOTIFICATION');
      if (res.statusCode == 200 && res.data is List) {
        final items = (res.data as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .where((e) => (e['soundUrl'] as String?)?.isNotEmpty == true)
            .toList();
        if (items.isNotEmpty && mounted) {
          setState(() {
            _sounds = items;
            _loading = false;
          });
          return;
        }
      }
    } catch (_) {}

    // Fallback: dung danh sach co dinh voi URL Supabase that.
    if (mounted) {
      setState(() {
        _sounds = _fallbackSounds
            .map((s) => Map<String, dynamic>.from(s))
            .toList();
        _loading = false;
      });
    }
  }

  Future<void> _previewAndSelect(Map<String, dynamic> sound) async {
    HapticFeedback.lightImpact();
    final name = (sound['title'] as String?) ?? '';
    final url = sound['soundUrl'] as String?;
    final key = sound['id'] as String? ?? sound['key'] as String? ?? '';

    setState(() {
      _currentSelected = name;
    });

    if (url == null || url.isEmpty) return;

    if (_playingKey == key) {
      // Đang phát -> dừng lại.
      await _preview.stop();
      if (mounted) setState(() => _playingKey = null);
      return;
    }

    // Phát âm thanh mới.
    final errMsg = widget.parentContext.t('Không phát được âm thanh');
    await _preview.stop();
    if (!mounted) return;
    setState(() => _playingKey = key);
    try {
      await _preview.setUrl(url);
      await _preview.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _playingKey = null);
      showSoftToast(context, message: errMsg, tone: SoftToastTone.error);
    }
  }

  Future<void> _saveAndConfirm() async {
    final sound = _sounds.firstWhere(
      (s) => ((s['title'] as String?) ?? '') == _currentSelected,
      orElse: () => <String, dynamic>{},
    );
    if (sound.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final name = (sound['title'] as String?) ?? '';
    final url = sound['soundUrl'] as String?;

    // Dừng preview nếu đang phát.
    await _preview.stop();

    widget.onSoundChanged(name);

    try {
      await secureStorage.write(key: 'relax_reminder_sound', value: name);
      if (url != null && url.isNotEmpty) {
        await secureStorage.write(
            key: 'relax_reminder_sound_url', value: url);
      }
    } catch (_) {}

    if (!widget.parentContext.mounted) return;
    showSoftToast(widget.parentContext,
        message: widget.parentContext
            .t('Đã thay đổi âm báo: {sound}', {'sound': widget.parentContext.t(name)}),
        tone: SoftToastTone.success);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _preview.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle.
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.fieldBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.parentContext.t('Chọn âm báo nhắc nhở 🔔'),
            style: TextStyle(
              color: context.appText,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.parentContext.t('Chạm vào âm báo để nghe thử và chọn'),
            style: TextStyle(color: context.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child:
                    CircularProgressIndicator(color: RelaxColors.violet),
              ),
            )
          else ...[
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _sounds.length,
                separatorBuilder: (_, index) =>
                    Divider(height: 1, color: context.fieldBorder),
                itemBuilder: (_, i) {
                  final s = _sounds[i];
                  final title =
                      (s['title'] as String?) ?? '';
                  final key =
                      s['id'] as String? ?? s['key'] as String? ?? '';
                  final hasUrl =
                      (s['soundUrl'] as String?)?.isNotEmpty == true;
                  final isSelected = _currentSelected == title;
                  final isPlaying = _playingKey == key;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: hasUrl
                        ? IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.stop_circle_rounded
                                  : Icons.play_circle_filled,
                              color: isPlaying
                                  ? RelaxColors.coral
                                  : RelaxColors.violet,
                              size: 32,
                            ),
                            onPressed: () => _previewAndSelect(s),
                          )
                        : const Icon(Icons.music_note,
                            color: RelaxColors.violet),
                    title: Text(
                      widget.parentContext.t(title),
                      style: TextStyle(
                        color: context.appText,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle,
                            color: RelaxColors.violet)
                        : const Icon(Icons.radio_button_unchecked,
                            color: Colors.grey, size: 20),
                    onTap: () => _previewAndSelect(s),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _preview.stop();
                      Navigator.pop(context);
                    },
                    child: Text(widget.parentContext.t('Hủy')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveAndConfirm,
                    child: Text(widget.parentContext.t('Xác nhận')),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
