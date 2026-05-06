import '../config/api_config.dart';
import '../models/activity_model.dart';
import '../exceptions/api_exception.dart';
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

  // Map display name to backend type
  // Backend only accepts 'walk' or 'run'
  // Walking and Yoga are walk type everything else is run type
  String _mapToBackendType(String displayType) {
    const walkTypes = {'Walking', 'Yoga', 'Other', 'walk'};
    return walkTypes.contains(displayType) ? 'walk' : 'run';
  }

  // POST /activities
  // Returns: ActivityModel with original display name preserved for UI
  Future<ActivityModel> createActivity({
    required String type,
    required int durationMinutes,
    required int caloriesBurned,
    DateTime? date,
  }) async {
    try {
      final headers = await _authHeaders;
      final today   = date ?? DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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

      // Parse backend response to get the real activity_id
      final saved = ActivityModel.fromBackendJson(response);

      // Return model with original display name not backend type
      // So UI shows Running, Football etc instead of run, walk
      return ActivityModel(
        id:              saved.id,
        type:            type,
        durationMinutes: saved.durationMinutes,
        caloriesBurned:  saved.caloriesBurned,
        timestamp:       saved.timestamp,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to create activity: $e');
    }
  }

  // GET /activities
  // Query: page (default 1), limit (default 20)
  // Returns: List of ActivityModel
  Future<List<ActivityModel>> getActivities({
    int page  = 1,
    int limit = 20,
  }) async {
    try {
      final headers  = await _authHeaders;
      final response = await _apiService.get(
        ApiConfig.getActivities,
        headers: headers,
        queryParameters: {'page': page, 'limit': limit},
      );

      // Response can be a list directly or wrapped in a data field
      final list = response['data'] is List
          ? response['data'] as List
          : response is List
              ? response as List
              : [];

      return list
          .map((e) => ActivityModel.fromBackendJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get activities: $e');
    }
  }

  // DELETE /activities/{id}
  // Only called for backend activities with valid integer ids
  // Health Connect activities are never sent here
  Future<void> deleteActivity(String id) async {
    try {
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

  void dispose() => _apiService.dispose();
}