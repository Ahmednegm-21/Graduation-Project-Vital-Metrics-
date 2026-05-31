// lib/data/models/notification_preferences_model.dart

class NotificationPreferencesModel {
  final int?   preferenceId;
  final bool   pushEnabled;
  final bool   dailyReminder;
  final bool   goalAlerts;
  final bool   waterReminders;
  final bool   mealReminders;
  final bool   activityReminders;
  final bool   sleepReminders;
  final String quietHoursStart;
  final String quietHoursEnd;

  const NotificationPreferencesModel({
    this.preferenceId,
    this.pushEnabled       = true,
    this.dailyReminder     = true,
    this.goalAlerts        = true,
    this.waterReminders    = true,
    this.mealReminders     = true,
    this.activityReminders = true,
    this.sleepReminders    = true,
    this.quietHoursStart   = '22:00',
    this.quietHoursEnd     = '07:00',
  });

  // ── fromJson ──────────────────────────────────────────────────────────────
  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      preferenceId:      json['preference_id'],
      pushEnabled:       json['push_enabled']       ?? true,
      dailyReminder:     json['daily_reminder']     ?? true,
      goalAlerts:        json['goal_alerts']         ?? true,
      waterReminders:    json['water_reminders']     ?? true,
      mealReminders:     json['meal_reminders']      ?? true,
      activityReminders: json['activity_reminders']  ?? true,
      sleepReminders:    json['sleep_reminders']     ?? true,
      quietHoursStart:   json['quiet_hours_start']   ?? '22:00',
      quietHoursEnd:     json['quiet_hours_end']     ?? '07:00',
    );
  }

  // ── toJson (PUT body — no preferenceId) ───────────────────────────────────
  Map<String, dynamic> toJson() => {
    'push_enabled':       pushEnabled,
    'daily_reminder':     dailyReminder,
    'goal_alerts':        goalAlerts,
    'water_reminders':    waterReminders,
    'meal_reminders':     mealReminders,
    'activity_reminders': activityReminders,
    'sleep_reminders':    sleepReminders,
    'quiet_hours_start':  quietHoursStart,
    'quiet_hours_end':    quietHoursEnd,
  };

  // ── copyWith ──────────────────────────────────────────────────────────────
  NotificationPreferencesModel copyWith({
    bool?   pushEnabled,
    bool?   dailyReminder,
    bool?   goalAlerts,
    bool?   waterReminders,
    bool?   mealReminders,
    bool?   activityReminders,
    bool?   sleepReminders,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationPreferencesModel(
      preferenceId:      preferenceId,
      pushEnabled:       pushEnabled       ?? this.pushEnabled,
      dailyReminder:     dailyReminder     ?? this.dailyReminder,
      goalAlerts:        goalAlerts        ?? this.goalAlerts,
      waterReminders:    waterReminders    ?? this.waterReminders,
      mealReminders:     mealReminders     ?? this.mealReminders,
      activityReminders: activityReminders ?? this.activityReminders,
      sleepReminders:    sleepReminders    ?? this.sleepReminders,
      quietHoursStart:   quietHoursStart   ?? this.quietHoursStart,
      quietHoursEnd:     quietHoursEnd     ?? this.quietHoursEnd,
    );
  }

  @override
  String toString() =>
      'NotificationPreferencesModel(pushEnabled: $pushEnabled, '
      'dailyReminder: $dailyReminder, goalAlerts: $goalAlerts, '
      'waterReminders: $waterReminders, mealReminders: $mealReminders, '
      'activityReminders: $activityReminders, sleepReminders: $sleepReminders, '
      'quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd)';
}