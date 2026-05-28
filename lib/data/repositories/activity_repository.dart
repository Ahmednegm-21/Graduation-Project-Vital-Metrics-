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
  }) : _apiService =
           apiService ?? ApiService(),
       _tokenStorage =
           tokenStorage ??
           TokenStorageService();

  // =====================================================
  // AUTH HEADERS
  // =====================================================

  Future<Map<String, String>>
  get _authHeaders async {
    final token =
        await _tokenStorage.getToken();

    return ApiConfig.headers(
      token: token,
    );
  }

  // =====================================================
  // MAP DISPLAY TYPE TO BACKEND TYPE
  // =====================================================

  String _mapToBackendType(
    String displayType,
  ) {
    final normalized =
        displayType
            .trim()
            .toLowerCase();

    const walkTypes = {
      'walking',
      'walk',
      'yoga',
      'stretching',
    };

    if (walkTypes.contains(
      normalized,
    )) {
      return 'walk';
    }

    return 'run';
  }

  // =====================================================
  // TODAY DATE STRING
  // =====================================================

  String _todayStr() {
    final now = DateTime.now();

    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // =====================================================
  // CREATE ACTIVITY
  // =====================================================

  Future<ActivityModel>
  createActivity({
    required String type,
    required int durationMinutes,
    required int caloriesBurned,
    DateTime? date,
  }) async {
    try {
      final headers =
          await _authHeaders;

      final activityDate =
          date ?? DateTime.now();

      final dateStr =
          '${activityDate.year}-${activityDate.month.toString().padLeft(2, '0')}-${activityDate.day.toString().padLeft(2, '0')}';

      final response =
          await _apiService.post(
            ApiConfig.createActivity,
            headers: headers,
            body: {
              'date': dateStr,
              'type':
                  _mapToBackendType(
                    type,
                  ),
              'duration':
                  durationMinutes,
              'calories_burned':
                  caloriesBurned,
            },
          );

      final data =
          response['data'] ??
          response;

      final saved =
          ActivityModel.fromBackendJson(
            Map<String, dynamic>.from(
              data,
            ),
          );

      return saved.copyWith(
        type: type,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message:
            'Failed to create activity: $e',
      );
    }
  }

  // =====================================================
  // GET ACTIVITIES
  // =====================================================

  Future<List<ActivityModel>>
  getActivities({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers =
          await _authHeaders;

      final today =
          _todayStr();

      final response =
          await _apiService.get(
            ApiConfig.getActivities,
            headers: headers,
            queryParameters: {
              'page': page,
              'limit': limit,
            },
          );

      print(
        '[ActivityRepo] response = $response',
      );

      dynamic rawList;

      // Response is list directly

      if (response is List) {
        rawList = response;
      }

      // Response is wrapped in map

      else if (response is Map) {
        final data =
            response['data'];

        if (data is List) {
          rawList = data;
        } else if (data is Map) {
          rawList =
              data['activities'] ??
              data['data'] ??
              [];
        } else {
          rawList =
              response['activities'] ??
              response['items'] ??
              [];
        }
      }

      // Invalid response

      if (rawList == null ||
          rawList is! List) {
        print(
          '[ActivityRepo] invalid response shape',
        );

        return [];
      }

      print(
        '[ActivityRepo] rawList = $rawList',
      );

      final activities =
          rawList
              .map(
                (item) =>
                    ActivityModel.fromBackendJson(
                      Map<String,
                        dynamic>.from(
                        item,
                      ),
                    ),
              )
              .toList();

      // Filter only today activities

      final todayActivities =
          activities.where((a) {
            final activityDate =
                '${a.timestamp.year}-${a.timestamp.month.toString().padLeft(2, '0')}-${a.timestamp.day.toString().padLeft(2, '0')}';

            return activityDate ==
                today;
          }).toList();

      // Sort newest first

      todayActivities.sort(
        (a, b) => b.timestamp
            .compareTo(
              a.timestamp,
            ),
      );

      print(
        '[ActivityRepo] total=${activities.length} today=${todayActivities.length}',
      );

      return todayActivities;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message:
            'Failed to get activities: $e',
      );
    }
  }

  // =====================================================
  // DELETE ACTIVITY
  // =====================================================

  Future<void> deleteActivity(
    String id,
  ) async {
    try {
      if (id.startsWith(
            'local_',
          ) ||
          id.startsWith('hc_')) {
        return;
      }

      final headers =
          await _authHeaders;

      await _apiService.delete(
        '${ApiConfig.deleteActivity}/$id',
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message:
            'Failed to delete activity: $e',
      );
    }
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  void dispose() {
    _apiService.dispose();
  }
}