// lib/data/models/admin_meal_model.dart

class AdminMealModel {
  final int    mealId;
  final String name;
  final String description;
  final int    calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? createdAt;
  final String? updatedAt;

  const AdminMealModel({
    required this.mealId,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminMealModel.fromJson(Map<String, dynamic> json) {
    return AdminMealModel(
      mealId:      (json['meal_id']     as num?)?.toInt() ?? 0,
      name:        json['name']         as String? ?? '',
      description: json['description']  as String? ?? '',
      calories:    (json['calories']    as num?)?.toInt()    ?? 0,
      protein:     (json['protein']     as num?)?.toDouble() ?? 0.0,
      carbs:       (json['carbs']       as num?)?.toDouble() ?? 0.0,
      fat:         (json['fat']         as num?)?.toDouble() ?? 0.0,
      createdAt:   json['created_at']   as String?,
      updatedAt:   json['updated_at']   as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'meal_id':     mealId,
    'name':        name,
    'description': description,
    'calories':    calories,
    'protein':     protein,
    'carbs':       carbs,
    'fat':         fat,
    'created_at':  createdAt,
    'updated_at':  updatedAt,
  };

  /// Body sent when creating a new meal (POST)
  Map<String, dynamic> toCreateJson() => {
    'name':        name,
    'description': description,
    'calories':    calories,
    'protein':     protein,
    'carbs':       carbs,
    'fat':         fat,
  };

  AdminMealModel copyWith({
    int?    mealId,
    String? name,
    String? description,
    int?    calories,
    double? protein,
    double? carbs,
    double? fat,
  }) =>
      AdminMealModel(
        mealId:      mealId      ?? this.mealId,
        name:        name        ?? this.name,
        description: description ?? this.description,
        calories:    calories    ?? this.calories,
        protein:     protein     ?? this.protein,
        carbs:       carbs       ?? this.carbs,
        fat:         fat         ?? this.fat,
        createdAt:   createdAt,
        updatedAt:   updatedAt,
      );

  @override
  String toString() =>
      'AdminMealModel(mealId: $mealId, name: $name, '
      'calories: $calories)';
}