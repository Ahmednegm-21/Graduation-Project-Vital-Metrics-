import '../config/api_config.dart';
import '../models/sleep_model.dart';
import '../exceptions/api_exception.dart';
import '../../services/api_service.dart';
import '../../services/token_storage_service.dart';

class SleepRepository {
  final ApiService _apiService;
  final TokenStorageService _tokenStorage;

  SleepRepository({
    ApiService? apiService,
    TokenStorageService? tokenStorage,
  })  : _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // POST /sleeps — log a new sleep session
  Future<SleepModel> createSleep({
    required int durationMinutes,
    required String quality,
  }) async {
    try {
      final headers  = await _authHeaders;
      final response = await _apiService.post(
        ApiConfig.createSleep,
        headers: headers,
        body: {
          'duration': durationMinutes,
          'quality':  quality,
          'date':     _todayStr(),
        },
      );
      return SleepModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to create sleep: $e');
    }
  }

  // PATCH /sleeps/{id} — update existing sleep session
  Future<SleepModel> updateSleep({
    required int id,
    required int durationMinutes,
    required String quality,
  }) async {
    try {
      final headers  = await _authHeaders;
      final response = await _apiService.patch(
        '${ApiConfig.updateSleep}/$id',
        headers: headers,
        body: {
          'duration': durationMinutes,
          'quality':  quality,
          'date':     _todayStr(),
        },
      );
      return SleepModel.fromJson(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to update sleep: $e');
    }
  }

  // GET /sleeps — fetch all to filter today locally
  Future<List<SleepModel>> getSleeps({
    int page  = 1,
    int limit = 50,
  }) async {
    try {
      final headers = await _authHeaders;
      final list    = await _apiService.getAsList(
        ApiConfig.getSleeps,
        headers: headers,
        queryParameters: {'page': page, 'limit': limit},
      );
      return list
          .map((e) => SleepModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get sleeps: $e');
    }
  }

  // DELETE /sleeps/{id}
  Future<void> deleteSleep(int id) async {
    try {
      final headers = await _authHeaders;
      await _apiService.delete(
        '${ApiConfig.deleteSleep}/$id',
        headers: headers,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete sleep: $e');
    }
  }

  void dispose() => _apiService.dispose();
}