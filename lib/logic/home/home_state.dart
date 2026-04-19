import '../../data/models/nutrition_model.dart';

class HomeState {
  final NutritionData nutritionData;

  HomeState({NutritionData? nutritionData})
      : nutritionData = nutritionData ?? NutritionData();

  int get calories => nutritionData.calories;
  int get caloriesRemaining => nutritionData.caloriesRemaining;
  double get protein => nutritionData.protein;
  double get proteinGoal => nutritionData.proteinGoal;
  double get carbs => nutritionData.carbs;
  double get carbsGoal => nutritionData.carbsGoal;
  double get fat => nutritionData.fat;
  double get fatGoal => nutritionData.fatGoal;
  int get waterIntake => nutritionData.waterIntake;
  int get waterGoal => nutritionData.waterGoal;

  HomeState copyWith({NutritionData? nutritionData}) {
    return HomeState(
      nutritionData: nutritionData ?? this.nutritionData,
    );
  }
}
