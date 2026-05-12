import 'dart:async';
import 'package:vital_metrics/logic/progress/progress_cubit.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

class StepsSyncService {
  final GoogleFitService _fitService;
  final ProgressCubit    _progressCubit;

  Timer? _timer;
  bool   _syncing = false;

  static const _interval = Duration(minutes: 30);

  StepsSyncService({
    required ProgressCubit progressCubit,
    GoogleFitService?      fitService,
  })  : _progressCubit = progressCubit,
        _fitService    = fitService ?? GoogleFitService();

  void start() {
    print('[StepsSync] Service started');
    _syncNow();
    _timer = Timer.periodic(_interval, (_) => _syncNow());
  }

  Future<void> syncNow() => _syncNow();

  Future<void> _syncNow() async {
    if (_syncing) {
      print('[StepsSync] Already syncing — skipped');
      return;
    }
    _syncing = true;
    print('[StepsSync] Starting sync...');
    try {
      final snapshot = await _fitService.getTodaySnapshot();
      print('[StepsSync] Steps from Health Connect: ${snapshot.steps}');

      if (snapshot.steps > 0) {
        print('[StepsSync] Syncing ${snapshot.steps} steps to backend...');
        await _progressCubit.syncStepsToBackend(snapshot.steps);
        print('[StepsSync] Sync complete');
      } else {
        print('[StepsSync] Steps = 0, skipping backend call');
      }
    } catch (e, stack) {
      print('[StepsSync] ERROR: $e');
      print('[StepsSync] STACK: $stack');
    } finally {
      _syncing = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    print('[StepsSync] Service disposed');
  }
}