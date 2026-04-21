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

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      type: json['type'] as String,
      durationMinutes: json['durationMinutes'] as int,
      caloriesBurned: json['caloriesBurned'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'timestamp': timestamp.toIso8601String(),
      };
}