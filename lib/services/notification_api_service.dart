// lib/services/notification_api_service.dart

import 'package:dio/dio.dart';
import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/models/device_token_model.dart';
import 'package:vital_metrics/data/models/notification_preferences_model.dart';
import 'package:vital_metrics/data/models/notification_api_model.dart';
import 'package:vital_metrics/services/token_storage_service.dart';

class NotificationApiService {
  late final Dio _dio;

  NotificationApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ بنقرأ من FlutterSecureStorage بـ key 'auth_token'
          final token = await TokenStorageService().getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Notification Preferences
  // ═══════════════════════════════════════════════════════════════════════════

  /// GET /notification-preferences
  Future<NotificationPreferencesModel> getPreferences() async {
    final response = await _dio.get(ApiConfig.getNotifPreferences);
    final data = _unwrap(response.data);
    return NotificationPreferencesModel.fromJson(data);
  }

  /// PUT /notification-preferences
  /// لو السيرفر رجع 404 (record مش موجود) بيعمل POST عشان يعمل create
  Future<NotificationPreferencesModel> updatePreferences(
    NotificationPreferencesModel prefs,
  ) async {
    try {
      // ✅ السيرفر بيستخدم PATCH مش PUT
      final response = await _dio.patch(
        ApiConfig.updateNotifPreferences,
        data: prefs.toJson(),
      );
      final data = _unwrap(response.data);
      return NotificationPreferencesModel.fromJson(data);
    } on DioException catch (e) {
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Notifications
  // ═══════════════════════════════════════════════════════════════════════════

  Future<List<NotificationApiModel>> getNotifications() async {
    final response = await _dio.get(ApiConfig.getNotifications);

    List raw = [];
    if (response.data is List) {
      raw = response.data as List;
    } else if (response.data is Map) {
      raw =
          (response.data as Map)['data'] ??
          (response.data as Map)['notifications'] ??
          [];
    }

    return raw
        .map((e) => NotificationApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiConfig.getUnreadCount);
    return (response.data as Map)['count'] ?? 0;
  }

  Future<void> markAsRead(int id) async {
    await _dio.patch(ApiConfig.markNotificationRead(id));
  }

  Future<void> markAllAsRead() async {
    await _dio.patch(ApiConfig.markAllNotificationsRead);
  }

  Future<void> deleteNotification(int id) async {
    await _dio.delete(ApiConfig.deleteNotification(id));
  }

  Future<int> deleteAllNotifications() async {
    final response = await _dio.delete(ApiConfig.deleteAllNotifications);
    return (response.data as Map)['deleted'] ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Device Tokens
  // ═══════════════════════════════════════════════════════════════════════════

  Future<DeviceTokenModel> registerDeviceToken({
    required String token,
    required String platform,
    required String deviceName,
  }) async {
    final body = DeviceTokenModel(
      token: token,
      platform: platform,
      deviceName: deviceName,
    );

    final response = await _dio.post(
      ApiConfig.registerDeviceToken,
      data: body.toRegisterJson(),
    );

    return DeviceTokenModel.fromJson(_unwrap(response.data));
  }

  Future<List<DeviceTokenModel>> getDeviceTokens() async {
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

  Future<void> deleteDeviceToken(int tokenId) async {
    await _dio.delete(ApiConfig.deleteDeviceToken(tokenId));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Helper
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        return raw['data'] as Map<String, dynamic>;
      }
      return raw;
    }
    throw FormatException('Unexpected response type: $raw');
  }
}