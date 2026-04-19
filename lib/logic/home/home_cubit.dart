import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  // Add meal calories + macros
  void addMealCalories(
    int calories, {
    double protein = 0,
    double carbs = 0,
    double fat = 0,
  }) {
    state.nutritionData.calories += calories;
    state.nutritionData.protein += protein;
    state.nutritionData.carbs += carbs;
    state.nutritionData.fat += fat;
    emit(state.copyWith(nutritionData: state.nutritionData));
  }

  void addWaterCup() {
    state.nutritionData.addWaterCup();
    emit(state.copyWith(nutritionData: state.nutritionData));
  }

  void updateProtein(double value) {
    state.nutritionData.protein += value;
    emit(state.copyWith(nutritionData: state.nutritionData));
  }

  void updateCarbs(double value) {
    state.nutritionData.carbs += value;
    emit(state.copyWith(nutritionData: state.nutritionData));
  }

  void updateFat(double value) {
    state.nutritionData.fat += value;
    emit(state.copyWith(nutritionData: state.nutritionData));
  }
}
