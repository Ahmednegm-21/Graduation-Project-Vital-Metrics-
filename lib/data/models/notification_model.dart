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
}

// ══════════════════════════════════════════════════════════════════════════════
// Default notifications list
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
    body: 'Getting 7–9 hours of quality sleep regulates hunger hormones (ghrelin & leptin). Poor sleep can slow weight loss by 55%. Wind down now!',
    time: '20 min ago', isRead: false,
  ),
  NotificationItem(
    id: '3', type: NotificationType.exercise,
    title: '🏃 Move Your Body!',
    body: 'You\'re 1,200 steps from your daily goal. Just a 15-min brisk walk burns ~80 kcal and accelerates your weight loss journey.',
    time: '1 hr ago', isRead: false,
  ),
  NotificationItem(
    id: '4', type: NotificationType.loseW,
    title: '🔥 Calorie Deficit on Track',
    body: 'Great work! You\'re at a healthy 350 kcal deficit today. Stay consistent — at this rate you\'ll reach your goal in 8 weeks.',
    time: '2 hr ago', isRead: true,
  ),
  NotificationItem(
    id: '5', type: NotificationType.water,
    title: '💧 Hydration Goal Reached!',
    body: 'You\'ve logged 8 glasses today! Staying hydrated reduces water retention and gives your skin a healthy glow.',
    time: '3 hr ago', isRead: true,
  ),
  NotificationItem(
    id: '6', type: NotificationType.gainW,
    title: '💪 Protein Intake Reminder',
    body: 'To build muscle and gain weight healthily, target 1.6–2.2g of protein per kg of body weight. You\'re at 60% of your goal — add a protein-rich snack.',
    time: 'Yesterday', isRead: true,
  ),
  NotificationItem(
    id: '7', type: NotificationType.exercise,
    title: '🏃 Strength Training Day',
    body: 'Resistance training 3× per week increases your resting metabolic rate by up to 7%. Today is the perfect day for a workout!',
    time: 'Yesterday', isRead: true,
  ),
  NotificationItem(
    id: '8', type: NotificationType.sleep,
    title: '🌙 Sleep Quality Alert',
    body: 'You slept only 5.5 hours last night. Lack of sleep increases cortisol levels which promotes fat storage — especially around the belly.',
    time: '2 days ago', isRead: true,
  ),
  NotificationItem(
    id: '9', type: NotificationType.nutrition,
    title: '🥗 Balanced Meal Tip',
    body: 'Fill half your plate with vegetables at every meal. High-fiber foods slow digestion, keeping you full for 4+ hours and reducing snack cravings.',
    time: '2 days ago', isRead: true,
  ),
  NotificationItem(
    id: '10', type: NotificationType.loseW,
    title: '🔥 Weekly Weigh-In Time!',
    body: 'Weigh yourself weekly, not daily — daily fluctuations can be misleading. Use morning weight after bathroom for the most accurate reading.',
    time: '3 days ago', isRead: true,
  ),
  NotificationItem(
    id: '11', type: NotificationType.gainW,
    title: '💪 Calorie Surplus Reminder',
    body: 'To gain weight healthily, aim for a 250–500 kcal surplus daily. Focus on whole foods like nuts, avocado, and whole grains — not junk food.',
    time: '3 days ago', isRead: true,
  ),
  NotificationItem(
    id: '12', type: NotificationType.water,
    title: '💧 Pre-Workout Hydration',
    body: 'Drink 500ml of water 30 minutes before exercise. Proper hydration improves performance by up to 20% and prevents muscle cramps.',
    time: '4 days ago', isRead: true,
  ),
];