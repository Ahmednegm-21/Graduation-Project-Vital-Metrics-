import '../config/api_config.dart';
import '../exceptions/api_exception.dart';
import '../../services/api_service.dart';
import '../../services/token_storage_service.dart';
import '../models/meal_model.dart';

class MealRepository {
  final ApiService _apiService;
  final TokenStorageService _tokenStorage;

  MealRepository({
    ApiService? apiService,
    TokenStorageService? tokenStorage,
  })  : _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  // ── GET /meals ─────────────────────────────────────────────────────────────
  // Returns the full shared meal catalog
  // Query params: page, limit, search

  Future<List<MealModel>> getMeals({
    int page      = 1,
    int limit     = 20,
    String? search,
  }) async {
    try {
      final headers = await _authHeaders;
      final params  = <String, dynamic>{
        'page':  page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiService.get(
        ApiConfig.getMeals,
        headers: headers,
        queryParameters: params,
      );

      // Backend returns list directly or wrapped in "data"
      final List<dynamic> list = response['data'] is List
          ? response['data'] as List<dynamic>
          : (response.values.first is List
              ? response.values.first as List<dynamic>
              : <dynamic>[]);

      return list
          .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get meals: $e');
    }
  }

  // ── GET /meals/{id} ────────────────────────────────────────────────────────

  Future<MealModel> getMeal(int id) async {
    try {
      final headers  = await _authHeaders;
      final response = await _apiService.get(
        '${ApiConfig.getMeals}/$id',
        headers: headers,
      );
      return MealModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get meal: $e');
    }
  }

  // ── GET /meals/{id}/swap ───────────────────────────────────────────────────
  // Returns up to 5 alternative meals based on user goal
  // - lose goal → lower calorie meals sorted by highest protein
  // - gain goal → higher calorie meals sorted by highest calories & protein

  Future<List<MealModel>> getSwapSuggestions(int mealId) async {
    try {
      final headers  = await _authHeaders;
      final response = await _apiService.get(
        '${ApiConfig.getMeals}/$mealId/swap',
        headers: headers,
      );

      final List<dynamic> list = response['data'] is List
          ? response['data'] as List<dynamic>
          : (response.values.first is List
              ? response.values.first as List<dynamic>
              : <dynamic>[]);

      return list
          .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get swap suggestions: $e');
    }
  }

  void dispose() => _apiService.dispose();
}