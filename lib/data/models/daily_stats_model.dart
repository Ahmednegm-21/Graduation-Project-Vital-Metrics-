import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/data/models/activity_model.dart';

class DailyStats {
  final ActivityLevel activityLevel;
  final int caloriesBurned;
  final int steps;
  final int workoutMinutes;
  final List<ActivityModel> trackedActivities;

  // User profile data for goal calculation
  final double? userWeight;
  final double? userHeight;
  final double? userAge;
  final String? userGender;

  const DailyStats({
    required this.activityLevel,
    required this.caloriesBurned,
    required this.steps,
    required this.workoutMinutes,
    required this.trackedActivities,
    this.userWeight,
    this.userHeight,
    this.userAge,
    this.userGender,
  });

  bool get _hasUserData =>
      userWeight != null &&
      userHeight != null &&
      userAge != null &&
      userGender != null;

  // ─── Goals ─────────────────────────────────────────────────────────────────
  int get caloriesGoal => _hasUserData
      ? activityLevel.caloriesGoalFor(
          weight: userWeight!,
          height: userHeight!,
          age: userAge!,
          gender: userGender!,
        )
      : activityLevel.caloriesGoal;

  int get stepsGoal => activityLevel.stepsGoal;
  int get workoutGoal => activityLevel.workoutGoal;

  // ─── Progress ───────────────────────────────────────────────────────────────
  double get caloriesProgress =>
      (caloriesGoal > 0 ? caloriesBurned / caloriesGoal : 0.0).clamp(0.0, 1.0);
  double get stepsProgress =>
      (stepsGoal > 0 ? steps / stepsGoal : 0.0).clamp(0.0, 1.0);
  double get workoutProgress =>
      (workoutGoal > 0 ? workoutMinutes / workoutGoal : 0.0).clamp(0.0, 1.0);

  bool get hasActivity => caloriesBurned > 0 || steps > 0 || workoutMinutes > 0;

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
