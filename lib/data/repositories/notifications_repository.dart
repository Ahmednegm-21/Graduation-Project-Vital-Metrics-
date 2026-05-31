import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/data/models/notification_model.dart';
import 'package:vital_metrics/services/api_service.dart';
import 'package:vital_metrics/services/token_storage_service.dart';

class NotificationsRepository {
  final ApiService          _api;
  final TokenStorageService _tokenStorage;

  NotificationsRepository({
    ApiService?          api,
    TokenStorageService? tokenStorage,
  })  : _api          = api          ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  // ── GET /notifications ─────────────────────────────────────────────────────
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final headers = await _authHeaders;
      final raw     = await _api.getAsList(
        ApiConfig.getNotifications,
        headers: headers,
      );
      return raw
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to load notifications: $e');
    }
  }

  // ── GET /notifications/unread-count ───────────────────────────────────────
  Future<int> getUnreadCount() async {
    try {
      final headers  = await _authHeaders;
      final response = await _api.get(
        ApiConfig.getUnreadCount,
        headers: headers,
      );
      return (response['count'] as num?)?.toInt() ?? 0;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get unread count: $e');
    }
  }

  // ── PATCH /notifications/{id}/read ────────────────────────────────────────
  Future<void> markAsRead(int id) async {
    try {
      final headers = await _authHeaders;
      await _api.patch(
        ApiConfig.markNotificationRead(id),
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to mark notification as read: $e');
    }
  }

  // ── PATCH /notifications/read-all ─────────────────────────────────────────
  Future<void> markAllAsRead() async {
    try {
      final headers = await _authHeaders;
      await _api.patch(
        ApiConfig.markAllNotificationsRead,
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to mark all as read: $e');
    }
  }

  // ── DELETE /notifications/{id} ────────────────────────────────────────────
  Future<void> deleteNotification(int id) async {
    try {
      final headers = await _authHeaders;
      await _api.delete(
        ApiConfig.deleteNotification(id),
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete notification: $e');
    }
  }

  // ── DELETE /notifications ─────────────────────────────────────────────────
  Future<void> deleteAll() async {
    try {
      final headers = await _authHeaders;
      await _api.delete(
        ApiConfig.deleteAllNotifications,
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete all notifications: $e');
    }
  }

  // ── GET /notification-preferences ────────────────────────────────────────
  Future<NotificationPreferences> getPreferences() async {
    try {
      final headers  = await _authHeaders;
      final response = await _api.get(
        ApiConfig.getNotifPreferences,
        headers: headers,
      );
      return NotificationPreferences.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get preferences: $e');
    }
  }

  // ── PUT /notification-preferences ────────────────────────────────────────
  Future<NotificationPreferences> updatePreferences(
      NotificationPreferences prefs) async {
    try {
      final headers  = await _authHeaders;
      final response = await _api.put(
        ApiConfig.updateNotifPreferences,
        headers: headers,
        body: prefs.toJson(),
      );
      return NotificationPreferences.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to update preferences: $e');
    }
  }

  // ── POST /device-tokens ───────────────────────────────────────────────────
  Future<void> registerDeviceToken({
    required String token,
    required String platform,   // 'android' | 'ios'
    required String deviceName,
  }) async {
    try {
      final headers = await _authHeaders;
      await _api.post(
        ApiConfig.registerDeviceToken,
        headers: headers,
        body: {
          'token':       token,
          'platform':    platform,
          'device_name': deviceName,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to register device token: $e');
    }
  }

  // ── DELETE /device-tokens/{tokenId} ──────────────────────────────────────
  Future<void> deleteDeviceToken(int tokenId) async {
    try {
      final headers = await _authHeaders;
      await _api.delete(
        ApiConfig.deleteDeviceToken(tokenId),
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete device token: $e');
    }
  }

  void dispose() => _api.dispose();
}