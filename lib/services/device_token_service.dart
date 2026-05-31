// lib/services/device_token_service.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/models/device_token_model.dart';

class DeviceTokenService {
  late final Dio _dio;

  static const _kSavedTokenId  = 'device_token_id';
  static const _kSavedFcmToken = 'device_fcm_token';

  DeviceTokenService() {
    _dio = Dio(
      BaseOptions(
        baseUrl:        ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token') ??
                        prefs.getString('accessToken')  ??
                        prefs.getString('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept']       = 'application/json';
          handler.next(options);
        },
      ),
    );
  }

  // ── Register ──────────────────────────────────────────────────────────────

  /// Registers [fcmToken] with the backend.
  /// Skips the call if the same token was already registered (cached locally).
  /// Returns null if skipped, otherwise returns the created [DeviceTokenModel].
  Future<DeviceTokenModel?> registerToken({
    required String fcmToken,
    required String platform,
    required String deviceName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Skip if already registered with the same FCM token
    final savedFcm = prefs.getString(_kSavedFcmToken);
    final savedId  = prefs.getInt(_kSavedTokenId);
    if (savedFcm == fcmToken && savedId != null) return null;

    try {
      final body = DeviceTokenModel(
        token:      fcmToken,
        platform:   platform,
        deviceName: deviceName,
      );

      final response = await _dio.post(
        ApiConfig.registerDeviceToken,
        data: body.toRegisterJson(),
      );

      final data = response.data is Map
          ? response.data as Map<String, dynamic>
          : (response.data['data'] as Map<String, dynamic>);

      final registered = DeviceTokenModel.fromJson(data);

      if (registered.tokenId != null) {
        await prefs.setInt(_kSavedTokenId, registered.tokenId!);
      }
      await prefs.setString(_kSavedFcmToken, fcmToken);

      return registered;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        // Token already exists on server
        await prefs.setString(_kSavedFcmToken, fcmToken);
      }
      rethrow;
    }
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Future<List<DeviceTokenModel>> getTokens() async {
    final response = await _dio.get(ApiConfig.getDeviceTokens);

    List raw = [];
    if (response.data is List) {
      raw = response.data as List;
    } else if (response.data is Map) {
      raw = (response.data as Map)['data'] ?? [];
    }

    return raw
        .map((e) => DeviceTokenModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Delete by ID ──────────────────────────────────────────────────────────

  Future<void> deleteToken(int tokenId) async {
    await _dio.delete(ApiConfig.deleteDeviceToken(tokenId));

    final prefs   = await SharedPreferences.getInstance();
    final savedId = prefs.getInt(_kSavedTokenId);
    if (savedId == tokenId) {
      await prefs.remove(_kSavedTokenId);
      await prefs.remove(_kSavedFcmToken);
    }
  }

  // ── Delete current device token (call on logout) ──────────────────────────

  Future<void> deleteCurrentToken() async {
    final prefs   = await SharedPreferences.getInstance();
    final tokenId = prefs.getInt(_kSavedTokenId);
    if (tokenId == null) return;

    try {
      await deleteToken(tokenId);
    } catch (_) {
      await prefs.remove(_kSavedTokenId);
      await prefs.remove(_kSavedFcmToken);
    }
  }
}