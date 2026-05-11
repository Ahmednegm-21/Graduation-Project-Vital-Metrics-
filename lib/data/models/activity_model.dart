class ActivityModel {
  final String id;
  final String type;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime timestamp;

  const ActivityModel({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.timestamp,
  });

  // For local/Google Fit activities
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id:              json['id'] as String,
      type:            json['type'] as String,
      durationMinutes: json['durationMinutes'] as int,
      caloriesBurned:  json['caloriesBurned'] as int,
      timestamp:       DateTime.parse(json['timestamp'] as String),
    );
  }

  // For backend API response
  factory ActivityModel.fromBackendJson(Map<String, dynamic> json) {
    return ActivityModel(
      id:              (json['activity_id'] ?? json['id'])?.toString() ?? '',
      type:            json['type'] as String? ?? 'Workout',
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 0,
      caloriesBurned:  (json['calories_burned'] as num?)?.toInt() ?? 0,
      timestamp:       json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id':              id,
        'type':            type,
        'durationMinutes': durationMinutes,
        'caloriesBurned':  caloriesBurned,
        'timestamp':       timestamp.toIso8601String(),
      };
}