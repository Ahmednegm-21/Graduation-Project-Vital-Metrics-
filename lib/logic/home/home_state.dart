import '../../data/models/nutrition_model.dart';

class HomeState {
  final NutritionData nutritionData;

  HomeState({
    NutritionData? nutritionData,
  }) : nutritionData = nutritionData ?? NutritionData();

  // =====================================================
  // WATER ONLY
  // =====================================================

  int get waterIntake =>
      nutritionData.waterIntake;

  int get waterGoal =>
      nutritionData.waterGoal;

  // =====================================================
  // COPY WITH
  // =====================================================

  HomeState copyWith({
    NutritionData? nutritionData,
  }) {
    return HomeState(
      nutritionData:
          nutritionData ?? this.nutritionData,
    );
  }
}