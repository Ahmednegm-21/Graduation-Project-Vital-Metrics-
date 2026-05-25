part of 'progress_cubit.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

class ProgressLoaded extends ProgressState {
  final List<DailyMetricModel> weeklyMetrics;

  // 0 = current week, -1 = last week, -2 = two weeks ago, etc.
  final int weekOffset;

  // The Saturday that starts this week
  final DateTime weekStart;

  const ProgressLoaded({
    required this.weeklyMetrics,
    this.weekOffset = 0,
    required this.weekStart,
  });

  // Calories consumed per day (7 values, Sat to Fri)
  List<int> get calories =>
      weeklyMetrics.map((e) => e.caloriesConsumed).toList();

  // Total steps per day
  List<int> get steps =>
      weeklyMetrics.map((e) => e.totalSteps).toList();

  // Total calories burned per day
  List<int> get burned =>
      weeklyMetrics.map((e) => e.burnedTotal).toList();

  // Total water intake in ml per day
  List<int> get waterMl =>
      weeklyMetrics.map((e) => e.totalWaterMl).toList();

  // Sleep duration in hours per day (converted from minutes)
  List<double> get sleepHrs =>
      weeklyMetrics.map((e) => e.sleepHours).toList();

  @override
  List<Object?> get props => [weeklyMetrics, weekOffset, weekStart];
}

class ProgressError extends ProgressState {
  final String message;

  const ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}