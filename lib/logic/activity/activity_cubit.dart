import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/data/models/activity_model.dart';
import 'package:vital_metrics/data/models/daily_stats_model.dart';
import 'package:vital_metrics/data/repositories/activity_repository.dart';
import 'package:vital_metrics/logic/activity/activity_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/progress/progress_cubit.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final OnboardingCubitAllData onboardingCubit;
  final ActivityRepository     _activityRepo;
  final GoogleFitService       _fitService = GoogleFitService();

  // Set from outside (activity_screen.dart) after creation
  ProgressCubit? _progressCubit;
  void setProgressCubit(ProgressCubit cubit) => _progressCubit = cubit;

  ActivityLevel _activityLevel = ActivityLevel.low;

  final List<ActivityModel> _localActivities = [];
  FitnessSnapshot? _lastSnapshot;

  // Total calories burned from local activities (for progress chart)
  int get localActivitiesCalories =>
      _localActivities.fold<int>(0, (sum, a) => sum + a.caloriesBurned);

  ActivityCubit({
    required this.onboardingCubit,
    ActivityRepository? activityRepository,
  })  : _activityRepo = activityRepository ?? ActivityRepository(),
        super(const TodayLoading()) {
    _load();
  }

  Future<void> refresh() => _load();

  void changeActivityLevel(ActivityLevel level) {
    _activityLevel = level;
    _rebuildLoaded();
  }

  bool _isHealthConnectId(String id) {
    if (id.startsWith('local_')) return false;
    final parsed = int.tryParse(id);
    if (parsed == null) return false;
    return parsed > 2147483647;
  }

  Future<void> addActivity(ActivityModel activity) async {
    _localActivities.add(activity);
    _rebuildLoaded();

    if (_isHealthConnectId(activity.id)) return;

    try {
      final saved = await _activityRepo.createActivity(
        type:            activity.type,
        durationMinutes: activity.durationMinutes,
        caloriesBurned:  activity.caloriesBurned,
        date:            activity.timestamp,
      );
      _localActivities.removeWhere((a) => a.id == activity.id);
      _localActivities.add(saved);
      _rebuildLoaded();
    } catch (_) {}
  }

  Future<void> removeActivity(String id) async {
    _localActivities.removeWhere((a) => a.id == id);
    _rebuildLoaded();

    if (_isHealthConnectId(id)) return;

    try {
      await _activityRepo.deleteActivity(id);
    } catch (_) {
      await _load();
    }
  }

  Future<void> _load() async {
    emit(const TodayLoading());
    try {
      final results = await Future.wait([
        _fitService.getTodaySnapshot(),
        _activityRepo.getActivities(),
      ]);

      _lastSnapshot = results[0] as FitnessSnapshot;

      final backendActivities = results[1] as List<ActivityModel>;
      for (final a in backendActivities) {
        if (!_localActivities.any((l) => l.id == a.id)) {
          _localActivities.add(a);
        }
      }

      _rebuildLoaded();
    } catch (e) {
      emit(TodayError('Failed to load activity data.\n${e.toString()}'));
    }
  }

  void _rebuildLoaded() {
    final snap = _lastSnapshot;
    if (snap == null) return;

    final userData = onboardingCubit.currentData;

    final allActivities = [...snap.activities, ..._localActivities];

    final extraCalories = _localActivities.fold<int>(0, (sum, a) => sum + a.caloriesBurned);
    final extraMinutes  = _localActivities.fold<int>(0, (sum, a) => sum + a.durationMinutes);

    final stats = DailyStats(
      activityLevel:     _activityLevel,
      caloriesBurned:    snap.caloriesBurned + extraCalories,
      steps:             snap.steps,
      workoutMinutes:    snap.workoutMinutes + extraMinutes,
      trackedActivities: allActivities,
      userWeight:        userData.weight,
      userHeight:        userData.height,
      userAge:           userData.age,
      userGender:        userData.gender,
    );

    emit(TodayLoaded(stats));

    // Notify ProgressCubit with updated local burned calories
    _progressCubit?.updateLocalBurned(extraCalories);
  }
}