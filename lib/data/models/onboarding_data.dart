import 'user_goal.dart';

class OnboardingData {
  String? gender;
  double? height;
  double? weight;
  double? age;
  UserGoal? goal;

  double? targetWeight;
  double? weightPerWeek;
  DateTime? targetDate;

  OnboardingData({
    this.gender,
    this.height,
    this.weight,
    this.age,
    this.goal,
    this.targetWeight,
    this.weightPerWeek,
    this.targetDate,
  });

  bool get isComplete {
    return gender != null &&
        height != null &&
        weight != null &&
        age != null &&
        goal != null &&
        targetWeight != null &&
        weightPerWeek != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'height': height,
      'weight': weight,
      'age': age,
      'goal': goal?.toJson(),
      'targetWeight': targetWeight,
      'weightPerWeek': weightPerWeek,
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  OnboardingData copyWith({
    String? gender,
    double? height,
    double? weight,
    double? age,
    UserGoal? goal,
    double? targetWeight,
    double? weightPerWeek,
    DateTime? targetDate,
  }) {
    return OnboardingData(
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      targetWeight: targetWeight ?? this.targetWeight,
      weightPerWeek: weightPerWeek ?? this.weightPerWeek,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  @override
  String toString() {
    return 'OnboardingData(gender: $gender, height: $height, weight: $weight, age: $age, goal: ${goal?.type}, targetWeight: $targetWeight, weightPerWeek: $weightPerWeek, targetDate: $targetDate)';
  }
}