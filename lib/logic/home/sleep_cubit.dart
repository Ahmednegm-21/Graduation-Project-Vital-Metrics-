import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/data/models/sleep_model.dart';
import 'package:vital_metrics/data/repositories/sleep_repository.dart';
import 'package:vital_metrics/logic/home/sleep_state.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

export 'sleep_state.dart';

class SleepCubit extends Cubit<SleepState> {
  final SleepRepository  _repo;
  final GoogleFitService _fitService;

  SleepCubit({
    SleepRepository?  repository,
    GoogleFitService? fitService,
  })  : _repo       = repository ?? SleepRepository(),
        _fitService = fitService ?? GoogleFitService(),
        super(const SleepState()) {
    _init();
  }

  // Load today's existing sleep record from backend on start
  Future<void> _init() async {
    emit(state.copyWith(isLoading: true));
    try {
      final sleeps     = await _repo.getSleeps();
      final todayEntry = sleeps.isNotEmpty ? sleeps.first : null;

      if (todayEntry != null) {
        emit(state.copyWith(
          sleepHours: _roundToHalf(todayEntry.hours),
          sleepId:    todayEntry.id,
          isLoading:  false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (_) {
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

  // Save to backend + write to Health Connect when user stops dragging
  Future<void> saveSleep() async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true));

    try {
      SleepModel result;

      if (state.hasTodaySleep) {
        // Update existing backend record
        result = await _repo.updateSleep(
          id:              state.sleepId!,
          durationMinutes: state.durationMinutes,
          quality:         state.quality,
        );
      } else {
        // Create new backend record
        result = await _repo.createSleep(
          durationMinutes: state.durationMinutes,
          quality:         state.quality,
        );
      }

      // Write to Health Connect so it shows in Google Fit
      // Fire and forget — failure here should not block the UI
      _fitService.writeSleep(state.durationMinutes);

      emit(state.copyWith(sleepId: result.id, isSaving: false));
    } catch (_) {
      // Keep UI value even if save fails silently
      emit(state.copyWith(isSaving: false));
    }
  }

  Future<void> refresh() => _init();
}