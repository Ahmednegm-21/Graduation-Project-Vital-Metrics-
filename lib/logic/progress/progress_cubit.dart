import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vital_metrics/data/models/daily_metric_model.dart';
import 'package:vital_metrics/data/repositories/daily_metrics_repository.dart';

import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';

part 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final DailyMetricsRepository _repository;

  CalorieCubit? _calorieCubit;
  WaterCubit? _waterCubit;

  int _localBurnedCalories = 0;
  int _localSteps = 0;
  bool _loading = false;

  StreamSubscription? _waterSubscription;
  StreamSubscription? _calorieSubscription;

  // Cache: weekOffset -> list of daily metrics
  final Map<int, List<DailyMetricModel>> _weekCache = {};

  ProgressCubit({
    DailyMetricsRepository? repository,
    CalorieCubit? calorieCubit,
    WaterCubit? waterCubit,
  })  : _repository = repository ?? DailyMetricsRepository(),
        _calorieCubit = calorieCubit,
        _waterCubit = waterCubit,
        super(const ProgressInitial()) {
    _waterSubscription = _waterCubit?.stream.listen((_) async {
      await refresh();
    });
    _calorieSubscription = _calorieCubit?.stream.listen((_) async {
      await refresh();
    });
  }

  // =====================================================
  // SET CUBITS
  // =====================================================

  void setCalorieCubit(CalorieCubit cubit) {
    _calorieCubit = cubit;
    _calorieSubscription?.cancel();
    _calorieSubscription = cubit.stream.listen((_) async {
      await refresh();
    });
  }

  void setWaterCubit(WaterCubit cubit) {
    _waterCubit = cubit;
    _waterSubscription?.cancel();
    _waterSubscription = cubit.stream.listen((_) async {
      await refresh();
    });
  }

  // =====================================================
  // UPDATE LOCAL BURNED CALORIES
  // Called from ActivityCubit with the total burned value
  // including both HC and manual activities
  // =====================================================

  void updateLocalBurned(int calories) {
    _localBurnedCalories = calories;
  }

  // =====================================================
  // UPDATE LOCAL STEPS
  // Called from ActivityCubit with the live HC steps value
  // =====================================================

  void updateLocalSteps(int steps) {
    _localSteps = steps;
  }

  // =====================================================
  // UPDATE TODAY SLEEP
  // Called directly from SleepCubit to update only the
  // current day in state without hitting the backend
  // =====================================================

  void updateTodaySleep(int sleepMinutes) {
    if (state is! ProgressLoaded) return;
    final loaded = state as ProgressLoaded;
    if (loaded.weekOffset != 0) return;

    final today = _fmt(DateTime.now());

    final updatedMetrics = loaded.weeklyMetrics.map((m) {
      final dateStr =
          m.date.length >= 10 ? m.date.substring(0, 10) : m.date;
      if (dateStr == today) {
        return DailyMetricModel(
          metricId: m.metricId,
          date: m.date,
          totalSteps: m.totalSteps,
          caloriesConsumed: m.caloriesConsumed,
          burnedTotal: m.burnedTotal,
          totalWaterMl: m.totalWaterMl,
          totalSleepMinutes: sleepMinutes,
        );
      }
      return m;
    }).toList();

    emit(ProgressLoaded(
      weeklyMetrics: updatedMetrics,
      weekOffset: loaded.weekOffset,
      weekStart: loaded.weekStart,
    ));

    print('[ProgressCubit] updateTodaySleep => $sleepMinutes min');
  }

  // =====================================================
  // LOAD WEEKLY METRICS
  // Does not call HC directly — all live data comes from
  // ActivityCubit via updateLocalBurned and updateLocalSteps
  // =====================================================

  Future<void> loadWeeklyMetrics({
    bool silent = false,
    int weekOffset = 0,
  }) async {
    if (_loading) return;
    _loading = true;

    if (!silent) emit(const ProgressLoading());

    try {
      final now     = DateTime.now();
      final today   = _fmt(now);
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
        case DateTime.friday:
          daysSinceSaturday = 6;
          break;
        default:
          daysSinceSaturday = 0;
      }

      final currentWeekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: daysSinceSaturday));

      final targetWeekStart =
          currentWeekStart.add(Duration(days: weekOffset * 7));

      final raw = await _repository.getWeeklyMetrics(weekOffset: weekOffset);

      final metricMap = <String, DailyMetricModel>{};
      for (final metric in raw) {
        final key = metric.date.length >= 10
            ? metric.date.substring(0, 10)
            : metric.date;
        metricMap[key] = metric;
      }

      final isCurrentWeek = weekOffset == 0;

      final localCalories = isCurrentWeek
          ? (_calorieCubit?.state.totalCaloriesConsumed ?? 0)
          : 0;
      final localWater =
          isCurrentWeek ? (_waterCubit?.state.consumedMl ?? 0) : 0;

      // All burned and steps values come from ActivityCubit
      // No direct HC calls here to avoid stale data after toggle
      final localBurned = isCurrentWeek ? _localBurnedCalories : 0;
      final localSteps  = isCurrentWeek ? _localSteps : 0;

      final filled = List.generate(7, (index) {
        final day     = targetWeekStart.add(Duration(days: index));
        final dateStr = _fmt(day);
        final metric  = metricMap[dateStr];
        final isToday = isCurrentWeek && dateStr == today;

        if (metric != null) {
          return DailyMetricModel(
            metricId: metric.metricId,
            date: metric.date,
            totalSteps: isToday
                ? (localSteps > 0 ? localSteps : metric.totalSteps)
                : metric.totalSteps,
            caloriesConsumed:
                isToday ? localCalories : metric.caloriesConsumed,
            // Today uses live value from ActivityCubit
            // Previous days always use backend value
            burnedTotal: isToday ? localBurned : metric.burnedTotal,
            totalWaterMl: isToday ? localWater : metric.totalWaterMl,
            totalSleepMinutes: metric.totalSleepMinutes,
          );
        }

        // Current day with no backend record yet
        if (isToday) {
          return DailyMetricModel(
            metricId: 0,
            date: dateStr,
            totalSteps: localSteps,
            caloriesConsumed: localCalories,
            burnedTotal: localBurned,
            totalWaterMl: localWater,
            totalSleepMinutes: 0,
          );
        }

        // Past day with no data
        return DailyMetricModel(
          metricId: 0,
          date: dateStr,
          totalSteps: 0,
          caloriesConsumed: 0,
          burnedTotal: 0,
          totalWaterMl: 0,
          totalSleepMinutes: 0,
        );
      });

      _weekCache[weekOffset] = filled;

      print(
        '[ProgressCubit] weekOffset=$weekOffset | CALORIES => '
        '${filled.map((e) => e.caloriesConsumed).toList()}',
      );
      print(
        '[ProgressCubit] weekOffset=$weekOffset | STEPS => '
        '${filled.map((e) => e.totalSteps).toList()}',
      );
      print(
        '[ProgressCubit] weekOffset=$weekOffset | BURNED => '
        '${filled.map((e) => e.burnedTotal).toList()}',
      );
      print(
        '[ProgressCubit] weekOffset=$weekOffset | WATER => '
        '${filled.map((e) => e.totalWaterMl).toList()}',
      );
      print(
        '[ProgressCubit] weekOffset=$weekOffset | SLEEP => '
        '${filled.map((e) => e.totalSleepMinutes).toList()}',
      );

      emit(ProgressLoaded(
        weeklyMetrics: filled,
        weekOffset: weekOffset,
        weekStart: targetWeekStart,
      ));
    } catch (e) {
      print('[ProgressCubit] ERROR => $e');
      emit(ProgressError(e.toString()));
    } finally {
      _loading = false;
    }
  }

  // =====================================================
  // SYNC STEPS TO BACKEND
  // =====================================================

  Future<void> syncStepsToBackend(int totalSteps) async {
    try {
      final today = await _repository.getTodayMetric();
      if (today == null || today.metricId == 0) return;
      await _repository.updateSteps(
        metricsId: today.metricId,
        totalSteps: totalSteps,
      );
    } catch (e) {
      print('[ProgressCubit] syncStepsToBackend ERROR => $e');
    }
  }

  // =====================================================
  // REFRESH
  // No longer calls HC directly — data comes from ActivityCubit
  // This prevents stale HC data after the user disables the toggle
  // =====================================================

  Future<void> refresh() async {
    try {
      _weekCache.remove(0);
      await loadWeeklyMetrics(
        silent: true,
        weekOffset: 0,
      );
    } catch (e) {
      print('[ProgressCubit] refresh ERROR => $e');
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