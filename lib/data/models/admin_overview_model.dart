// lib/data/models/admin_overview_model.dart

class AdminOverviewModel {
  final int totalUsers;
  final int totalGoals;
  final int totalMeals;
  final int totalDailyMetrics;

  const AdminOverviewModel({
    required this.totalUsers,
    required this.totalGoals,
    required this.totalMeals,
    required this.totalDailyMetrics,
  });

  factory AdminOverviewModel.fromJson(Map<String, dynamic> json) {
    return AdminOverviewModel(
      totalUsers:        (json['totalUsers']              as num?)?.toInt() ?? 0,
      totalGoals:        (json['totalGoals']              as num?)?.toInt() ?? 0,
      totalMeals:        (json['totalMeals']              as num?)?.toInt() ?? 0,
      totalDailyMetrics: (json['totalDailyMetricsRecords'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalUsers':               totalUsers,
    'totalGoals':               totalGoals,
    'totalMeals':               totalMeals,
    'totalDailyMetricsRecords': totalDailyMetrics,
  };

  @override
  String toString() =>
      'AdminOverviewModel(users: $totalUsers, goals: $totalGoals, '
      'meals: $totalMeals, dailyMetrics: $totalDailyMetrics)';
}