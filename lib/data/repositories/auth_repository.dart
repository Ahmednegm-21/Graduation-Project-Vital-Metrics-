import 'package:google_sign_in/google_sign_in.dart';

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/token_storage_service.dart';
import '../exceptions/api_exception.dart';

class AuthRepository {
  final ApiService          _apiService;
  final TokenStorageService _tokenStorage;

 
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await _googleSignIn.initialize(
      serverClientId: ApiConfig.googleWebClientId,
      // clientId: ApiConfig.googleIosClientId,
    );
    _googleSignInInitialized = true;
  }

  AuthRepository({
    ApiService?          apiService,
    TokenStorageService? tokenStorage,
  })  : _apiService   = apiService   ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  // ── Sign In ───────────────────────────────────────────────────────────────
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
        if (data is Map<String, dynamic>) await _trySaveTokenFromResponse(data);
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

  Future<GoogleSignInResult> startGoogleSignIn() async {
    try {
      await _ensureGoogleSignInInitialized();

      GoogleSignInAccount googleUser;
      try {
        googleUser = await _googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          throw ApiException(message: 'Google sign-in cancelled');
        }
        throw ApiException(
          message: 'Google sign-in failed: ${e.description ?? e.code.name}',
        );
      }

      final googleAuth = googleUser.authentication; 
      final idToken    = googleAuth.idToken;
      if (idToken == null) {
        throw ApiException(message: 'Failed to get Google ID token');
      }

      try {
        final response = await _apiService.post(
          ApiConfig.googleToken, 
          body: {'id_token': idToken},
        );

        final saved = await _trySaveTokenFromResponse(response);
        if (!saved) {
          final data = response['data'];
          if (data is Map<String, dynamic>) {
            await _trySaveTokenFromResponse(data);
          }
        }

        final user = await getUserProfile();
        return GoogleSignInResult.success(user);

      } on BadRequestException {
        return GoogleSignInResult.needsProfile(
          idToken:     idToken,
          displayName: googleUser.displayName ?? '',
          email:       googleUser.email,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Google sign-in failed: $e');
    }
  }

  Future<UserModel> completeGoogleSignIn({
    required String idToken,
    required String name,
    required String gender,
    required String dateOfBirth,
    required double height,
    required double weight,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.googleToken,
        body: {
          'id_token':      idToken,
          'name':          name,
          'gender':        gender,
          'date_of_birth': dateOfBirth,
          'height':        height,
          'weight':        weight,
        },
      );

      final saved = await _trySaveTokenFromResponse(response);
      if (!saved) {
        final data = response['data'];
        if (data is Map<String, dynamic>) await _trySaveTokenFromResponse(data);
      }

      return await getUserProfile();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Google sign-in failed: $e');
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────
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
  Future<void> verifyOTP({
    required String email,
    required String otp,
    String purpose = 'verify_email',
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.verifyOtp,
        body: {'email': email, 'code': otp, 'purpose': purpose},
      );
      if (purpose == 'verify_email') {
        final saved = await _trySaveTokenFromResponse(response);
        if (!saved) {
          final data = response['data'];
          if (data is Map<String, dynamic>) await _trySaveTokenFromResponse(data);
        }
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'OTP verification failed: $e');
    }
  }

  // ── Verify OTP (forgot password) ──────────────────────────────────────────
  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      await _apiService.post(
        ApiConfig.verifyOtp,
        body: {'email': email, 'code': otp, 'purpose': 'reset_password'},
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
        if (data is Map<String, dynamic>) await _trySaveTokenFromResponse(data);
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
      if (_googleSignInInitialized) {
        await _googleSignIn.disconnect();
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
    return val is String ? val : null;
  }

  UserModel _toUserModelFromProfile(Map<String, dynamic> json) {
    final rawAdmin = json['is_admin'] ?? json['isAdmin'];
    final isAdmin  = rawAdmin == true ||
        rawAdmin == 1 ||
        rawAdmin?.toString().toLowerCase() == 'true';

    return UserModel(
      id: json['user_id']?.toString()
          ?? json['id']?.toString()
          ?? json['_id']?.toString(),
      name:  _safeStr(json, 'name')  ?? '',
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
      isAdmin: isAdmin,
    );
  }

  void dispose() => _apiService.dispose();
}

// ── Result class ──────────────────────────────────────────────────────────────
class GoogleSignInResult {
  final UserModel? user;
  final String?    idToken;
  final String?    displayName;
  final String?    email;
  final bool       needsProfile;

  const GoogleSignInResult._({
    this.user,
    this.idToken,
    this.displayName,
    this.email,
    required this.needsProfile,
  });

  factory GoogleSignInResult.success(UserModel user) =>
      GoogleSignInResult._(user: user, needsProfile: false);

  factory GoogleSignInResult.needsProfile({
    required String idToken,
    required String displayName,
    required String email,
  }) =>
      GoogleSignInResult._(
        idToken:      idToken,
        displayName:  displayName,
        email:        email,
        needsProfile: true,
      );
}