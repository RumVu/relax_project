import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// Bộ điều khiển phát nhạc dùng chung toàn app — giữ MỘT AudioPlayer nên
/// nhạc tiếp tục phát khi user chuyển màn. Mini-player toàn cục + màn
/// SoundsScreen đều đọc/điều khiển qua đây.
class AudioController extends ChangeNotifier {
  AudioController() {
    // Cập nhật UI mỗi khi trạng thái phát đổi + detect completion.
    _playerStateSub = _player.playerStateStream.listen((state) {
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;

  /// Broadcast emit khi MỘT track phát xong. Sounds screen / mini-player
  /// có thể listen để hiện JourneyPrompt "Nghe bài khác?". Broadcast
  /// để nhiều listener cùng nghe được.
  final _completionCtrl = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onTrackCompleted => _completionCtrl.stream;

  List<Map<String, dynamic>> _queue = [];
  int _index = -1;

  final Map<String, double> _downloadProgress = {};
  Map<String, double> get downloadProgress => _downloadProgress;

  Future<String> _getLocalPath(String soundId) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/sound_$soundId.mp3';
  }

  Future<bool> isDownloaded(String soundId) async {
    final path = await _getLocalPath(soundId);
    return File(path).existsSync();
  }

  Future<void> download(String soundId, String url) async {
    if (_downloadProgress.containsKey(soundId)) return;
    _downloadProgress[soundId] = 0.0;
    notifyListeners();
    try {
      final path = await _getLocalPath(soundId);
      final dio = Dio();
      await dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress[soundId] = received / total;
            notifyListeners();
          }
        },
      );
      _downloadProgress.remove(soundId);
      notifyListeners();
    } catch (e) {
      _downloadProgress.remove(soundId);
      notifyListeners();
      rethrow;
    }
  }

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
    final t = _queue[i];
    final url = t['soundUrl'] as String?;
    final soundId = t['id'] as String?;
    if (url == null) return;
    _index = i;
    notifyListeners();
    try {
      if (soundId != null) {
        final localPath = await _getLocalPath(soundId);
        if (File(localPath).existsSync()) {
          debugPrint('Playing local cached audio: $localPath');
          await _player.setAudioSource(AudioSource.file(localPath));
          await _player.play();
          return;
        }
      }
      debugPrint('Streaming remote audio: $url');
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

  /// Track end handler: nếu còn track tiếp theo thì auto-advance (không
  /// emit, không làm phiền), chỉ emit khi hết hẳn queue → UI dùng để
  /// hiện JourneyPrompt "Nghe bài khác?" cuối session.
  void _onTrackCompleted() {
    if (hasNext) {
      next();
      return;
    }
    final finished = current;
    _player.stop();
    notifyListeners();
    if (finished != null) {
      _completionCtrl.add(Map<String, dynamic>.from(finished));
    }
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _completionCtrl.close();
    _player.dispose();
    super.dispose();
  }
}
