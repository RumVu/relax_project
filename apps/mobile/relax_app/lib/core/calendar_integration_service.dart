import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class CalendarEvent {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool isMeeting;

  CalendarEvent({
    required this.title,
    required this.startTime,
    required this.endTime,
    this.isMeeting = true,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'isMeeting': isMeeting,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        title: json['title'] ?? '',
        startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
        endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
        isMeeting: json['isMeeting'] ?? true,
      );
}

class CalendarIntegrationService {
  static final CalendarIntegrationService instance = CalendarIntegrationService._();
  CalendarIntegrationService._();

  bool _isSynced = false;
  bool get isSynced => _isSynced;
  
  late Box<String> _eventsBox;
  Completer<void>? _initCompleter;

  Future<void> init() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();
    _eventsBox = await Hive.openBox<String>('calendar_events');
    _isSynced = _eventsBox.get('isSynced', defaultValue: 'false') == 'true';
    if (_eventsBox.isEmpty) {
      // Seed default events
      final today = DateTime.now();
      final defaultEvents = [
        CalendarEvent(
          title: "Daily Standup Meeting",
          startTime: DateTime(today.year, today.month, today.day, 9, 30),
          endTime: DateTime(today.year, today.month, today.day, 10, 0),
        ),
        CalendarEvent(
          title: "Sprint Planning",
          startTime: DateTime(today.year, today.month, today.day, 11, 0),
          endTime: DateTime(today.year, today.month, today.day, 12, 30),
        ),
        CalendarEvent(
          title: "Client Demo Review",
          startTime: DateTime(today.year, today.month, today.day, 14, 0),
          endTime: DateTime(today.year, today.month, today.day, 15, 30),
        ),
        CalendarEvent(
          title: "Project Architecture Alignment",
          startTime: DateTime(today.year, today.month, today.day, 16, 0),
          endTime: DateTime(today.year, today.month, today.day, 17, 0),
        ),
      ];
      for (var e in defaultEvents) {
        await _eventsBox.add(jsonEncode(e.toJson()));
      }
    }
    _initCompleter!.complete();
  }

  Future<bool> toggleSync() async {
    await init();
    await Future.delayed(const Duration(milliseconds: 600));
    _isSynced = !_isSynced;
    await _eventsBox.put('isSynced', _isSynced ? 'true' : 'false');
    return _isSynced;
  }

  Future<void> addEvent(CalendarEvent event) async {
    await init();
    await _eventsBox.add(jsonEncode(event.toJson()));
  }

  Future<void> clearEvents() async {
    await init();
    // Clear only events, keep the sync status
    final keysToKeep = ['isSynced'];
    final keys = List.from(_eventsBox.keys);
    for (var key in keys) {
      if (!keysToKeep.contains(key)) {
        await _eventsBox.delete(key);
      }
    }
  }

  List<CalendarEvent> getEvents() {
    if (_initCompleter == null || !_initCompleter!.isCompleted) return [];
    if (!_isSynced) return [];
    final list = <CalendarEvent>[];
    for (var key in _eventsBox.keys) {
      if (key == 'isSynced') continue;
      final val = _eventsBox.get(key);
      if (val != null) {
        try {
          list.add(CalendarEvent.fromJson(jsonDecode(val)));
        } catch (_) {}
      }
    }
    return list;
  }

  String? getWellnessRecommendation() {
    if (_initCompleter == null || !_initCompleter!.isCompleted) return null;
    if (!_isSynced) return null;
    final events = getEvents();
    final meetingsCount = events.where((e) => e.isMeeting).length;

    if (meetingsCount >= 4) {
      return "Lịch của bạn hôm nay có tới $meetingsCount cuộc họp. Hãy thực hiện một bài hít thở ngắn 2 phút Focus Break nhé!";
    } else if (meetingsCount >= 2) {
      return "Bạn có một ngày bận rộn vừa phải. Đừng quên mở ambient sounds lúc làm việc để giữ tập trung.";
    }
    return "Lịch làm việc hôm nay khá thoáng. Tận hưởng nhịp điệu cân bằng nhé!";
  }
}
