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

  // =====================================================
  // LOCAL JSON
  // =====================================================

  factory ActivityModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ActivityModel(
      id: json['id']?.toString() ?? '',

      type: _parseType(
        json['type'],
      ),

      durationMinutes:
          (json['durationMinutes'] as num?)
              ?.toInt() ??
          0,

      caloriesBurned:
          (json['caloriesBurned'] as num?)
              ?.toInt() ??
          0,

      timestamp:
          json['timestamp'] != null
              ? DateTime.tryParse(
                    json['timestamp'].toString(),
                  ) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  // =====================================================
  // BACKEND JSON
  // =====================================================

  factory ActivityModel.fromBackendJson(
    Map<String, dynamic> json,
  ) {
    return ActivityModel(
      id:
          (json['activity_id'] ??
                  json['id'])
              ?.toString() ??
          '',

      type: _formatActivityType(
        _parseType(
          json['type'],
        ),
      ),

      durationMinutes:
          (json['duration'] as num?)
              ?.toInt() ??
          0,

      caloriesBurned:
          (json['calories_burned']
                  as num?)
              ?.toInt() ??
          0,

      timestamp:
          json['date'] != null
              ? DateTime.tryParse(
                    json['date']
                        .toString(),
                  ) ??
                  DateTime.now()
              : DateTime.now(),
    );
  }

  // =====================================================
  // SERIALIZE
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'durationMinutes':
          durationMinutes,
      'caloriesBurned':
          caloriesBurned,
      'timestamp':
          timestamp.toIso8601String(),
    };
  }

  // =====================================================
  // HELPERS
  // =====================================================

  bool get isHealthConnectActivity {
    return id.startsWith('hc_');
  }

  bool get isLocalActivity {
    return id.startsWith('local_');
  }

  bool get isBackendActivity {
    return !isHealthConnectActivity &&
        !isLocalActivity;
  }

  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes min';
    }

    final hours =
        durationMinutes ~/ 60;

    final mins =
        durationMinutes % 60;

    if (mins == 0) {
      return '$hours h';
    }

    return '$hours h $mins min';
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  ActivityModel copyWith({
    String? id,
    String? type,
    int? durationMinutes,
    int? caloriesBurned,
    DateTime? timestamp,
  }) {
    return ActivityModel(
      id: id ?? this.id,

      type: type ?? this.type,

      durationMinutes:
          durationMinutes ??
              this.durationMinutes,

      caloriesBurned:
          caloriesBurned ??
              this.caloriesBurned,

      timestamp:
          timestamp ??
              this.timestamp,
    );
  }

  // =====================================================
  // TYPE PARSER
  // =====================================================

  static String _parseType(
    dynamic value,
  ) {
    if (value == null) {
      return 'Workout';
    }

    if (value is String) {
      return value;
    }

    if (value is List) {
      if (value.isEmpty) {
        return 'Workout';
      }

      return value.first.toString();
    }

    return value.toString();
  }

  // =====================================================
  // FORMAT ACTIVITY TYPE
  // =====================================================

  static String _formatActivityType(
    String raw,
  ) {
    final lower =
        raw.toLowerCase();

    switch (lower) {
      case 'run':
        return 'Running';

      case 'walk':
        return 'Walking';

      case 'bike':
        return 'Cycling';

      case 'gym':
        return 'Workout';

      case 'yoga':
        return 'Yoga';

      case 'stretching':
        return 'Stretching';

      default:
        return raw;
    }
  }

  // =====================================================
  // EQUATABLE HELPERS
  // =====================================================

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ActivityModel &&
            runtimeType ==
                other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return 'ActivityModel('
        'id: $id, '
        'type: $type, '
        'duration: $durationMinutes, '
        'calories: $caloriesBurned'
        ')';
  }
}