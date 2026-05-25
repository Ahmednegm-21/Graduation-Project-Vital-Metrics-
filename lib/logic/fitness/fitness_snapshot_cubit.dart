import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

part 'fitness_snapshot_state.dart';

class FitnessSnapshotCubit extends Cubit<FitnessSnapshotState> {
  final GoogleFitService _fitService;

  FitnessSnapshotCubit({GoogleFitService? fitService})
      : _fitService = fitService ?? GoogleFitService(),
        super(const FitnessSnapshotInitial());

  // =====================================================
  // LOAD — بيتحقق من اختيار اليوزر الأول
  // =====================================================

  Future<void> load() async {
    // لو اليوزر عطّل Health Connect → emit disabled مباشرة
    final enabled = await _fitService.isHealthConnectEnabled();
    if (!enabled) {
      emit(const FitnessSnapshotDisabled());
      return;
    }

    emit(const FitnessSnapshotLoading());
    try {
      final snapshot = await _fitService.getTodaySnapshot();
      emit(FitnessSnapshotLoaded(snapshot));
    } catch (e) {
      emit(FitnessSnapshotError(e.toString()));
    }
  }

  // =====================================================
  // ENABLE — اليوزر فعّل Health Connect
  // =====================================================

  Future<void> enable() async {
    await _fitService.setHealthConnectEnabled(true);
    // بعد التفعيل → حمّل الـ snapshot
    await load();
  }

  // =====================================================
  // DISABLE — اليوزر عطّل Health Connect
  // =====================================================

  Future<void> disable() async {
    await _fitService.setHealthConnectEnabled(false);
    emit(const FitnessSnapshotDisabled());
  }

  void refresh() => load();
}