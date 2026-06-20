// lib/logic/admin/admin_state.dart

import 'package:vital_metrics/data/models/admin_meal_model.dart';
import 'package:vital_metrics/data/models/admin_user_model.dart';

// ── Overview ──────────────────────────────────────────────────────────────────
class AdminOverview {
  final int totalUsers;
  final int totalGoals;
  final int totalMeals;
  final int totalDailyMetrics;

  const AdminOverview({
    required this.totalUsers,
    required this.totalGoals,
    required this.totalMeals,
    required this.totalDailyMetrics,
  });

  factory AdminOverview.fromJson(Map<String, dynamic> json) {
    return AdminOverview(
      totalUsers:        (json['total_users']         as num?)?.toInt() ?? 0,
      totalGoals:        (json['total_goals']         as num?)?.toInt() ?? 0,
      totalMeals:        (json['total_meals']         as num?)?.toInt() ?? 0,
      totalDailyMetrics: (json['total_daily_metrics'] as num?)?.toInt() ?? 0,
    );
  }
}

// ── State ─────────────────────────────────────────────────────────────────────
class AdminState {
  final bool                 loading;
  final String?              error;
  final List<AdminUserModel> users;
  final List<AdminMealModel> meals;
  final AdminOverview?       overview;

  const AdminState({
    this.loading  = false,
    this.error,
    this.users    = const [],
    this.meals    = const [],
    this.overview,
  });

  factory AdminState.initial() => const AdminState();

  AdminState copyWithLoading() => AdminState(
        loading:  true,
        error:    null,
        users:    users,
        meals:    meals,
        overview: overview,
      );

  AdminState copyWithData({
    List<AdminUserModel>? users,
    List<AdminMealModel>? meals,
    AdminOverview?        overview,
  }) =>
      AdminState(
        loading:  false,
        error:    null,
        users:    users    ?? this.users,
        meals:    meals    ?? this.meals,
        overview: overview ?? this.overview,
      );

  AdminState copyWithError(String error) => AdminState(
        loading:  false,
        error:    error,
        users:    users,
        meals:    meals,
        overview: overview,
      );

  AdminState copyWith({
    bool?                 loading,
    String?               error,
    List<AdminUserModel>? users,
    List<AdminMealModel>? meals,
    AdminOverview?        overview,
    bool                  clearError = false,
  }) =>
      AdminState(
        loading:  loading  ?? this.loading,
        error:    clearError ? null : (error ?? this.error),
        users:    users    ?? this.users,
        meals:    meals    ?? this.meals,
        overview: overview ?? this.overview,
      );
}