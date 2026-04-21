class ApiConfig {
  // ── Base URL ───────────────────────────────────────────────────────────────
  static const String baseUrl = 'http://10.0.2.2:3000';

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login    = '/auth/login';
  static const String register = '/auth/register';
  static const String logout   = '/auth/logout';

  // ── Forgot Password ────────────────────────────────────────────────────────
  static const String resetPassword        = '/auth/reset-password';
  static const String verifyOtp            = '/auth/verify-otp';
  static const String resetPasswordConfirm = '/auth/reset-password/confirm';

  // ── Token ──────────────────────────────────────────────────────────────────
  static const String refreshToken = '/auth/refresh';
  static const String googleToken  = '/auth/google/token';

  // ── User ───────────────────────────────────────────────────────────────────
  static const String getUserProfile = '/users/profile';

  // ── Onboarding ─────────────────────────────────────────────────────────────
  static const String onboardingProfile  = '/onboarding/profile';
  static const String onboardingGender   = '/onboarding/gender';
  static const String onboardingHeight   = '/onboarding/height';
  static const String onboardingWeight   = '/onboarding/weight';
  static const String onboardingAge      = '/onboarding/age';
  static const String onboardingGoal     = '/onboarding/goal';
  static const String onboardingComplete = '/onboarding/complete';

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