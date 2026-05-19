import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calorie_state.dart';

export 'calorie_state.dart';

class CalorieCubit extends Cubit<CalorieState> {
  static const _mealsKey = 'cached_meals';

  static const _budgetKey = 'cached_budget';

  CalorieCubit() : super(const CalorieState()) {
    _loadCache();
  }

  // =====================================================
  // LOAD CACHE
  // =====================================================

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // تحقق من التاريخ
      final savedDate = prefs.getString('cached_date') ?? '';
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month}-${today.day}';

      if (savedDate != todayStr) {
        // يوم جديد - امسح الكالوريز
        await prefs.setStringList(_mealsKey, []);
        await prefs.setString('cached_date', todayStr);
        final budget = prefs.getInt(_budgetKey) ?? 2000;
        emit(state.copyWith(meals: [], caloriesBudget: budget));
        return;
      }

      // نفس اليوم - حمّل العادي
      final budget = prefs.getInt(_budgetKey) ?? 2000;
      final mealsJson = prefs.getStringList(_mealsKey) ?? [];
      final meals = mealsJson.map((mealString) {
        final mealJson = jsonDecode(mealString) as Map<String, dynamic>;
        return MealEntry(
          name: mealJson['name'] as String,
          calories: mealJson['calories'] as int,
          protein: mealJson['protein'] as int,
          carbs: mealJson['carbs'] as int,
          fat: mealJson['fat'] as int,
          mealType: mealJson['mealType'] as String,
        );
      }).toList();

      emit(state.copyWith(meals: meals, caloriesBudget: budget));
    } catch (e) {
      print('[CalorieCubit] load cache error => $e');
    }
  }

  // =====================================================
  // SAVE CACHE
  // =====================================================

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final meals = state.meals.map((meal) {
        return jsonEncode({
          'name': meal.name,
          'calories': meal.calories,
          'protein': meal.protein,
          'carbs': meal.carbs,
          'fat': meal.fat,
          'mealType': meal.mealType,
        });
      }).toList();

      await prefs.setString(
        'cached_date',
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
      );

      await prefs.setInt(_budgetKey, state.caloriesBudget);
    } catch (e) {
      print('[CalorieCubit] save cache error => $e');
    }
  }

  // =====================================================
  // CALCULATE DYNAMIC CALORIES
  // =====================================================

  void calculateAndSetBudget({
    required double weight,
    required double height,
    required double age,
    required String gender,
    required String goal,
    required String activityLevel,
  }) {
    double bmr;

    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    double multiplier = 1.2;

    switch (activityLevel.toLowerCase()) {
      case 'low':
        multiplier = 1.2;
        break;

      case 'medium':
        multiplier = 1.55;
        break;

      case 'high':
        multiplier = 1.75;
        break;
    }

    double targetCalories = bmr * multiplier;

    switch (goal.toLowerCase()) {
      case 'lose_weight':
        targetCalories -= 500;
        break;

      case 'gain_weight':
        targetCalories += 300;
        break;
    }

    if (targetCalories < 1200) {
      targetCalories = 1200;
    }

    updateBudget(targetCalories.round());
  }

  // =====================================================
  // ADD MEAL
  // =====================================================

  void addMeal(MealEntry meal) {
    final updatedMeals = List<MealEntry>.from(state.meals)..add(meal);

    emit(state.copyWith(meals: updatedMeals));

    _saveCache();

    print('[CalorieCubit] Meal Added => ${meal.name}');
  }

  // =====================================================
  // QUICK ADD
  // =====================================================

  void addMealByName({
    required String name,
    required double calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    String mealType = 'lunch',
  }) {
    final meal = MealEntry(
      name: name,
      calories: calories.round(),
      protein: protein.round(),
      carbs: carbs.round(),
      fat: fat.round(),
      mealType: mealType,
    );

    addMeal(meal);
  }

  // =====================================================
  // REMOVE MEAL
  // =====================================================

  void removeMeal(MealEntry meal) {
    final updatedMeals = List<MealEntry>.from(state.meals)..remove(meal);

    emit(state.copyWith(meals: updatedMeals));

    _saveCache();
  }

  // =====================================================
  // RESET SPECIFIC MEAL TYPE
  // =====================================================

  void resetMeal(String mealType) {
    final updatedMeals = state.meals.where((meal) {
      return meal.mealType != mealType;
    }).toList();

    emit(state.copyWith(meals: updatedMeals));

    _saveCache();

    print('[CalorieCubit] Reset Meal => $mealType');
  }

  // =====================================================
  // UPDATE BUDGET
  // =====================================================

  void updateBudget(int budget) {
    emit(state.copyWith(caloriesBudget: budget));

    _saveCache();
  }

  // =====================================================
  // RESET ALL
  // =====================================================

  Future<void> reset() async {
    emit(const CalorieState());

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_mealsKey);

    await prefs.remove(_budgetKey);
  }
}
