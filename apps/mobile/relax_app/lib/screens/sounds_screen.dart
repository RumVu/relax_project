import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/api_client.dart';
import '../core/theme.dart';

/// Trình phát âm thanh nền / podcast — dựng theo mockup "Đang nghe nhạc".
/// Lấy danh sách từ /ambient-sounds, phát soundUrl bằng just_audio, có
/// thanh tiến trình + nút trước/phát-dừng/sau.
class SoundsScreen extends StatefulWidget {
  const SoundsScreen({super.key, this.category});

  /// Lọc theo category (vd 'PODCAST'); null = tất cả nhạc nền.
  final String? category;

  @override
  State<SoundsScreen> createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
  final _player = AudioPlayer();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _tracks = [];
  int _current = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await RelaxApi.instance
          .get('/ambient-sounds', query: {'limit': 40});
      final data = res.data;
      final items = data is Map ? data['items'] : data;
      var list = (items is List)
          ? items
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .where((e) => (e['soundUrl'] as String?)?.isNotEmpty == true)
              .toList()
          : <Map<String, dynamic>>[];
      if (widget.category != null) {
        list = list.where((e) => e['category'] == widget.category).toList();
      }
      _tracks = list;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _playIndex(int i) async {
    if (i < 0 || i >= _tracks.length) return;
    final url = _tracks[i]['soundUrl'] as String?;
    if (url == null) return;
    setState(() => _current = i);
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: RelaxColors.coral,
          content: Text('Không phát được: $e'),
        ));
      }
    }
  }

  void _togglePlay() {
    if (_player.playing) {
      _player.pause();
    } else {
      if (_current < 0 && _tracks.isNotEmpty) {
        _playIndex(0);
      } else {
        _player.play();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.category == 'PODCAST' ? 'Podcast' : 'Nhạc thư giãn',
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
                        child: _tracks.isEmpty
                            ? Center(
                                child: Text(
                                  'Chưa có bản nào.',
                                  style: TextStyle(color: context.mutedText),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 8, 16, 8),
                                itemCount: _tracks.length,
                                itemBuilder: (context, i) {
                                  final t = _tracks[i];
                                  final playing = _current == i;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: playing
                                          ? RelaxColors.violet
                                              .withValues(alpha: 0.12)
                                          : context.surface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: playing
                                            ? RelaxColors.violet
                                            : context.fieldBorder,
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: () => _playIndex(i),
                                      leading: CircleAvatar(
                                        backgroundColor: RelaxColors.violet
                                            .withValues(alpha: 0.15),
                                        child: Icon(
                                          playing && _player.playing
                                              ? Icons.graphic_eq
                                              : Icons.music_note,
                                          color: RelaxColors.violet,
                                        ),
                                      ),
                                      title: Text(
                                        (t['title'] as String?) ?? 'Không tên',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: context.appText,
                                        ),
                                      ),
                                      subtitle: Text(
                                        (t['category'] as String?) ?? '',
                                        style: TextStyle(
                                            color: context.mutedText,
                                            fontSize: 12),
                                      ),
                                      trailing: Icon(
                                        playing
                                            ? Icons.equalizer
                                            : Icons.play_arrow,
                                        color: RelaxColors.violet,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (_current >= 0) _nowPlayingBar(context),
                    ],
                  ),
      ),
    );
  }

  Widget _nowPlayingBar(BuildContext context) {
    final t = _tracks[_current];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
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
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.album, color: Colors.white70),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (t['title'] as String?) ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      (t['category'] as String?) ?? 'Đang phát',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Thanh tiến trình thật từ player position/duration.
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snap) {
              final pos = snap.data ?? Duration.zero;
              final dur = _player.duration ?? Duration.zero;
              final value = dur.inMilliseconds == 0
                  ? 0.0
                  : pos.inMilliseconds / dur.inMilliseconds;
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: value.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(pos),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      Text(_fmt(dur),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _current > 0 ? () => _playIndex(_current - 1) : null,
                icon: const Icon(Icons.skip_previous, color: Colors.white),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _player.playing ? Icons.pause : Icons.play_arrow,
                    color: RelaxColors.violet,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _current < _tracks.length - 1
                    ? () => _playIndex(_current + 1)
                    : null,
                icon: const Icon(Icons.skip_next, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
