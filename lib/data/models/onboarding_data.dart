import 'user_goal.dart';
import 'activity_level.dart';

class OnboardingData {
  String? gender;

  double? height;

  double? weight;

  double? age;

  UserGoal? goal;

  ActivityLevel? activityLevel;

  double? targetWeight;

  double? weightPerWeek;

  DateTime? targetDate;

  OnboardingData({
    this.gender,
    this.height,
    this.weight,
    this.age,
    this.goal,
    this.activityLevel,
    this.targetWeight,
    this.weightPerWeek,
    this.targetDate,
  });

  // =====================================================
  // COMPLETE CHECK
  // =====================================================

  bool get isComplete {
    return gender != null &&
        height != null &&
        weight != null &&
        age != null &&
        goal != null &&
        activityLevel != null &&
        targetWeight != null &&
        weightPerWeek != null;
  }

  // =====================================================
  // TO JSON
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,

      'height': height,

      'weight': weight,

      'age': age,

      'goal': goal?.toJson(),

      'activityLevel':
          activityLevel?.name,

      'targetWeight':
          targetWeight,

      'weightPerWeek':
          weightPerWeek,

      'targetDate':
          targetDate
              ?.toIso8601String(),
    };
  }

  // =====================================================
  // FROM JSON
  // =====================================================

  factory OnboardingData.fromJson(
    Map<String, dynamic> json,
  ) {
    return OnboardingData(
      gender:
          json['gender'] as String?,

      height:
          (json['height'] as num?)
              ?.toDouble(),

      weight:
          (json['weight'] as num?)
              ?.toDouble(),

      age:
          (json['age'] as num?)
              ?.toDouble(),

      goal:
          json['goal'] != null
              ? UserGoal.fromJson(
                  json['goal'],
                )
              : null,

      activityLevel:
          json['activityLevel'] != null
              ? ActivityLevel.values
                  .firstWhere(
                  (e) =>
                      e.name ==
                      json['activityLevel'],
                )
              : ActivityLevel.low,

      targetWeight:
          (json['targetWeight']
                  as num?)
              ?.toDouble(),

      weightPerWeek:
          (json['weightPerWeek']
                  as num?)
              ?.toDouble(),

      targetDate:
          json['targetDate'] != null
              ? DateTime.parse(
                  json['targetDate'],
                )
              : null,
    );
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  OnboardingData copyWith({
    String? gender,
    double? height,
    double? weight,
    double? age,
    UserGoal? goal,
    ActivityLevel? activityLevel,
    double? targetWeight,
    double? weightPerWeek,
    DateTime? targetDate,
  }) {
    return OnboardingData(
      gender:
          gender ?? this.gender,

      height:
          height ?? this.height,

      weight:
          weight ?? this.weight,

      age:
          age ?? this.age,

      goal:
          goal ?? this.goal,

      activityLevel:
          activityLevel ??
              this.activityLevel,

      targetWeight:
          targetWeight ??
              this.targetWeight,

      weightPerWeek:
          weightPerWeek ??
              this.weightPerWeek,

      targetDate:
          targetDate ??
              this.targetDate,
    );
  }

  // =====================================================
  // DEBUG
  // =====================================================

  @override
  String toString() {
    return '''
OnboardingData(
  gender: $gender,
  height: $height,
  weight: $weight,
  age: $age,
  goal: ${goal?.type},
  activityLevel: $activityLevel,
  targetWeight: $targetWeight,
  weightPerWeek: $weightPerWeek,
  targetDate: $targetDate
)
''';
  }
}