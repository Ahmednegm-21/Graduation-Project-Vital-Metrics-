// lib/services/admin_api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/models/admin_meal_model.dart';
import 'package:vital_metrics/data/models/admin_overview_model.dart';
import 'package:vital_metrics/data/models/admin_user_model.dart';

class AdminApiService {
  late final Dio _dio;

  // ✅ SecureStorage — نفس الـ instance اللي بيحفظ فيها التوكن بعد اللوجين
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  AdminApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl:        ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('[AdminApiService] ✅ Token attached: ${token.substring(0, token.length.clamp(0, 20))}...');
          } else {
            debugPrint('[AdminApiService] ❌ No token found — request will likely return 401');
          }

          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept']       = 'application/json';
          handler.next(options);
        },

        onError: (DioException e, handler) async {
          // لو رجع 401، اطبع تحذير واضح
          if (e.response?.statusCode == 401) {
            debugPrint('[AdminApiService] 🚨 401 Unauthorized — Token missing or expired');
          }
          handler.next(e);
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Token helper — بيدور في SecureStorage الأول، بعدين SharedPreferences
  // ══════════════════════════════════════════════════════════════════════════

  static Future<String?> _getToken() async {
    // 1️⃣ دور في FlutterSecureStorage (ده اللي بيحفظ فيه TokenStorageService)
    try {
      final secureToken = await _secureStorage.read(key: 'auth_token');
      if (secureToken != null && secureToken.isNotEmpty) {
        return secureToken;
      }
    } catch (e) {
      debugPrint('[AdminApiService] SecureStorage read error: $e');
    }

    // 2️⃣ Fallback: دور في SharedPreferences (احتياط)
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token') ??
             prefs.getString('accessToken')  ??
             prefs.getString('token');
    } catch (e) {
      debugPrint('[AdminApiService] SharedPreferences read error: $e');
    }

    return null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Overview
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /admin/metrics/overview
  Future<AdminOverviewModel> getOverview() async {
    final response = await _dio.get(ApiConfig.adminOverview);
    final data = _unwrap(response.data);
    return AdminOverviewModel.fromJson(data);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Users
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /admin/users
  Future<List<AdminUserModel>> getUsers({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final response = await _dio.get(
      ApiConfig.adminUsers,
      queryParameters: {
        'page':  page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    List raw = [];
    if (response.data is List) {
      raw = response.data as List;
    } else if (response.data is Map) {
      raw = (response.data as Map)['data'] ?? [];
    }

    return raw
        .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// DELETE /admin/users/{id}
  Future<void> deleteUser(int userId) async {
    await _dio.delete(ApiConfig.adminDeleteUser(userId));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Meals
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /admin/meals
  Future<List<AdminMealModel>> getMeals() async {
    final response = await _dio.get(ApiConfig.adminMeals);

    List raw = [];
    if (response.data is List) {
      raw = response.data as List;
    } else if (response.data is Map) {
      raw = (response.data as Map)['data'] ?? [];
    }

    return raw
        .map((e) => AdminMealModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /admin/meals
  Future<AdminMealModel> createMeal({
    required String name,
    required String description,
    required int    calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final body = AdminMealModel(
      mealId:      0,
      name:        name,
      description: description,
      calories:    calories,
      protein:     protein,
      carbs:       carbs,
      fat:         fat,
    );

    final response = await _dio.post(
      ApiConfig.adminMeals,
      data: body.toCreateJson(),
    );

    return AdminMealModel.fromJson(_unwrap(response.data));
  }

  /// PUT /admin/meals/{id}
  Future<AdminMealModel> updateMeal({
    required int    id,
    required String name,
    required String description,
    required int    calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final body = {
      'name':        name,
      'description': description,
      'calories':    calories,
      'protein':     protein,
      'carbs':       carbs,
      'fat':         fat,
    };

    final response = await _dio.put(
      ApiConfig.adminMealById(id),
      data: body,
    );

    return AdminMealModel.fromJson(_unwrap(response.data));
  }

  /// DELETE /admin/meals/{id}
  Future<void> deleteMeal(int mealId) async {
    await _dio.delete(ApiConfig.adminMealById(mealId));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Helper
  // ══════════════════════════════════════════════════════════════════════════

  /// Unwraps { data: {...} } or returns the map directly.
  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        return raw['data'] as Map<String, dynamic>;
      }
      return raw;
    }
    throw FormatException('AdminApiService: unexpected response type: $raw');
  }
}