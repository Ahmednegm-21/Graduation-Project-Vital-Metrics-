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

  // ── Sign In → OTP sent to email ───────────────────────────────────────────

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _apiService.post(
        ApiConfig.login,
        body: {'email': email, 'password': password},
      );
    } on ForbiddenException catch (e) {
      // 403 = email not verified → OTP sent
      final msg = e.message.toLowerCase();
      if (msg.contains('not verified') ||
          msg.contains('verification') ||
          msg.contains('email')) {
        return;
      }
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Sign in failed: $e');
    }
  }

  // ── Sign Up → OTP sent to email ───────────────────────────────────────────

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
      // الباك إند بيبعت OTP ويرجع message فقط → نرجع الـ email
      return email;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Sign up failed: $e');
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  // الباك إند عايز: email, code, purpose

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

      // نحاول نحفظ الـ token
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
      throw ApiException(message: 'OTP verification failed: $e');
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────────────────

  Future<void> resendOTP({
    required String email,
    String purpose = 'verify_email',
  }) async {
    try {
      await _apiService.post(
        ApiConfig.resendOtp,
        body: {
          'email':   email,
          'purpose': purpose,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to resend OTP: $e');
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

  Future<void> resetPasswordConfirm({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _apiService.post(
        ApiConfig.resetPasswordConfirm,
        body: {
          'email':       email,
          'code':        otp,
          'newPassword': newPassword,
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
        id:                 json['user_id']?.toString()
            ?? json['id']?.toString()
            ?? json['_id']?.toString(),
        name:               _safeStr(json, 'name') ?? '',
        email:              _safeStr(json, 'email') ?? '',
        profileImage:       json['profileImage'] is String
            ? json['profileImage'] as String
            : null,
        createdAt:          json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      );

  void dispose() => _apiService.dispose();
}