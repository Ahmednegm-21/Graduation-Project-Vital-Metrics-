import '../config/api_config.dart';
import '../models/onboarding_data.dart';
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
  })  : _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  // ── Shared: get auth headers ───────────────────────────────────────────────
  Future<Map<String, String>> get _authHeaders async {
    final token = await _tokenStorage.getToken();
    return ApiConfig.headers(token: token);
  }

  // ── Save gender ────────────────────────────────────────────────────────────
  Future<void> saveGender(String gender) async {
    try {
      final headers = await _authHeaders;
      await _apiService.patch(
        ApiConfig.onboardingGender,
        headers: headers,
        body: {'gender': gender},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to save gender: $e');
    }
  }

  // ── Save height ────────────────────────────────────────────────────────────
  Future<void> saveHeight(double height) async {
    try {
      final headers = await _authHeaders;
      await _apiService.patch(
        ApiConfig.onboardingHeight,
        headers: headers,
        body: {'height': height},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to save height: $e');
    }
  }

  // ── Save weight ────────────────────────────────────────────────────────────
  Future<void> saveWeight(double weight) async {
    try {
      final headers = await _authHeaders;
      await _apiService.patch(
        ApiConfig.onboardingWeight,
        headers: headers,
        body: {'weight': weight},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to save weight: $e');
    }
  }

  // ── Save age ───────────────────────────────────────────────────────────────
  Future<void> saveAge(double age) async {
    try {
      final birthYear   = DateTime.now().year - age.toInt();
      final dateOfBirth = '$birthYear-01-01';

      final headers = await _authHeaders;
      await _apiService.patch(
        ApiConfig.onboardingAge,
        headers: headers,
        body: {
          'age':           age.toInt(),
          'date_of_birth': dateOfBirth,
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to save age: $e');
    }
  }

  // ── Save goal ──────────────────────────────────────────────────────────────
  Future<void> saveGoal({
    required UserGoal goal,
    double? targetWeight,
    double? weightPerWeek,
    DateTime? targetDate,
  }) async {
    try {
      final headers = await _authHeaders;
      await _apiService.patch(
        ApiConfig.onboardingGoal,
        headers: headers,
        body: {
          'goal': goal.type.toString().split('.').last,
          'target_weight': targetWeight,
          'weight_per_week': weightPerWeek,
          'target_date': targetDate?.toIso8601String(),
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to save goal: $e');
    }
  }

  // ── Save full profile at once ──────────────────────────────────────────────
  Future<void> saveProfile(OnboardingData data) async {
    try {
      final birthYear   = DateTime.now().year - (data.age ?? 25).toInt();
      final dateOfBirth = '$birthYear-01-01';

      final headers = await _authHeaders;
      await _apiService.patch(
        ApiConfig.onboardingProfile,
        headers: headers,
        body: {
          'gender':        data.gender,
          'height':        data.height,
          'weight':        data.weight,
          'age':           data.age?.toInt(),
          'date_of_birth': dateOfBirth,
          'goal':          data.goal?.type.toString().split('.').last,
          'target_weight': data.targetWeight,
          'weight_per_week': data.weightPerWeek,
          'target_date':   data.targetDate?.toIso8601String(),
        },
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to save profile: $e');
    }
  }

  // ── Mark onboarding as complete ────────────────────────────────────────────
  Future<void> completeOnboarding() async {
    try {
      final headers = await _authHeaders;
      await _apiService.post(
        ApiConfig.onboardingComplete,
        headers: headers,
        body: {'completed': true},
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to complete onboarding: $e');
    }
  }

  void dispose() => _apiService.dispose();
}