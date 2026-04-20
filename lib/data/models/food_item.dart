// Represents a single food item with nutritional info
class FoodItem {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final double calories;  // per 100g
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final List<String> tags;

  const FoodItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    this.tags = const [],
  });

  // Match score against another food (0-100)
  double matchScore(FoodItem other) {
    final calDiff  = (calories - other.calories).abs() / 500;
    final protDiff = (protein  - other.protein ).abs() / 50;
    final carbDiff = (carbs    - other.carbs   ).abs() / 100;
    final fatDiff  = (fats     - other.fats    ).abs() / 50;
    final score = 1 - ((calDiff + protDiff + carbDiff + fatDiff) / 4);
    return (score * 100).clamp(0, 100);
  }

  /// Scale all macros by [grams] / 100
  FoodItem scaledTo(double grams) {
    final factor = grams / 100;
    return FoodItem(
      id:       id,
      name:     name,
      emoji:    emoji,
      category: category,
      calories: calories * factor,
      protein:  protein  * factor,
      carbs:    carbs    * factor,
      fats:     fats     * factor,
      fiber:    fiber    * factor,
      tags:     tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':       id,
        'name':     name,
        'emoji':    emoji,
        'category': category,
        'calories': calories,
        'protein':  protein,
        'carbs':    carbs,
        'fats':     fats,
        'fiber':    fiber,
        'tags':     tags,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id:       json['id']       as String,
        name:     json['name']     as String,
        emoji:    json['emoji']    as String,
        category: json['category'] as String,
        calories: (json['calories'] as num).toDouble(),
        protein:  (json['protein']  as num).toDouble(),
        carbs:    (json['carbs']    as num).toDouble(),
        fats:     (json['fats']     as num).toDouble(),
        fiber:    (json['fiber']    as num).toDouble(),
        tags:     List<String>.from(json['tags'] ?? []),
      );
}

// ── Swap result models ────────────────────────────────────────────────────────
class FoodSwapResult {
  final FoodItem original;
  final List<SwapAlternative> alternatives;
  const FoodSwapResult({required this.original, required this.alternatives});
}

class SwapAlternative {
  final FoodItem food;
  final double matchScore;
  final String swapReason;
  final SwapBenefit benefit;
  const SwapAlternative({
    required this.food,
    required this.matchScore,
    required this.swapReason,
    required this.benefit,
  });
}

enum SwapBenefit {
  higherProtein,
  lowerCalories,
  lowerCarbs,
  lowerFats,
  higherFiber,
  balanced,
}

extension SwapBenefitExt on SwapBenefit {
  String get label {
    switch (this) {
      case SwapBenefit.higherProtein: return 'Higher Protein';
      case SwapBenefit.lowerCalories: return 'Fewer Calories';
      case SwapBenefit.lowerCarbs:    return 'Lower Carbs';
      case SwapBenefit.lowerFats:     return 'Lower Fat';
      case SwapBenefit.higherFiber:   return 'More Fiber';
      case SwapBenefit.balanced:      return 'Well Balanced';
    }
  }

  String get emoji {
    switch (this) {
      case SwapBenefit.higherProtein: return '💪';
      case SwapBenefit.lowerCalories: return '🔥';
      case SwapBenefit.lowerCarbs:    return '⚡';
      case SwapBenefit.lowerFats:     return '✨';
      case SwapBenefit.higherFiber:   return '🌿';
      case SwapBenefit.balanced:      return '⚖️';
    }
  }
}