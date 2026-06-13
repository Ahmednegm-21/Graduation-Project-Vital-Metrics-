class MealModel {
  final int id;
  final String name;
  final String? description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MealModel({
    required this.id,
    required this.name,
    this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id:          (json['meal_id'] as num).toInt(),
      name:        json['name'] as String,
      description: json['description'] as String?,
      calories:    double.parse(json['calories'].toString()),
      protein:     double.parse(json['protein'].toString()),
      carbs:       double.parse(json['carbs'].toString()),
      fat:         double.parse(json['fat'].toString()),
    );
  }

}

// Lightweight compat class so MealModel works with existing FoodItem UI
class FoodItemCompat {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;

  const FoodItemCompat({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
  });
}