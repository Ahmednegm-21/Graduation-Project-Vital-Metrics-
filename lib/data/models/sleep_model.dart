class SleepModel {
  final int    id;
  final int    durationMinutes;
  final String quality;
  final int    metricsId;

  const SleepModel({
    required this.id,
    required this.durationMinutes,
    required this.quality,
    required this.metricsId,
  });

  // Convert duration minutes to hours for UI
  double get hours => durationMinutes / 60.0;

  factory SleepModel.fromJson(Map<String, dynamic> json) {
    return SleepModel(
      id:              (json['sleep_id'] as num).toInt(),
      durationMinutes: (json['duration']  as num).toInt(),
      quality:         json['quality']    as String? ?? 'good',
      metricsId:       (json['metrics_id'] as num).toInt(),
    );
  }
}