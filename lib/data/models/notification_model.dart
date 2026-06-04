import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
// NotificationType — mapped from backend "type" field
// ══════════════════════════════════════════════════════════════════════════════
enum NotificationType {
  water       ('💧', 'Water',        Color(0xFF4CC9F0)),
  sleep       ('🌙', 'Sleep',        Color(0xFF7B5EA7)),
  exercise    ('🏃', 'Exercise',     Color(0xFF63E6BE)),
  loseW       ('🔥', 'Lose Weight',  Color(0xFFFF6B6B)),
  gainW       ('💪', 'Gain Weight',  Color(0xFFFFA94D)),
  nutrition   ('🥗', 'Nutrition',    Color(0xFF51CF66)),
  goalReached ('🎉', 'Goal',         Color(0xFF4361EE)),
  general     ('🔔', 'General',      Color(0xFF9B9B9B));

  final String emoji, label;
  final Color  color;
  const NotificationType(this.emoji, this.label, this.color);

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'water':        return NotificationType.water;
      case 'sleep':        return NotificationType.sleep;
      case 'exercise':
      case 'activity':    return NotificationType.exercise;
      case 'lose_weight': return NotificationType.loseW;
      case 'gain_weight': return NotificationType.gainW;
      case 'nutrition':
      case 'meal':        return NotificationType.nutrition;
      case 'goal_reached':
      case 'goal':        return NotificationType.goalReached;
      default:            return NotificationType.general;
    }
  }

  String get apiValue {
    switch (this) {
      case NotificationType.water:       return 'water';
      case NotificationType.sleep:       return 'sleep';
      case NotificationType.exercise:    return 'exercise';
      case NotificationType.loseW:       return 'lose_weight';
      case NotificationType.gainW:       return 'gain_weight';
      case NotificationType.nutrition:   return 'nutrition';
      case NotificationType.goalReached: return 'goal_reached';
      case NotificationType.general:     return 'general';
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NotificationItem — matches backend response exactly
// ══════════════════════════════════════════════════════════════════════════════
class NotificationItem {
  final int              notificationId;
  final String           title;
  final String           message;
  final NotificationType type;
  final String?          data;       // JSON string e.g. {"screen":"goals","goal_id":5}
  final String           time;       // formatted for display
  final String           rawTime;    // ISO8601 from backend
  final bool             pushSent;
  final int              userId;
  bool                   isRead;
  bool                   isSelected;

  NotificationItem({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.rawTime,
    required this.userId,
    this.data,
    this.pushSent    = false,
    this.isRead      = false,
    this.isSelected  = false,
  });

  // ── fromJson ───────────────────────────────────────────────────────────────
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final rawTime = json['time'] as String? ?? '';
    return NotificationItem(
      notificationId: (json['notification_id'] as num?)?.toInt() ?? 0,
      title:   json['title']   as String? ?? '',
      message: json['message'] as String? ?? '',
      type:    NotificationType.fromString(json['type'] as String? ?? ''),
      data:    json['data']    as String?,
      rawTime: rawTime,
      time:    _formatTime(rawTime),
      isRead:  json['is_read'] as bool? ?? false,
      pushSent: json['push_sent'] as bool? ?? false,
      userId:  (json['user_id'] as num?)?.toInt() ?? 0,
    );
  }

  // ── toJson ─────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'notification_id': notificationId,
    'title':           title,
    'message':         message,
    'type':            type.apiValue,
    'data':            data,
    'time':            rawTime,
    'is_read':         isRead,
    'push_sent':       pushSent,
    'user_id':         userId,
  };

  NotificationItem copyWith({bool? isRead, bool? isSelected}) =>
      NotificationItem(
        notificationId: notificationId,
        title:    title,
        message:  message,
        type:     type,
        data:     data,
        time:     time,
        rawTime:  rawTime,
        userId:   userId,
        pushSent: pushSent,
        isRead:      isRead      ?? this.isRead,
        isSelected:  isSelected  ?? this.isSelected,
      );

  // ── time formatter ─────────────────────────────────────────────────────────
  static String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final date = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1)  return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours   < 24) return '${diff.inHours} hr ago';
      if (diff.inDays    < 7)  return '${diff.inDays} days ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) { return iso; }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NotificationPreferences
// ══════════════════════════════════════════════════════════════════════════════
class NotificationPreferences {
  final int    preferenceId;
  bool         pushEnabled;
  bool         dailyReminder;
  bool         goalAlerts;
  bool         waterReminders;
  bool         mealReminders;
  bool         activityReminders;
  bool         sleepReminders;
  final String quietHoursStart;
  final String quietHoursEnd;

  NotificationPreferences({
    required this.preferenceId,
    this.pushEnabled        = true,
    this.dailyReminder      = true,
    this.goalAlerts         = true,
    this.waterReminders     = true,
    this.mealReminders      = true,
    this.activityReminders  = true,
    this.sleepReminders     = true,
    this.quietHoursStart    = '22:00',
    this.quietHoursEnd      = '07:00',
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        preferenceId:      (json['preference_id'] as num?)?.toInt() ?? 0,
        pushEnabled:       json['push_enabled']        as bool? ?? true,
        dailyReminder:     json['daily_reminder']      as bool? ?? true,
        goalAlerts:        json['goal_alerts']         as bool? ?? true,
        waterReminders:    json['water_reminders']     as bool? ?? true,
        mealReminders:     json['meal_reminders']      as bool? ?? true,
        activityReminders: json['activity_reminders']  as bool? ?? true,
        sleepReminders:    json['sleep_reminders']     as bool? ?? true,
        quietHoursStart:   json['quiet_hours_start']   as String? ?? '22:00',
        quietHoursEnd:     json['quiet_hours_end']     as String? ?? '07:00',
      );

  Map<String, dynamic> toJson() => {
    'push_enabled':        pushEnabled,
    'daily_reminder':      dailyReminder,
    'goal_alerts':         goalAlerts,
    'water_reminders':     waterReminders,
    'meal_reminders':      mealReminders,
    'activity_reminders':  activityReminders,
    'sleep_reminders':     sleepReminders,
    'quiet_hours_start':   quietHoursStart,
    'quiet_hours_end':     quietHoursEnd,
  };
}

// ══════════════════════════════════════════════════════════════════════════════
// Fallback local notifications (used when offline)
// ══════════════════════════════════════════════════════════════════════════════
List<NotificationItem> defaultNotifications() => [
  NotificationItem(
    notificationId: 1, userId: 0,
    type: NotificationType.water,
    title: '💧 Time to Hydrate!',
    message: 'You haven\'t logged water in 3 hours. Drinking enough water boosts your metabolism by up to 30%.',
    rawTime: DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
    time: '5 min ago', isRead: false,
  ),
  NotificationItem(
    notificationId: 2, userId: 0,
    type: NotificationType.sleep,
    title: '🌙 Sleep Reminder',
    message: 'Getting 7–9 hours of quality sleep regulates hunger hormones. Wind down now!',
    rawTime: DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
    time: '20 min ago', isRead: false,
  ),
  NotificationItem(
    notificationId: 3, userId: 0,
    type: NotificationType.exercise,
    title: '🏃 Move Your Body!',
    message: 'You\'re 1,200 steps from your daily goal. A 15-min walk burns ~80 kcal.',
    rawTime: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    time: '1 hr ago', isRead: false,
  ),
  NotificationItem(
    notificationId: 4, userId: 0,
    type: NotificationType.goalReached,
    title: '🎉 Goal Reached!',
    message: 'You\'ve reached your daily calorie goal. Great work!',
    rawTime: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    time: '2 hr ago', isRead: true,
  ),
];