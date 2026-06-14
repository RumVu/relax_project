import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/audio_controller.dart';
import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import 'widgets/now_playing_bar.dart';
import 'widgets/track_tile.dart';

// Trinh phat am thanh nen / podcast. Phat qua AudioController dung chung
// nen nhac tiep tuc khi user thoat man (mini-player toan cuc hien o shell).
class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key, this.category});

  final String? category;

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _tracks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final query = <String, dynamic>{'limit': 100};
      if (widget.category != null) {
        query['category'] = widget.category;
      } else {
        query['excludeCategories'] = 'PODCAST,MEDITATION,BUDDHA,NOTIFICATION';
      }
      final res = await RelaxApi.instance
          .get('/ambient-sounds', query: query);
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      var list = (items is List)
          ? items
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .where((e) => (e['soundUrl'] as String?)?.isNotEmpty == true)
              .toList()
          : <Map<String, dynamic>>[];
      _tracks = list;
      if (mounted) context.read<AudioController>().setQueue(_tracks);
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _playTrack(int index) {
    if (!mounted) return;
    final auth = context.read<AuthState>();
    if (auth.activeSessionId == null) {
      final cat = widget.category ?? 'MUSIC';
      String type = 'MUSIC';
      String title = 'Nhạc';
      if (cat == 'PODCAST') {
        type = 'PODCAST';
        title = 'Podcast';
      } else if (cat == 'MEDITATION') {
        type = 'MEDITATION';
        title = 'Thiền định';
      }
      auth.startRelaxSession(type, title);
    }
    context.read<AudioController>().playAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.category == 'PODCAST'
              ? context.t('Podcast')
              : context.t('Nhạc thư giãn'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: RelaxColors.violet))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: RelaxColors.coral, fontSize: 12),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: RelaxColors.violet,
                          onRefresh: _load,
                          child: _tracks.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height: 320,
                                      child: Center(
                                        child: Text(
                                          context.t(
                                              'Chưa có bản nào.\nKéo xuống để tải lại.'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: context.mutedText),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  itemCount: _tracks.length,
                                  itemBuilder: (context, i) {
                                    final t = _tracks[i];
                                    final playing =
                                        identical(audio.current, _tracks[i]) ||
                                            audio.current?['id'] == t['id'];
                                    return TrackTile(
                                      track: t,
                                      playing: playing,
                                      audio: audio,
                                      onTap: () => _playTrack(i),
                                    );
                                  },
                                ),
                        ),
                      ),
                      if (audio.hasTrack) NowPlayingBar(audio: audio),
                    ],
                  ),
      ),
    );
  }
}
