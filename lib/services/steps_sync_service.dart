import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/logic/progress/progress_cubit.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

class StepsSyncService {
  final ProgressCubit _progressCubit;
  final GoogleFitService _fitService;

  Timer? _timer;
  bool _syncing = false;

  // Sync every 15 minutes
  static const Duration _interval = Duration(minutes: 15);

  StepsSyncService({
    required ProgressCubit progressCubit,
    GoogleFitService? fitService,
  })  : _progressCubit = progressCubit,
        _fitService = fitService ?? GoogleFitService();

  // =====================================================
  // START SERVICE
  // =====================================================

  void start() {
    _timer?.cancel();

    // First sync
    syncNow();

    // Periodic sync
    _timer = Timer.periodic(_interval, (_) => syncNow());

    print('[StepsSyncService] started');
  }

  // =====================================================
  // MANUAL SYNC
  // Checks HC preference before calling the fit service
  // so disabled HC is respected and no stale data appears
  // =====================================================

  Future<void> syncNow() async {
    if (_syncing) {
      print('[StepsSyncService] already syncing');
      return;
    }

    _syncing = true;

    try {
      print('[StepsSyncService] syncing...');

      // Check HC preference before calling the fit service
      // If user disabled HC skip the snapshot entirely
      final prefs       = await SharedPreferences.getInstance();
      final stepsEnabled = prefs.getBool('hc_steps_enabled') ?? true;

      if (!stepsEnabled) {
        print('[StepsSyncService] HC disabled — skipping sync');
        return;
      }

      final snapshot = await _fitService.getTodaySnapshot();

      print('[StepsSyncService] steps=${snapshot.steps}');

      // Sync steps to backend so progress chart shows correct value
      if (snapshot.steps > 0) {
        await _progressCubit.syncStepsToBackend(snapshot.steps);
      }

      // Load weekly metrics without passing snapshot
      // Steps and burned values come from ActivityCubit
      // via updateLocalBurned and updateLocalSteps
      await _progressCubit.loadWeeklyMetrics(silent: true);

      print('[StepsSyncService] sync completed');
    } catch (e) {
      print('[StepsSyncService] error => $e');
    } finally {
      _syncing = false;
    }
  }

  // =====================================================
  // STOP SERVICE
  // =====================================================

  void dispose() {
    _timer?.cancel();
    _timer = null;
    print('[StepsSyncService] disposed');
  }
}