import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/data/models/activity_model.dart';
import 'package:vital_metrics/data/models/daily_stats_model.dart';
import 'package:vital_metrics/data/repositories/activity_repository.dart';
import 'package:vital_metrics/logic/activity/activity_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/services/google_fit_service.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final OnboardingCubitAllData onboardingCubit;
  final ActivityRepository _activityRepo;
  final GoogleFitService _fitService = GoogleFitService();

  ActivityLevel _activityLevel = ActivityLevel.low;

  // Local activities added in this session before next refresh
  final List<ActivityModel> _localActivities = [];
  FitnessSnapshot? _lastSnapshot;

  ActivityCubit({
    required this.onboardingCubit,
    ActivityRepository? activityRepository,
  })  : _activityRepo = activityRepository ?? ActivityRepository(),
        super(const TodayLoading()) {
    _load();
  }

  // Public actions

  Future<void> refresh() => _load();

  void changeActivityLevel(ActivityLevel level) {
    _activityLevel = level;
    _rebuildLoaded();
  }

  // Check if the activity id came from Health Connect
  // Manually logged activities have 'local_' prefix and should always go to backend
  // Health Connect activities are pure large timestamp numbers above 2147483647
  // Backend activities have small integer ids like 1, 2, 3
  bool _isHealthConnectId(String id) {
    // Manually logged activities always have local_ prefix — send to backend
    if (id.startsWith('local_')) return false;
    // Pure integer ids from Health Connect are very large timestamps
    final parsed = int.tryParse(id);
    if (parsed == null) return false;
    return parsed > 2147483647;
  }

  // Add activity to UI instantly then save to backend
  // Skip backend call for Health Connect activities since they are read only
  Future<void> addActivity(ActivityModel activity) async {
    // Add locally first for instant UI feedback
    _localActivities.add(activity);
    _rebuildLoaded();

    // Health Connect activities should not be saved to backend
    if (_isHealthConnectId(activity.id)) return;

    try {
      // Save manually logged activity to backend
      final saved = await _activityRepo.createActivity(
        type:            activity.type,
        durationMinutes: activity.durationMinutes,
        caloriesBurned:  activity.caloriesBurned,
        date:            activity.timestamp,
      );

      // Replace local entry with backend response which has a real integer id
      _localActivities.removeWhere((a) => a.id == activity.id);
      _localActivities.add(saved);
      _rebuildLoaded();
    } catch (_) {
    }
  }

  // Skip backend call for Health Connect activities since they cannot be deleted
  Future<void> removeActivity(String id) async {
    // Remove locally first for instant UI feedback
    _localActivities.removeWhere((a) => a.id == id);
    _rebuildLoaded();

    // Health Connect activities have no backend record so skip delete call
    if (_isHealthConnectId(id)) return;

    try {
      // Delete backend activity using its integer id
      await _activityRepo.deleteActivity(id);
    } catch (_) {
      // If delete fails refresh to get correct state from backend
      await _load();
    }
  }

  // Internal

  Future<void> _load() async {
    emit(const TodayLoading());
    try {
      // Load Health Connect data and backend activities at the same time
      final results = await Future.wait([
        _fitService.getTodaySnapshot(),
        _activityRepo.getActivities(),
      ]);

      _lastSnapshot = results[0] as FitnessSnapshot;

      // Merge backend activities into local list and avoid duplicates
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

    // Combine Health Connect activities with manually logged activities
    final allActivities = [...snap.activities, ..._localActivities];

    // Calculate extra calories and minutes from manually logged activities only
    final extraCalories = _localActivities.fold<int>(
      0,
      (sum, a) => sum + a.caloriesBurned,
    );
    final extraMinutes = _localActivities.fold<int>(
      0,
      (sum, a) => sum + a.durationMinutes,
    );

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
  }
}