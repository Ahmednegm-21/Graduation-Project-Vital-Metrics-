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

  void updateBudget(int budget) {
    emit(state.copyWith(caloriesBudget: budget));
  }
}