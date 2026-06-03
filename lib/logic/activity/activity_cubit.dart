import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/data/models/activity_model.dart';
import 'package:vital_metrics/data/models/daily_stats_model.dart';

import 'package:vital_metrics/data/repositories/activity_repository.dart';

import 'package:vital_metrics/logic/activity/activity_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/progress/progress_cubit.dart';

import 'package:vital_metrics/services/google_fit_service.dart';

const _kOriginalTypesKey  = 'activity_original_types';
const _kActivityLevelKey  = 'activity_level';
const _kCachedActivities  = 'activity_cached_list';
const _kCachedDate        = 'activity_cached_date';
const _kHcLastSyncDate    = 'hc_last_sync_date';

class ActivityCubit extends Cubit<ActivityState> {
  final OnboardingCubitAllData onboardingCubit;

  final ActivityRepository _activityRepo;
  final GoogleFitService _fitService = GoogleFitService();

  ProgressCubit? _progressCubit;

  void setProgressCubit(ProgressCubit cubit) {
    _progressCubit = cubit;
  }

  late ActivityLevel _activityLevel;

  // Tracks whether the saved level has been synced to onboardingCubit
  bool _levelSyncedToOnboarding = false;

  final List<ActivityModel> _localActivities = [];
  final Map<String, String> _originalTypes = {};

  FitnessSnapshot? _lastSnapshot;

  // Timer that fires at midnight to reset the day data automatically
  Timer? _midnightTimer;

  ActivityCubit({
    required this.onboardingCubit,
    ActivityRepository? activityRepository,
  })  : _activityRepo = activityRepository ?? ActivityRepository(),
        super(const TodayLoading()) {
    _activityLevel =
        onboardingCubit.currentData.activityLevel ?? ActivityLevel.low;
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    await Future.wait([
      _loadOriginalTypes(),
      _loadActivityLevel(),
    ]);

    await _checkAndResetIfNewDay();
    await _loadCachedActivities();
    await _load();

    // Schedule midnight reset so data clears even if app stays open overnight
    _scheduleMidnightReset();
  }

  // =====================================================
  // MIDNIGHT RESET
  // Schedules a timer that fires exactly at midnight
  // so the day resets automatically without reopening the app
  // =====================================================

  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();
    final now      = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final duration = midnight.difference(now);

    _midnightTimer = Timer(duration, () async {
      print('[ActivityCubit] midnight timer fired — resetting day');
      _lastSnapshot = null;
      _localActivities.clear();
      _fitService.clearPermissionCache();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kCachedActivities);
      await prefs.remove(_kCachedDate);
      await prefs.remove(_kHcLastSyncDate);

      await _load();

      // Schedule the next midnight reset for tomorrow
      _scheduleMidnightReset();
    });

    print('[ActivityCubit] midnight reset scheduled in ${duration.inMinutes} minutes');
  }

  // =====================================================
  // SHARED PREFERENCES — activity level
  // =====================================================

  Future<void> _loadActivityLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_kActivityLevelKey);
      if (saved == null) return;
      _activityLevel = ActivityLevel.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => _activityLevel,
      );
    } catch (_) {}
  }

  Future<void> _saveActivityLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kActivityLevelKey, _activityLevel.name);
    } catch (_) {}
  }

  // =====================================================
  // SHARED PREFERENCES — original types
  // =====================================================

  Future<void> _loadOriginalTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kOriginalTypesKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _originalTypes
        ..clear()
        ..addAll(decoded.cast<String, String>());
    } catch (_) {
      _originalTypes.clear();
    }
  }

  Future<void> _saveOriginalTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kOriginalTypesKey, jsonEncode(_originalTypes));
    } catch (_) {}
  }

  Future<void> _removeOriginalType(String id) async {
    _originalTypes.remove(id);
    await _saveOriginalTypes();
  }

  // =====================================================
  // SHARED PREFERENCES — cached activities
  // =====================================================

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadCachedActivities() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final cached = prefs.getString(_kCachedDate);
      final today  = _todayStr();

      if (cached != today) {
        await prefs.remove(_kCachedActivities);
        await prefs.remove(_kCachedDate);
        _localActivities.clear();
        print('[ActivityCubit] new day detected — cleared cached activities');
        _rebuildLoaded();
        return;
      }

      final raw = prefs.getString(_kCachedActivities);
      if (raw == null) {
        _rebuildLoaded();
        return;
      }

      final list = (jsonDecode(raw) as List)
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList();

      _localActivities
        ..clear()
        ..addAll(list);

      print('[ActivityCubit] loaded ${list.length} cached activities for $today');
      _rebuildLoaded();
    } catch (e) {
      print('[ActivityCubit] _loadCachedActivities error: $e');
      _rebuildLoaded();
    }
  }

  Future<void> _saveCachedActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final toCache = _localActivities
          .where((a) => !_isHealthConnectId(a.id))
          .map((a) => a.toJson())
          .toList();

      await prefs.setString(_kCachedActivities, jsonEncode(toCache));
      await prefs.setString(_kCachedDate, _todayStr());
    } catch (e) {
      print('[ActivityCubit] _saveCachedActivities error: $e');
    }
  }

  // =====================================================
  // SYNC HC ACTIVITIES TO BACKEND
  // Sends HC workout activities to the backend once per day
  // so burned_total is persisted and shows in the progress chart
  // Skips sync if already done today to avoid duplicate records
  // =====================================================

  Future<void> _syncHCActivitiesToBackend(FitnessSnapshot snapshot) async {
    try {
      if (snapshot.activities.isEmpty) return;

      final prefs    = await SharedPreferences.getInstance();
      final lastSync = prefs.getString(_kHcLastSyncDate) ?? '';
      final today    = _todayStr();

      // Only sync once per day to avoid duplicate backend records
      if (lastSync == today) return;

      print('[ActivityCubit] syncing ${snapshot.activities.length} HC activities to backend');

      for (final activity in snapshot.activities) {
        await _activityRepo.syncHCActivity(
          type:            activity.type,
          durationMinutes: activity.durationMinutes,
          caloriesBurned:  activity.caloriesBurned,
          date:            activity.timestamp,
        );
      }

      await prefs.setString(_kHcLastSyncDate, today);
      print('[ActivityCubit] HC activities synced to backend for $today');
    } catch (e) {
      print('[ActivityCubit] HC sync failed (non-fatal): $e');
    }
  }

  // =====================================================
  // PUBLIC API
  // =====================================================

  Future<void> refresh() async {
    await _checkAndResetIfNewDay();
    await _load();
  }

  // Clears the HC snapshot and permission cache immediately
  // then rebuilds state so stale HC data disappears from UI right away
  void clearSnapshot() {
    _lastSnapshot = null;
    _fitService.clearPermissionCache();
    _rebuildLoaded();
  }

  Future<void> _checkAndResetIfNewDay() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final cached = prefs.getString(_kCachedDate);
      final today  = _todayStr();

      if (cached != null && cached != today) {
        await prefs.remove(_kCachedActivities);
        await prefs.remove(_kCachedDate);
        await prefs.remove(_kHcLastSyncDate);
        _localActivities.clear();
        print('[ActivityCubit] midnight reset triggered');
      }
    } catch (_) {}
  }

  void changeActivityLevel(ActivityLevel level) {
    _activityLevel = level;
    onboardingCubit.updateActivityLevel(level);
    _saveActivityLevel();
    _rebuildLoaded();
  }

  // =====================================================
  // ADD ACTIVITY
  // =====================================================

  Future<void> addActivity(ActivityModel activity) async {
    final tempId       = activity.id;
    final originalType = activity.type;

    _originalTypes[tempId] = originalType;
    await _saveOriginalTypes();

    final exists = _localActivities.any((a) => a.id == tempId);
    if (!exists) _localActivities.add(activity);

    await _saveCachedActivities();
    _rebuildLoaded();

    if (_isHealthConnectId(tempId)) return;

    try {
      final saved = await _activityRepo.createActivity(
        type:            originalType,
        durationMinutes: activity.durationMinutes,
        caloriesBurned:  activity.caloriesBurned,
        date:            activity.timestamp,
      );

      _originalTypes[saved.id] = originalType;
      _originalTypes.remove(tempId);
      await _saveOriginalTypes();

      _localActivities.removeWhere((a) => a.id == tempId);
      _localActivities.add(saved.copyWith(type: originalType));

      await _saveCachedActivities();
      _rebuildLoaded();
    } catch (e) {
      print('[ActivityCubit] createActivity failed: $e | keeping temp entry');
    }
  }

  // =====================================================
  // REMOVE ACTIVITY
  // =====================================================

  Future<void> removeActivity(String id) async {
    final removed = _localActivities.where((a) => a.id == id).toList();
    _localActivities.removeWhere((a) => a.id == id);
    await _removeOriginalType(id);
    await _saveCachedActivities();
    _rebuildLoaded();

    if (_isHealthConnectId(id)) return;

    try {
      await _activityRepo.deleteActivity(id);
    } catch (_) {
      for (final a in removed) _originalTypes[a.id] = a.type;
      await _saveOriginalTypes();
      _localActivities.addAll(removed);
      await _saveCachedActivities();
      _rebuildLoaded();
    }
  }

  // =====================================================
  // LOAD
  // =====================================================

  Future<void> _load() async {
    final hasExistingData = state is TodayLoaded;
    if (!hasExistingData) emit(const TodayLoading());

    try {
      final prefs       = await SharedPreferences.getInstance();
      final stepsEnabled = prefs.getBool('hc_steps_enabled') ?? true;

      if (stepsEnabled) {
        final snapshot = await _fitService.getTodaySnapshot();
        _lastSnapshot = snapshot;
        print('[ActivityCubit] snapshot loaded: steps=${snapshot.steps}');

        // Sync HC workout activities to backend once per day
        // so burned_total is persisted for the progress chart
        await _syncHCActivitiesToBackend(snapshot);
      } else {
        _lastSnapshot = null;
        print('[ActivityCubit] HC disabled — snapshot skipped');
      }
    } catch (e) {
      print('[ActivityCubit] Health Connect failed (non-fatal): $e');
    }

    try {
      final backendActivities = await _activityRepo.getActivities();
      final today = _todayStr();

      _localActivities.clear();

      final todayOnly = backendActivities.where((a) {
        final d       = a.timestamp;
        final dateStr =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        return dateStr == today;
      }).toList();

      final restored = todayOnly.map((a) {
        final originalType = _originalTypes[a.id];
        return originalType != null ? a.copyWith(type: originalType) : a;
      }).toList();

      _localActivities.addAll(restored);

      if (restored.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_kCachedActivities);
        await prefs.setString(_kCachedDate, today);
      } else {
        await _saveCachedActivities();
      }

      print('[ActivityCubit] today=$today loaded=${restored.length} '
          '(total from backend=${backendActivities.length})');
    } catch (e) {
      print('[ActivityCubit] backend activities failed: $e');

      final today      = _todayStr();
      final prefs      = await SharedPreferences.getInstance();
      final cachedDate = prefs.getString(_kCachedDate);

      if (_localActivities.isNotEmpty && cachedDate == today) {
        print('[ActivityCubit] using ${_localActivities.length} cached activities (same day)');
        _rebuildLoaded();
        return;
      }

      _localActivities.clear();
      _rebuildLoaded();
      return;
    }

    _rebuildLoaded();
  }

  // =====================================================
  // REBUILD STATE
  // =====================================================

  void _rebuildLoaded() {
    final snap     = _lastSnapshot;
    final userData = onboardingCubit.currentData;

    final map = <String, ActivityModel>{};
    for (final a in [...?snap?.activities, ..._localActivities]) {
      map[a.id] = a;
    }

    final allActivities = map.values.toList();
    final localOnly     =
        _localActivities.where((a) => !_isHealthConnectId(a.id));

    final extraCalories =
        localOnly.fold<int>(0, (s, a) => s + a.caloriesBurned);
    final extraMinutes  =
        localOnly.fold<int>(0, (s, a) => s + a.durationMinutes);

    final stats = DailyStats(
      activityLevel:     _activityLevel,
      caloriesBurned:    (snap?.caloriesBurned ?? 0) + extraCalories,
      steps:             snap?.steps ?? 0,
      workoutMinutes:    (snap?.workoutMinutes ?? 0) + extraMinutes,
      trackedActivities: allActivities,
      userWeight:        userData.weight ?? 70,
      userHeight:        userData.height ?? 170,
      userAge:           userData.age    ?? 25,
      userGender:        userData.gender ?? 'male',
    );

    emit(TodayLoaded(stats));

    // Sync the loaded level to onboardingCubit once on startup
    if (!_levelSyncedToOnboarding) {
      _levelSyncedToOnboarding = true;
      if (onboardingCubit.currentData.activityLevel != _activityLevel) {
        onboardingCubit.updateActivityLevel(_activityLevel);
        print('[ActivityCubit] synced saved level=$_activityLevel to onboardingCubit');
      }
    }

    // Pass total burned including HC calories to ProgressCubit
    // so the burned chart shows the correct value for today
    final totalBurned = (snap?.caloriesBurned ?? 0) + extraCalories;
    _progressCubit?.updateLocalBurned(totalBurned);
    _progressCubit?.updateLocalSteps(snap?.steps ?? 0);
    _progressCubit?.refresh();
  }

  // =====================================================
  // HELPERS
  // =====================================================

  bool _isHealthConnectId(String id) {
    if (id.startsWith('local_')) return false;
    final parsed = int.tryParse(id);
    if (parsed == null) return false;
    return parsed > 2147483647;
  }

  // =====================================================
  // CLOSE
  // =====================================================

  @override
  Future<void> close() {
    _midnightTimer?.cancel();
    return super.close();
  }
}