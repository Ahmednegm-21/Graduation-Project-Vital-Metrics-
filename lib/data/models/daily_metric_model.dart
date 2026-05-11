class DailyMetricModel {
  final int    metricId;
  final String date;
  final int    totalSteps;
  final int    caloriesConsumed;
  final int    burnedTotal;
  final int    totalWaterMl;
  final int    totalSleepMinutes;

  const DailyMetricModel({
    required this.metricId,
    required this.date,
    required this.totalSteps,
    required this.caloriesConsumed,
    required this.burnedTotal,
    required this.totalWaterMl,
    required this.totalSleepMinutes,
  });

  factory DailyMetricModel.fromJson(Map<String, dynamic> json) {
    return DailyMetricModel(
      metricId:          (json['metric_id'] ?? json['metrics_id'] ?? json['id'] ?? 0) as int,
      date:              json['date']?.toString() ?? '',
      totalSteps:        (json['total_steps']         as num?)?.toInt() ?? 0,
      caloriesConsumed:  (json['calories_consumed']   as num?)?.toInt() ?? 0,
      burnedTotal:       (json['burned_total']        as num?)?.toInt() ?? 0,
      totalWaterMl:      (json['total_water_ml']      as num?)?.toInt() ?? 0,
      totalSleepMinutes: (json['total_sleep_minutes'] as num?)?.toInt() ?? 0,
    );
  }

  // Sleep in hours — capped at 12h max since backend accumulates all sessions
  // and can go way over 12h if user logs multiple times
  double get sleepHours => (totalSleepMinutes / 60.0).clamp(0.0, 12.0);

  // Water in litres — used by the chart
  double get waterLitres => totalWaterMl / 1000.0;
}