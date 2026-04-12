import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving authentication tokens.
class TokenStorageService {
  static const String _tokenKey        = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey       = 'user_id';

  SharedPreferences? _prefs;

  /// Returns cached instance or creates one on first call
  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Save authentication token
  Future<void> saveToken(String token) async =>
      (await _instance).setString(_tokenKey, token);

  /// Get authentication token
  Future<String?> getToken() async =>
      (await _instance).getString(_tokenKey);

  /// Save refresh token
  Future<void> saveRefreshToken(String refreshToken) async =>
      (await _instance).setString(_refreshTokenKey, refreshToken);

  /// Get refresh token
  Future<String?> getRefreshToken() async =>
      (await _instance).getString(_refreshTokenKey);

  /// Save user ID
  Future<void> saveUserId(String userId) async =>
      (await _instance).setString(_userIdKey, userId);

  /// Get user ID
  Future<String?> getUserId() async =>
      (await _instance).getString(_userIdKey);

  /// Check if user is logged in (has token)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear auth tokens only (logout)
  Future<void> clearTokens() async {
    final prefs = await _instance;
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
  }

  /// Clear all app data
  Future<void> clearAll() async => (await _instance).clear();
}