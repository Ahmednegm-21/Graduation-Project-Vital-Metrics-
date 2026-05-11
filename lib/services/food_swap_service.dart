import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/data/repositories/meal_repository.dart';
import 'package:vital_metrics/data/models/meal_model.dart';

FoodItem _mealToFoodItem(MealModel meal) => FoodItem(
      id:       meal.id.toString(),
      name:     meal.name,
      emoji:    '🍽️',
      category: 'meals',
      calories: meal.calories,
      protein:  meal.protein,
      carbs:    meal.carbs,
      fats:     meal.fat,
      tags:     [],
    );

class FoodSwapService {
  static final FoodSwapService _instance = FoodSwapService._();
  factory FoodSwapService() => _instance;
  FoodSwapService._();

  final MealRepository _mealRepo = MealRepository();

  Future<List<FoodItem>> searchFromBackend(String query) async {
    try {
      final meals = await _mealRepo.getMeals(search: query, limit: 20);
      if (meals.isNotEmpty) return meals.map(_mealToFoodItem).toList();
      return search(query);
    } catch (_) {
      return search(query);
    }
  }

  Future<FoodSwapResult> getSwapsFromBackend(
    FoodItem original,
    String userGoal,
  ) async {
    try {
      final mealId = int.tryParse(original.id);
      if (mealId == null) return getSwaps(original, userGoal);

      final suggestions = await _mealRepo.getSwapSuggestions(mealId);
      if (suggestions.isEmpty) return getSwaps(original, userGoal);

      final alts = suggestions.map((meal) {
        final food    = _mealToFoodItem(meal);
        final benefit = _determineBenefit(original, food, userGoal);
        final reason  = _buildReason(original, food);
        return SwapAlternative(
          food:       food,
          matchScore: original.matchScore(food),
          swapReason: reason,
          benefit:    benefit,
        );
      }).toList();

      return FoodSwapResult(original: original, alternatives: alts);
    } catch (_) {
      return getSwaps(original, userGoal);
    }
  }

  Future<List<FoodItem>> getMealsFromBackend({
    int page  = 1,
    int limit = 20,
  }) async {
    try {
      final meals = await _mealRepo.getMeals(page: page, limit: limit);
      return meals.map(_mealToFoodItem).toList();
    } catch (_) {
      return [];
    }
  }

  List<FoodItem> search(String query, {String? category}) {
    if (query.trim().isEmpty) return [];
    final q    = query.toLowerCase();
    final pool = category != null
        ? _database.where((f) => f.category == category)
        : _database.cast<FoodItem>();
    return pool
        .where((f) =>
            f.name.toLowerCase().contains(q) ||
            f.category.toLowerCase().contains(q) ||
            f.tags.any((t) => t.contains(q)))
        .toList();
  }

  FoodSwapResult getSwaps(FoodItem original, String userGoal) {
    final candidates = _database.where((f) => f.id != original.id).toList();

    final alts = candidates.map((f) {
      final score   = original.matchScore(f);
      final benefit = _determineBenefit(original, f, userGoal);
      final reason  = _buildReason(original, f);
      return SwapAlternative(
        food:       f,
        matchScore: score,
        swapReason: reason,
        benefit:    benefit,
      );
    }).toList();

    alts.sort((a, b) {
      final aGoal = _goalScore(a, userGoal);
      final bGoal = _goalScore(b, userGoal);
      if (aGoal != bGoal) return bGoal.compareTo(aGoal);
      return b.matchScore.compareTo(a.matchScore);
    });

    return FoodSwapResult(
      original:     original,
      alternatives: alts.take(4).toList(),
    );
  }

  double _goalScore(SwapAlternative alt, String goal) {
    switch (goal.toLowerCase()) {
      case 'lose weight':  return alt.food.calories < 150 ? 2.0 : 0.0;
      case 'build muscle': return alt.food.protein > 20 ? 2.0 : 0.0;
      case 'maintain':     return alt.benefit == SwapBenefit.balanced ? 2.0 : 0.5;
      default:             return 0.0;
    }
  }

  SwapBenefit _determineBenefit(FoodItem orig, FoodItem alt, String goal) {
    if (alt.protein > orig.protein * 1.2)   return SwapBenefit.higherProtein;
    if (alt.calories < orig.calories * 0.8) return SwapBenefit.lowerCalories;
    if (alt.carbs < orig.carbs * 0.8)       return SwapBenefit.lowerCarbs;
    if (alt.fats < orig.fats * 0.8)         return SwapBenefit.lowerFats;
    return SwapBenefit.balanced;
  }

  String _buildReason(FoodItem orig, FoodItem alt) {
    final parts = <String>[];
    if (alt.protein > orig.protein + 3)
      parts.add('+${(alt.protein - orig.protein).round()}g protein');
    if (alt.calories < orig.calories - 20)
      parts.add('-${(orig.calories - alt.calories).round()} kcal');
    if (alt.carbs < orig.carbs - 5)
      parts.add('-${(orig.carbs - alt.carbs).round()}g carbs');
    if (parts.isEmpty) return 'Similar nutrition profile';
    return parts.join(' · ');
  }

  List<FoodItem> get allFoods => List.unmodifiable(_database);

  List<FoodItem> byCategory(String category) =>
      _database.where((f) => f.category == category).toList();

  FoodItem? findById(String id) {
    try { return _database.firstWhere((f) => f.id == id); }
    catch (_) { return null; }
  }

  static const List<FoodItem> _database = [
    FoodItem(id: 'chicken_breast', name: 'Chicken Breast', emoji: '🍗',
        category: 'protein', calories: 165, protein: 31, carbs: 0, fats: 3.6,
        tags: ['high-protein', 'low-fat']),
    FoodItem(id: 'tuna', name: 'Tuna', emoji: '🐟',
        category: 'protein', calories: 132, protein: 28, carbs: 0, fats: 1.3,
        tags: ['high-protein', 'low-fat']),
    FoodItem(id: 'eggs', name: 'Eggs', emoji: '🥚',
        category: 'protein', calories: 155, protein: 13, carbs: 1.1, fats: 11,
        tags: ['complete-protein']),
    FoodItem(id: 'beef', name: 'Beef', emoji: '🥩',
        category: 'protein', calories: 250, protein: 26, carbs: 0, fats: 16,
        tags: ['high-protein']),
    FoodItem(id: 'salmon', name: 'Salmon', emoji: '🐠',
        category: 'protein', calories: 208, protein: 20, carbs: 0, fats: 13,
        tags: ['high-protein']),
    FoodItem(id: 'tofu', name: 'Tofu', emoji: '🫘',
        category: 'protein', calories: 76, protein: 8, carbs: 2, fats: 4.8,
        tags: ['vegan', 'plant-protein']),
    FoodItem(id: 'lentils', name: 'Lentils', emoji: '🌱',
        category: 'protein', calories: 116, protein: 9, carbs: 20, fats: 0.4,
        tags: ['vegan', 'plant-protein']),
    FoodItem(id: 'greek_yogurt', name: 'Greek Yogurt', emoji: '🥛',
        category: 'dairy', calories: 59, protein: 10, carbs: 3.6, fats: 0.4,
        tags: ['high-protein', 'probiotic']),
    FoodItem(id: 'white_rice', name: 'White Rice', emoji: '🍚',
        category: 'carbs', calories: 130, protein: 2.7, carbs: 28, fats: 0.3,
        tags: ['quick-energy']),
    FoodItem(id: 'brown_rice', name: 'Brown Rice', emoji: '🌾',
        category: 'carbs', calories: 123, protein: 2.7, carbs: 26, fats: 1,
        tags: ['whole-grain']),
    FoodItem(id: 'quinoa', name: 'Quinoa', emoji: '🌿',
        category: 'carbs', calories: 120, protein: 4.4, carbs: 22, fats: 1.9,
        tags: ['complete-protein', 'whole-grain']),
    FoodItem(id: 'oats', name: 'Oats', emoji: '🥣',
        category: 'carbs', calories: 389, protein: 17, carbs: 66, fats: 7,
        tags: ['whole-grain']),
    FoodItem(id: 'sweet_potato', name: 'Sweet Potato', emoji: '🍠',
        category: 'carbs', calories: 86, protein: 1.6, carbs: 20, fats: 0.1,
        tags: ['vitamin-a']),
    FoodItem(id: 'broccoli', name: 'Broccoli', emoji: '🥦',
        category: 'vegetables', calories: 34, protein: 2.8, carbs: 7, fats: 0.4,
        tags: ['low-calorie', 'vitamin-c']),
    FoodItem(id: 'spinach', name: 'Spinach', emoji: '🥬',
        category: 'vegetables', calories: 23, protein: 2.9, carbs: 3.6, fats: 0.4,
        tags: ['low-calorie', 'vegan']),
    FoodItem(id: 'avocado', name: 'Avocado', emoji: '🥑',
        category: 'fats', calories: 160, protein: 2, carbs: 9, fats: 15,
        tags: ['healthy-fats']),
    FoodItem(id: 'banana', name: 'Banana', emoji: '🍌',
        category: 'fruits', calories: 89, protein: 1.1, carbs: 23, fats: 0.3,
        tags: ['quick-energy']),
    FoodItem(id: 'apple', name: 'Apple', emoji: '🍎',
        category: 'fruits', calories: 52, protein: 0.3, carbs: 14, fats: 0.2,
        tags: ['low-calorie']),
    FoodItem(id: 'almonds', name: 'Almonds', emoji: '🥜',
        category: 'fats', calories: 579, protein: 21, carbs: 22, fats: 50,
        tags: ['healthy-fats']),
  ];
}