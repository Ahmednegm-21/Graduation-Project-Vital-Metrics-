import 'package:equatable/equatable.dart';

class MealEntry extends Equatable {
  final String name;
  final int calories;
  final int protein; // grams
  final int carbs;   // grams
  final int fat;     // grams
  final String mealType; // breakfast, lunch, dinner, snacks

  const MealEntry({
    required this.name,
    required this.calories,
    required this.mealType,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  @override
  List<Object> get props => [name, calories, mealType, protein, carbs, fat];
}

class CalorieState extends Equatable {
  final int caloriesBudget;
  final List<MealEntry> meals;

  const CalorieState({
    this.caloriesBudget = 3245,
    this.meals = const [],
  });

  // ── Goals ──────────────────────────────────────────────────────────────────
  int get proteinGoal => 245;
  int get carbsGoal   => 345;
  int get fatGoal     => 145;

  // ── Consumed totals (محسوبة من الوجبات الفعلية) ────────────────────────────
  int get totalCaloriesConsumed => meals.fold(0, (s, m) => s + m.calories);
  int get totalProtein          => meals.fold(0, (s, m) => s + m.protein);
  int get totalCarbs            => meals.fold(0, (s, m) => s + m.carbs);
  int get totalFat              => meals.fold(0, (s, m) => s + m.fat);

  int get caloriesRemaining => caloriesBudget - totalCaloriesConsumed;

  List<MealEntry> mealsFor(String type) =>
      meals.where((m) => m.mealType == type).toList();

  CalorieState copyWith({
    int? caloriesBudget,
    List<MealEntry>? meals,
  }) {
    return CalorieState(
      caloriesBudget: caloriesBudget ?? this.caloriesBudget,
      meals: meals ?? this.meals,
    );
  }

  @override
  List<Object> get props => [caloriesBudget, meals];
}