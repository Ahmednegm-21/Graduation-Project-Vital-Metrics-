import 'package:dio/dio.dart';
import 'package:vital_metrics/data/config/api_config.dart';

class ConsumedMealsService {
  final Dio dio;

  ConsumedMealsService(this.dio);

  Future<void> addConsumedMeal({
    required int mealId,
    required int quantity,
    required int metricsId,
  }) async {
    await dio.post(
      '${ApiConfig.baseUrl}${ApiConfig.consumedMeals}',
      data: {
        "quantity": quantity,
        "meal_id": mealId,
        "metrics_id": metricsId,
      },
    );
  }
}