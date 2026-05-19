import 'package:flutter/material.dart';

import '../data/models/nutrition_model.dart';

class NutritionController extends ChangeNotifier {
  NutritionData _nutritionData =
      NutritionData();

  NutritionData get nutritionData =>
      _nutritionData;

  // =====================================================
  // WATER
  // =====================================================

  void addWaterCup() {
    _nutritionData.addWaterCup();

    notifyListeners();
  }

  void resetWater() {
    _nutritionData.resetWater();

    notifyListeners();
  }

  // =====================================================
  // ADD MEAL
  // =====================================================

  void addMeal({
    required int calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
  }) {
    _nutritionData.calories += calories;

    _nutritionData.protein += protein;

    _nutritionData.carbs += carbs;

    _nutritionData.fat += fat;

    notifyListeners();
  }

  // =====================================================
  // RESET
  // =====================================================

  void resetDailyData() {
    _nutritionData = NutritionData();

    notifyListeners();
  }
}