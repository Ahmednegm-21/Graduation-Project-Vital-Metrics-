import '../config/api_config.dart';
import '../models/user_goal.dart';
import '../exceptions/api_exception.dart';
import '../../services/api_service.dart';
import '../../services/token_storage_service.dart';

class OnboardingRepository {
  final ApiService _apiService;
  final TokenStorageService _tokenStorage;

  OnboardingRepository({
    ApiService? apiService,
    TokenStorageService? tokenStorage,
  }) : _apiService = apiService ?? ApiService(),
      _tokenStorage = tokenStorage ?? TokenStorageService();

  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  // ── POST /goals ────────────────────────────────────────────────────────────

  Future<void> saveGoal({
    required UserGoal goal,
    double? currentWeight,
    double? targetWeight,
    double? weightPerWeek,
    DateTime? targetDate,
  }) async {
    try {
      final headers = await _authHeaders;
      final goalType = goal.type.toString().split('.').last;

      await _apiService.post(
        ApiConfig.createGoal,
        headers: headers,
        body: {
          'type': goalType == 'maintain'
              ? 'lose'
              : goalType,
          'target_weight': targetWeight,
          'weekly_rate': weightPerWeek,
          'target_date': targetDate?.toIso8601String().split('T').first,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to save goal: $e');
    }
  }

  // ── PATCH /goals ───────────────────────────────────────────────────────────

  Future<void> updateGoal({
    required UserGoal goal,
    double? targetWeight,
    double? weightPerWeek,
  }) async {
    try {
      final headers = await _authHeaders;
      final goalType = goal.type.toString().split('.').last;

      await _apiService.patch(
        ApiConfig.updateGoal,
        headers: headers,
        body: {
          'type': goalType,
          'target_weight': targetWeight,
          'weekly_rate': weightPerWeek,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to update goal: $e');
    }
  }

  // ── GET /goals ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getGoal() async {
    try {
      final headers = await _authHeaders;
      return await _apiService.get(ApiConfig.getGoal, headers: headers);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to get goal: $e');
    }
  }

  // ── DELETE /goals ──────────────────────────────────────────────────────────

  Future<void> deleteGoal() async {
    try {
      final headers = await _authHeaders;
      await _apiService.delete(ApiConfig.deleteGoal, headers: headers);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete goal: $e');
    }
  }

  // ── Complete onboarding ────────────────────────────────────────────────────

  Future<void> completeOnboarding() async => Future.value();

  void dispose() => _apiService.dispose();
}
