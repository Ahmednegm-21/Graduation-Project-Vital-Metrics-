import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/data/repositories/meal_repository.dart';
import 'package:vital_metrics/data/models/meal_model.dart';
import 'package:vital_metrics/data/utils/food_categorizer.dart';

FoodItem _mealToFoodItem(MealModel meal) => FoodItem(
      id:       meal.id.toString(),
      name:     meal.name,
      emoji:    guessFoodEmoji(meal.name),
      category: guessFoodCategory(meal.name),
      calories: meal.calories,
      protein:  meal.protein,
      carbs:    meal.carbs,
      fats:     meal.fat,
      tags:     [],
    );

class FoodSwapService {
  static final FoodSwapService _instance = FoodSwapService._();
  factory FoodSwapService() => _instance;

  FoodSwapService._() {
    _loadCatalog();
  }

  final MealRepository _mealRepo = MealRepository();

  List<FoodItem> _catalog = [];
  bool _loaded  = false;
  bool _loading = false;

  Future<void> _loadCatalog() async {
    if (_loading) return;
    _loading = true;
    try {
      const pageSize = 100;
      final List<MealModel> allMeals = [];
      int page = 1;

      while (true) {
        final batch = await _mealRepo.getMeals(page: page, limit: pageSize);
        if (batch.isEmpty) break;
        allMeals.addAll(batch);
        if (batch.length < pageSize) break;
        page++;
      }

      if (allMeals.isNotEmpty) {
        _catalog = allMeals.map(_mealToFoodItem).toList();
      }
      _loaded = true;
    } catch (_) {
      // keep _catalog as-is
    } finally {
      _loading = false;
    }
  }

  Future<void> ensureLoaded() async {
    if (_loaded && _catalog.isNotEmpty) return;
    await _loadCatalog();
  }

  Future<void> refreshCatalog() => _loadCatalog();

  // ── Category filter logic (shared between service & cubit) ───────────────

  /// فلتر الـ category بالـ nutrition values مش بالـ category string
  bool matchesCategoryId(FoodItem f, String categoryId) {
    switch (categoryId) {
      case 'high_protein': return f.protein  >= 15;
      case 'low_protein':  return f.protein  <= 5;
      case 'high_calorie': return f.calories >= 400;
      case 'low_calorie':  return f.calories <= 200;
      case 'high_carb':    return f.carbs    >= 40;
      case 'low_carb':     return f.carbs    <= 10;
      case 'high_fat':     return f.fats     >= 15;
      case 'low_fat':      return f.fats     <= 5;
      default:             return true;
    }
  }

  // ── Backend search ────────────────────────────────────────────────────────

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
      const pageSize = 100;
      final List<MealModel> allMeals = [];
      int currentPage = 1;

      while (true) {
        final batch = await _mealRepo.getMeals(
          page:  currentPage,
          limit: pageSize,
        );
        if (batch.isEmpty) break;
        allMeals.addAll(batch);
        if (batch.length < pageSize) break;
        currentPage++;
      }

      return allMeals.map(_mealToFoodItem).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Local search ──────────────────────────────────────────────────────────

  /// ✅ بيشتغل مع category حتى لو query فاضي
  List<FoodItem> search(String query, {String? categoryId}) {
    final q = query.trim().toLowerCase();

    // لو فيه category filter → طبّقه على الـ catalog
    Iterable<FoodItem> pool = _catalog;
    if (categoryId != null) {
      pool = pool.where((f) => matchesCategoryId(f, categoryId));
    }

    // لو query فاضي → رجّع كل الـ pool (filtered by category فقط)
    if (q.isEmpty) return pool.toList();

    // لو فيه query → فلتر بالاسم كمان
    return pool
        .where((f) =>
            f.name.toLowerCase().contains(q) ||
            f.category.toLowerCase().contains(q) ||
            f.tags.any((t) => t.contains(q)))
        .toList();
  }

  // ── Swaps ─────────────────────────────────────────────────────────────────

  FoodSwapResult getSwaps(FoodItem original, String userGoal) {
    final candidates = _catalog.where((f) => f.id != original.id).toList();

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

  List<FoodItem> get allFoods => List.unmodifiable(_catalog);

  List<FoodItem> byCategory(String category) =>
      _catalog.where((f) => f.category == category).toList();

  FoodItem? findById(String id) {
    try { return _catalog.firstWhere((f) => f.id == id); }
    catch (_) { return null; }
  }
}