class MealModel {
  final int     id;
  final String  name;
  final String  nameEn;
  final String? description;
  final String? descriptionEn;
  final double  calories;
  final double  protein;
  final double  carbs;
  final double  fat;

  const MealModel({
    required this.id,
    required this.name,
    this.nameEn        = '',
    this.description,
    this.descriptionEn,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
        id:            (json['meal_id'] as num).toInt(),
        name:          json['name']           as String,
        nameEn:        json['name_en']        as String? ?? '',
        description:   json['description']    as String?,
        descriptionEn: json['description_en'] as String?,
        calories:      double.parse(json['calories'].toString()),
        protein:       double.parse(json['protein'].toString()),
        carbs:         double.parse(json['carbs'].toString()),
        fat:           double.parse(json['fat'].toString()),
      );

  /// Returns the right name based on locale.
  String localizedName({bool isArabic = true}) =>
      isArabic || nameEn.isEmpty ? name : nameEn;

  String localizedDescription({bool isArabic = true}) {
    if (isArabic) return description ?? '';
    return descriptionEn?.isNotEmpty == true
        ? descriptionEn!
        : description ?? '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FoodItemCompat — lightweight bridge for existing FoodItem UI
// ─────────────────────────────────────────────────────────────────────────────
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