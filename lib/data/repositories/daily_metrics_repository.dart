import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/data/models/daily_metric_model.dart';
import 'package:vital_metrics/services/api_service.dart';
import 'package:vital_metrics/services/token_storage_service.dart';

class DailyMetricsRepository {
  final ApiService _api;
  final TokenStorageService _tokenStorage;

  DailyMetricsRepository({ApiService? api, TokenStorageService? tokenStorage})
    : _api = api ?? ApiService(),
      _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  // GET /daily-metrics?page=1&limit=7
  // Backend returns newest-first → reverse to get Mon→Sun order
  Future<List<DailyMetricModel>> getWeeklyMetrics() async {
    try {
      final headers = await _authHeaders;
      final raw = await _api.getAsList(
        ApiConfig.getDailyMetrics,
        headers: headers,
        queryParameters: {'page': 1, 'limit': 7},
      );
      final metrics = raw
          .map((e) => DailyMetricModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return metrics.reversed.toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch daily metrics: $e');
    }
  }

  // GET /daily-metrics — find today's record to get its metric_id
  Future<DailyMetricModel?> getTodayMetric() async {
    try {
      final headers = await _authHeaders;
      final today = _todayStr();
      final raw = await _api.getAsList(
        ApiConfig.getDailyMetrics,
        headers: headers,
        queryParameters: {'page': 1, 'limit': 30}, // زود الـ limit
      );
      final metrics = raw
          .map((e) => DailyMetricModel.fromJson(e as Map<String, dynamic>))
          .toList();
      try {
        return metrics.firstWhere((m) => m.date.startsWith(today));
      } catch (_) {
        return null;
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get today metric: $e');
    }
  }

  // PATCH /daily-metrics/{id}/steps — sync Health Connect steps
  Future<DailyMetricModel> updateSteps({
    required int metricsId,
    required int totalSteps,
  }) async {
    try {
      final headers = await _authHeaders;
      final response = await _api.patch(
        ApiConfig.updateDailySteps(metricsId),
        headers: headers,
        body: {'total_steps': totalSteps},
      );
      return DailyMetricModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to update steps: $e');
    }
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
