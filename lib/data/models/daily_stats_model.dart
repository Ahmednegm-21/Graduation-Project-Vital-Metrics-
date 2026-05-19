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

  // Check if user profile exists
  bool get _hasUserData =>
      userWeight != null &&
      userHeight != null &&
      userAge != null &&
      userGender != null;

  // Calories goal based on onboarding data
  int get caloriesGoal {
    if (_hasUserData) {
      return activityLevel.caloriesGoalFor(
        weight: userWeight!,
        height: userHeight!,
        age: userAge!,
        gender: userGender!,
      );
    }

    return activityLevel.caloriesGoal;
  }

  // Steps goal
  int get stepsGoal => activityLevel.stepsGoal;

  // Workout goal
  int get workoutGoal => activityLevel.workoutGoal;

  // Calories progress
  double get caloriesProgress {
    if (caloriesGoal <= 0) {
      return 0;
    }

    return (caloriesBurned / caloriesGoal).clamp(0.0, 1.0);
  }

  // Steps progress
  double get stepsProgress {
    if (stepsGoal <= 0) {
      return 0;
    }

    return (steps / stepsGoal).clamp(0.0, 1.0);
  }

  // Workout progress
  double get workoutProgress {
    if (workoutGoal <= 0) {
      return 0;
    }

    return (workoutMinutes / workoutGoal).clamp(0.0, 1.0);
  }

  // Check if there is any activity today
  bool get hasActivity {
    return caloriesBurned > 0 ||
        steps > 0 ||
        workoutMinutes > 0;
  }

  // Total activity count
  int get activityCount {
    return trackedActivities.length;
  }

  // Check if Health Connect workouts exist
  bool get hasHealthConnectActivities {
    return trackedActivities.any(
      (a) => a.isHealthConnectActivity,
    );
  }

  // Total manual calories only
  int get manualCaloriesBurned {
    return trackedActivities
        .where((a) => !a.isHealthConnectActivity)
        .fold(
          0,
          (sum, a) => sum + a.caloriesBurned,
        );
  }

  // Total Health Connect workout minutes
  int get healthConnectWorkoutMinutes {
    return trackedActivities
        .where((a) => a.isHealthConnectActivity)
        .fold(
          0,
          (sum, a) => sum + a.durationMinutes,
        );
  }

  // Create updated copy
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
      activityLevel:
          activityLevel ?? this.activityLevel,

      caloriesBurned:
          caloriesBurned ?? this.caloriesBurned,

      steps:
          steps ?? this.steps,

      workoutMinutes:
          workoutMinutes ?? this.workoutMinutes,

      trackedActivities:
          trackedActivities ?? this.trackedActivities,

      userWeight:
          userWeight ?? this.userWeight,

      userHeight:
          userHeight ?? this.userHeight,

      userAge:
          userAge ?? this.userAge,

      userGender:
          userGender ?? this.userGender,
    );
  }
}