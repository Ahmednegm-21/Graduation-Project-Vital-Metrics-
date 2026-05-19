import 'dart:async';

import 'package:vital_metrics/logic/progress/progress_cubit.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

class StepsSyncService {
  final ProgressCubit _progressCubit;

  final GoogleFitService _fitService;

  Timer? _timer;

  bool _syncing = false;

  // Sync every 15 minutes
  static const Duration _interval =
      Duration(minutes: 15);

  StepsSyncService({
    required ProgressCubit progressCubit,
    GoogleFitService? fitService,
  })  : _progressCubit = progressCubit,
        _fitService =
            fitService ?? GoogleFitService();

  // =====================================================
  // START SERVICE
  // =====================================================

  void start() {
    // Prevent duplicate timers
    _timer?.cancel();

    // First sync
    syncNow();

    // Periodic sync
    _timer = Timer.periodic(
      _interval,
      (_) => syncNow(),
    );

    print(
      '[StepsSyncService] started',
    );
  }

  // =====================================================
  // MANUAL SYNC
  // =====================================================

  Future<void> syncNow() async {
    // Prevent duplicate executions
    if (_syncing) {
      print(
        '[StepsSyncService] already syncing',
      );
      return;
    }

    _syncing = true;

    try {
      print(
        '[StepsSyncService] syncing...',
      );

      // =========================
      // FETCH HEALTH DATA
      // =========================

      final snapshot =
          await _fitService
              .getTodaySnapshot();

      print(
        '[StepsSyncService] '
        'steps=${snapshot.steps}',
      );

      // =========================
      // SYNC STEPS ONLY
      // =========================

      if (snapshot.steps > 0) {
        await _progressCubit
            .syncStepsToBackend(
          snapshot.steps,
        );
      }

      // =========================
      // LOAD UI DATA ONCE
      // =========================

      await _progressCubit
          .loadWeeklyMetrics();

      print(
        '[StepsSyncService] sync completed',
      );
    } catch (e) {
      print(
        '[StepsSyncService] error => $e',
      );
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

    print(
      '[StepsSyncService] disposed',
    );
  }
}