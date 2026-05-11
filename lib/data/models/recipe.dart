import 'package:vital_metrics/data/models/meal_model.dart';

class Recipe {
  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String servingSize;
  final String category;
  final String emoji;

  const Recipe({
    required this.id,
    required this.name,
    required this.calories,
    required this.servingSize,
    required this.category,
    required this.emoji,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  factory Recipe.fromMealModel(MealModel meal) => Recipe(
    id:          meal.id.toString(),
    name:        meal.name,
    calories:    meal.calories.round(),
    protein:     meal.protein.round(),
    carbs:       meal.carbs.round(),
    fat:         meal.fat.round(),
    servingSize: '1 Serving',
    category:    _guessCategory(meal.name),
    emoji:       _guessEmoji(meal.name),
  );

  static String _guessCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('oat') || n.contains('egg') || n.contains('toast') ||
        n.contains('yogurt') || n.contains('smoothie') || n.contains('pancake')) return 'breakfast';
    if (n.contains('steak') || n.contains('chicken') || n.contains('salmon') ||
        n.contains('pasta') || n.contains('pizza') || n.contains('burger') ||
        n.contains('ravioli')) return 'dinner';
    if (n.contains('bar') || n.contains('nut') || n.contains('chocolate') ||
        n.contains('cookie') || n.contains('moo')) return 'snacks';
    return 'lunch';
  }

  static String _guessEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('chicken'))  return '🍗';
    if (n.contains('beef') || n.contains('steak')) return '🥩';
    if (n.contains('fish') || n.contains('salmon') || n.contains('tuna')) return '🐟';
    if (n.contains('egg'))      return '🥚';
    if (n.contains('rice'))     return '🍚';
    if (n.contains('pasta') || n.contains('ravioli')) return '🍝';
    if (n.contains('salad'))    return '🥗';
    if (n.contains('bread') || n.contains('toast')) return '🍞';
    if (n.contains('oat'))      return '🥣';
    if (n.contains('yogurt'))   return '🥛';
    if (n.contains('smoothie')) return '🥤';
    if (n.contains('soup'))     return '🍲';
    if (n.contains('wrap'))     return '🌯';
    if (n.contains('pizza'))    return '🍕';
    if (n.contains('burger'))   return '🍔';
    if (n.contains('avocado'))  return '🥑';
    if (n.contains('banana'))   return '🍌';
    if (n.contains('nut') || n.contains('almond')) return '🥜';
    if (n.contains('bar') || n.contains('chocolate')) return '🍫';
    return '🍽️';
  }

  static const List<Recipe> sampleRecipes = [
    Recipe(id: '1',  name: 'Organic Old Fashioned Oats',  calories: 160, protein: 5,  carbs: 28, fat: 3,  servingSize: '43 Gram',   category: 'breakfast', emoji: '🥣'),
    Recipe(id: '2',  name: 'Spicy Lentil wrap w/ sauce',  calories: 580, protein: 22, carbs: 75, fat: 18, servingSize: '1 Serving', category: 'lunch',     emoji: '🌯'),
    Recipe(id: '3',  name: 'TJ 4 Cheese Mini Ravioli',    calories: 250, protein: 10, carbs: 35, fat: 8,  servingSize: '94 Gram',   category: 'dinner',    emoji: '🍝'),
    Recipe(id: '4',  name: 'Chiles Rellenos Con Queso',   calories: 350, protein: 14, carbs: 20, fat: 22, servingSize: '194 Gram',  category: 'lunch',     emoji: '🌶️'),
    Recipe(id: '5',  name: 'Organic Midnight Moo',        calories: 110, protein: 3,  carbs: 18, fat: 3,  servingSize: '34 Gram',   category: 'snacks',    emoji: '🥛'),
    Recipe(id: '6',  name: 'Chicken Tikka Masala',        calories: 350, protein: 28, carbs: 22, fat: 14, servingSize: '1 Box',     category: 'dinner',    emoji: '🍛'),
    Recipe(id: '7',  name: 'Greek Yogurt with Honey',     calories: 180, protein: 12, carbs: 24, fat: 3,  servingSize: '200g',      category: 'breakfast', emoji: '🍯'),
    Recipe(id: '8',  name: 'Avocado Toast',               calories: 290, protein: 8,  carbs: 30, fat: 16, servingSize: '1 Slice',   category: 'breakfast', emoji: '🥑'),
    Recipe(id: '9',  name: 'Caesar Salad',                calories: 220, protein: 9,  carbs: 14, fat: 15, servingSize: '1 Bowl',    category: 'lunch',     emoji: '🥗'),
    Recipe(id: '10', name: 'Grilled Salmon',              calories: 410, protein: 46, carbs: 0,  fat: 24, servingSize: '180g',      category: 'dinner',    emoji: '🐟'),
    Recipe(id: '11', name: 'Mixed Nuts',                  calories: 180, protein: 5,  carbs: 8,  fat: 15, servingSize: '30g',       category: 'snacks',    emoji: '🥜'),
    Recipe(id: '12', name: 'Banana Smoothie',             calories: 240, protein: 6,  carbs: 45, fat: 4,  servingSize: '350ml',     category: 'snacks',    emoji: '🍌'),
    Recipe(id: '13', name: 'Scrambled Eggs',              calories: 200, protein: 14, carbs: 2,  fat: 15, servingSize: '2 Eggs',    category: 'breakfast', emoji: '🍳'),
    Recipe(id: '14', name: 'Brown Rice Bowl',             calories: 320, protein: 6,  carbs: 68, fat: 2,  servingSize: '1 Cup',     category: 'lunch',     emoji: '🍚'),
    Recipe(id: '15', name: 'Protein Bar',                 calories: 210, protein: 20, carbs: 22, fat: 7,  servingSize: '1 Bar',     category: 'snacks',    emoji: '🍫'),
  ];
}