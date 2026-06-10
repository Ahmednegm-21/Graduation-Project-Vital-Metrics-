// lib/data/config/api_config.dart

import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // ── Base URL ───────────────────────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb)             return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://192.168.1.5:3000';
    if (Platform.isIOS)     return 'http://localhost:3000';
    return 'http://localhost:3000';
  }

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login    = '/auth/login';
  static const String register = '/auth/register';
  static const String logout   = '/auth/logout';

  // ── OTP ────────────────────────────────────────────────────────────────────
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/verify-otp';

  // ── Forgot Password ────────────────────────────────────────────────────────
  static const String resetPassword        = '/auth/reset-password';
  static const String resetPasswordConfirm = '/auth/reset-password/confirm';

  // ── Token ──────────────────────────────────────────────────────────────────
  static const String refreshToken = '/auth/refresh';
  static const String googleToken  = '/auth/google/token';

  // ── User ───────────────────────────────────────────────────────────────────
  static const String getUserProfile = '/users/profile';

  // ── Goals ──────────────────────────────────────────────────────────────────
  static const String createGoal = '/goals';
  static const String getGoal    = '/goals';
  static const String updateGoal = '/goals';
  static const String deleteGoal = '/goals';

  // ── Activities ─────────────────────────────────────────────────────────────
  static const String createActivity = '/activities';
  static const String getActivities  = '/activities';
  static const String getActivity    = '/activities';
  static const String updateActivity = '/activities';
  static const String deleteActivity = '/activities';

  // ── Meals (admin catalog) ──────────────────────────────────────────────────
  static const String getMeals    = '/meals';
static const String createMeal  = '/admin/meals';
static String updateMeal(int id) => '/admin/meals/$id';
static String deleteMeal(int id) => '/admin/meals/$id';
  // ── Consumed Meals (user log) ──────────────────────────────────────────────
  static const String consumedMeals      = '/consumed-meals';
  static String consumedMeal(int id) => '/consumed-meals/$id';

  // ── Water Intakes ──────────────────────────────────────────────────────────
  static const String createWaterIntake = '/water-intakes';
  static const String getWaterIntakes   = '/water-intakes';
  static const String deleteWaterIntake = '/water-intakes';

  // ── Sleeps ─────────────────────────────────────────────────────────────────
  static const String createSleep = '/sleeps';
  static const String getSleeps   = '/sleeps';
  static const String updateSleep = '/sleeps';
  static const String deleteSleep = '/sleeps';

  // ── Daily Metrics ──────────────────────────────────────────────────────────
  static const String getDailyMetrics = '/daily-metrics';
  static String updateDailySteps(int metricsId) =>
      '/daily-metrics/$metricsId/steps';

  // ── Notifications ──────────────────────────────────────────────────────────
  static const String getNotifications         = '/notifications';
  static const String deleteAllNotifications   = '/notifications';
  static const String getUnreadCount           = '/notifications/unread-count';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static String markNotificationRead(int id)   => '/notifications/$id/read';
  static String deleteNotification(int id)     => '/notifications/$id';

  // ── Notification Preferences ───────────────────────────────────────────────
  static const String getNotifPreferences    = '/notification-preferences';
  static const String updateNotifPreferences = '/notification-preferences';

  // ── Device Tokens (FCM) ────────────────────────────────────────────────────
  static const String registerDeviceToken      = '/device-tokens';
  static const String getDeviceTokens          = '/device-tokens';
  static String deleteDeviceToken(int tokenId) => '/device-tokens/$tokenId';

  // ── Admin ──────────────────────────────────────────────────────────────────
  static const String adminStats    = '/admin/stats';
  static const String adminUsers    = '/admin/users';
  static const String adminOverview = '/admin/metrics/overview';
  static const String adminMeals    = '/admin/meals';
  static String adminMealById(int id)   => '/admin/meals/$id';
  static String adminDeleteUser(int id) => '/admin/users/$id';

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout    = Duration(seconds: 60);

  // ── Headers ────────────────────────────────────────────────────────────────
  static Map<String, String> headers({String? token}) => {
    'Content-Type': 'application/json',
    'Accept':       'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}