import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vital_metrics/data/models/daily_metric_model.dart';
import 'package:vital_metrics/data/repositories/daily_metrics_repository.dart';

import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';

import 'package:vital_metrics/services/google_fit_service.dart';

part 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final DailyMetricsRepository _repository;

  final GoogleFitService _fitService;

  CalorieCubit? _calorieCubit;

  WaterCubit? _waterCubit;

  int _localBurnedCalories = 0;

  bool _loading = false;

  StreamSubscription? _waterSubscription;

  StreamSubscription? _calorieSubscription;

  ProgressCubit({
    DailyMetricsRepository? repository,
    GoogleFitService? fitService,
    CalorieCubit? calorieCubit,
    WaterCubit? waterCubit,
  })  : _repository = repository ?? DailyMetricsRepository(),
        _fitService = fitService ?? GoogleFitService(),
        _calorieCubit = calorieCubit,
        _waterCubit = waterCubit,
        super(const ProgressInitial()) {

    // =================================================
    // LISTEN WATER CHANGES
    // =================================================

    _waterSubscription =
        _waterCubit?.stream.listen((_) async {
      await refresh();
    });

    // =================================================
    // LISTEN CALORIES CHANGES
    // =================================================

    _calorieSubscription =
        _calorieCubit?.stream.listen((_) async {
      await refresh();
    });
  }

  // =====================================================
  // SET CUBITS
  // =====================================================

  void setCalorieCubit(CalorieCubit cubit) {
    _calorieCubit = cubit;

    _calorieSubscription?.cancel();

    _calorieSubscription =
        cubit.stream.listen((_) async {
      await refresh();
    });
  }

  void setWaterCubit(WaterCubit cubit) {
    _waterCubit = cubit;

    _waterSubscription?.cancel();

    _waterSubscription =
        cubit.stream.listen((_) async {
      await refresh();
    });
  }

  // =====================================================
  // UPDATE LOCAL BURNED CALORIES
  // =====================================================

  void updateLocalBurned(int calories) {
    _localBurnedCalories = calories;
  }

  // =====================================================
  // LOAD WEEKLY METRICS
  // =====================================================

  Future<void> loadWeeklyMetrics({
    bool silent = false,
    FitnessSnapshot? snapshot,
  }) async {
    if (_loading) return;

    _loading = true;

    if (!silent) {
      emit(const ProgressLoading());
    }

    try {
      // =================================================
      // GET BACKEND DATA
      // =================================================

      final raw =
          await _repository.getWeeklyMetrics();

      // =================================================
      // CURRENT DATE
      // =================================================

      final now = DateTime.now();

      final today = _fmt(now);

      final weekday = now.weekday;

      final int daysSinceSaturday;

      switch (weekday) {
        case DateTime.saturday:
          daysSinceSaturday = 0;
          break;

        case DateTime.sunday:
          daysSinceSaturday = 1;
          break;

        case DateTime.monday:
          daysSinceSaturday = 2;
          break;

        case DateTime.tuesday:
          daysSinceSaturday = 3;
          break;

        case DateTime.wednesday:
          daysSinceSaturday = 4;
          break;

        case DateTime.thursday:
          daysSinceSaturday = 5;
          break;

        default:
          daysSinceSaturday = 6;
      }

      final weekStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(
        Duration(days: daysSinceSaturday),
      );

      // =================================================
      // MAP BACKEND DATA
      // =================================================

      final metricMap =
          <String, DailyMetricModel>{};

      for (final metric in raw) {
        final key =
            metric.date.length >= 10
                ? metric.date.substring(0, 10)
                : metric.date;

        metricMap[key] = metric;
      }

      // =================================================
      // LIVE LOCAL DATA
      // =================================================

      final localCalories =
          _calorieCubit
                  ?.state
                  .totalCaloriesConsumed ??
              0;

      final localWater =
          _waterCubit
                  ?.state
                  .consumedMl ??
              0;

      final localBurned =
          _localBurnedCalories;

      final liveSteps =
          snapshot?.steps ?? 0;

      final liveBurned =
          (snapshot?.caloriesBurned ?? 0) +
              localBurned;

      // =================================================
      // GENERATE WEEK DATA
      // =================================================

      final filled = List.generate(
        7,
        (index) {
          final day = weekStart.add(
            Duration(days: index),
          );

          final dateStr = _fmt(day);

          final metric =
              metricMap[dateStr];

          final isToday =
              dateStr == today;

          // =============================================
          // EXISTING METRIC
          // =============================================

          if (metric != null) {
            return DailyMetricModel(
              metricId: metric.metricId,

              date: metric.date,

              // =========================
              // STEPS
              // =========================

              totalSteps: isToday
                  ? (liveSteps > 0
                      ? liveSteps
                      : metric.totalSteps)
                  : metric.totalSteps,

              // =========================
              // CALORIES CONSUMED
              // =========================

              caloriesConsumed: isToday
                  ? localCalories
                  : metric.caloriesConsumed,

              // =========================
              // BURNED
              // =========================

              burnedTotal: isToday
                  ? (liveBurned > 0
                      ? liveBurned
                      : metric.burnedTotal)
                  : metric.burnedTotal,

              // =========================
              // WATER
              // =========================

              totalWaterMl: isToday
                  ? localWater
                  : metric.totalWaterMl,

              totalSleepMinutes:
                  metric.totalSleepMinutes,
            );
          }

          // =============================================
          // TODAY FALLBACK
          // =============================================

          if (isToday) {
            return DailyMetricModel(
              metricId: 0,

              date: dateStr,

              totalSteps: liveSteps,

              caloriesConsumed:
                  localCalories,

              burnedTotal:
                  liveBurned,

              totalWaterMl:
                  localWater,

              totalSleepMinutes: 0,
            );
          }

          // =============================================
          // EMPTY DAY
          // =============================================

          return DailyMetricModel(
            metricId: 0,

            date: dateStr,

            totalSteps: 0,

            caloriesConsumed: 0,

            burnedTotal: 0,

            totalWaterMl: 0,

            totalSleepMinutes: 0,
          );
        },
      );

      // =================================================
      // DEBUG
      // =================================================

      print(
        '[ProgressCubit] FINAL CALORIES => '
        '${filled.map((e) => e.caloriesConsumed).toList()}',
      );

      print(
        '[ProgressCubit] FINAL STEPS => '
        '${filled.map((e) => e.totalSteps).toList()}',
      );

      print(
        '[ProgressCubit] FINAL BURNED => '
        '${filled.map((e) => e.burnedTotal).toList()}',
      );

      print(
        '[ProgressCubit] FINAL WATER => '
        '${filled.map((e) => e.totalWaterMl).toList()}',
      );

      // =================================================
      // EMIT
      // =================================================

      emit(
        ProgressLoaded(
          weeklyMetrics: filled,
        ),
      );
    } catch (e) {
      print(
        '[ProgressCubit] ERROR => $e',
      );

      emit(
        ProgressError(
          e.toString(),
        ),
      );
    } finally {
      _loading = false;
    }
  }

  // =====================================================
  // SYNC STEPS TO BACKEND
  // =====================================================

  Future<void> syncStepsToBackend(
    int totalSteps,
  ) async {
    try {
      final today =
          await _repository.getTodayMetric();

      if (today == null ||
          today.metricId == 0) {
        return;
      }

      await _repository.updateSteps(
        metricsId: today.metricId,
        totalSteps: totalSteps,
      );
    } catch (e) {
      print(
        '[ProgressCubit] syncStepsToBackend ERROR => $e',
      );
    }
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> refresh() async {
    try {
      FitnessSnapshot? snapshot;

      final granted =
          await _fitService.requestPermissions();

      if (granted) {
        snapshot =
            await _fitService.getTodaySnapshot();
      }

      await loadWeeklyMetrics(
        snapshot: snapshot,
        silent: true,
      );
    } catch (e) {
      print(
        '[ProgressCubit] refresh ERROR => $e',
      );
    }
  }

  // =====================================================
  // FORMAT DATE
  // =====================================================

  String _fmt(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  // =====================================================
  // CLOSE
  // =====================================================

  @override
  Future<void> close() {
    _waterSubscription?.cancel();

    _calorieSubscription?.cancel();

    return super.close();
  }
}