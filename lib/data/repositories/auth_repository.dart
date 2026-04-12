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

  // ── Sign In ────────────────────────────────────────────────────────────────

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        body: {'email': email, 'password': password},
      );

      final authResponse = AuthResponse.fromJson(response['data']);
      await _saveTokens(authResponse);

      return _toUserModel(authResponse.user);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  // ── Sign Up ────────────────────────────────────────────────────────────────

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        body: {'name': name, 'email': email, 'password': password},
      );

      final authResponse = AuthResponse.fromJson(response['data']);
      await _saveTokens(authResponse);

      return _toUserModel(authResponse.user);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token != null) {
        await _apiService.post(
          ApiConfig.logout,
          headers: ApiConfig.headers(token: token),
        );
      }
      await _tokenStorage.clearTokens();
    } on ApiException {
      await _tokenStorage.clearTokens();
      rethrow;
    } catch (e) {
      await _tokenStorage.clearTokens();
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  // ── Forgot Password ────────────────────────────────────────────────────────

  /// Step 1: Send reset email → backend sends OTP to the email
  Future<void> sendResetEmail({required String email}) async {
    try {
      await _apiService.post(
        ApiConfig.resetPassword,
        body: {'email': email},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Step 2: Verify the OTP code sent to email
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _apiService.post(
        ApiConfig.verifyOtp,
        body: {'email': email, 'otp': otp},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Step 3: Set the new password after OTP is verified
  Future<void> resetPasswordConfirm({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _apiService.post(
        ApiConfig.resetPasswordConfirm,
        body: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  // ── Token Refresh ──────────────────────────────────────────────────────────

  /// Refresh access token using stored refresh token
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) throw UnauthorizedException();

      final response = await _apiService.post(
        ApiConfig.refreshToken,
        body: {'refreshToken': refreshToken},
      );

      final newToken = response['data']['token'] as String;
      await _tokenStorage.saveToken(newToken);

      // Save new refresh token if backend sends one
      final newRefresh = response['data']['refreshToken'] as String?;
      if (newRefresh != null) {
        await _tokenStorage.saveRefreshToken(newRefresh);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  // ── Google Sign In ─────────────────────────────────────────────────────────

  /// Exchange Google ID token with backend for app token
  Future<UserModel> signInWithGoogleToken({
    required String googleIdToken,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.googleToken,
        body: {'idToken': googleIdToken},
      );

      final authResponse = AuthResponse.fromJson(response['data']);
      await _saveTokens(authResponse);

      return _toUserModel(authResponse.user);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<UserModel> getUserProfile() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token == null) throw UnauthorizedException();

      final response = await _apiService.get(
        ApiConfig.userProfile,
        headers: ApiConfig.headers(token: token),
      );

      final userData = UserData.fromJson(response['data']);
      return _toUserModel(userData);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<bool> isLoggedIn() => _tokenStorage.isLoggedIn();

  Future<String?> getToken() => _tokenStorage.getToken();

  /// Save token + refreshToken + userId after login/register
  Future<void> _saveTokens(AuthResponse authResponse) async {
    await _tokenStorage.saveToken(authResponse.token);
    if (authResponse.refreshToken != null) {
      await _tokenStorage.saveRefreshToken(authResponse.refreshToken!);
    }
    await _tokenStorage.saveUserId(authResponse.user.id);
  }

  /// Convert UserData → UserModel
  UserModel _toUserModel(UserData data) => UserModel(
        id: data.id,
        name: data.name,
        email: data.email,
        profileImage: data.profileImage,
        createdAt: DateTime.now(),
      );

  void dispose() => _apiService.dispose();
}