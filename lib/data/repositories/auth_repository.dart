import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/token_storage_service.dart';
import '../exceptions/api_exception.dart';

class AuthRepository {
  final ApiService _apiService;
  final TokenStorageService _tokenStorage;

  AuthRepository({
    ApiService? apiService,
    TokenStorageService? tokenStorage,
  })  : _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  // ── Sign In ───────────────────────────────────────────────────────────────
  // true  → email verified → token saved → AuthSuccess → home
  // false → email not verified (403) → AuthSignInOTPSent → OTP screen

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        body: {'email': email, 'password': password},
      );

      final saved = await _trySaveTokenFromResponse(response);
      if (!saved) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          await _trySaveTokenFromResponse(data);
        }
      }
      return true;
    } on ForbiddenException {
      return false;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Sign in failed: $e');
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────
  // 201 → OTP sent → AuthRegistrationSuccess
  // 409 → email exists → treat as success → OTP screen

  Future<String> signUp({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String dateOfBirth,
    required double height,
    required double weight,
  }) async {
    try {
      await _apiService.post(
        ApiConfig.register,
        body: {
          'name':          name,
          'email':         email,
          'password':      password,
          'gender':        gender,
          'date_of_birth': dateOfBirth,
          'height':        height,
          'weight':        weight,
        },
      );
      return email;
    } on HttpException catch (e) {
      if (e.statusCode == 409) return email;
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Sign up failed: $e');
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  // verify_email → save tokens
  // reset_password → no tokens saved

  Future<void> verifyOTP({
    required String email,
    required String otp,
    String purpose = 'verify_email',
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.verifyOtp,
        body: {
          'email':   email,
          'code':    otp,
          'purpose': purpose,
        },
      );

      if (purpose == 'verify_email') {
        final saved = await _trySaveTokenFromResponse(response);
        if (!saved) {
          final data = response['data'];
          if (data is Map<String, dynamic>) {
            await _trySaveTokenFromResponse(data);
          }
        }
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'OTP verification failed: $e');
    }
  }

  // ── Verify OTP for forgot password ────────────────────────────────────────

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _apiService.post(
        ApiConfig.verifyOtp,
        body: {
          'email':   email,
          'code':    otp,
          'purpose': 'reset_password',
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'OTP verification failed: $e');
    }
  }

  // ── Refresh Token ─────────────────────────────────────────────────────────

  Future<void> refreshToken() async {
    try {
      final accessToken  = await _tokenStorage.getToken();
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        throw UnauthorizedException('No tokens found');
      }

      final response = await _apiService.post(
        ApiConfig.refreshToken,
        headers: ApiConfig.headers(token: accessToken),
        body: {'refresh_token': refreshToken},
      );

      final saved = await _trySaveTokenFromResponse(response);
      if (!saved) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          await _trySaveTokenFromResponse(data);
        }
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Token refresh failed: $e');
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token != null) {
        await _apiService.post(
          ApiConfig.logout,
          headers: ApiConfig.headers(token: token),
        );
      }
    } catch (_) {
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  // ── Get User Profile ──────────────────────────────────────────────────────

  Future<UserModel> getUserProfile() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token == null) throw UnauthorizedException('No token found');

      final response = await _apiService.get(
        ApiConfig.getUserProfile,
        headers: ApiConfig.headers(token: token),
      );

      final Map<String, dynamic> userData =
          response['data'] is Map<String, dynamic>
              ? response['data'] as Map<String, dynamic>
              : response;

      return _toUserModelFromProfile(userData);
    } on UnauthorizedException {
      try {
        await refreshToken();
        return getUserProfile();
      } catch (_) {
        rethrow;
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get profile: $e');
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────────

  Future<void> sendResetEmail({required String email}) async {
    try {
      await _apiService.post(ApiConfig.resetPassword, body: {'email': email});
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to send reset email: $e');
    }
  }

  // ── Reset Password Confirm ────────────────────────────────────────────────

  Future<void> resetPasswordConfirm({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiService.post(
        ApiConfig.resetPasswordConfirm,
        body: {
          'email':           email,
          'code':            otp,
          'newPassword':     newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Password reset failed: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<bool> isLoggedIn() => _tokenStorage.isLoggedIn();
  Future<String?> getToken() => _tokenStorage.getToken();

  Future<bool> _trySaveTokenFromResponse(Map<String, dynamic> map) async {
    final token = _safeStr(map, 'access_token')
        ?? _safeStr(map, 'token')
        ?? _safeStr(map, 'accessToken');
    if (token == null) return false;
    final authResponse = AuthResponse.fromJson(map);
    await _saveTokens(authResponse);
    return true;
  }

  Future<void> _saveTokens(AuthResponse auth) async {
    await _tokenStorage.saveToken(auth.token);
    if (auth.refreshToken != null) {
      await _tokenStorage.saveRefreshToken(auth.refreshToken!);
    }
    await _tokenStorage.saveUserId(auth.user.id);
  }

  String? _safeStr(Map<String, dynamic> map, String key) {
    final val = map[key];
    if (val is String) return val;
    return null;
  }

  UserModel _toUserModelFromProfile(Map<String, dynamic> json) => UserModel(
        id:    json['user_id']?.toString()
            ?? json['id']?.toString()
            ?? json['_id']?.toString(),
        name:  _safeStr(json, 'name') ?? '',
        email: _safeStr(json, 'email') ?? '',
        profileImage: json['profileImage'] is String
            ? json['profileImage'] as String
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        onboardingComplete: json['onboardingComplete'] as bool?
            ?? json['is_verified'] as bool?
            ?? false,
      );

  void dispose() => _apiService.dispose();
}