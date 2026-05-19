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

  final ActivityRepository _activityRepo;

  final GoogleFitService _fitService =
      GoogleFitService();

  ProgressCubit? _progressCubit;

  void setProgressCubit(
    ProgressCubit cubit,
  ) {
    _progressCubit = cubit;
  }

  // Activity level

  late ActivityLevel _activityLevel;

  // Local activities

  final List<ActivityModel>
      _localActivities = [];

  FitnessSnapshot? _lastSnapshot;

  // Constructor

  ActivityCubit({
    required this.onboardingCubit,
    ActivityRepository?
        activityRepository,
  })  : _activityRepo =
            activityRepository ??
                ActivityRepository(),
        super(
          const TodayLoading(),
        ) {
    _activityLevel =
        onboardingCubit
            .currentData
            .activityLevel ??
        ActivityLevel.low;

    _load();
  }

  // Refresh data

  Future<void> refresh() async {
    await _load();
  }

  // Change activity level

  void changeActivityLevel(
    ActivityLevel level,
  ) {
    _activityLevel = level;

    onboardingCubit
        .updateActivityLevel(
      level,
    );

    _rebuildLoaded();
  }

  // Detect Health Connect activities

  bool _isHealthConnectId(
    String id,
  ) {
    if (id.startsWith('local_')) {
      return false;
    }

    final parsed =
        int.tryParse(id);

    if (parsed == null) {
      return false;
    }

    return parsed > 2147483647;
  }

  // Add activity

  Future<void> addActivity(
    ActivityModel activity,
  ) async {
    final exists =
        _localActivities.any(
      (a) => a.id == activity.id,
    );

    if (!exists) {
      _localActivities.add(
        activity,
      );
    }

    _rebuildLoaded();

    if (_isHealthConnectId(
      activity.id,
    )) {
      return;
    }

    try {
      final saved =
          await _activityRepo
              .createActivity(
        type: activity.type,

        durationMinutes:
            activity.durationMinutes,

        caloriesBurned:
            activity.caloriesBurned,

        date:
            activity.timestamp,
      );

      _localActivities.removeWhere(
        (a) => a.id == activity.id,
      );

      _localActivities.add(
        saved,
      );

      _rebuildLoaded();
    } catch (_) {}
  }

  // Remove activity

  Future<void> removeActivity(
    String id,
  ) async {
    final removed =
        _localActivities.where(
      (a) => a.id == id,
    ).toList();

    _localActivities.removeWhere(
      (a) => a.id == id,
    );

    _rebuildLoaded();

    if (_isHealthConnectId(id)) {
      return;
    }

    try {
      await _activityRepo
          .deleteActivity(id);
    } catch (_) {
      _localActivities.addAll(
        removed,
      );

      _rebuildLoaded();
    }
  }

  // Load all activity data

  Future<void> _load() async {
    emit(
      const TodayLoading(),
    );

    try {
      final results =
          await Future.wait([
        _fitService
            .getTodaySnapshot(),

        _activityRepo
            .getActivities(),
      ]);

      _lastSnapshot =
          results[0]
              as FitnessSnapshot;

      final backendActivities =
          results[1]
              as List<ActivityModel>;

      _localActivities.clear();

      _localActivities.addAll(
        backendActivities,
      );

      _rebuildLoaded();
    } catch (e) {
      emit(
        TodayError(
          'Failed to load activity data\n${e.toString()}',
        ),
      );
    }
  }

  // Rebuild loaded state

  void _rebuildLoaded() {
    final snap = _lastSnapshot;

    if (snap == null) {
      return;
    }

    final userData =
        onboardingCubit.currentData;

    // Remove duplicate activities

    final map =
        <String, ActivityModel>{};

    for (final activity in [
      ...snap.activities,
      ..._localActivities,
    ]) {
      map[activity.id] =
          activity;
    }

    final allActivities =
        map.values.toList();

    // Only count local manual activities

    final localOnlyActivities =
        _localActivities.where(
      (a) => !_isHealthConnectId(
        a.id,
      ),
    );

    final extraCalories =
        localOnlyActivities.fold<int>(
      0,
      (sum, activity) =>
          sum +
          activity.caloriesBurned,
    );

    final extraMinutes =
        localOnlyActivities.fold<int>(
      0,
      (sum, activity) =>
          sum +
          activity.durationMinutes,
    );

    final stats = DailyStats(
      activityLevel:
          _activityLevel,

      caloriesBurned:
          snap.caloriesBurned +
              extraCalories,

      steps:
          snap.steps,

      workoutMinutes:
          snap.workoutMinutes +
              extraMinutes,

      trackedActivities:
          allActivities,

      userWeight:
          userData.weight ?? 70,

      userHeight:
          userData.height ?? 170,

      userAge:
          userData.age ?? 25,

      userGender:
          userData.gender ?? 'male',
    );

    emit(
      TodayLoaded(stats),
    );

    // Update progress screen

    _progressCubit
        ?.updateLocalBurned(
      extraCalories,
    );

    _progressCubit
        ?.refresh();
  }
}
