import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/data/repositories/meal_repository.dart';
import 'package:vital_metrics/data/models/meal_model.dart';
import 'package:vital_metrics/data/utils/meal_to_food_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Normalize Arabic/English text for fuzzy matching
// ─────────────────────────────────────────────────────────────────────────────
String _normalize(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
    .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
    .replaceAll(RegExp(r'ة'), 'ه')
    .replaceAll(RegExp(r'ى'), 'ي')
    .replaceAll(RegExp(r'[،,.\-_]'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

bool _fuzzyMatch(String normalizedName, String normalizedQuery) {
  if (normalizedName.contains(normalizedQuery)) return true;
  final words = normalizedQuery
      .split(' ')
      .where((w) => w.length >= 2)
      .toList();
  if (words.isEmpty) return false;
  return words.every((w) => normalizedName.contains(w));
}

// ─────────────────────────────────────────────────────────────────────────────
// Improvement score
// ─────────────────────────────────────────────────────────────────────────────
double calcImprovementScore(FoodItem orig, FoodItem alt,
    {String goal = 'maintain'}) {
  final calImprove  = (orig.calories - alt.calories) / (orig.calories + 1);
  final protImprove = (alt.protein   - orig.protein) / (orig.protein  + 1);
  final carbImprove = (orig.carbs    - alt.carbs)    / (orig.carbs    + 1);
  final fatImprove  = (orig.fats     - alt.fats)     / (orig.fats     + 1);

  double weighted;
  switch (goal.toLowerCase()) {
    case 'lose weight':
      weighted = (calImprove  * 0.5) +
                 (protImprove * 0.2) +
                 (carbImprove * 0.2) +
                 (fatImprove  * 0.1);
      break;
    case 'build muscle':
      final calGain  = (alt.calories - orig.calories) / (orig.calories + 1);
      final carbGain = (alt.carbs    - orig.carbs)    / (orig.carbs    + 1);
      weighted = (protImprove * 0.6) +
                 (calGain     * 0.2) +
                 (carbGain    * 0.2);
      break;
    default:
      weighted = (calImprove  * 0.3) +
                 (protImprove * 0.3) +
                 (carbImprove * 0.2) +
                 (fatImprove  * 0.2);
  }

  return ((weighted + 1) / 2 * 100).clamp(0.0, 100.0);
}

// ─────────────────────────────────────────────────────────────────────────────
// FoodSwapService
// ─────────────────────────────────────────────────────────────────────────────
class FoodSwapService {
  static final FoodSwapService _instance = FoodSwapService._();
  factory FoodSwapService() => _instance;

  FoodSwapService._() {
    _loadCatalog();
  }

  final MealRepository _mealRepo = MealRepository();

  List<FoodItem> _catalog  = [];
  bool           _loaded   = false;
  bool           _loading  = false;

  // normalized name cache — عربي + إنجليزي مع بعض
  final Map<String, String> _normalizedNames    = {};
  final Map<String, String> _normalizedNamesEn  = {};

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

      // FIX: the old code only replaced _catalog when allMeals was
      // non-empty, so a successful fetch that legitimately returns an
      // empty or changed list (e.g. right after an admin wipes and
      // re-imports meals) left the OLD catalog sitting in memory forever.
      // The fetch itself succeeded here (no exception was thrown), so we
      // always trust its result and replace the catalog — including the
      // empty-list case.
      _catalog = allMeals.map((m) => mealToFoodItem(m)).toList();

      _normalizedNames.clear();
      _normalizedNamesEn.clear();
      for (int i = 0; i < allMeals.length; i++) {
        final id = allMeals[i].id.toString();
        _normalizedNames[id]   = _normalize(allMeals[i].name);
        _normalizedNamesEn[id] = _normalize(allMeals[i].nameEn);
      }

      _loaded = true;
    } catch (_) {
      // Network/server error — keep _catalog as-is so the app stays usable.
    } finally {
      _loading = false;
    }
  }

  Future<void> ensureLoaded() async {
    if (_loaded && _catalog.isNotEmpty) return;
    await _loadCatalog();
  }

  // Forces a fresh fetch from the backend, replacing the in-memory catalog.
  // Safe to call even while a load is already in-flight — _loadCatalog()
  // guards on `_loading` and simply no-ops if one is already running,
  // so this never fires two parallel requests.
  Future<void> refreshCatalog() => _loadCatalog();

  // ── Category filter ────────────────────────────────────────────────────────
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

  // ── Backend search ─────────────────────────────────────────────────────────
  Future<List<FoodItem>> searchFromBackend(String query) async {
    try {
      final meals = await _mealRepo.getMeals(search: query, limit: 20);
      if (meals.isNotEmpty) return meals.map((m) => mealToFoodItem(m)).toList();
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
        final food    = mealToFoodItem(meal);
        final benefit = _determineBenefit(original, food, userGoal);
        final reason  = _buildReason(original, food, userGoal);
        return SwapAlternative(
          food:       food,
          matchScore: calcImprovementScore(original, food, goal: userGoal),
          swapReason: reason,
          benefit:    benefit,
        );
      }).toList();

      alts.sort((a, b) =>
          calcImprovementScore(original, b.food, goal: userGoal)
              .compareTo(calcImprovementScore(original, a.food, goal: userGoal)));

      return FoodSwapResult(original: original, alternatives: alts);
    } catch (_) {
      return getSwaps(original, userGoal);
    }
  }

  Future<List<FoodItem>> getMealsFromBackend() async {
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

      return allMeals.map((m) => mealToFoodItem(m)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Local search — fuzzy Arabic + English ─────────────────────────────────
  List<FoodItem> search(String query, {String? categoryId}) {
    final raw = query.trim();
    if (raw.isEmpty) return categoryId != null
        ? _catalog.where((f) => matchesCategoryId(f, categoryId)).toList()
        : [];

    final q = _normalize(raw);

    Iterable<FoodItem> pool = _catalog;
    if (categoryId != null) {
      pool = pool.where((f) => matchesCategoryId(f, categoryId));
    }

    return pool.where((f) {
      final arName = _normalizedNames[f.id]   ?? _normalize(f.name);
      final enName = _normalizedNamesEn[f.id] ?? '';
      if (_fuzzyMatch(arName, q)) return true;
      if (enName.isNotEmpty && _fuzzyMatch(enName, q)) return true;
      if (f.category.toLowerCase().contains(raw.toLowerCase())) return true;
      if (f.tags.any((t) => _normalize(t).contains(q))) return true;
      return false;
    }).toList();
  }

  // ── Swaps ──────────────────────────────────────────────────────────────────
  FoodSwapResult getSwaps(FoodItem original, String userGoal) {
    final candidates = _catalog.where((f) => f.id != original.id).toList();

    final alts = candidates.map((f) {
      final benefit = _determineBenefit(original, f, userGoal);
      final reason  = _buildReason(original, f, userGoal);
      return SwapAlternative(
        food:       f,
        matchScore: calcImprovementScore(original, f, goal: userGoal),
        swapReason: reason,
        benefit:    benefit,
      );
    }).toList();

    alts.sort((a, b) =>
        calcImprovementScore(original, b.food, goal: userGoal)
            .compareTo(calcImprovementScore(original, a.food, goal: userGoal)));

    return FoodSwapResult(
      original:     original,
      alternatives: alts.take(10).toList(),
    );
  }

  SwapBenefit _determineBenefit(FoodItem orig, FoodItem alt, String goal) {
    switch (goal.toLowerCase()) {
      case 'build muscle':
        if (alt.protein  > orig.protein  * 1.2) return SwapBenefit.higherProtein;
        if (alt.calories > orig.calories * 1.1) return SwapBenefit.higherCalories;
        if (alt.carbs    > orig.carbs    * 1.2) return SwapBenefit.higherCarbs;
        break;
      case 'lose weight':
        if (alt.calories < orig.calories * 0.8) return SwapBenefit.lowerCalories;
        if (alt.fats     < orig.fats     * 0.8) return SwapBenefit.lowerFats;
        if (alt.carbs    < orig.carbs    * 0.8) return SwapBenefit.lowerCarbs;
        break;
      default:
        if (alt.protein  > orig.protein  * 1.2) return SwapBenefit.higherProtein;
        if (alt.calories < orig.calories * 0.8) return SwapBenefit.lowerCalories;
        if (alt.carbs    < orig.carbs    * 0.8) return SwapBenefit.lowerCarbs;
        if (alt.fats     < orig.fats     * 0.8) return SwapBenefit.lowerFats;
    }
    return SwapBenefit.balanced;
  }

  String _buildReason(FoodItem orig, FoodItem alt, String goal) {
    final parts = <String>[];

    switch (goal.toLowerCase()) {
      case 'build muscle':
        if (alt.protein  > orig.protein  + 3)  parts.add('+${(alt.protein  - orig.protein ).round()}g protein');
        if (alt.calories > orig.calories + 20)  parts.add('+${(alt.calories - orig.calories).round()} kcal');
        if (alt.carbs    > orig.carbs    + 5)   parts.add('+${(alt.carbs    - orig.carbs   ).round()}g carbs');
        break;
      default:
        if (alt.protein  > orig.protein  + 3)  parts.add('+${(alt.protein  - orig.protein ).round()}g protein');
        if (alt.calories < orig.calories - 20)  parts.add('-${(orig.calories - alt.calories).round()} kcal');
        if (alt.carbs    < orig.carbs    - 5)   parts.add('-${(orig.carbs    - alt.carbs   ).round()}g carbs');
        if (alt.fats     < orig.fats     - 3)   parts.add('-${(orig.fats     - alt.fats    ).round()}g fat');
    }

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