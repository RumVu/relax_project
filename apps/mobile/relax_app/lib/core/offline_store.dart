import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'api_client.dart';

enum SyncStatus { pending, syncing, failed, resolved }

class SyncQueueItem {
  final String id;
  final String method;
  final String path;
  final dynamic body;
  final DateTime createdAt;
  SyncStatus status;
  String? errorMessage;
  int retryCount;

  SyncQueueItem({
    required this.id,
    required this.method,
    required this.path,
    this.body,
    required this.createdAt,
    this.status = SyncStatus.pending,
    this.errorMessage,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'path': path,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'errorMessage': errorMessage,
        'retryCount': retryCount,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        id: json['id'] as String? ?? '',
        method: json['method'] as String? ?? 'POST',
        path: json['path'] as String? ?? '',
        body: json['body'],
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        status: SyncStatus.values.firstWhere(
          (s) => s.name == (json['status'] as String? ?? 'pending'),
          orElse: () => SyncStatus.pending,
        ),
        errorMessage: json['errorMessage'] as String?,
        retryCount: json['retryCount'] as int? ?? 0,
      );
}

/// Offline-first cache + sync queue with conflict resolution.
class OfflineStore extends ChangeNotifier {
  OfflineStore._();
  static final OfflineStore instance = OfflineStore._();

  late Box<String> _cacheBox;
  late Box<String> _queueBox;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _initialized = false;
  bool _flushing = false;

  List<SyncQueueItem> _queueItems = [];
  List<SyncQueueItem> get queueItems => List.unmodifiable(_queueItems);
  int get pendingCount =>
      _queueItems.where((i) => i.status == SyncStatus.pending).length;
  int get failedCount =>
      _queueItems.where((i) => i.status == SyncStatus.failed).length;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox<String>('offline_cache');
    _queueBox = await Hive.openBox<String>('sync_queue');
    _initialized = true;
    _loadQueueItems();

    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) {
      final hasNet = results.any((r) => r != ConnectivityResult.none);
      if (hasNet) flushQueue();
    });
  }

  void _loadQueueItems() {
    _queueItems = [];
    for (final key in _queueBox.keys) {
      final raw = _queueBox.get(key);
      if (raw == null) continue;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        if (json['id'] == null) json['id'] = key.toString();
        _queueItems.add(SyncQueueItem.fromJson(json));
      } catch (_) {}
    }
    notifyListeners();
  }

  // ─── Cache ──────────────────────────────────────────────

  void cacheResponse(String path, Map<String, dynamic>? query, dynamic data) {
    final key = _cacheKey(path, query);
    _cacheBox.put(key, jsonEncode(data));
  }

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

  Future<void> enqueue({
    required String method,
    required String path,
    dynamic body,
  }) async {
    final id = '${DateTime.now().millisecondsSinceEpoch}_${_queueBox.length}';
    final item = SyncQueueItem(
      id: id,
      method: method,
      path: path,
      body: body,
      createdAt: DateTime.now(),
    );
    await _queueBox.put(id, jsonEncode(item.toJson()));
    _queueItems.add(item);
    notifyListeners();
  }

  int get queueLength => _queueBox.length;

  Future<void> flushQueue() async {
    if (_flushing) return;
    final pendingItems =
        _queueItems.where((i) => i.status == SyncStatus.pending).toList();
    if (pendingItems.isEmpty) return;
    _flushing = true;

    try {
      for (final item in pendingItems) {
        item.status = SyncStatus.syncing;
        notifyListeners();

        try {
          switch (item.method) {
            case 'POST':
              await RelaxApi.instance.post(item.path, body: item.body);
            case 'PATCH':
              await RelaxApi.instance.patch(item.path, body: item.body);
            case 'DELETE':
              await RelaxApi.instance.delete(item.path, body: item.body);
          }
          item.status = SyncStatus.resolved;
          await _queueBox.delete(item.id);
          _queueItems.remove(item);
        } catch (e) {
          item.retryCount++;
          final errMsg = e.toString();

          if (_isConflict(errMsg) || item.retryCount >= 3) {
            item.status = SyncStatus.failed;
            item.errorMessage = _isConflict(errMsg)
                ? 'Xung đột dữ liệu — server có phiên bản mới hơn'
                : 'Thử lại ${item.retryCount} lần không thành công';
          } else {
            item.status = SyncStatus.pending;
          }
          await _queueBox.put(item.id, jsonEncode(item.toJson()));
        }
        notifyListeners();
      }
    } finally {
      _flushing = false;
    }
  }

  bool _isConflict(String error) {
    final lower = error.toLowerCase();
    return lower.contains('409') ||
        lower.contains('conflict') ||
        lower.contains('outdated') ||
        lower.contains('stale');
  }

  /// Resolve a failed item by choosing local (retry force) or server (discard).
  Future<void> resolveConflict(String itemId, {required bool keepLocal}) async {
    final idx = _queueItems.indexWhere((i) => i.id == itemId);
    if (idx < 0) return;

    if (keepLocal) {
      _queueItems[idx].status = SyncStatus.pending;
      _queueItems[idx].retryCount = 0;
      _queueItems[idx].errorMessage = null;
      await _queueBox.put(itemId, jsonEncode(_queueItems[idx].toJson()));
      notifyListeners();
      flushQueue();
    } else {
      await _queueBox.delete(itemId);
      _queueItems.removeAt(idx);
      notifyListeners();
    }
  }

  Future<void> discardItem(String itemId) async {
    await _queueBox.delete(itemId);
    _queueItems.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  Future<void> retryAll() async {
    for (final item in _queueItems) {
      if (item.status == SyncStatus.failed) {
        item.status = SyncStatus.pending;
        item.retryCount = 0;
        item.errorMessage = null;
        await _queueBox.put(item.id, jsonEncode(item.toJson()));
      }
    }
    notifyListeners();
    flushQueue();
  }

  // ─── Connectivity check ─────────────────────────────────

  Future<bool> get isOnline async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
