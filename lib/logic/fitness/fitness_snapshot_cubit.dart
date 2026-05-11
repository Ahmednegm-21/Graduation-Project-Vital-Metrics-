import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

part 'fitness_snapshot_state.dart';

class FitnessSnapshotCubit extends Cubit<FitnessSnapshotState> {
  final GoogleFitService _fitService;

  FitnessSnapshotCubit({GoogleFitService? fitService})
      : _fitService = fitService ?? GoogleFitService(),
        super(const FitnessSnapshotInitial());

  Future<void> load() async {
    emit(const FitnessSnapshotLoading());
    try {
      final snapshot = await _fitService.getTodaySnapshot();
      emit(FitnessSnapshotLoaded(snapshot));
    } catch (e) {
      emit(FitnessSnapshotError(e.toString()));
    }
  }

  void refresh() => load();
}