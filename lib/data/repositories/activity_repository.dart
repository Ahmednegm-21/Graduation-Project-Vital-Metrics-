import '../config/api_config.dart';
import '../exceptions/api_exception.dart';
import '../models/activity_model.dart';

import '../../services/api_service.dart';
import '../../services/token_storage_service.dart';

class ActivityRepository {
  final ApiService _apiService;
  final TokenStorageService _tokenStorage;

  ActivityRepository({
    ApiService? apiService,
    TokenStorageService? tokenStorage,
  })  : _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  // Build auth headers from stored token
  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  // Map display type to what the backend accepts (walk or run only)
  String _mapToBackendType(String displayType) {
    final normalized = displayType.trim().toLowerCase();

    const walkTypes = {'walking', 'walk', 'yoga', 'stretching'};

    if (walkTypes.contains(normalized)) return 'walk';

    return 'run';
  }

  // Create a new activity on the backend
  Future<ActivityModel> createActivity({
    required String type,
    required int durationMinutes,
    required int caloriesBurned,
    DateTime? date,
  }) async {
    try {
      final headers = await _authHeaders;
      final activityDate = date ?? DateTime.now();

      final dateStr =
          '${activityDate.year}-${activityDate.month.toString().padLeft(2, '0')}-${activityDate.day.toString().padLeft(2, '0')}';

      final response = await _apiService.post(
        ApiConfig.createActivity,
        headers: headers,
        body: {
          'date': dateStr,
          'type': _mapToBackendType(type),
          'duration': durationMinutes,
          'calories_burned': caloriesBurned,
        },
      );

      // Support both wrapped and direct response shapes
      final data = response['data'] ?? response;

      final saved = ActivityModel.fromBackendJson(data);

      // Return with original UI type preserved (not the mapped backend type)
      return saved.copyWith(type: type);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to create activity: $e');
    }
  }

  // Fetch all activities from backend
  Future<List<ActivityModel>> getActivities({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final headers = await _authHeaders;

      final response = await _apiService.get(
        ApiConfig.getActivities,
        headers: headers,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      // Support both wrapped and direct list responses
      final dynamic rawList = response['data'] ?? response;

      if (rawList is! List) return [];

      final activities = rawList
          .map((item) =>
              ActivityModel.fromBackendJson(item as Map<String, dynamic>))
          .toList();

      // Sort newest first
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return activities;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get activities: $e');
    }
  }

  // Delete an activity by id
  Future<void> deleteActivity(String id) async {
    try {
      // Skip local and Health Connect activities
      if (id.startsWith('local_') || id.startsWith('hc_')) return;

      final headers = await _authHeaders;

      await _apiService.delete(
        '${ApiConfig.deleteActivity}/$id',
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete activity: $e');
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}