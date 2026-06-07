import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/notification_item.dart';

/// Inbox local — sinh thông báo từ state app + lưu read status vào prefs.
///
/// Không dùng push backend (chưa cần). Mỗi lần app open, service:
///   1. Generate "system" notifications dựa trên app state (welcome, streak,
///      feature highlight, idle warning)
///   2. Merge với user-generated noti từ prefs (mood logged, journal saved)
///   3. Áp dụng read status từ prefs (key = notification id)
///
/// Note: chỉ sinh notifications phù hợp ngữ cảnh (user state) — không spam.
class InboxService {
  InboxService._();
  static final instance = InboxService._();

  static const _readKey = 'inbox_read_ids';
  static const _firstOpenKey = 'inbox_first_open_at';

  /// Build inbox cho 1 user — context-aware notifications.
  ///
  /// [isLoggedIn], [moodHistoryCount], [streakDays], [hasAccentTheme]
  /// dùng để gen notification phù hợp.
  Future<List<NotificationItem>> build({
    required bool isLoggedIn,
    required int moodHistoryCount,
    required int streakDays,
    required bool hasAccentTheme,
    DateTime? lastMoodAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = (prefs.getStringList(_readKey) ?? const <String>[]).toSet();

    // First-open timestamp để welcome noti hiển thị ngày đầu
    final firstOpenMs = prefs.getInt(_firstOpenKey);
    final now = DateTime.now();
    final firstOpen = firstOpenMs != null
        ? DateTime.fromMillisecondsSinceEpoch(firstOpenMs)
        : now;
    if (firstOpenMs == null) {
      await prefs.setInt(_firstOpenKey, now.millisecondsSinceEpoch);
    }

    final items = <NotificationItem>[];

    // ── Welcome (luôn có nếu < 7 ngày kể từ first open)
    if (now.difference(firstOpen).inDays < 7) {
      items.add(NotificationItem(
        id: 'welcome',
        title: 'Chào mừng đến với Thi Ái Chill ✦',
        body: 'Mình ở đây để cùng bạn dịu lại mỗi ngày. Khi nào sẵn sàng, '
            'thử 1 phiên thư giãn ngắn nha ~',
        icon: Icons.celebration_rounded,
        color: const Color(0xFFFFC96E),
        createdAt: firstOpen,
        actionLabel: 'Bắt đầu',
        actionPayload: 'relax',
      ));
    }

    // ── Streak milestone (3, 7, 14, 30 ngày)
    if (streakDays >= 3) {
      final milestone = _milestoneFor(streakDays);
      if (milestone != null) {
        items.add(NotificationItem(
          id: 'streak-$milestone',
          title: '🔥 Streak $milestone ngày!',
          body: 'Bạn đã chăm sóc bản thân $milestone ngày liên tiếp. '
              'Mình hãnh diện về bạn 💜',
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFE85A6A),
          createdAt: now.subtract(const Duration(hours: 1)),
          actionLabel: 'Xem streak',
          actionPayload: 'insights',
        ));
      }
    }

    // ── Idle warning (>2 ngày chưa check-in mood)
    if (isLoggedIn && lastMoodAt != null) {
      final since = now.difference(lastMoodAt);
      if (since.inDays >= 2) {
        items.add(NotificationItem(
          id: 'idle-${since.inDays}d',
          title: 'Hơn ${since.inDays} ngày chưa gặp bạn nè ~',
          body: 'Cảm xúc hôm nay của bạn ra sao? Một tap thôi, mình lắng '
              'nghe nha 💜',
          icon: Icons.favorite_border_rounded,
          color: const Color(0xFF6C4DE6),
          createdAt: now.subtract(const Duration(minutes: 30)),
          actionLabel: 'Check-in',
          actionPayload: 'home',
        ));
      }
    }

    // ── Onboarding nudge khi chưa login
    if (!isLoggedIn) {
      items.add(NotificationItem(
        id: 'login-nudge',
        title: 'Đăng nhập để mình theo dõi giúp bạn ✦',
        body: 'Streak, mood history, nhật ký — tất cả đồng bộ khi bạn có '
            'tài khoản. Free hoàn toàn nha ~',
        icon: Icons.login_rounded,
        color: const Color(0xFF48D3A8),
        createdAt: now.subtract(const Duration(hours: 2)),
        actionLabel: 'Đăng nhập',
        actionPayload: 'login',
      ));
    }

    // ── Feature highlight: Customs theme
    if (!hasAccentTheme) {
      items.add(NotificationItem(
        id: 'feature-customs-theme',
        title: 'Bạn biết app có Customs theme không?',
        body: 'Vào Setup → Giao diện → Customs để chọn màu nhấn cá nhân. '
            '10 màu pastel xinh xỉu đợi bạn 🎨',
        icon: Icons.palette_rounded,
        color: const Color(0xFF9C86FF),
        createdAt: now.subtract(const Duration(days: 1)),
        actionLabel: 'Chọn màu',
        actionPayload: 'setup',
      ));
    }

    // ── Crisis support always-on info (low-key, không spam)
    items.add(NotificationItem(
      id: 'crisis-info',
      title: 'Khi bạn thực sự khó khăn ~',
      body: 'Setup → Hỗ trợ khẩn cấp có sẵn hotline + tài nguyên hỗ trợ '
          'tâm lý. Mình ở đây, nhưng đôi khi cần một con người 💜',
      icon: Icons.health_and_safety_rounded,
      color: const Color(0xFFFFAFD2),
      createdAt: firstOpen,
      actionLabel: 'Xem',
      actionPayload: 'crisis',
    ));

    // Apply read status + sort newest first
    final result = items
        .map((n) => n.copyWith(read: readIds.contains(n.id)))
        .toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Đếm số chưa đọc — dùng cho badge bell icon.
  Future<int> unreadCount({
    required bool isLoggedIn,
    required int moodHistoryCount,
    required int streakDays,
    required bool hasAccentTheme,
    DateTime? lastMoodAt,
  }) async {
    final items = await build(
      isLoggedIn: isLoggedIn,
      moodHistoryCount: moodHistoryCount,
      streakDays: streakDays,
      hasAccentTheme: hasAccentTheme,
      lastMoodAt: lastMoodAt,
    );
    return items.where((n) => !n.read).length;
  }

  Future<void> markRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final read = (prefs.getStringList(_readKey) ?? const <String>[]).toSet();
    read.add(id);
    await prefs.setStringList(_readKey, read.toList());
  }

  Future<void> markAllRead(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final read = (prefs.getStringList(_readKey) ?? const <String>[]).toSet();
    read.addAll(ids);
    await prefs.setStringList(_readKey, read.toList());
  }

  Future<void> clearRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_readKey);
  }

  int? _milestoneFor(int days) {
    const milestones = [3, 7, 14, 30, 60, 100, 365];
    int? best;
    for (final m in milestones) {
      if (days >= m) best = m;
    }
    return best;
  }
}

/// Helper convert raw to/from json (for future remote sync).
@visibleForTesting
String encodeIds(Set<String> ids) => jsonEncode(ids.toList());
