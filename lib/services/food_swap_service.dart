import 'package:vital_metrics/data/models/food_item.dart';

// In-memory food database — expand later with API or local DB
class FoodSwapService {
  static final FoodSwapService _instance = FoodSwapService._();
  factory FoodSwapService() => _instance;
  FoodSwapService._();

  //  food database
  static const List<FoodItem> _database = [
    // ── Proteins ──────────────────────────────────────────────────────────────
    FoodItem(id: 'chicken_breast', name: 'Chicken Breast', emoji: '🍗',
        category: 'protein', calories: 165, protein: 31, carbs: 0, fats: 3.6, fiber: 0,
        tags: ['high-protein', 'low-fat']),
    FoodItem(id: 'tuna', name: 'Tuna', emoji: '🐟',
        category: 'protein', calories: 132, protein: 28, carbs: 0, fats: 1.3, fiber: 0,
        tags: ['high-protein', 'low-fat', 'omega3']),
    FoodItem(id: 'eggs', name: 'Eggs', emoji: '🥚',
        category: 'protein', calories: 155, protein: 13, carbs: 1.1, fats: 11, fiber: 0,
        tags: ['complete-protein']),
    FoodItem(id: 'beef', name: 'Beef', emoji: '🥩',
        category: 'protein', calories: 250, protein: 26, carbs: 0, fats: 16, fiber: 0,
        tags: ['high-protein', 'iron']),
    FoodItem(id: 'salmon', name: 'Salmon', emoji: '🐠',
        category: 'protein', calories: 208, protein: 20, carbs: 0, fats: 13, fiber: 0,
        tags: ['high-protein', 'omega3', 'healthy-fats']),
    FoodItem(id: 'tofu', name: 'Tofu', emoji: '🫘',
        category: 'protein', calories: 76, protein: 8, carbs: 2, fats: 4.8, fiber: 0.3,
        tags: ['vegan', 'plant-protein']),
    FoodItem(id: 'lentils', name: 'Lentils', emoji: '🌱',
        category: 'protein', calories: 116, protein: 9, carbs: 20, fats: 0.4, fiber: 8,
        tags: ['vegan', 'high-fiber', 'plant-protein']),
    FoodItem(id: 'greek_yogurt', name: 'Greek Yogurt', emoji: '🥛',
        category: 'dairy', calories: 59, protein: 10, carbs: 3.6, fats: 0.4, fiber: 0,
        tags: ['high-protein', 'probiotic']),
    FoodItem(id: 'cottage_cheese', name: 'Cottage Cheese', emoji: '🧀',
        category: 'dairy', calories: 98, protein: 11, carbs: 3.4, fats: 4.3, fiber: 0,
        tags: ['high-protein', 'low-fat']),

    // ── Carbs ─────────────────────────────────────────────────────────────────
    FoodItem(id: 'white_rice', name: 'White Rice', emoji: '🍚',
        category: 'carbs', calories: 130, protein: 2.7, carbs: 28, fats: 0.3, fiber: 0.4,
        tags: ['quick-energy']),
    FoodItem(id: 'brown_rice', name: 'Brown Rice', emoji: '🌾',
        category: 'carbs', calories: 123, protein: 2.7, carbs: 26, fats: 1, fiber: 1.8,
        tags: ['whole-grain', 'high-fiber']),
    FoodItem(id: 'quinoa', name: 'Quinoa', emoji: '🌿',
        category: 'carbs', calories: 120, protein: 4.4, carbs: 22, fats: 1.9, fiber: 2.8,
        tags: ['complete-protein', 'whole-grain', 'gluten-free']),
    FoodItem(id: 'oats', name: 'Oats', emoji: '🥣',
        category: 'carbs', calories: 389, protein: 17, carbs: 66, fats: 7, fiber: 11,
        tags: ['high-fiber', 'whole-grain']),
    FoodItem(id: 'sweet_potato', name: 'Sweet Potato', emoji: '🍠',
        category: 'carbs', calories: 86, protein: 1.6, carbs: 20, fats: 0.1, fiber: 3,
        tags: ['vitamin-a', 'high-fiber']),
    FoodItem(id: 'pasta', name: 'Pasta', emoji: '🍝',
        category: 'carbs', calories: 158, protein: 5.8, carbs: 31, fats: 0.9, fiber: 1.8,
        tags: ['quick-energy']),
    FoodItem(id: 'bread', name: 'White Bread', emoji: '🍞',
        category: 'carbs', calories: 265, protein: 9, carbs: 49, fats: 3.2, fiber: 2.7,
        tags: ['quick-energy']),
    FoodItem(id: 'whole_bread', name: 'Whole Wheat Bread', emoji: '🫓',
        category: 'carbs', calories: 247, protein: 13, carbs: 41, fats: 4.2, fiber: 7,
        tags: ['whole-grain', 'high-fiber']),

    // ── Vegetables ────────────────────────────────────────────────────────────
    FoodItem(id: 'broccoli', name: 'Broccoli', emoji: '🥦',
        category: 'vegetables', calories: 34, protein: 2.8, carbs: 7, fats: 0.4, fiber: 2.6,
        tags: ['low-calorie', 'high-fiber', 'vitamin-c']),
    FoodItem(id: 'spinach', name: 'Spinach', emoji: '🥬',
        category: 'vegetables', calories: 23, protein: 2.9, carbs: 3.6, fats: 0.4, fiber: 2.2,
        tags: ['low-calorie', 'iron', 'vegan']),
    FoodItem(id: 'avocado', name: 'Avocado', emoji: '🥑',
        category: 'fats', calories: 160, protein: 2, carbs: 9, fats: 15, fiber: 7,
        tags: ['healthy-fats', 'high-fiber']),

    // ── Fruits ────────────────────────────────────────────────────────────────
    FoodItem(id: 'banana', name: 'Banana', emoji: '🍌',
        category: 'fruits', calories: 89, protein: 1.1, carbs: 23, fats: 0.3, fiber: 2.6,
        tags: ['quick-energy', 'potassium']),
    FoodItem(id: 'apple', name: 'Apple', emoji: '🍎',
        category: 'fruits', calories: 52, protein: 0.3, carbs: 14, fats: 0.2, fiber: 2.4,
        tags: ['low-calorie', 'high-fiber']),
    FoodItem(id: 'berries', name: 'Mixed Berries', emoji: '🍓',
        category: 'fruits', calories: 57, protein: 0.7, carbs: 14, fats: 0.3, fiber: 2,
        tags: ['antioxidants', 'low-calorie']),

    // ── Fats & Nuts ───────────────────────────────────────────────────────────
    FoodItem(id: 'almonds', name: 'Almonds', emoji: '🥜',
        category: 'fats', calories: 579, protein: 21, carbs: 22, fats: 50, fiber: 12.5,
        tags: ['healthy-fats', 'high-fiber', 'vitamin-e']),
    FoodItem(id: 'olive_oil', name: 'Olive Oil', emoji: '🫙',
        category: 'fats', calories: 884, protein: 0, carbs: 0, fats: 100, fiber: 0,
        tags: ['healthy-fats', 'omega9']),
  ];

  // Search foods by name — optionally scoped to a category
  List<FoodItem> search(String query, {String? category}) {
    if (query.trim().isEmpty) return [];
    final q    = query.toLowerCase();
    final pool = category != null
        ? _database.where((f) => f.category == category)
        : _database.cast<FoodItem>();
    return pool
        .where((f) => f.name.toLowerCase().contains(q) ||
                      f.category.toLowerCase().contains(q) ||
                      f.tags.any((t) => t.contains(q)))
        .toList();
  }

  // Get swap suggestions for a food item based on user goal
  FoodSwapResult getSwaps(FoodItem original, String userGoal) {
    final candidates = _database
        .where((f) => f.id != original.id)
        .toList();

    final alts = candidates.map((f) {
      final score   = original.matchScore(f);
      final benefit = _determineBenefit(original, f, userGoal);
      final reason  = _buildReason(original, f);
      return SwapAlternative(
        food: f,
        matchScore: score,
        swapReason: reason,
        benefit: benefit,
      );
    }).toList();

    // Sort by goal-relevance first, then match score
    alts.sort((a, b) {
      final aGoal = _goalScore(a, userGoal);
      final bGoal = _goalScore(b, userGoal);
      if (aGoal != bGoal) return bGoal.compareTo(aGoal);
      return b.matchScore.compareTo(a.matchScore);
    });

    return FoodSwapResult(
      original: original,
      alternatives: alts.take(4).toList(),
    );
  }

  // Score how well an alternative fits the user's goal
  double _goalScore(SwapAlternative alt, String goal) {
    switch (goal.toLowerCase()) {
      case 'lose weight':
        return alt.food.calories < 150 ? 2.0 : 0.0;
      case 'build muscle':
        return alt.food.protein > 20 ? 2.0 : 0.0;
      case 'maintain':
        return alt.benefit == SwapBenefit.balanced ? 2.0 : 0.5;
      default:
        return 0.0;
    }
  }

  SwapBenefit _determineBenefit(FoodItem orig, FoodItem alt, String goal) {
    if (alt.protein > orig.protein * 1.2)  return SwapBenefit.higherProtein;
    if (alt.calories < orig.calories * 0.8) return SwapBenefit.lowerCalories;
    if (alt.carbs < orig.carbs * 0.8)       return SwapBenefit.lowerCarbs;
    if (alt.fats < orig.fats * 0.8)         return SwapBenefit.lowerFats;
    if (alt.fiber > orig.fiber * 1.2)       return SwapBenefit.higherFiber;
    return SwapBenefit.balanced;
  }

  String _buildReason(FoodItem orig, FoodItem alt) {
    final parts = <String>[];
    if (alt.protein > orig.protein + 3) {
      parts.add('+${(alt.protein - orig.protein).round()}g protein');
    }
    if (alt.calories < orig.calories - 20) {
      parts.add('-${(orig.calories - alt.calories).round()} kcal');
    }
    if (alt.carbs < orig.carbs - 5) {
      parts.add('-${(orig.carbs - alt.carbs).round()}g carbs');
    }
    if (alt.fiber > orig.fiber + 1) {
      parts.add('+${(alt.fiber - orig.fiber).round()}g fiber');
    }
    if (parts.isEmpty) return 'Similar nutrition profile';
    return parts.join(' · ');
  }

  // All foods for a given category
  List<FoodItem> byCategory(String category) =>
      _database.where((f) => f.category == category).toList();

  FoodItem? findById(String id) {
    try { return _database.firstWhere((f) => f.id == id); }
    catch (_) { return null; }
  }
}