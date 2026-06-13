import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'api_client.dart';

/// Offline-first cache + sync queue.
///
/// - Cache GET responses locally (mood checkins, journal, preferences).
/// - Queue POST/PATCH/DELETE when offline, replay when back online.
/// - Connectivity listener auto-flushes queue on reconnect.
class OfflineStore {
  OfflineStore._();
  static final OfflineStore instance = OfflineStore._();

  late Box<String> _cacheBox;
  late Box<String> _queueBox;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _initialized = false;
  bool _flushing = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox<String>('offline_cache');
    _queueBox = await Hive.openBox<String>('sync_queue');
    _initialized = true;

    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) {
      final hasNet = results.any((r) => r != ConnectivityResult.none);
      if (hasNet) flushQueue();
    });
  }

  // ─── Cache ──────────────────────────────────────────────

  /// Cache a GET response. Key = path + sorted query params.
  void cacheResponse(String path, Map<String, dynamic>? query, dynamic data) {
    final key = _cacheKey(path, query);
    _cacheBox.put(key, jsonEncode(data));
  }

  /// Read cached response. Returns null if not cached.
  dynamic readCache(String path, {Map<String, dynamic>? query}) {
    final key = _cacheKey(path, query);
    final raw = _cacheBox.get(key);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  void clearCache() => _cacheBox.clear();

  String _cacheKey(String path, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return path;
    final sorted = query.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final qs = sorted.map((e) => '${e.key}=${e.value}').join('&');
    return '$path?$qs';
  }

  // ─── Sync Queue ─────────────────────────────────────────

  /// Enqueue a write operation for later sync.
  Future<void> enqueue({
    required String method,
    required String path,
    dynamic body,
  }) async {
    final entry = jsonEncode({
      'method': method,
      'path': path,
      'body': body,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _queueBox.add(entry);
  }

  int get queueLength => _queueBox.length;

  /// Flush all queued writes. Called automatically on reconnect.
  Future<void> flushQueue() async {
    if (_flushing || _queueBox.isEmpty) return;
    _flushing = true;

    try {
      final keys = _queueBox.keys.toList();
      for (final key in keys) {
        final raw = _queueBox.get(key);
        if (raw == null) continue;
        final entry = jsonDecode(raw) as Map<String, dynamic>;
        final method = entry['method'] as String;
        final path = entry['path'] as String;
        final body = entry['body'];

        try {
          switch (method) {
            case 'POST':
              await RelaxApi.instance.post(path, body: body);
            case 'PATCH':
              await RelaxApi.instance.patch(path, body: body);
            case 'DELETE':
              await RelaxApi.instance.delete(path, body: body);
          }
          await _queueBox.delete(key);
        } catch (_) {
          break;
        }
      }
    } finally {
      _flushing = false;
    }
  }

  // ─── Connectivity check ─────────────────────────────────

  Future<bool> get isOnline async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}
