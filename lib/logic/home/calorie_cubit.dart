import 'package:flutter_bloc/flutter_bloc.dart';
import 'calorie_state.dart';

export 'calorie_state.dart';

class CalorieCubit extends Cubit<CalorieState> {
  CalorieCubit() : super(const CalorieState());

  void addMeal(MealEntry meal) {
    final updated = List<MealEntry>.from(state.meals)..add(meal);
    emit(state.copyWith(meals: updated));
  }

  void removeMeal(MealEntry meal) {
    final updated = List<MealEntry>.from(state.meals)..remove(meal);
    emit(state.copyWith(meals: updated));
  }

  // Add a meal from the recipes screen using name + calories only
  // (used for local fallback meals that don't have macros from backend)
  void addMealByName({
    required String name,
    required double calories,
    double protein = 0,
    double carbs   = 0,
    double fat     = 0,
    String mealType = 'lunch',
  }) {
    final meal = MealEntry(
      name:     name,
      calories: calories.round(),
      protein:  protein.round(),
      carbs:    carbs.round(),
      fat:      fat.round(),
      mealType: mealType,
    );
    addMeal(meal);
    print('[CalorieCubit] Added meal: $name (${calories.round()} kcal)');
  }

  void updateBudget(int budget) {
    emit(state.copyWith(caloriesBudget: budget));
  }

  void reset() {
    emit(const CalorieState());
  }
}