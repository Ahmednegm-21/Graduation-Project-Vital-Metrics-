import 'package:vital_metrics/data/models/daily_stats_model.dart';

abstract class ActivityState {
  const ActivityState();
}

class TodayLoading extends ActivityState {
  const TodayLoading();
}

class TodayLoaded extends ActivityState {
  final DailyStats stats;
  const TodayLoaded(this.stats);
}

class TodayError extends ActivityState {
  final String message;
  const TodayError(this.message);
}
