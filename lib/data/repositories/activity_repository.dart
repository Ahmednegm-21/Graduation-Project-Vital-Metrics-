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

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  String _mapToBackendType(String displayType) {
    final normalized = displayType.trim().toLowerCase();
    const walkTypes  = {'walking', 'walk', 'yoga', 'stretching'};
    if (walkTypes.contains(normalized)) return 'walk';
    return 'run';
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // =====================================================
  // CREATE ACTIVITY
  // Only called for manually logged activities
  // HC activities are never sent to the backend to avoid
  // duplicate records in the activity list
  // =====================================================

  Future<ActivityModel> createActivity({
    required String type,
    required int durationMinutes,
    required int caloriesBurned,
    DateTime? date,
  }) async {
    try {
      final headers      = await _authHeaders;
      final activityDate = date ?? DateTime.now();
      final dateStr      =
          '${activityDate.year}-${activityDate.month.toString().padLeft(2, '0')}-${activityDate.day.toString().padLeft(2, '0')}';

      final response = await _apiService.post(
        ApiConfig.createActivity,
        headers: headers,
        body: {
          'date':            dateStr,
          'type':            _mapToBackendType(type),
          'duration':        durationMinutes,
          'calories_burned': caloriesBurned,
        },
      );

      final data  = response['data'] ?? response;
      final saved = ActivityModel.fromBackendJson(data);
      return saved.copyWith(type: type);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to create activity: $e');
    }
  }

  // =====================================================
  // GET ACTIVITIES
  // Returns only today's manually logged activities
  // HC activities are shown separately from the snapshot
  // =====================================================

  Future<List<ActivityModel>> getActivities({
    int page  = 1,
    int limit = 50,
  }) async {
    try {
      final headers = await _authHeaders;
      final today   = _todayStr();

      final raw = await _apiService.getAsList(
        ApiConfig.getActivities,
        headers: headers,
        queryParameters: {
          'page':  page,
          'limit': limit,
        },
      );

      final activities = raw
          .map((item) =>
              ActivityModel.fromBackendJson(item as Map<String, dynamic>))
          .toList();

      // Filter to today only using local time to avoid timezone mismatches
      final todayActivities = activities.where((a) {
        final localTime    = a.timestamp.toLocal();
        final activityDate =
            '${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}';
        return activityDate == today;
      }).toList();

      // Sort newest first
      todayActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      print('[ActivityRepo] fetched ${activities.length} total, '
          '${todayActivities.length} for today ($today)');

      return todayActivities;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get activities: $e');
    }
  }

  // =====================================================
  // DELETE ACTIVITY
  // =====================================================

  Future<void> deleteActivity(String id) async {
    try {
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