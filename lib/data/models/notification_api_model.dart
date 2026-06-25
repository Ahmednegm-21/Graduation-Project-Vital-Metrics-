// lib/data/models/notification_api_model.dart

import 'package:vital_metrics/data/models/notification_model.dart';

class NotificationApiModel {
  final int    notificationId;
  final String title;
  final String message;
  final String type;
  final String? data;
  final String time;       // ISO8601 from backend
  final bool   isRead;
  final bool   pushSent;
  final int    userId;

  NotificationApiModel({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
    required this.userId,
    this.data,
    this.pushSent = false,
  });

  // ── fromJson ──────────────────────────────────────────────────────────────
  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      notificationId: (json['notification_id'] as num?)?.toInt() ?? 0,
      title:          json['title']      as String? ?? '',
      message:        json['message']    as String? ?? '',
      type:           json['type']       as String? ?? '',
      data:           json['data']       as String?,
      time:           json['time']       as String? ?? '',
      isRead:         json['is_read']    as bool?   ?? false,
      pushSent:       json['push_sent']  as bool?   ?? false,
      userId:         (json['user_id'] as num?)?.toInt() ?? 0,
    );
  }

  // ── toNotificationItem ────────────────────────────────────────────────────
  NotificationItem toNotificationItem() {
    return NotificationItem(
      notificationId: notificationId,
      title:          title,
      message:        message,
      type:           NotificationType.fromString(type),
      data:           data,
      rawTime:        time,
      time:           _formatTime(time),
      isRead:         isRead,
      pushSent:       pushSent,
      userId:         userId,
    );
  }

  // ── time formatter ────────────────────────────────────────────────────────
  static String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final date = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1)  return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours   < 24) return '${diff.inHours} hr ago';
      if (diff.inDays    == 1) return 'Yesterday';
      if (diff.inDays    < 7)  return '${diff.inDays} days ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return iso;
    }
  }
}