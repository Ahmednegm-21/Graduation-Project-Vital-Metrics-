import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/data/models/daily_metric_model.dart';
import 'package:vital_metrics/data/repositories/daily_metrics_repository.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

part 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final DailyMetricsRepository _repository;
  final GoogleFitService       _fitService;
  CalorieCubit? _calorieCubit;

  // Local burned calories set from ActivityCubit
  int _localBurnedCalories = 0;

  ProgressCubit({
    DailyMetricsRepository? repository,
    GoogleFitService?       fitService,
    CalorieCubit?           calorieCubit,
  })  : _repository   = repository   ?? DailyMetricsRepository(),
        _fitService    = fitService    ?? GoogleFitService(),
        _calorieCubit = calorieCubit,
        super(const ProgressInitial());

  void setCalorieCubit(CalorieCubit cubit) => _calorieCubit = cubit;

  // Called from ActivityCubit whenever local activities change
  void updateLocalBurned(int calories) {
    _localBurnedCalories = calories;
  }

  Future<void> loadWeeklyMetrics() async {
    emit(const ProgressLoading());
    try {
      final results = await Future.wait([
        _repository.getWeeklyMetrics(),
        _fitService.getTodaySnapshot(),
      ]);

      final raw      = results[0] as List<DailyMetricModel>;
      final snapshot = results[1] as FitnessSnapshot;
      final now      = DateTime.now();
      final today    = _fmt(now);

      final weekday = now.weekday;
      final int daysSinceSat;
      switch (weekday) {
        case 6: daysSinceSat = 0; break;
        case 7: daysSinceSat = 1; break;
        case 1: daysSinceSat = 2; break;
        case 2: daysSinceSat = 3; break;
        case 3: daysSinceSat = 4; break;
        case 4: daysSinceSat = 5; break;
        case 5: daysSinceSat = 6; break;
        default: daysSinceSat = 0;
      }

      final weekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: daysSinceSat));

      final localCalories  = _calorieCubit?.state.totalCaloriesConsumed ?? 0;
      final localBurned    = _localBurnedCalories;

      final metricMap = <String, DailyMetricModel>{};
      for (final m in raw) {
        final key = m.date.length >= 10 ? m.date.substring(0, 10) : m.date;
        metricMap[key] = m;
      }

      print('[ProgressCubit] today=$today localBurned=$localBurned snapshot.burned=${snapshot.caloriesBurned}');

      final filled = List.generate(7, (i) {
        final day     = weekStart.add(Duration(days: i));
        final dateStr = _fmt(day);
        final isToday = dateStr == today;
        final metric  = metricMap[dateStr];

        if (metric != null) {
          if (isToday) {
            final burned = snapshot.caloriesBurned > 0
                ? snapshot.caloriesBurned + localBurned
                : (metric.burnedTotal > 0
                    ? metric.burnedTotal + localBurned
                    : localBurned);

            return DailyMetricModel(
              metricId:          metric.metricId,
              date:              metric.date,
              totalSteps:        snapshot.steps > 0
                  ? snapshot.steps
                  : metric.totalSteps,
              caloriesConsumed:  metric.caloriesConsumed > 0
                  ? metric.caloriesConsumed
                  : localCalories,
              burnedTotal:       burned,
              totalWaterMl:      metric.totalWaterMl,
              totalSleepMinutes: metric.totalSleepMinutes,
            );
          }
          return metric;
        }

        if (isToday) {
          return DailyMetricModel(
            metricId:          0,
            date:              dateStr,
            totalSteps:        snapshot.steps,
            caloriesConsumed:  localCalories,
            burnedTotal:       snapshot.caloriesBurned + localBurned,
            totalWaterMl:      0,
            totalSleepMinutes: 0,
          );
        }

        return DailyMetricModel(
          metricId: 0, date: dateStr,
          totalSteps: 0, caloriesConsumed: 0,
          burnedTotal: 0, totalWaterMl: 0, totalSleepMinutes: 0,
        );
      });

      emit(ProgressLoaded(weeklyMetrics: filled));
    } catch (e) {
      print('[ProgressCubit] loadWeeklyMetrics ERROR: $e');
      emit(ProgressError(e.toString()));
    }
  }

  Future<void> syncStepsToBackend(int totalSteps) async {
    try {
      final today = await _repository.getTodayMetric();
      if (today == null || today.metricId == 0) return;
      await _repository.updateSteps(
        metricsId:  today.metricId,
        totalSteps: totalSteps,
      );
      await loadWeeklyMetrics();
    } catch (e) {
      print('[ProgressCubit] syncStepsToBackend ERROR: $e');
    }
  }

  void refresh() => loadWeeklyMetrics();

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}