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

  // =====================================================
  // GET WEEKLY METRICS
  // weekOffset: 0 = current week, -1 = last week, etc.
  // Backend returns records newest first so we fetch enough
  // records to guarantee the full requested week is included
  // =====================================================

  Future<List<DailyMetricModel>> getWeeklyMetrics({
    int weekOffset = 0,
  }) async {
    try {
      final headers   = await _authHeaders;
      final range     = _weekDateRange(weekOffset);
      final weekStart = range.$1;
      final weekEnd   = range.$2;

      // Fetch enough records to always cover the requested week
      // Base of 30 ensures the current week is fully covered
      // Each additional past week adds 7 more records
      final limit = 30 + (weekOffset.abs() * 7);

      final raw = await _api.getAsList(
        ApiConfig.getDailyMetrics,
        headers: headers,
        queryParameters: {'page': 1, 'limit': limit},
      );

      final allMetrics = raw
          .map((e) => DailyMetricModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Keep only records that fall inside the requested week range
      final filtered = allMetrics.where((m) {
        final dateStr =
            m.date.length >= 10 ? m.date.substring(0, 10) : m.date;
        final date = DateTime.tryParse(dateStr);
        if (date == null) return false;
        return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
      }).toList();

      // Sort ascending so days appear Sat -> Fri
      filtered.sort((a, b) {
        final da =
            a.date.length >= 10 ? a.date.substring(0, 10) : a.date;
        final db =
            b.date.length >= 10 ? b.date.substring(0, 10) : b.date;
        return da.compareTo(db);
      });

      print('[DailyMetricsRepo] weekOffset=$weekOffset '
          'fetched=${allMetrics.length} filtered=${filtered.length} '
          'range=${_fmt(weekStart)} -> ${_fmt(weekEnd)}');

      return filtered;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch daily metrics: $e');
    }
  }

  // =====================================================
  // GET TODAY METRIC
  // =====================================================

  Future<DailyMetricModel?> getTodayMetric() async {
    try {
      final headers = await _authHeaders;
      final today   = _todayStr();

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

  // =====================================================
  // GET METRIC BY DATE
  // date format: yyyy-MM-dd (e.g. "2026-05-30")
  // Returns null if no record exists for that date
  // =====================================================

  Future<DailyMetricModel?> getMetricByDate(String date) async {
    try {
      final headers = await _authHeaders;

      final raw = await _api.getAsList(
        ApiConfig.getDailyMetrics,
        headers: headers,
        queryParameters: {'page': 1, 'limit': 60},
      );

      final metrics = raw
          .map((e) => DailyMetricModel.fromJson(e as Map<String, dynamic>))
          .toList();

      try {
        return metrics.firstWhere((m) => m.date.startsWith(date));
      } catch (_) {
        return null;
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to get metric for date $date: $e',
      );
    }
  }

  // =====================================================
  // UPDATE STEPS
  // =====================================================

  Future<DailyMetricModel> updateSteps({
    required int metricsId,
    required int totalSteps,
  }) async {
    try {
      final headers  = await _authHeaders;
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

  // =====================================================
  // HELPERS
  // =====================================================

  // Calculate start and end dates for a given week offset
  // Week starts on Saturday and ends on Friday
  // DateTime weekday values: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7
  (DateTime, DateTime) _weekDateRange(int weekOffset) {
    final now     = DateTime.now();
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
      case DateTime.friday:
        daysSinceSaturday = 6;
        break;
      default:
        daysSinceSaturday = 0;
    }

    final currentWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysSinceSaturday));
    final targetWeekStart =
        currentWeekStart.add(Duration(days: weekOffset * 7));
    final targetWeekEnd =
        targetWeekStart.add(const Duration(days: 6));

    return (targetWeekStart, targetWeekEnd);
  }

  // Returns today as yyyy-MM-dd
  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // Format a DateTime as yyyy-MM-dd for logging
  String _fmt(DateTime d) =>
      '${d.year}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}