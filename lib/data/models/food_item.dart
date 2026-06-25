// lib/data/models/food_item.dart

class FoodItem {
  final String id;
  final String name;
  final String nameEn;
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
    this.nameEn = '',
    required this.emoji,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.tags = const [],
  });

  // Returns the right name based on locale.
  // Falls back to the Arabic name if no English name was set.
  String displayName({bool isArabic = true}) =>
      isArabic || nameEn.isEmpty ? name : nameEn;

  // Weighted match score
  // 40% calories, 30% protein, 20% carbs, 10% fats
  // Returns 0 to 100, higher means closer match
  double matchScore(FoodItem other) {
    final calDiff  = (calories - other.calories).abs() / 500;
    final protDiff = (protein  - other.protein ).abs() / 50;
    final carbDiff = (carbs    - other.carbs   ).abs() / 100;
    final fatDiff  = (fats     - other.fats    ).abs() / 50;

    final weighted = (calDiff  * 0.4) +
                     (protDiff * 0.3) +
                     (carbDiff * 0.2) +
                     (fatDiff  * 0.1);

    return ((1 - weighted) * 100).clamp(0, 100);
  }

  FoodItem scaledTo(double grams) {
    final factor = grams / 100;
    return FoodItem(
      id:       id,
      name:     name,
      nameEn:   nameEn,
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
        'nameEn':   nameEn,
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
  higherCalories,
  higherCarbs,
  lowerCalories,
  lowerCarbs,
  lowerFats,
  balanced,
}

extension SwapBenefitExt on SwapBenefit {
  String get label {
    switch (this) {
      case SwapBenefit.higherProtein:  return 'Higher Protein';
      case SwapBenefit.higherCalories: return 'More Calories';
      case SwapBenefit.higherCarbs:    return 'More Carbs';
      case SwapBenefit.lowerCalories:  return 'Fewer Calories';
      case SwapBenefit.lowerCarbs:     return 'Lower Carbs';
      case SwapBenefit.lowerFats:      return 'Lower Fat';
      case SwapBenefit.balanced:       return 'Well Balanced';
    }
  }

  String get emoji {
    switch (this) {
      case SwapBenefit.higherProtein:  return '💪';
      case SwapBenefit.higherCalories: return '⚡';
      case SwapBenefit.higherCarbs:    return '🍚';
      case SwapBenefit.lowerCalories:  return '🔥';
      case SwapBenefit.lowerCarbs:     return '🥩';
      case SwapBenefit.lowerFats:      return '✨';
      case SwapBenefit.balanced:       return '⚖️';
    }
  }
}