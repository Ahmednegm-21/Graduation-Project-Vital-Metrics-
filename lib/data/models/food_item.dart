class FoodItem {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
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
    this.tags = const [],
  });

  double matchScore(FoodItem other) {
    final calDiff  = (calories - other.calories).abs() / 500;
    final protDiff = (protein  - other.protein ).abs() / 50;
    final carbDiff = (carbs    - other.carbs   ).abs() / 100;
    final fatDiff  = (fats     - other.fats    ).abs() / 50;
    final score = 1 - ((calDiff + protDiff + carbDiff + fatDiff) / 4);
    return (score * 100).clamp(0, 100);
  }

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
        'tags':     tags,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id:       json['id']?.toString()       ?? '',
        name:     json['name']?.toString()     ?? '',
        emoji:    json['emoji']?.toString()    ?? '🍽️',
        category: json['category']?.toString() ?? '',
        calories: (json['calories'] as num?)?.toDouble()
               ?? (json['calorie']  as num?)?.toDouble()
               ?? 0.0,
        protein:  (json['protein']  as num?)?.toDouble() ?? 0.0,
        carbs:    (json['carbs']    as num?)?.toDouble()
               ?? (json['carbohydrates'] as num?)?.toDouble()
               ?? 0.0,
        fats:     (json['fats']     as num?)?.toDouble()
               ?? (json['fat']      as num?)?.toDouble()
               ?? 0.0,
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
  balanced,
}

extension SwapBenefitExt on SwapBenefit {
  String get label {
    switch (this) {
      case SwapBenefit.higherProtein: return 'Higher Protein';
      case SwapBenefit.lowerCalories: return 'Fewer Calories';
      case SwapBenefit.lowerCarbs:    return 'Lower Carbs';
      case SwapBenefit.lowerFats:     return 'Lower Fat';
      case SwapBenefit.balanced:      return 'Well Balanced';
    }
  }

  String get emoji {
    switch (this) {
      case SwapBenefit.higherProtein: return '💪';
      case SwapBenefit.lowerCalories: return '🔥';
      case SwapBenefit.lowerCarbs:    return '⚡';
      case SwapBenefit.lowerFats:     return '✨';
      case SwapBenefit.balanced:      return '⚖️';
    }
  }
}