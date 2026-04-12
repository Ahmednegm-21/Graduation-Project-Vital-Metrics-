class ApiConfig {
  // ── Base URL ───────────────────────────────────────────────────────────────
  // Android emulator → 10.0.2.2 = localhost
  // iOS simulator   → localhost
  // Real device     → IP of your machine e.g. 192.168.1.x
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login    = '/auth/login';
  static const String register = '/auth/register';
  static const String logout   = '/auth/logout';

  // ── Forgot Password flow ───────────────────────────────────────────────────
  static const String resetPassword        = '/auth/reset-password';
  static const String verifyOtp            = '/auth/verify-otp';
  static const String resetPasswordConfirm = '/auth/reset-password/confirm';

  // ── Token ──────────────────────────────────────────────────────────────────
  static const String refreshToken = '/auth/refresh';
  static const String googleToken  = '/auth/google/token';

  // ── User ───────────────────────────────────────────────────────────────────
  static const String userProfile = '/user/profile';

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout    = Duration(seconds: 30);

  // ── Headers ────────────────────────────────────────────────────────────────
  static Map<String, String> headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}