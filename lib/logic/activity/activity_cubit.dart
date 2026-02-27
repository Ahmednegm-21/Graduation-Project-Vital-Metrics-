import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/data/models/activity_model.dart';
import 'package:vital_metrics/data/models/daily_stats_model.dart';
import 'package:vital_metrics/logic/activity/activity_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final OnboardingCubitAllData onboardingCubit;

  ActivityCubit({required this.onboardingCubit}) : super(const TodayLoading()) {
    _load();
  }

  final GoogleFitService _fitService = GoogleFitService();
  ActivityLevel _activityLevel = ActivityLevel.low;
  final List<ActivityModel> _localActivities = [];
  FitnessSnapshot? _lastSnapshot;

  // ─── Public actions ─────────────────────────────────────────────────────────
  Future<void> refresh() => _load();

  void changeActivityLevel(ActivityLevel level) {
    _activityLevel = level;
    _rebuildLoaded();
  }

  void removeActivity(String id) {
    _localActivities.removeWhere((a) => a.id == id);
    _rebuildLoaded();
  }

  void addActivity(ActivityModel activity) {
    _localActivities.add(activity);
    _rebuildLoaded();
  }

  // ─── Internal ────────────────────────────────────────────────────────────────
  Future<void> _load() async {
    emit(const TodayLoading());
    try {
      _lastSnapshot = await _fitService.getTodaySnapshot();
      _rebuildLoaded();
    } catch (e) {
      emit(TodayError('Failed to load activity data.\n${e.toString()}'));
    }
  }

  void _rebuildLoaded() {
    final snap = _lastSnapshot;
    if (snap == null) return;

    // ── Pull user profile from onboarding cubit ──────────────────────────────
    final userData = onboardingCubit.currentData;

    final allActivities = [...snap.activities, ..._localActivities];
    final extraCalories = _localActivities.fold<int>(
      0,
      (sum, a) => sum + a.caloriesBurned,
    );
    final extraMinutes = _localActivities.fold<int>(
      0,
      (sum, a) => sum + a.durationMinutes,
    );

    final stats = DailyStats(
      activityLevel: _activityLevel,
      caloriesBurned: snap.caloriesBurned + extraCalories,
      steps: snap.steps,
      workoutMinutes: snap.workoutMinutes + extraMinutes,
      trackedActivities: allActivities,
      // ── user data ──
      userWeight: userData.weight,
      userHeight: userData.height,
      userAge: userData.age,
      userGender: userData.gender,
    );

    emit(TodayLoaded(stats));
  }
}
