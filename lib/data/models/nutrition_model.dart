class NutritionData {
  int calories;
  int caloriesGoal;

  double protein;
  double proteinGoal;

  double carbs;
  double carbsGoal;

  double fat;
  double fatGoal;

  int waterIntake;
  int waterGoal;

  NutritionData({
    this.calories = 0,

    // Daily calories target
    this.caloriesGoal = 2000,

    // Current intake
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,

    // Correct macro goals for 2000 kcal
    this.proteinGoal = 150, // 600 kcal
    this.carbsGoal = 200,   // 800 kcal
    this.fatGoal = 67,      // 603 kcal

    this.waterIntake = 0,
    this.waterGoal = 3200,
  });

  // WATER
  void addWaterCup() {
    waterIntake += 240;

    if (waterIntake > 99999) {
      waterIntake = 99999;
    }
  }

  void resetWater() {
    waterIntake = 0;
  }

  // PERCENTAGES
  double get proteinPercentage =>
      proteinGoal == 0 ? 0 : protein / proteinGoal;

  double get carbsPercentage =>
      carbsGoal == 0 ? 0 : carbs / carbsGoal;

  double get fatPercentage =>
      fatGoal == 0 ? 0 : fat / fatGoal;

  // CALORIES LEFT
  int get caloriesRemaining =>
      caloriesGoal - calories;
}