import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/services/api_service.dart';
import 'package:vital_metrics/services/token_storage_service.dart';

class ConsumedMealModel {
  final int    consumedId;
  final int    quantity;
  final String consumedAt;
  final int    mealId;
  final int    metricsId;

  const ConsumedMealModel({
    required this.consumedId,
    required this.quantity,
    required this.consumedAt,
    required this.mealId,
    required this.metricsId,
  });

  factory ConsumedMealModel.fromJson(Map<String, dynamic> json) =>
      ConsumedMealModel(
        consumedId: (json['consumed_id'] as num).toInt(),
        quantity:   (json['quantity']    as num).toInt(),
        consumedAt: json['consumed_at']  as String,
        mealId:     (json['meal_id']     as num).toInt(),
        metricsId:  (json['metrics_id']  as num).toInt(),
      );
}

class ConsumedMealRepository {
  final ApiService          _api;
  final TokenStorageService _tokenStorage;

  ConsumedMealRepository({
    ApiService?          api,
    TokenStorageService? tokenStorage,
  })  : _api          = api          ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ── POST /consumed-meals ───────────────────────────────────────────────────
  Future<ConsumedMealModel> addMeal({
    required int mealId,
    int quantity = 1,
  }) async {
    try {
      final headers  = await _authHeaders;
      final response = await _api.post(
        '/consumed-meals',
        headers: headers,
        body: {
          'meal_id':  mealId,
          'date':     _todayStr(),
          'quantity': quantity,
        },
      );
      return ConsumedMealModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to add consumed meal: $e');
    }
  }

  // ── GET /consumed-meals ────────────────────────────────────────────────────
  Future<List<ConsumedMealModel>> getMeals({
    int page  = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _authHeaders;
      final raw     = await _api.getAsList(
        '/consumed-meals',
        headers:         headers,
        queryParameters: {'page': page, 'limit': limit},
      );
      return raw
          .map((e) => ConsumedMealModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get consumed meals: $e');
    }
  }

  // ── DELETE /consumed-meals/{id} ────────────────────────────────────────────
  Future<void> deleteMeal(int consumedId) async {
    try {
      final headers = await _authHeaders;
      await _api.delete('/consumed-meals/$consumedId', headers: headers);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete consumed meal: $e');
    }
  }
}