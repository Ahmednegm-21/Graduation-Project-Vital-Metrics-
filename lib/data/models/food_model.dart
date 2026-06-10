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
      food: json['food'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      similarity: json['similarity'] != null
          ? (json['similarity'] as num).toDouble()
          : null,
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
      food: json['food'],
      weightG: (json['weight_g'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
    );
  }
}