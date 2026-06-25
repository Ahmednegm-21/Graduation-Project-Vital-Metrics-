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

      final data = response['data'] ?? response;

      // The create response never includes a date field, only metrics_id
      // We already know the real date since we just sent it, so inject it
      // manually before parsing to avoid falling back to DateTime.now()
      final enriched = Map<String, dynamic>.from(data as Map<String, dynamic>);
      enriched['date'] = dateStr;

      final saved = ActivityModel.fromBackendJson(enriched);
      return saved.copyWith(type: type);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to create activity: $e');
    }
  }

  // =====================================================
  // GET DAILY METRICS DATE MAP
  // The /activities endpoint only returns metrics_id, not a date.
  // We fetch daily-metrics and build metrics_id -> date so every
  // activity can be resolved to its real day instead of "now".
  // =====================================================

  Future<Map<int, String>> _getMetricsIdToDateMap() async {
    try {
      final headers = await _authHeaders;
      final raw = await _apiService.getAsList(
        ApiConfig.getDailyMetrics,
        headers: headers,
        queryParameters: {'page': 1, 'limit': 60},
      );

      final map = <int, String>{};
      for (final item in raw) {
        final m = item as Map<String, dynamic>;
        final id = (m['metrics_id'] ?? m['metric_id'] ?? m['id']) as int?;
        final date = m['date']?.toString();
        if (id != null && date != null) {
          map[id] = date.length >= 10 ? date.substring(0, 10) : date;
        }
      }
      return map;
    } catch (e) {
      print('[ActivityRepo] failed to load metrics date map: $e');
      return {};
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

      // Resolve each activity's real date through its metrics_id
      // since the /activities response itself has no date field
      final metricsDateMap = await _getMetricsIdToDateMap();

      final activities = raw.map((item) {
        final m = item as Map<String, dynamic>;
        final metricsId = (m['metrics_id'] ?? m['metricsId']) as int?;
        final resolvedDate = metricsId != null ? metricsDateMap[metricsId] : null;

        // Inject the resolved date before parsing so fromBackendJson
        // uses the real day instead of falling back to DateTime.now()
        final enriched = Map<String, dynamic>.from(m);
        if (resolvedDate != null) {
          enriched['date'] = resolvedDate;
        }

        return ActivityModel.fromBackendJson(enriched);
      }).toList();

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