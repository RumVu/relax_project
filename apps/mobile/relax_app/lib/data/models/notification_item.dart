import 'package:flutter/material.dart';

/// Một mục thông báo trong inbox của user.
///
/// Nguồn:
/// - System: welcome, feature release, app update
/// - Engagement: streak milestone, "đã 2 ngày chưa check-in"
/// - Content: mood log success, journal save, payment confirm
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.createdAt,
    this.read = false,
    this.actionLabel,
    this.actionPayload,
  });

  final String id;
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final DateTime createdAt;
  final bool read;

  /// Optional CTA: "Xem ngay", "Bắt đầu", "Đăng nhập"...
  final String? actionLabel;

  /// Routing key cho action — `home`, `relax`, `setup`, `insights`,
  /// `journal`, `crisis`, `search`.
  final String? actionPayload;

  NotificationItem copyWith({bool? read}) => NotificationItem(
        id: id,
        title: title,
        body: body,
        icon: icon,
        color: color,
        createdAt: createdAt,
        read: read ?? this.read,
        actionLabel: actionLabel,
        actionPayload: actionPayload,
      );

  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    final d = createdAt;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }
}
