import '../config/api_config.dart';
import '../models/notification_model.dart';
import '../exceptions/api_exception.dart';
import '../../services/api_service.dart';
import '../../services/token_storage_service.dart';

class NotificationsRepository {
  final ApiService _apiService;
  final TokenStorageService _tokenStorage;

  NotificationsRepository({
    ApiService? apiService,
    TokenStorageService? tokenStorage,
  })  : _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  // ── Shared headers ─────────────────────────────────────────────────────────
  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  // ── Get all notifications ──────────────────────────────────────────────────
  Future<List<NotificationItem>> getNotifications() async {
    try {
      final headers  = await _authHeaders;
      final response = await _apiService.get(
        ApiConfig.notifications,
        headers: headers,
      );

      final List<dynamic> data =
          response['data'] as List<dynamic>? ??
          response['notifications'] as List<dynamic>? ??
          [];

      return data
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to load notifications: $e');
    }
  }

  // ── Get unread count ───────────────────────────────────────────────────────
  Future<int> getUnreadCount() async {
    try {
      final headers  = await _authHeaders;
      final response = await _apiService.get(
        ApiConfig.notificationUnread,
        headers: headers,
      );
      return response['count'] as int? ?? 0;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get unread count: $e');
    }
  }

  // ── Mark single notification as read ──────────────────────────────────────
  Future<void> markAsRead(String id) async {
    try {
      final headers = await _authHeaders;
      await _apiService.patch(
        ApiConfig.notificationMarkRead(id),
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to mark notification as read: $e');
    }
  }

  // ── Mark all as read ───────────────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    try {
      final headers = await _authHeaders;
      await _apiService.patch(
        ApiConfig.notificationsMarkAllRead,
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to mark all as read: $e');
    }
  }

  // ── Delete single notification ─────────────────────────────────────────────
  Future<void> deleteNotification(String id) async {
    try {
      final headers = await _authHeaders;
      await _apiService.delete(
        ApiConfig.notificationById(id),
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete notification: $e');
    }
  }

  // ── Delete all notifications ───────────────────────────────────────────────
  Future<void> deleteAll() async {
    try {
      final headers = await _authHeaders;
      await _apiService.delete(
        ApiConfig.notificationsDeleteAll,
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete notifications: $e');
    }
  }

  void dispose() => _apiService.dispose();
}