// lib/data/models/ai_food_models.dart
//
// Models خاصة بـ AI API — متوافقة مع FoodItem و MealModel الموجودين عندك

import 'food_item.dart';   // الـ FoodItem بتاعك الموجود
import 'meal_model.dart';  // الـ MealModel بتاعك الموجود

// ─────────────────────────────────────────────────────────────────────────────
// 1) AiFoodItem — بيجي من /foods و /recommend و /similar
// ─────────────────────────────────────────────────────────────────────────────
class AiFoodItem {
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final double? similarity; // موجود في /recommend و /similar بس

  const AiFoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    this.similarity,
  });

  factory AiFoodItem.fromJson(Map<String, dynamic> json) {
    return AiFoodItem(
      name:          json['food'] as String,
      calories:      (json['calories']      as num).toDouble(),
      protein:       (json['protein']       as num).toDouble(),
      fat:           (json['fat']           as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      similarity:    json['similarity'] != null
                       ? (json['similarity'] as num).toDouble()
                       : null,
    );
  }

  // ── تحويل لـ FoodItem الموجود عندك في المشروع ─────────────────────────────
  // بيستخدم emoji من MealModel._emojiForMeal
  FoodItem toFoodItem() {
    return FoodItem(
      id:       name.toLowerCase().replaceAll(' ', '_'),
      name:     name,
      emoji:    MealModel.getEmoji(name), // ← شوف ملاحظة أسفل
      category: _inferCategory(),
      calories: calories,
      protein:  protein,
      carbs:    carbohydrates,
      fats:     fat,
    );
  }

  // ── تخمين الـ category من الاسم ───────────────────────────────────────────
  String _inferCategory() {
    final n = name.toLowerCase();
    if (n.contains('chicken') || n.contains('beef') || n.contains('fish') ||
        n.contains('turkey') || n.contains('lamb') || n.contains('دجاج') ||
        n.contains('لحم')    || n.contains('سمك'))
      return 'Protein';
    if (n.contains('rice') || n.contains('pasta') || n.contains('bread') ||
        n.contains('أرز')   || n.contains('مكرونة') || n.contains('خبز'))
      return 'Carbs';
    if (n.contains('salad') || n.contains('vegetable') || n.contains('سلطة') ||
        n.contains('خضار'))
      return 'Vegetables';
    if (n.contains('fruit') || n.contains('apple') || n.contains('فاكهة'))
      return 'Fruits';
    if (n.contains('milk') || n.contains('cheese') || n.contains('yogurt') ||
        n.contains('لبن')   || n.contains('جبن'))
      return 'Dairy';
    return 'Other';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2) AiMealSuggestion — بيجي من /suggest
// ─────────────────────────────────────────────────────────────────────────────
class AiMealSuggestion {
  final String name;
  final double weightG;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  const AiMealSuggestion({
    required this.name,
    required this.weightG,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory AiMealSuggestion.fromJson(Map<String, dynamic> json) {
    return AiMealSuggestion(
      name:          json['food']     as String,
      weightG:       (json['weight_g']       as num).toDouble(),
      calories:      (json['calories']        as num).toDouble(),
      protein:       (json['protein']         as num).toDouble(),
      fat:           (json['fat']             as num).toDouble(),
      carbohydrates: (json['carbohydrates']   as num).toDouble(),
    );
  }

  // ── تحويل لـ FoodItem الموجود عندك ────────────────────────────────────────
  FoodItem toFoodItem() {
    return FoodItem(
      id:       name.toLowerCase().replaceAll(' ', '_'),
      name:     name,
      emoji:    MealModel.getEmoji(name),
      category: 'Suggested',
      calories: calories,
      protein:  protein,
      carbs:    carbohydrates,
      fats:     fat,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3) Typed responses (بيسهل التعامل مع نتيجة الـ API)
// ─────────────────────────────────────────────────────────────────────────────
class AiFoodsResponse {
  final bool          success;
  final int           count;
  final List<AiFoodItem> items;

  const AiFoodsResponse({
    required this.success,
    required this.count,
    required this.items,
  });

  factory AiFoodsResponse.fromJson(Map<String, dynamic> json) {
    return AiFoodsResponse(
      success: json['success'] as bool,
      count:   (json['count'] ?? 0) as int,
      items:   (json['data'] as List<dynamic>)
                   .map((e) => AiFoodItem.fromJson(e as Map<String, dynamic>))
                   .toList(),
    );
  }
}

class AiRecommendResponse {
  final bool             success;
  final int              count;
  final String           query;
  final List<AiFoodItem> items;

  const AiRecommendResponse({
    required this.success,
    required this.count,
    required this.query,
    required this.items,
  });

  factory AiRecommendResponse.fromJson(Map<String, dynamic> json) {
    return AiRecommendResponse(
      success: json['success'] as bool,
      count:   (json['count'] ?? 0) as int,
      query:   (json['query']  ?? '') as String,
      items:   (json['data'] as List<dynamic>)
                   .map((e) => AiFoodItem.fromJson(e as Map<String, dynamic>))
                   .toList(),
    );
  }
}

class AiSuggestResponse {
  final bool               success;
  final AiMealSuggestion?  meal;   // null لو مفيش وجبة في النطاق ده
  final String?            message;

  const AiSuggestResponse({
    required this.success,
    this.meal,
    this.message,
  });

  factory AiSuggestResponse.fromJson(Map<String, dynamic> json) {
    return AiSuggestResponse(
      success: json['success'] as bool,
      meal:    json['data'] != null
                 ? AiMealSuggestion.fromJson(json['data'] as Map<String, dynamic>)
                 : null,
      message: json['message'] as String?,
    );
  }
}