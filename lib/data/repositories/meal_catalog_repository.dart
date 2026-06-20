import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/models/egyptian_meals_data.dart';
import 'package:vital_metrics/services/api_service.dart';
import 'package:vital_metrics/services/token_storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CatalogMeal
// ─────────────────────────────────────────────────────────────────────────────
class CatalogMeal {
  final int    mealId;
  final String name;
  final String nameEn;          // English name  (empty for backend meals)
  final String description;
  final String descriptionEn;   // English description (empty for backend meals)
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String emojiOverride;   // explicit emoji from local data
  final String categoryOverride;// explicit category from local data
  final bool   isLocal;

  const CatalogMeal({
    required this.mealId,
    required this.name,
    this.nameEn         = '',
    required this.description,
    this.descriptionEn  = '',
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.emojiOverride    = '',
    this.categoryOverride = '',
    this.isLocal          = false,
  });

  // ── From backend JSON ──────────────────────────────────────────────────────
  factory CatalogMeal.fromJson(Map<String, dynamic> json) => CatalogMeal(
        mealId:      (json['meal_id']   as num).toInt(),
        name:        json['name']        as String,
        nameEn:      json['name_en']     as String? ?? '',
        description: json['description'] as String? ?? '',
        descriptionEn: json['description_en'] as String? ?? '',
        calories:    double.parse(json['calories'].toString()),
        protein:     double.parse(json['protein'].toString()),
        carbs:       double.parse(json['carbs'].toString()),
        fat:         double.parse(json['fat'].toString()),
      );

  // ── Resolved emoji — prefers explicit override, falls back to name logic ──
  String get emoji {
    if (emojiOverride.isNotEmpty) return emojiOverride;
    final n = name.toLowerCase();
    if (n.contains('chicken') || n.contains('دجاج') || n.contains('فراخ')) return '🍗';
    if (n.contains('beef')   || n.contains('steak') || n.contains('لحم'))  return '🥩';
    if (n.contains('fish')   || n.contains('salmon') || n.contains('سمك')) return '🐟';
    if (n.contains('egg')    || n.contains('بيض'))                          return '🥚';
    if (n.contains('rice')   || n.contains('أرز'))                          return '🍚';
    if (n.contains('pasta')  || n.contains('مكرونة'))                       return '🍝';
    if (n.contains('salad')  || n.contains('سلطة'))                         return '🥗';
    if (n.contains('bread')  || n.contains('toast') || n.contains('عيش'))  return '🍞';
    if (n.contains('oat')    || n.contains('شوفان'))                         return '🥣';
    if (n.contains('yogurt') || n.contains('زبادي') || n.contains('لبن'))  return '🥛';
    if (n.contains('soup')   || n.contains('شوربة'))                        return '🍲';
    if (n.contains('foul')   || n.contains('فول'))                          return '🫘';
    if (n.contains('pizza')  || n.contains('بيتزا'))                        return '🍕';
    if (n.contains('burger') || n.contains('هامبرجر'))                      return '🍔';
    return '🍽️';
  }

  // ── Resolved category ──────────────────────────────────────────────────────
  String get category {
    if (categoryOverride.isNotEmpty) return categoryOverride;
    final n = name.toLowerCase();
    if (n.contains('oat')     || n.contains('egg')    || n.contains('toast')   ||
        n.contains('yogurt')  || n.contains('smoothie')|| n.contains('cereal') ||
        n.contains('فول')     || n.contains('طعمية')  || n.contains('فطار')   ||
        n.contains('فطير')    || n.contains('فطائر')  || n.contains('بيض'))    return 'breakfast';
    if (n.contains('steak')   || n.contains('chicken') || n.contains('salmon') ||
        n.contains('pasta')   || n.contains('pizza')   || n.contains('burger') ||
        n.contains('كفتة')    || n.contains('شاورما') || n.contains('حمام')   ||
        n.contains('كباب')    || n.contains('فتة'))                             return 'dinner';
    if (n.contains('bar')     || n.contains('nut')     || n.contains('chocolate') ||
        n.contains('بسبوسة') || n.contains('كنافة')   || n.contains('حلوى')   ||
        n.contains('بقلاوة') || n.contains('مهلبية'))                          return 'snacks';
    return 'lunch';
  }

  // ── Localized getters ──────────────────────────────────────────────────────
  String localizedName({bool isArabic = true}) =>
      isArabic || nameEn.isEmpty ? name : nameEn;

  String localizedDescription({bool isArabic = true}) =>
      isArabic || descriptionEn.isEmpty ? description : descriptionEn;
}

// ─────────────────────────────────────────────────────────────────────────────
// MealCatalogRepository
// ─────────────────────────────────────────────────────────────────────────────
class MealCatalogRepository {
  final ApiService          _api;
  final TokenStorageService _tokenStorage;

  MealCatalogRepository({
    ApiService?          api,
    TokenStorageService? tokenStorage,
  })  : _api          = api          ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  // Local fallback — الداتا المصرية الكاملة بعربي + إنجليزي
  static final List<CatalogMeal> _localFallback = egyptianMeals();

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  /// Fetch from backend.
  /// If backend returns empty or fails → fall back to local Egyptian data.
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

      if (meals.isNotEmpty) return meals;

      print('[MealCatalog] Backend returned 0 meals — using local fallback');
      return _filterLocal(query);
    } catch (e) {
      print('[MealCatalog] Backend error ($e) — using local fallback');
      return _filterLocal(query);
    }
  }

  List<CatalogMeal> _filterLocal(String query) {
    if (query.trim().isEmpty) return _localFallback;
    final q = query.toLowerCase();
    return _localFallback.where((m) =>
        m.name.toLowerCase().contains(q) ||
        m.nameEn.toLowerCase().contains(q),
    ).toList();
  }
}