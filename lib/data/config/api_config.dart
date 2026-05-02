import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // ── Base URL ───────────────────────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://192.168.1.11:3000';
    if (Platform.isIOS) return 'http://localhost:3000';
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
  static const String createGoal = '/goals'; // POST
  static const String getGoal    = '/goals'; // GET
  static const String updateGoal = '/goals'; // PATCH
  static const String deleteGoal = '/goals'; // DELETE

  // ── Notifications ──────────────────────────────────────────────────────────
  static const String getNotifications         = '/Get/notifications';
  static const String deleteNotifications      = '/Delete/notifications';
  static const String getUnreadCount           = '/Get/notifications/unread-count';
  static const String markNotificationRead     = '/Patch/notifications/{id}/read';
  static const String markAllNotificationsRead = '/Patch/notifications/read-all';

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout    = Duration(seconds: 60);

  // ── Headers ────────────────────────────────────────────────────────────────
  static Map<String, String> headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}