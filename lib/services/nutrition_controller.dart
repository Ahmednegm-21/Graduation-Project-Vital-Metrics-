// lib/services/nutrition_controller.dart

import 'package:flutter/material.dart';
import '../data/models/nutrition_model.dart';

class NutritionController extends ChangeNotifier {
  NutritionData _nutritionData = NutritionData();

  NutritionData get nutritionData => _nutritionData;

  // Add water cup (240ml)
  void addWaterCup() {
    _nutritionData.addWaterCup();
    notifyListeners();
  }

  // Reset water tracker
  void resetWater() {
    _nutritionData.resetWater();
    notifyListeners();
  }

  // Add meal
  void addMeal(Meal meal) {
    _nutritionData.calories += meal.calories;
    notifyListeners();
  }

  // Update macros
  void updateMacros({
    double? protein,
    double? carbs,
    double? fat,
  }) {
    if (protein != null) _nutritionData.protein += protein;
    if (carbs != null) _nutritionData.carbs += carbs;
    if (fat != null) _nutritionData.fat += fat;
    notifyListeners();
  }

  // Reset daily data
  void resetDailyData() {
    _nutritionData = NutritionData();
    notifyListeners();
  }
}