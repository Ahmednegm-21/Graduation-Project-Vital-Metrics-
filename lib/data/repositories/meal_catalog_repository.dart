import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/models/egyptian_meals_data.dart';
import 'package:vital_metrics/services/api_service.dart';
import 'package:vital_metrics/services/token_storage_service.dart';
final List<CatalogMeal> localFallback = egyptianMeals();


/// A meal from the backend catalog (/meals).
class CatalogMeal {
  final int    mealId;
  final String name;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final bool   isLocal; // true = came from local fallback

  const CatalogMeal({
    required this.mealId,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.isLocal = false, required String emoji, required String category,
  });

  factory CatalogMeal.fromJson(Map<String, dynamic> json) => CatalogMeal(
        mealId:      (json['meal_id']   as num).toInt(),
        name:        json['name']        as String,
        description: json['description'] as String? ?? '',
        calories:    double.parse(json['calories'].toString()),
        protein:     double.parse(json['protein'].toString()),
        carbs:       double.parse(json['carbs'].toString()),
        fat:         double.parse(json['fat'].toString()), emoji: '', category: '',
      );

  String get emoji {
    final n = name.toLowerCase();
    if (n.contains('chicken'))                              return '🍗';
    if (n.contains('beef') || n.contains('steak'))         return '🥩';
    if (n.contains('fish') || n.contains('salmon') || n.contains('tuna')) return '🐟';
    if (n.contains('egg'))                                  return '🥚';
    if (n.contains('rice'))                                 return '🍚';
    if (n.contains('pasta') || n.contains('ravioli'))      return '🍝';
    if (n.contains('salad'))                                return '🥗';
    if (n.contains('bread') || n.contains('toast'))        return '🍞';
    if (n.contains('oat'))                                  return '🥣';
    if (n.contains('yogurt'))                               return '🥛';
    if (n.contains('smoothie') || n.contains('shake'))     return '🥤';
    if (n.contains('soup'))                                 return '🍲';
    if (n.contains('wrap') || n.contains('burrito'))       return '🌯';
    if (n.contains('pizza'))                                return '🍕';
    if (n.contains('burger'))                               return '🍔';
    if (n.contains('avocado'))                              return '🥑';
    if (n.contains('banana'))                               return '🍌';
    if (n.contains('apple'))                                return '🍎';
    if (n.contains('nut') || n.contains('almond'))         return '🥜';
    if (n.contains('bar') || n.contains('chocolate'))      return '🍫';
    if (n.contains('chil') || n.contains('pepper'))        return '🌶️';
    return '🍽️';
  }

  String get category {
    final n = name.toLowerCase();
    if (n.contains('oat') || n.contains('egg') || n.contains('toast') ||
        n.contains('yogurt') || n.contains('smoothie') || n.contains('pancake') ||
        n.contains('breakfast') || n.contains('cereal')) {
      return 'breakfast';
    }
    if (n.contains('steak') || n.contains('chicken') || n.contains('salmon') ||
        n.contains('pasta') || n.contains('pizza') || n.contains('burger') ||
        n.contains('ravioli') || n.contains('dinner')) {
      return 'dinner';
    }
    if (n.contains('bar') || n.contains('nut') || n.contains('fruit') ||
        n.contains('chocolate') || n.contains('cookie') ||
        n.contains('snack') || n.contains('moo')) {
      return 'snacks';
    }
    if (n.contains('salad') || n.contains('wrap') || n.contains('sandwich') ||
        n.contains('soup') || n.contains('bowl') || n.contains('lunch') ||
        n.contains('lentil') || n.contains('chil')) {
      return 'lunch';
    }
    return 'lunch';
  }

  // ── Local fallback data — used when backend catalog is empty ──────────────
  static const List<CatalogMeal> localFallback = [
    CatalogMeal(mealId: -1,  name: 'Organic Old Fashioned Oats',  description: '', calories: 160, protein: 5,  carbs: 28, fat: 3,  isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -2,  name: 'Spicy Lentil Wrap w/ Sauce',  description: '', calories: 580, protein: 22, carbs: 75, fat: 18, isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -3,  name: 'TJ 4 Cheese Mini Ravioli',    description: '', calories: 250, protein: 10, carbs: 35, fat: 8,  isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -4,  name: 'Chiles Rellenos Con Queso',   description: '', calories: 350, protein: 14, carbs: 20, fat: 22, isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -5,  name: 'Organic Midnight Moo',        description: '', calories: 110, protein: 3,  carbs: 18, fat: 3,  isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -6,  name: 'Chicken Tikka Masala',        description: '', calories: 350, protein: 28, carbs: 22, fat: 14, isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -7,  name: 'Greek Yogurt with Honey',     description: '', calories: 180, protein: 12, carbs: 24, fat: 3,  isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -8,  name: 'Avocado Toast',               description: '', calories: 290, protein: 8,  carbs: 30, fat: 16, isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -9,  name: 'Caesar Salad',                description: '', calories: 220, protein: 9,  carbs: 14, fat: 15, isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -10, name: 'Grilled Salmon',              description: '', calories: 410, protein: 46, carbs: 0,  fat: 24, isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -11, name: 'Mixed Nuts',                  description: '', calories: 180, protein: 5,  carbs: 8,  fat: 15, isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -12, name: 'Banana Smoothie',             description: '', calories: 240, protein: 6,  carbs: 45, fat: 4,  isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -13, name: 'Scrambled Eggs',              description: '', calories: 200, protein: 14, carbs: 2,  fat: 15, isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -14, name: 'Brown Rice Bowl',             description: '', calories: 320, protein: 6,  carbs: 68, fat: 2,  isLocal: true, emoji: '', category: ''),
    CatalogMeal(mealId: -15, name: 'Protein Bar',                 description: '', calories: 210, protein: 20, carbs: 22, fat: 7,  isLocal: true, emoji: '', category: ''),
  ];
}

class MealCatalogRepository {
  final ApiService          _api;
  final TokenStorageService _tokenStorage;

  MealCatalogRepository({
    ApiService?          api,
    TokenStorageService? tokenStorage,
  })  : _api          = api          ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  /// Fetch from backend.
  /// If backend returns empty → fall back to local data automatically.
  Future<List<CatalogMeal>> getMeals({
    int    page  = 1,
    int    limit = 50,
    String query = '',
  }) async {
    try {
      final headers = await _authHeaders;
      final raw     = await _api.getAsList(
        ApiConfig.getMeals,
        headers:         headers,
        queryParameters: {
          'page':  page,
          'limit': limit,
          if (query.trim().isNotEmpty) 'search': query.trim(),
        },
      );

      final meals = raw
          .map((e) => CatalogMeal.fromJson(e as Map<String, dynamic>))
          .toList();

      // ── Backend has data → use it ─────────────────────────────────────────
      if (meals.isNotEmpty) return meals;

      // ── Backend empty → fall back to local ───────────────────────────────
      print('[MealCatalog] Backend returned 0 meals — using local fallback');
      return _filterLocal(query);
    } catch (e) {
      // ── Network error → fall back to local ───────────────────────────────
      print('[MealCatalog] Backend error ($e) — using local fallback');
      return _filterLocal(query);
    }
  }

  List<CatalogMeal> _filterLocal(String query) {
    if (query.trim().isEmpty) return CatalogMeal.localFallback;
    final q = query.toLowerCase();
    return CatalogMeal.localFallback
        .where((m) => m.name.toLowerCase().contains(q))
        .toList();
  }
}