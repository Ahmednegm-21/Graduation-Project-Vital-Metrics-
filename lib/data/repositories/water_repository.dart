import '../config/api_config.dart';
import '../models/water_model.dart';
import '../exceptions/api_exception.dart';
import '../../services/api_service.dart';
import '../../services/token_storage_service.dart';

class WaterRepository {
  final ApiService _apiService;
  final TokenStorageService _tokenStorage;

  WaterRepository({
    ApiService? apiService,
    TokenStorageService? tokenStorage,
  })  : _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  // POST /water-intakes — log one drink entry
  Future<WaterModel> logIntake({
    required int amountMl,
    DateTime? date,
  }) async {
    try {
      final headers = await _authHeaders;
      final today   = date ?? DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await _apiService.post(
        ApiConfig.createWaterIntake,
        headers: headers,
        body: {'amount_ml': amountMl, 'date': dateStr},
      );

      return WaterModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to log water intake: $e');
    }
  }

  // GET /water-intakes — fetch all entries to filter today locally
  Future<List<WaterModel>> getIntakes({
    int page  = 1,
    int limit = 50,
  }) async {
    try {
      final headers = await _authHeaders;
      final list    = await _apiService.getAsList(
        ApiConfig.getWaterIntakes,
        headers: headers,
        queryParameters: {'page': page, 'limit': limit},
      );

      return list
          .map((e) => WaterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get water intakes: $e');
    }
  }

  // DELETE /water-intakes/{id}
  Future<void> deleteIntake(int id) async {
    try {
      final headers = await _authHeaders;
      await _apiService.delete(
        '${ApiConfig.deleteWaterIntake}/$id',
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete water intake: $e');
    }
  }

  void dispose() => _apiService.dispose();
}