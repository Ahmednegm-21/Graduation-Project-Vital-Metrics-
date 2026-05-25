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

  String get targetSummary {
    switch (this) {
      case ActivityLevel.low:
        return 'Burn 300 kcal · Walk 5,000 steps · 30 min workout';
      case ActivityLevel.moderate:
        return 'Burn 500 kcal · Walk 8,000 steps · 45 min workout';
      case ActivityLevel.high:
        return 'Burn 750 kcal · Walk 12,000 steps · 60 min workout';
    }
  }

  List<_LevelTip> get tips {
    switch (this) {
      case ActivityLevel.low:
        return [
          _LevelTip(
            icon: '🔥',
            title: 'Burn 300 kcal',
            detail: 'A 30-min brisk walk or light home workout',
          ),
          _LevelTip(
            icon: '👣',
            title: '5,000 steps',
            detail: 'About 4 km — try taking stairs and short walks',
          ),
          _LevelTip(
            icon: '⏱',
            title: '30 min workout',
            detail: 'Yoga, stretching, or a casual bike ride',
          ),
        ];
      case ActivityLevel.moderate:
        return [
          _LevelTip(
            icon: '🔥',
            title: 'Burn 500 kcal',
            detail: 'A 45-min jog or cycling session',
          ),
          _LevelTip(
            icon: '👣',
            title: '8,000 steps',
            detail: 'About 6 km — mix walking and light running',
          ),
          _LevelTip(
            icon: '⏱',
            title: '45 min workout',
            detail: 'Running, swimming, or a gym session',
          ),
        ];
      case ActivityLevel.high:
        return [
          _LevelTip(
            icon: '🔥',
            title: 'Burn 750 kcal',
            detail: 'A 60-min intense run or HIIT session',
          ),
          _LevelTip(
            icon: '👣',
            title: '12,000 steps',
            detail: 'About 9 km — run, hike, or stay on your feet',
          ),
          _LevelTip(
            icon: '⏱',
            title: '60 min workout',
            detail: 'HIIT, sports, or heavy gym training',
          ),
        ];
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

  // =====================================================
  // WATER GOAL — معادلة طبية: weight × mlPerKg
  // low      → 35 ml/kg  (أقل نشاط = أقل تعرق)
  // moderate → 40 ml/kg
  // high     → 45 ml/kg  (أكتر نشاط = أكتر تعرق)
  // =====================================================

  int get _mlPerKg {
    switch (this) {
      case ActivityLevel.low:
        return 35;
      case ActivityLevel.moderate:
        return 40;
      case ActivityLevel.high:
        return 45;
    }
  }

  /// يرجع الـ water goal بالـ ml بناءً على الـ weight
  /// مثال: weight=70kg, moderate → 70 × 40 = 2800 ml
  int waterGoalMl({required double weight}) {
    final ml = (weight * _mlPerKg).round();
    // clamp بين 1500ml و 5000ml عشان نتجنب أرقام غريبة
    return ml.clamp(1500, 5000);
  }
}

class _LevelTip {
  final String icon;
  final String title;
  final String detail;
  const _LevelTip({
    required this.icon,
    required this.title,
    required this.detail,
  });
}