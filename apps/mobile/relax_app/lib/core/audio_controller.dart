import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Bộ điều khiển phát nhạc dùng chung toàn app — giữ MỘT AudioPlayer nên
/// nhạc tiếp tục phát khi user chuyển màn. Mini-player toàn cục + màn
/// SoundsScreen đều đọc/điều khiển qua đây.
class AudioController extends ChangeNotifier {
  AudioController() {
    // Cập nhật UI mỗi khi trạng thái phát đổi.
    _player.playerStateStream.listen((_) => notifyListeners());
  }

  final AudioPlayer _player = AudioPlayer();

  List<Map<String, dynamic>> _queue = [];
  int _index = -1;

  AudioPlayer get player => _player;
  bool get playing => _player.playing;
  int get index => _index;
  Map<String, dynamic>? get current =>
      (_index >= 0 && _index < _queue.length) ? _queue[_index] : null;
  bool get hasTrack => current != null;
  bool get hasPrev => _index > 0;
  bool get hasNext => _index >= 0 && _index < _queue.length - 1;

  Stream<Duration> get positionStream => _player.positionStream;
  Duration get duration => _player.duration ?? Duration.zero;

  /// Nạp danh sách phát (vd toàn bộ track của một category) — chỉ thay queue,
  /// không tự phát.
  void setQueue(List<Map<String, dynamic>> tracks) {
    _queue = tracks;
    notifyListeners();
  }

  Future<void> playAt(int i) async {
    if (i < 0 || i >= _queue.length) return;
    final url = _queue[i]['soundUrl'] as String?;
    if (url == null) return;
    _index = i;
    notifyListeners();
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Audio playAt failed: $e');
      }
    }
  }

  Future<void> toggle() async {
    if (_player.playing) {
      await _player.pause();
    } else if (_index >= 0) {
      await _player.play();
    } else if (_queue.isNotEmpty) {
      await playAt(0);
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (hasNext) await playAt(_index + 1);
  }

  Future<void> prev() async {
    if (hasPrev) await playAt(_index - 1);
  }

  Future<void> stop() async {
    await _player.stop();
    _index = -1;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
