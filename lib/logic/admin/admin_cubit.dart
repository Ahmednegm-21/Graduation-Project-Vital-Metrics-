// lib/logic/admin/admin_cubit.dart

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:vital_metrics/data/config/api_config.dart';
import 'package:vital_metrics/data/models/admin_meal_model.dart';
import 'package:vital_metrics/data/models/admin_user_model.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit({required this.token}) : super(AdminState.initial());

  /// Bearer token of the logged-in admin
  final String token;

  Map<String, String> get _headers => ApiConfig.headers(token: token);

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  /// Throws a readable message on non-2xx responses.
  void _assertOk(http.Response res, String action) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = action;
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        msg = body['message'] as String? ?? body['error'] as String? ?? action;
      } catch (_) {}
      throw Exception('$msg (${res.statusCode})');
    }
  }

  // ── Load All ─────────────────────────────────────────────────────────────────
  Future<void> loadAll() async {
    emit(state.copyWithLoading());
    try {
      final results = await Future.wait([
        http.get(_uri(ApiConfig.adminOverview), headers: _headers),
        http.get(_uri(ApiConfig.adminUsers),    headers: _headers),
        http.get(_uri(ApiConfig.adminMeals),    headers: _headers),
      ]);

      _assertOk(results[0], 'Failed to load overview');
      _assertOk(results[1], 'Failed to load users');
      _assertOk(results[2], 'Failed to load meals');

      final overviewJson = jsonDecode(results[0].body);
      final usersJson    = jsonDecode(results[1].body);
      final mealsJson    = jsonDecode(results[2].body);

      // API may return { "data": [...] } or a raw list — handle both
      List<dynamic> _asList(dynamic raw) =>
          raw is List ? raw : (raw as Map<String, dynamic>)['data'] as List? ?? [];

      final overview = AdminOverview.fromJson(
        overviewJson is Map<String, dynamic>
            ? overviewJson
            : (overviewJson as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );

      final users = _asList(usersJson)
          .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final meals = _asList(mealsJson)
          .map((e) => AdminMealModel.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(state.copyWithData(overview: overview, users: users, meals: meals));
    } catch (e) {
      emit(state.copyWithError(e.toString()));
    }
  }

  // ── Delete User ───────────────────────────────────────────────────────────────
  Future<void> deleteUser(AdminUserModel user) async {
    try {
      final res = await http.delete(
        _uri(ApiConfig.adminDeleteUser(user.userId)),
        headers: _headers,
      );
      _assertOk(res, 'Failed to delete user');

      final updatedUsers = state.users
          .where((u) => u.userId != user.userId)
          .toList();

      final updatedOverview = state.overview == null
          ? null
          : AdminOverview(
              totalUsers:        updatedUsers.length,
              totalGoals:        state.overview!.totalGoals,
              totalMeals:        state.overview!.totalMeals,
              totalDailyMetrics: state.overview!.totalDailyMetrics,
            );

      emit(state.copyWith(
        users:      updatedUsers,
        overview:   updatedOverview,
        clearError: true,
      ));
    } catch (e) {
      rethrow;
    }
  }

  // ── Create Meal ───────────────────────────────────────────────────────────────
  Future<void> createMeal({
    required String name,
    required String description,
    required int    calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    try {
      final body = AdminMealModel(
        mealId:      0, // ignored by server on create
        name:        name,
        description: description,
        calories:    calories,
        protein:     protein,
        carbs:       carbs,
        fat:         fat,
      ).toCreateJson();

      final res = await http.post(
        _uri(ApiConfig.adminMeals),
        headers: _headers,
        body:    jsonEncode(body),
      );
      _assertOk(res, 'Failed to create meal');

      // Parse the newly created meal returned by the server
      final responseJson = jsonDecode(res.body);
      final mealJson = responseJson is Map<String, dynamic> &&
              responseJson.containsKey('data')
          ? responseJson['data'] as Map<String, dynamic>
          : responseJson as Map<String, dynamic>;

      final newMeal = AdminMealModel.fromJson(mealJson);

      final updatedMeals = [...state.meals, newMeal];

      final updatedOverview = state.overview == null
          ? null
          : AdminOverview(
              totalUsers:        state.overview!.totalUsers,
              totalGoals:        state.overview!.totalGoals,
              totalMeals:        updatedMeals.length,
              totalDailyMetrics: state.overview!.totalDailyMetrics,
            );

      emit(state.copyWith(
        meals:      updatedMeals,
        overview:   updatedOverview,
        clearError: true,
      ));
    } catch (e) {
      rethrow;
    }
  }

  // ── Update Meal ───────────────────────────────────────────────────────────────
  Future<void> updateMeal({
    required int    id,
    required String name,
    required String description,
    required int    calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    try {
      final body = jsonEncode({
        'name':        name,
        'description': description,
        'calories':    calories,
        'protein':     protein,
        'carbs':       carbs,
        'fat':         fat,
      });

      final res = await http.put(
        _uri(ApiConfig.updateMeal(id)),
        headers: _headers,
        body:    body,
      );
      _assertOk(res, 'Failed to update meal');

      final updatedMeals = state.meals.map((m) {
        if (m.mealId != id) return m;
        return m.copyWith(
          name:        name,
          description: description,
          calories:    calories,
          protein:     protein,
          carbs:       carbs,
          fat:         fat,
        );
      }).toList();

      emit(state.copyWith(meals: updatedMeals, clearError: true));
    } catch (e) {
      rethrow;
    }
  }

  // ── Delete Meal ───────────────────────────────────────────────────────────────
  Future<void> deleteMeal(AdminMealModel meal) async {
    try {
      final res = await http.delete(
        _uri(ApiConfig.deleteMeal(meal.mealId)),
        headers: _headers,
      );
      _assertOk(res, 'Failed to delete meal');

      final updatedMeals = state.meals
          .where((m) => m.mealId != meal.mealId)
          .toList();

      final updatedOverview = state.overview == null
          ? null
          : AdminOverview(
              totalUsers:        state.overview!.totalUsers,
              totalGoals:        state.overview!.totalGoals,
              totalMeals:        updatedMeals.length,
              totalDailyMetrics: state.overview!.totalDailyMetrics,
            );

      emit(state.copyWith(
        meals:      updatedMeals,
        overview:   updatedOverview,
        clearError: true,
      ));
    } catch (e) {
      rethrow;
    }
  }
}