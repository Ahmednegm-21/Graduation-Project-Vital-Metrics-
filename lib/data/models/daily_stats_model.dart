import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/data/models/activity_model.dart';

class DailyStats {
  final ActivityLevel activityLevel;
  final int caloriesBurned;
  final int steps;
  final int workoutMinutes;
  final List<ActivityModel> trackedActivities;
  final double userWeight;
  final double userHeight;
  final double userAge;
  final String userGender;

  const DailyStats({
    required this.activityLevel,
    required this.caloriesBurned,
    required this.steps,
    required this.workoutMinutes,
    required this.trackedActivities,
    required this.userWeight,
    required this.userHeight,
    required this.userAge,
    required this.userGender,
  });

  // Calories goal calculated from real user profile using Mifflin-St Jeor
  int get caloriesGoal => activityLevel.caloriesGoalFor(
        weight: userWeight,
        height: userHeight,
        age: userAge,
        gender: userGender,
      );

  // Steps goal from activity level
  int get stepsGoal => activityLevel.stepsGoal;

  // Workout goal in minutes from activity level
  int get workoutGoal => activityLevel.workoutGoal;

  // Water goal in ml calculated from real user weight
  // Formula: weight x ml-per-kg (35/40/45 depending on activity level)
  int get waterGoalMl => activityLevel.waterGoalMl(weight: userWeight);

  // Water goal formatted as liters string e.g. 2.8L
  String get waterGoalL => (waterGoalMl / 1000).toStringAsFixed(1);

  // Calories burn progress clamped between 0.0 and 1.0
  double get caloriesProgress {
    if (caloriesGoal <= 0) return 0;
    return (caloriesBurned / caloriesGoal).clamp(0.0, 1.0);
  }

  // Steps progress clamped between 0.0 and 1.0
  double get stepsProgress {
    if (stepsGoal <= 0) return 0;
    return (steps / stepsGoal).clamp(0.0, 1.0);
  }

  // Workout progress clamped between 0.0 and 1.0
  double get workoutProgress {
    if (workoutGoal <= 0) return 0;
    return (workoutMinutes / workoutGoal).clamp(0.0, 1.0);
  }

  // Returns true if any activity was recorded today
  bool get hasActivity => caloriesBurned > 0 || steps > 0 || workoutMinutes > 0;

  // Total number of tracked activities
  int get activityCount => trackedActivities.length;

  // Returns true if any tracked activity came from Health Connect
  bool get hasHealthConnectActivities =>
      trackedActivities.any((a) => a.isHealthConnectActivity);

  // Sum of calories burned from manually added activities only
  int get manualCaloriesBurned => trackedActivities
      .where((a) => !a.isHealthConnectActivity)
      .fold(0, (sum, a) => sum + a.caloriesBurned);

  // Sum of workout minutes from Health Connect activities only
  int get healthConnectWorkoutMinutes => trackedActivities
      .where((a) => a.isHealthConnectActivity)
      .fold(0, (sum, a) => sum + a.durationMinutes);

  DailyStats copyWith({
    ActivityLevel? activityLevel,
    int? caloriesBurned,
    int? steps,
    int? workoutMinutes,
    List<ActivityModel>? trackedActivities,
    double? userWeight,
    double? userHeight,
    double? userAge,
    String? userGender,
  }) {
    return DailyStats(
      activityLevel: activityLevel ?? this.activityLevel,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      steps: steps ?? this.steps,
      workoutMinutes: workoutMinutes ?? this.workoutMinutes,
      trackedActivities: trackedActivities ?? this.trackedActivities,
      userWeight: userWeight ?? this.userWeight,
      userHeight: userHeight ?? this.userHeight,
      userAge: userAge ?? this.userAge,
      userGender: userGender ?? this.userGender,
    );
  }
}