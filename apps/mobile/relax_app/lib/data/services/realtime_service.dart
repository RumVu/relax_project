import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../config/env.dart';

/// Realtime client kết nối tới backend Socket.IO `/realtime` namespace.
///
/// Backend gateway xác thực qua JWT trong handshake `auth.token`. Sau khi
/// join, user nhận events qua room riêng `user:<id>` + role room.
///
/// Lifecycle:
///   1. Shell sau login → call `RealtimeService.instance.connect(token)`
///   2. Mỗi event được forward qua ValueNotifier để UI subscribe
///   3. Logout → `disconnect()`
///
/// Events backend emit:
///   - `realtime.ready` — connection acked
///   - `notification.created` — new notification
///   - `reminder.created` / `reminder.updated`
///   - `mood.logged` / `relax_session.completed`
///   - `subscription.activated` (sau payment thành công)
///
/// Khi nhận event, callback subscriber được invoke (caller registerListener).
class RealtimeService extends ChangeNotifier {
  RealtimeService._();
  static final instance = RealtimeService._();

  io.Socket? _socket;
  bool _connected = false;
  String? _lastError;
  final Map<String, List<void Function(dynamic)>> _listeners = {};

  bool get isConnected => _connected;
  String? get lastError => _lastError;

  /// Kết nối Socket.IO. Nếu đã có socket → disconnect trước rồi reconnect
  /// với token mới (vd: refresh sau khi token refresh).
  void connect(String accessToken) {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    // backend URL từ env, namespace /realtime đã có sẵn ở backend
    final url = Env.apiUrl.replaceFirst(RegExp(r'/v1$'), '');
    try {
      _socket = io.io(
        '$url/realtime',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': accessToken})
            .setExtraHeaders({'Authorization': 'Bearer $accessToken'})
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .build(),
      );
      _wireHandlers();
      _socket!.connect();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _connected = false;
    _lastError = null;
    notifyListeners();
  }

  /// Đăng ký listener cho event cụ thể. Trả unsubscribe function.
  VoidCallback on(String event, void Function(dynamic data) callback) {
    _listeners.putIfAbsent(event, () => []).add(callback);
    _socket?.on(event, callback);
    return () {
      _listeners[event]?.remove(callback);
      _socket?.off(event, callback);
    };
  }

  void _wireHandlers() {
    final s = _socket;
    if (s == null) return;
    s.onConnect((_) {
      _connected = true;
      _lastError = null;
      debugPrint('[realtime] connected');
      notifyListeners();
    });
    s.onDisconnect((reason) {
      _connected = false;
      debugPrint('[realtime] disconnected: $reason');
      notifyListeners();
    });
    s.onConnectError((err) {
      _lastError = err?.toString() ?? 'connect_error';
      _connected = false;
      debugPrint('[realtime] connect_error: $_lastError');
      notifyListeners();
    });
    s.on('realtime.auth_failed', (data) {
      _lastError = 'AUTH_FAILED';
      debugPrint('[realtime] auth_failed: $data');
      notifyListeners();
    });
    s.on('realtime.ready', (data) {
      debugPrint('[realtime] ready: $data');
    });
    // Re-attach saved listeners (đã register trước khi connect)
    _listeners.forEach((event, callbacks) {
      for (final cb in callbacks) {
        s.on(event, cb);
      }
    });
  }
}
