
import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/data/models/meal_model.dart';
import 'package:vital_metrics/data/utils/food_categorizer.dart';
import 'package:vital_metrics/data/utils/meal_translation_lookup.dart';

FoodItem mealToFoodItem(MealModel meal) {
  final backendNameEn = meal.nameEn;
  final resolvedNameEn = backendNameEn.isNotEmpty
      ? backendNameEn
      : MealTranslationLookup.englishForFuzzy(meal.name);

  return FoodItem(
    id:       meal.id.toString(),
    name:     meal.name,
    nameEn:   resolvedNameEn,
    emoji:    guessFoodEmoji(meal.name),
    category: guessFoodCategory(meal.name),
    calories: meal.calories,
    protein:  meal.protein,
    carbs:    meal.carbs,
    fats:     meal.fat,
    tags:     [],
  );
}