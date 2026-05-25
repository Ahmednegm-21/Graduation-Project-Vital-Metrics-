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

  // Cache: weekOffset -> list of daily metrics
  final Map<int, List<DailyMetricModel>> _weekCache = {};

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
  // =====================================================

  void updateLocalBurned(int calories) {
    _localBurnedCalories = calories;
  }

  // =====================================================
  // UPDATE TODAY SLEEP — يُستدعى من SleepCubit مباشرة
  // بيحدّث اليوم الحالي فقط في الـ state من غير ما يروح للباك
  // =====================================================

  void updateTodaySleep(int sleepMinutes) {
    // شغّال بس لو في loaded state وعلى current week
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
          totalSleepMinutes: sleepMinutes, // ← ده اللي بيتغير بس
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
  // =====================================================

  Future<void> loadWeeklyMetrics({
    bool silent = false,
    FitnessSnapshot? snapshot,
    int weekOffset = 0,
  }) async {
    if (_loading) return;
    _loading = true;

    if (!silent) emit(const ProgressLoading());

    try {
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

      final currentWeekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: daysSinceSaturday));

      final targetWeekStart =
          currentWeekStart.add(Duration(days: weekOffset * 7));

      final raw =
          await _repository.getWeeklyMetrics(weekOffset: weekOffset);

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
      final localBurned = isCurrentWeek ? _localBurnedCalories : 0;

      final liveSteps =
          (isCurrentWeek && snapshot != null) ? snapshot.steps : 0;

      // liveBurned من Health Connect + الـ local manual activities
      final healthConnectBurned =
          (isCurrentWeek && snapshot != null) ? snapshot.caloriesBurned : 0;
      final liveBurnedFromHC = healthConnectBurned + localBurned;

      final filled = List.generate(7, (index) {
        final day = targetWeekStart.add(Duration(days: index));
        final dateStr = _fmt(day);
        final metric = metricMap[dateStr];
        final isToday = isCurrentWeek && dateStr == today;

        if (metric != null) {
          // ── حساب الـ burned لليوم الحالي ──
          // لو Health Connect شغال → استخدم قيمته + الـ manual
          // لو مش شغال → استخدم الـ backend value + الـ manual
          final int todayBurned;
          if (isToday) {
            if (liveBurnedFromHC > 0) {
              // Health Connect شغال
              todayBurned = liveBurnedFromHC;
            } else if (localBurned > 0) {
              // Health Connect مش شغال بس في manual activities
              todayBurned = (metric.burnedTotal) + localBurned;
            } else {
              // مفيش Health Connect ومفيش manual → خد من الباك
              todayBurned = metric.burnedTotal;
            }
          } else {
            // الأيام السابقة دايماً من الباك
            todayBurned = metric.burnedTotal;
          }

          return DailyMetricModel(
            metricId: metric.metricId,
            date: metric.date,
            totalSteps: isToday
                ? (liveSteps > 0 ? liveSteps : metric.totalSteps)
                : metric.totalSteps,
            caloriesConsumed:
                isToday ? localCalories : metric.caloriesConsumed,
            burnedTotal: todayBurned,
            totalWaterMl: isToday ? localWater : metric.totalWaterMl,
            // النوم دايماً من الباك — التحديث الفوري عن طريق updateTodaySleep
            totalSleepMinutes: metric.totalSleepMinutes,
          );
        }

        // اليوم الحالي بدون record في الباك بعد
        if (isToday) {
          return DailyMetricModel(
            metricId: 0,
            date: dateStr,
            totalSteps: liveSteps,
            caloriesConsumed: localCalories,
            // لو Health Connect شغال خد منه، لو لأ خد الـ manual فقط
            burnedTotal: liveBurnedFromHC > 0 ? liveBurnedFromHC : localBurned,
            totalWaterMl: localWater,
            totalSleepMinutes: 0,
          );
        }

        // يوم سابق بدون داتا
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
  // =====================================================

  Future<void> refresh() async {
    try {
      FitnessSnapshot? snapshot;
      final granted = await _fitService.requestPermissions();
      if (granted) {
        snapshot = await _fitService.getTodaySnapshot();
      }
      _weekCache.remove(0);
      await loadWeeklyMetrics(
        snapshot: snapshot,
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