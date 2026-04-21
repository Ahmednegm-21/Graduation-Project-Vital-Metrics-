class NutritionData {
  int calories;
  int caloriesGoal;
  double protein;
  double proteinGoal;
  double carbs;
  double carbsGoal;
  double fat;
  double fatGoal;
  int waterIntake; // in ml
  int waterGoal; // in ml

  NutritionData({
    this.calories = 0,
    this.caloriesGoal = 3421,
    this.protein = 0,
    this.proteinGoal = 245,
    this.carbs = 0,
    this.carbsGoal = 345,
    this.fat = 0,
    this.fatGoal = 145,
    this.waterIntake = 0,
    this.waterGoal = 3208,
  });

  // Add water (240ml per cup)
  void addWaterCup() {
    waterIntake += 240;
    if (waterIntake > 99999) {
      waterIntake = 99999;
    }
  }

  // Reset water intake
  void resetWater() {
    waterIntake = 0;
  }

  // Get protein percentage
  double get proteinPercentage => protein / proteinGoal;

  // Get carbs percentage
  double get carbsPercentage => carbs / carbsGoal;

  // Get fat percentage
  double get fatPercentage => fat / fatGoal;

  // Get calories remaining
  int get caloriesRemaining => caloriesGoal - calories;
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snacks,
}

class Meal {
  final MealType type;
  final String name;
  final int calories;

  Meal({
    required this.type,
    required this.name,
    required this.calories,
  });
}