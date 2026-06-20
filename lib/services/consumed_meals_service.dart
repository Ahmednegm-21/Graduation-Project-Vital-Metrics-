import 'package:dio/dio.dart';
import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/services/token_storage_service.dart';

class ConsumedMealsService {
  final Dio                _dio;
  final TokenStorageService _tokenStorage;

  ConsumedMealsService({
    required Dio dio,
    TokenStorageService? tokenStorage,
  })  : _dio          = dio,
        _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<void> addConsumedMeal({
    required int mealId,
    required int quantity,
    required int metricsId,
  }) async {
    final token   = await _tokenStorage.getToken();
    final headers = ApiConfig.headers(token: token);

    await _dio.post(
      '${ApiConfig.baseUrl}${ApiConfig.consumedMeals}',
      data: {
        'quantity':   quantity,
        'meal_id':    mealId,
        'metrics_id': metricsId,
      },
      options: Options(headers: headers),
    );
  }
}