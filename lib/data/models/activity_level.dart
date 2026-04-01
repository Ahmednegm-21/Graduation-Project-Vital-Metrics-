enum ActivityLevel {
  low,
  moderate,
  high;

  String get label {
    switch (this) {
      case ActivityLevel.low:
        return 'Low';
      case ActivityLevel.moderate:
        return 'Moderate';
      case ActivityLevel.high:
        return 'High';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.low:
        return 'Light activity, mostly sedentary. Tap to change';
      case ActivityLevel.moderate:
        return 'Moderately active lifestyle. Tap to change';
      case ActivityLevel.high:
        return 'Very active lifestyle. Tap to change';
    }
  }

  double get _activityMultiplier {
    switch (this) {
      case ActivityLevel.low:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.high:
        return 1.725;
    }
  }

  int get stepsGoal {
    switch (this) {
      case ActivityLevel.low:
        return 5000;
      case ActivityLevel.moderate:
        return 8000;
      case ActivityLevel.high:
        return 12000;
    }
  }

  int get workoutGoal {
    switch (this) {
      case ActivityLevel.low:
        return 30;
      case ActivityLevel.moderate:
        return 45;
      case ActivityLevel.high:
        return 60;
    }
  }

  ///calorie burn goal using Mifflin-St Jeor BMR × activity multiplier
  int caloriesGoalFor({
    required double weight,
    required double height,
    required double age,
    required String gender,
  }) {
    final double bmr = gender.toLowerCase() == 'female'
        ? (10 * weight) + (6.25 * height) - (5 * age) - 161
        : (10 * weight) + (6.25 * height) - (5 * age) + 5;

    final tdee = bmr * _activityMultiplier;
    final activeCalories = (tdee * 0.2).round();
    return activeCalories.clamp(200, 1200);
  }

  /// Static fallback when user data not available
  int get caloriesGoal {
    switch (this) {
      case ActivityLevel.low:
        return 300;
      case ActivityLevel.moderate:
        return 500;
      case ActivityLevel.high:
        return 750;
    }
  }
}