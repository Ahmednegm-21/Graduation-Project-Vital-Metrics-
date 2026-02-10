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

  /// Sign In
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      // Parse response
      final authResponse = AuthResponse.fromJson(response['data']);

      // Save token
      await _tokenStorage.saveToken(authResponse.token);
      if (authResponse.refreshToken != null) {
        await _tokenStorage.saveRefreshToken(authResponse.refreshToken!);
      }
      await _tokenStorage.saveUserId(authResponse.user.id);

      // Convert to UserModel
      return UserModel(
        id: authResponse.user.id,
        name: authResponse.user.name,
        email: authResponse.user.email,
        profileImage: authResponse.user.profileImage,
        createdAt: DateTime.now(),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Sign Up
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      // Parse response
      final authResponse = AuthResponse.fromJson(response['data']);

      // Save token
      await _tokenStorage.saveToken(authResponse.token);
      if (authResponse.refreshToken != null) {
        await _tokenStorage.saveRefreshToken(authResponse.refreshToken!);
      }
      await _tokenStorage.saveUserId(authResponse.user.id);

      // Convert to UserModel
      return UserModel(
        id: authResponse.user.id,
        name: authResponse.user.name,
        email: authResponse.user.email,
        profileImage: authResponse.user.profileImage,
        createdAt: DateTime.now(),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      final token = await _tokenStorage.getToken();

      if (token != null) {
        // Call backend logout endpoint
        await _apiService.post(
          ApiConfig.logout,
          headers: ApiConfig.headers(token: token),
        );
      }

      // Clear local tokens
      await _tokenStorage.clearTokens();
    } on ApiException {
      // Even if API call fails, clear local tokens
      await _tokenStorage.clearTokens();
      rethrow;
    } catch (e) {
      await _tokenStorage.clearTokens();
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Get Current User Profile
  Future<UserModel> getUserProfile() async {
    try {
      final token = await _tokenStorage.getToken();

      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await _apiService.get(
        ApiConfig.getUserProfile,
        headers: ApiConfig.headers(token: token),
      );

      final userData = UserData.fromJson(response['data']);

      return UserModel(
        id: userData.id,
        name: userData.name,
        email: userData.email,
        profileImage: userData.profileImage,
        createdAt: DateTime.now(),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.isLoggedIn();
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _tokenStorage.getToken();
  }

  /// Dispose
  void dispose() {
    _apiService.dispose();
  }
}