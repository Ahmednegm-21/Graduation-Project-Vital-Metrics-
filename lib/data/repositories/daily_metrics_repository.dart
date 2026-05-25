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

  // GET /daily-metrics?page=X&limit=7
  // weekOffset: 0 = current week, -1 = last week, -2 = two weeks ago, etc.
  // Backend returns newest-first so we reverse to get Sat->Fri order.
  // We fetch limit=14 to have enough records then filter by the target week dates.
  Future<List<DailyMetricModel>> getWeeklyMetrics({
    int weekOffset = 0,
  }) async {
    try {
      final headers = await _authHeaders;

      // Calculate the target week date range
      final range = _weekDateRange(weekOffset);
      final weekStart = range.$1;
      final weekEnd = range.$2;

      // Fetch enough records to cover the target week.
      // weekOffset 0 needs page 1, offset -1 might need page 1 or 2, etc.
      // We fetch a generous limit and filter by date on the client side.
      final limit = 7 + (weekOffset.abs() * 7) + 7;

      final raw = await _api.getAsList(
        ApiConfig.getDailyMetrics,
        headers: headers,
        queryParameters: {'page': 1, 'limit': limit},
      );

      final allMetrics = raw
          .map((e) => DailyMetricModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Filter to only records within the target week
      final filtered = allMetrics.where((m) {
        final dateStr = m.date.length >= 10 ? m.date.substring(0, 10) : m.date;
        final date = DateTime.tryParse(dateStr);
        if (date == null) return false;
        // Include dates from weekStart to weekEnd inclusive
        return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
      }).toList();

      // Sort ascending (Sat to Fri)
      filtered.sort((a, b) {
        final da = a.date.length >= 10 ? a.date.substring(0, 10) : a.date;
        final db = b.date.length >= 10 ? b.date.substring(0, 10) : b.date;
        return da.compareTo(db);
      });

      return filtered;
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
        queryParameters: {'page': 1, 'limit': 30},
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

  // Returns (weekStart, weekEnd) for a given weekOffset
  // weekOffset 0 = current week (Sat to Fri)
  // weekOffset -1 = last week, etc.
  (DateTime, DateTime) _weekDateRange(int weekOffset) {
    final now = DateTime.now();
    final weekday = now.weekday;

    final int daysSinceSaturday;
    switch (weekday) {
      case DateTime.saturday:
        daysSinceSaturday = 0;
        break;
      case DateTime.sunday:
        daysSinceSaturday = 1;
        break;
      case DateTime.monday:
        daysSinceSaturday = 2;
        break;
      case DateTime.tuesday:
        daysSinceSaturday = 3;
        break;
      case DateTime.wednesday:
        daysSinceSaturday = 4;
        break;
      case DateTime.thursday:
        daysSinceSaturday = 5;
        break;
      default:
        daysSinceSaturday = 6;
    }

    final currentWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysSinceSaturday));

    final targetWeekStart =
        currentWeekStart.add(Duration(days: weekOffset * 7));

    final targetWeekEnd = targetWeekStart.add(const Duration(days: 6));

    return (targetWeekStart, targetWeekEnd);
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}