import 'package:equatable/equatable.dart';

class MealEntry extends Equatable {
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String mealType;

  const MealEntry({
    required this.name,
    required this.calories,
    required this.mealType,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  @override
  List<Object> get props => [
        name,
        calories,
        mealType,
        protein,
        carbs,
        fat,
      ];
}

class CalorieState extends Equatable {
  final int caloriesBudget;
  final List<MealEntry> meals;

  const CalorieState({
    this.caloriesBudget = 3245,
    this.meals = const [],
  });

  // =====================================================
  // DYNAMIC MACROS
  // =====================================================

  /// 30% Protein
  int get proteinGoal =>
      ((caloriesBudget * 0.30) / 4).round();

  /// 40% Carbs
  int get carbsGoal =>
      ((caloriesBudget * 0.40) / 4).round();

  /// 30% Fat
  int get fatGoal =>
      ((caloriesBudget * 0.30) / 9).round();

  // =====================================================
  // CONSUMED TOTALS
  // =====================================================

  int get totalCaloriesConsumed =>
      meals.fold(0, (s, m) => s + m.calories);

  int get totalProtein =>
      meals.fold(0, (s, m) => s + m.protein);

  int get totalCarbs =>
      meals.fold(0, (s, m) => s + m.carbs);

  int get totalFat =>
      meals.fold(0, (s, m) => s + m.fat);

  // =====================================================
  // REMAINING
  // =====================================================

  int get caloriesRemaining =>
      caloriesBudget - totalCaloriesConsumed;

  // =====================================================
  // MEALS FILTER
  // =====================================================

  List<MealEntry> mealsFor(String type) =>
      meals.where((m) => m.mealType == type).toList();

  // =====================================================
  // COPY
  // =====================================================

  CalorieState copyWith({
    int? caloriesBudget,
    List<MealEntry>? meals,
  }) {
    return CalorieState(
      caloriesBudget:
          caloriesBudget ?? this.caloriesBudget,
      meals: meals ?? this.meals,
    );
  }

  @override
  List<Object> get props => [
        caloriesBudget,
        meals,
      ];
}