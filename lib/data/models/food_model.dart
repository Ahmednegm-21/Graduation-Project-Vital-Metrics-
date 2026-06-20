class FoodItem {
  final String food;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double? similarity;

  FoodItem({
    required this.food,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    this.similarity,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      food: json['food']?.toString() ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0.0,
      similarity: (json['similarity'] as num?)?.toDouble(),
    );
  }
}

class MealSuggestion {
  final String food;
  final double weightG;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  MealSuggestion({
    required this.food,
    required this.weightG,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) {
    return MealSuggestion(
      food: json['food']?.toString() ?? '',
      weightG: (json['weight_g'] as num?)?.toDouble() ?? 0.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0.0,
    );
  }
}