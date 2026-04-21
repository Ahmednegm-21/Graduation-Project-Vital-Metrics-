import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
// NotificationType
// ══════════════════════════════════════════════════════════════════════════════
enum NotificationType {
  water   ('💧', 'Water',       Color(0xFF4CC9F0)),
  sleep   ('🌙', 'Sleep',       Color(0xFF7B5EA7)),
  exercise('🏃', 'Exercise',    Color(0xFF63E6BE)),
  loseW   ('🔥', 'Lose Weight', Color(0xFFFF6B6B)),
  gainW   ('💪', 'Gain Weight', Color(0xFFFFA94D)),
  nutrition('🥗','Nutrition',   Color(0xFF51CF66));

  final String emoji, label;
  final Color  color;
  const NotificationType(this.emoji, this.label, this.color);

  // من الـ backend string للـ enum
  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'water':     return NotificationType.water;
      case 'sleep':     return NotificationType.sleep;
      case 'exercise':  return NotificationType.exercise;
      case 'lose_weight':
      case 'losew':     return NotificationType.loseW;
      case 'gain_weight':
      case 'gainw':     return NotificationType.gainW;
      case 'nutrition': return NotificationType.nutrition;
      default:          return NotificationType.water;
    }
  }

  // للـ backend
  String get apiValue {
    switch (this) {
      case NotificationType.water:     return 'water';
      case NotificationType.sleep:     return 'sleep';
      case NotificationType.exercise:  return 'exercise';
      case NotificationType.loseW:     return 'lose_weight';
      case NotificationType.gainW:     return 'gain_weight';
      case NotificationType.nutrition: return 'nutrition';
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NotificationItem
// ══════════════════════════════════════════════════════════════════════════════
class NotificationItem {
  final String           id;
  final NotificationType type;
  final String           title;
  final String           body;
  final String           time;
  bool                   isRead;
  bool                   isSelected;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isRead     = false,
    this.isSelected = false,
  });

  // ── fromJson — من الـ backend ─────────────────────────────────────────────
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id:     json['id']?.toString()    ?? '',
      type:   NotificationType.fromString(json['type'] as String? ?? 'water'),
      title:  json['title']  as String? ?? '',
      body:   json['body']   as String? ??
              json['message'] as String? ?? '',
      time:   _formatTime(json['created_at'] as String?),
      isRead: json['is_read'] as bool?  ?? false,
    );
  }

  // ── toJson — للـ backend ──────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'id':      id,
    'type':    type.apiValue,
    'title':   title,
    'body':    body,
    'is_read': isRead,
  };

  NotificationItem copyWith({
    bool? isRead,
    bool? isSelected,
  }) => NotificationItem(
    id:         id,
    type:       type,
    title:      title,
    body:       body,
    time:       time,
    isRead:     isRead     ?? this.isRead,
    isSelected: isSelected ?? this.isSelected,
  );

  // ── Helper: حوّل ISO date لـ human readable ───────────────────────────────
  static String _formatTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1)  return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours   < 24) return '${diff.inHours} hr ago';
      if (diff.inDays    < 7)  return '${diff.inDays} days ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Default notifications — تُستخدم لو الـ API فشل أو offline
// ══════════════════════════════════════════════════════════════════════════════
List<NotificationItem> defaultNotifications() => [
  NotificationItem(
    id: '1', type: NotificationType.water,
    title: '💧 Time to Hydrate!',
    body: 'You haven\'t logged water in 3 hours. Drinking enough water boosts your metabolism by up to 30% and keeps hunger at bay.',
    time: '5 min ago', isRead: false,
  ),
  NotificationItem(
    id: '2', type: NotificationType.sleep,
    title: '🌙 Sleep Reminder',
    body: 'Getting 7–9 hours of quality sleep regulates hunger hormones. Poor sleep can slow weight loss by 55%. Wind down now!',
    time: '20 min ago', isRead: false,
  ),
  NotificationItem(
    id: '3', type: NotificationType.exercise,
    title: '🏃 Move Your Body!',
    body: 'You\'re 1,200 steps from your daily goal. Just a 15-min brisk walk burns ~80 kcal.',
    time: '1 hr ago', isRead: false,
  ),
  NotificationItem(
    id: '4', type: NotificationType.loseW,
    title: '🔥 Calorie Deficit on Track',
    body: 'Great work! You\'re at a healthy 350 kcal deficit today.',
    time: '2 hr ago', isRead: true,
  ),
  NotificationItem(
    id: '5', type: NotificationType.water,
    title: '💧 Hydration Goal Reached!',
    body: 'You\'ve logged 8 glasses today! Staying hydrated reduces water retention.',
    time: '3 hr ago', isRead: true,
  ),
];