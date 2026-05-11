import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/data/models/meal_model.dart';
import 'package:vital_metrics/data/repositories/consumed_meal_repository.dart';
import 'package:vital_metrics/data/repositories/meal_repository.dart';

part 'recipes_state.dart';

class RecipesCubit extends Cubit<RecipesState> {
  final MealRepository         _mealRepo;
  final ConsumedMealRepository _consumedRepo;

  RecipesCubit({
    MealRepository?         mealRepo,
    ConsumedMealRepository? consumedRepo,
  })  : _mealRepo     = mealRepo     ?? MealRepository(),
        _consumedRepo = consumedRepo ?? ConsumedMealRepository(),
        super(const RecipesInitial()) {
    load();
  }

  static final List<MealModel> _localFallback = [
    const MealModel(id: -1,  name: 'Organic Old Fashioned Oats',  calories: 160, protein: 5,  carbs: 28, fat: 3),
    const MealModel(id: -2,  name: 'Spicy Lentil Wrap w/ Sauce',  calories: 580, protein: 22, carbs: 75, fat: 18),
    const MealModel(id: -3,  name: 'TJ 4 Cheese Mini Ravioli',    calories: 250, protein: 10, carbs: 35, fat: 8),
    const MealModel(id: -4,  name: 'Chiles Rellenos Con Queso',   calories: 350, protein: 14, carbs: 20, fat: 22),
    const MealModel(id: -5,  name: 'Organic Midnight Moo',        calories: 110, protein: 3,  carbs: 18, fat: 3),
    const MealModel(id: -6,  name: 'Chicken Tikka Masala',        calories: 350, protein: 28, carbs: 22, fat: 14),
    const MealModel(id: -7,  name: 'Greek Yogurt with Honey',     calories: 180, protein: 12, carbs: 24, fat: 3),
    const MealModel(id: -8,  name: 'Avocado Toast',               calories: 290, protein: 8,  carbs: 30, fat: 16),
    const MealModel(id: -9,  name: 'Caesar Salad',                calories: 220, protein: 9,  carbs: 14, fat: 15),
    const MealModel(id: -10, name: 'Grilled Salmon',              calories: 410, protein: 46, carbs: 0,  fat: 24),
    const MealModel(id: -11, name: 'Mixed Nuts',                  calories: 180, protein: 5,  carbs: 8,  fat: 15),
    const MealModel(id: -12, name: 'Banana Smoothie',             calories: 240, protein: 6,  carbs: 45, fat: 4),
    const MealModel(id: -13, name: 'Scrambled Eggs',              calories: 200, protein: 14, carbs: 2,  fat: 15),
    const MealModel(id: -14, name: 'Brown Rice Bowl',             calories: 320, protein: 6,  carbs: 68, fat: 2),
    const MealModel(id: -15, name: 'Protein Bar',                 calories: 210, protein: 20, carbs: 22, fat: 7),
  ];

  Future<void> load({String query = ''}) async {
    emit(const RecipesLoading());
    try {
      final meals = await _mealRepo.getMeals(
        page:   1,
        limit:  50,
        search: query.trim().isEmpty ? null : query.trim(),
      );
      if (meals.isNotEmpty) {
        emit(RecipesLoaded(meals: meals, query: query, isLocalData: false));
      } else {
        print('[RecipesCubit] Backend empty — using local fallback');
        emit(RecipesLoaded(meals: _localFallback, query: query, isLocalData: true));
      }
    } catch (e) {
      print('[RecipesCubit] Error ($e) — using local fallback');
      emit(RecipesLoaded(meals: _localFallback, query: query, isLocalData: true));
    }
  }

  void search(String query) {
    final s = state;
    if (s is RecipesLoaded) emit(s.copyWith(query: query));
  }

  void setCategory(String cat) {
    final s = state;
    if (s is RecipesLoaded) emit(s.copyWith(categoryFilter: cat));
  }

  void toggleMeal(int mealId) {
    final s = state;
    if (s is! RecipesLoaded) return;
    final updated = Set<int>.from(s.selectedIds);
    updated.contains(mealId) ? updated.remove(mealId) : updated.add(mealId);
    emit(s.copyWith(selectedIds: updated));
  }

  // Returns list of (name, calories) for each added meal.
  // - Real backend meals (id > 0): POST to /consumed-meals
  // - Local fallback meals (id < 0): skip backend, return name+calories only
  //   so the caller (UI) can add them to CalorieCubit locally
  Future<List<(String, double)>> addSelected() async {
    final s = state;
    if (s is! RecipesLoaded || s.selectedIds.isEmpty) return [];

    emit(s.copyWith(isAdding: true));

    final results = <(String, double)>[];
    for (final mealId in s.selectedIds) {
      try {
        final meal = s.meals.firstWhere((m) => m.id == mealId);

        if (mealId > 0) {
          // Real backend meal — POST to consumed-meals
          await _consumedRepo.addMeal(mealId: mealId);
          print('[RecipesCubit] Added real meal ${meal.name} to backend');
        } else {
          // Local fallback meal — no backend call, just track locally
          print('[RecipesCubit] Added local meal ${meal.name} (id=$mealId) — skipping backend');
        }

        // Always return the meal so CalorieCubit can update calories
        results.add((meal.name, meal.calories));
      } catch (e) {
        print('[RecipesCubit] Failed to add meal $mealId: $e');
      }
    }

    emit(s.copyWith(selectedIds: {}, isAdding: false));
    return results;
  }

  void clearSelection() {
    final s = state;
    if (s is RecipesLoaded) emit(s.copyWith(selectedIds: {}));
  }

  void refresh() => load();
}