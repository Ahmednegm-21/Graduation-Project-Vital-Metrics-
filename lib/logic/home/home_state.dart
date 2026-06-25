  import '../../data/models/nutrition_model.dart';

  class HomeState {
    final NutritionData nutritionData;

    HomeState({
      NutritionData? nutritionData,
    }) : nutritionData = nutritionData ?? NutritionData();


    int get waterIntake =>
        nutritionData.waterIntake;

    int get waterGoal =>
        nutritionData.waterGoal;


    HomeState copyWith({
      NutritionData? nutritionData,
    }) {
      return HomeState(
        nutritionData:
            nutritionData ?? this.nutritionData,
      );
    }
  }