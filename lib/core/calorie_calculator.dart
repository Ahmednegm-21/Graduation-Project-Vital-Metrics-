import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/data/models/user_goal.dart';

class CalorieCalculator {
  static double calculateBMR({
    required String gender,
    required double weight,
    required double height,
    required double age,
  }) {
    if (gender.toLowerCase() == 'male') {
      return (10 * weight) +
          (6.25 * height) -
          (5 * age) +
          5;
    }

    return (10 * weight) +
        (6.25 * height) -
        (5 * age) -
        161;
  }

  static int calculateDailyCalories({
    required double bmr,
    required GoalType goalType,
    required double weightPerWeek,
  }) {
    final tdee = bmr * AppConstants.activityMultiplier;

    final weeklyAdjustment =
        (weightPerWeek * AppConstants.caloriesPerKg) / 7;

    switch (goalType) {
      case GoalType.loseWeight:
        return (tdee - weeklyAdjustment).round();

      case GoalType.gainWeight:
        return (tdee + weeklyAdjustment).round();
    }
  }

  static int calculateWaterIntake(double weight) {
    return (weight * AppConstants.waterPerKg).round();
  }
}