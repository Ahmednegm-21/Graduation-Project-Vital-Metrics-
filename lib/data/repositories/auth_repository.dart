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

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        body: {'email': email, 'password': password},
      );
      final authResponse = AuthResponse.fromJson(response);
      await _saveTokens(authResponse);
      return _toUserModelFromAuth(authResponse.user); // ✅ CHANGED
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Sign in failed: $e');
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String dateOfBirth,
    required double height,
    required double weight,
  }) async {
    try {
      print('📤 Sending Sign Up Request:');
      print('  Name: $name');
      print('  Email: $email');
      print('  Gender: $gender');
      print('  Date of Birth: $dateOfBirth');
      print('  Height: $height');
      print('  Weight: $weight');
      
      final response = await _apiService.post(
        ApiConfig.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'gender': gender,
          'height': height,
          'weight': weight,
          'date_of_birth': dateOfBirth,
        },
      );
      
      print('📥 Sign Up Response:');
      print(response);
      
      final authResponse = AuthResponse.fromJson(response);
      await _saveTokens(authResponse);
      return _toUserModelFromAuth(authResponse.user); // ✅ CHANGED
    } on ApiException {
      rethrow;
    } catch (e) {
      print('❌ Sign Up Error: $e');
      throw ApiException(message: 'Sign up failed: $e');
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

      return _toUserModelFromProfile(userData); // ✅ CHANGED
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

  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      await _apiService.post(ApiConfig.verifyOtp, body: {'email': email, 'otp': otp});
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
        body: {'email': email, 'otp': otp, 'newPassword': newPassword},
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

  Future<void> _saveTokens(AuthResponse auth) async {
    await _tokenStorage.saveToken(auth.token);
    if (auth.refreshToken != null) {
      await _tokenStorage.saveRefreshToken(auth.refreshToken!);
    }
    await _tokenStorage.saveUserId(auth.user.id);
  }

  // ✅ NEW: Convert from AuthResponse (after login/signup)
  UserModel _toUserModelFromAuth(UserData user) => UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        profileImage: user.profileImage,
        createdAt: DateTime.now(),
        onboardingComplete: user.onboardingComplete ?? false, // ✅ Get from response
      );

  // ✅ NEW: Convert from profile endpoint
  UserModel _toUserModelFromProfile(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? json['_id']?.toString(),
        name: json['name'] as String,
        email: json['email'] as String,
        profileImage: json['profileImage'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        onboardingComplete: json['onboardingComplete'] as bool? ?? false, // ✅ Get from profile
      );

  void dispose() => _apiService.dispose();
}