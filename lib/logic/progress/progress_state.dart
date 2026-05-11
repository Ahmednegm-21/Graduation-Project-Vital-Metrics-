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

  const ProgressLoaded({required this.weeklyMetrics});

  List<int>    get steps    => weeklyMetrics.map((d) => d.totalSteps).toList();
  List<int>    get calories => weeklyMetrics.map((d) => d.caloriesConsumed).toList();
  List<int>    get burned   => weeklyMetrics.map((d) => d.burnedTotal).toList();
  List<int>    get waterMl  => weeklyMetrics.map((d) => d.totalWaterMl).toList();
  List<double> get sleepHrs => weeklyMetrics.map((d) => d.sleepHours).toList();

  @override
  List<Object?> get props => [weeklyMetrics];
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);
  @override
  List<Object?> get props => [message];
}