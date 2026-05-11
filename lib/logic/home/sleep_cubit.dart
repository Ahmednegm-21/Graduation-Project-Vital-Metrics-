import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/data/models/sleep_model.dart';
import 'package:vital_metrics/data/repositories/daily_metrics_repository.dart';
import 'package:vital_metrics/data/repositories/sleep_repository.dart';
import 'package:vital_metrics/logic/home/sleep_state.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

export 'sleep_state.dart';

class SleepCubit extends Cubit<SleepState> {
  final SleepRepository          _repo;
  final GoogleFitService         _fitService;
  final DailyMetricsRepository   _metricsRepo;

  SleepCubit({
    SleepRepository?        repository,
    GoogleFitService?       fitService,
    DailyMetricsRepository? metricsRepo,
  })  : _repo        = repository  ?? SleepRepository(),
        _fitService  = fitService  ?? GoogleFitService(),
        _metricsRepo = metricsRepo ?? DailyMetricsRepository(),
        super(const SleepState()) {
    _init();
  }

  Future<void> _init() async {
    emit(state.copyWith(isLoading: true));
    try {
      // Step 1: get today's metrics_id from backend
      final todayMetric = await _metricsRepo.getTodayMetric();
      final todayMetricsId = todayMetric?.metricId;

      if (todayMetricsId == null || todayMetricsId == 0) {
        // No metrics record for today — keep default
        emit(state.copyWith(isLoading: false));
        return;
      }

      // Step 2: fetch all sleep sessions
      final allSleeps = await _repo.getSleeps();

      // Step 3: filter to sessions belonging to today's metrics record only
      final todaySleeps = allSleeps
          .where((s) => s.metricsId == todayMetricsId)
          .toList();

      if (todaySleeps.isEmpty) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      // Step 4: use the FIRST session of today (the original one)
      // and sum duration from all sessions to show accurate total
      // but only store the first session's id for updates
      final firstSession = todaySleeps.first;
      final totalMinutes = todaySleeps.fold<int>(
        0, (sum, s) => sum + s.durationMinutes,
      );

      // Cap at 12h max to avoid inflated totals from duplicates
      final cappedMinutes = totalMinutes.clamp(0, 12 * 60);
      final hours = _roundToHalf(cappedMinutes / 60.0);

      print('[SleepCubit] todayMetricsId=$todayMetricsId sessions=${todaySleeps.length} totalMin=$totalMinutes cappedMin=$cappedMinutes hours=$hours');

      emit(state.copyWith(
        sleepHours: hours,
        sleepId:    firstSession.id,
        isLoading:  false,
      ));
    } catch (e) {
      print('[SleepCubit] _init error: $e');
      // Keep default 7h if backend fails
      emit(state.copyWith(isLoading: false));
    }
  }

  // Round to nearest 0.5 for slider steps
  double _roundToHalf(double value) => (value * 2).round() / 2.0;

  // Update hours locally while user drags slider — no backend call yet
  void updateHours(double hours) {
    emit(state.copyWith(sleepHours: hours));
  }

  // Save to backend + write to Health Connect when user confirms
  Future<void> saveSleep() async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true));

    try {
      SleepModel result;

      if (state.hasTodaySleep) {
        // Update the existing session — don't create a new one
        result = await _repo.updateSleep(
          id:              state.sleepId!,
          durationMinutes: state.durationMinutes,
          quality:         state.quality,
        );
        print('[SleepCubit] Updated sleep id=${state.sleepId} duration=${state.durationMinutes}min');
      } else {
        // Create new session only if none exists today
        result = await _repo.createSleep(
          durationMinutes: state.durationMinutes,
          quality:         state.quality,
        );
        print('[SleepCubit] Created new sleep id=${result.id} duration=${state.durationMinutes}min');
      }

      // Write to Health Connect — fire and forget
      _fitService.writeSleep(state.durationMinutes);

      emit(state.copyWith(sleepId: result.id, isSaving: false));
    } catch (e) {
      print('[SleepCubit] saveSleep error: $e');
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> refresh() => _init();
}