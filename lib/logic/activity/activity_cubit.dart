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

const _kOriginalTypesKey = 'activity_original_types';
const _kActivityLevelKey = 'activity_level';
const _kCachedActivities = 'activity_cached_list';
const _kCachedDate       = 'activity_cached_date';

class ActivityCubit extends Cubit<ActivityState> {
  final OnboardingCubitAllData onboardingCubit;

  final ActivityRepository _activityRepo;
  final GoogleFitService _fitService = GoogleFitService();

  ProgressCubit? _progressCubit;

  void setProgressCubit(ProgressCubit cubit) {
    _progressCubit = cubit;
  }

  late ActivityLevel _activityLevel;

  final List<ActivityModel> _localActivities = [];
  final Map<String, String> _originalTypes = {};

  FitnessSnapshot? _lastSnapshot;

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

    await _loadCachedActivities();
    await _load();
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

      // ← يوم جديد: امسح الكاش من الديسك والميموري
      if (cached != today) {
        await prefs.remove(_kCachedActivities);
        await prefs.remove(_kCachedDate);
        _localActivities.clear(); // ← الإصلاح: امسح الميموري كمان
        print('[ActivityCubit] new day detected — cleared cached activities');
        return;
      }

      final raw = prefs.getString(_kCachedActivities);
      if (raw == null) return;

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
  // PUBLIC API
  // =====================================================

  Future<void> refresh() async {
    // ← تحقق من اليوم عند كل refresh عشان لو التطبيق فضل شغال بعد منتصف الليل
    await _checkAndResetIfNewDay();
    await _load();
  }

  // ← إصلاح: تحقق من التاريخ عند كل فتح للـ screen
  Future<void> _checkAndResetIfNewDay() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final cached = prefs.getString(_kCachedDate);
      final today  = _todayStr();

      if (cached != null && cached != today) {
        await prefs.remove(_kCachedActivities);
        await prefs.remove(_kCachedDate);
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
        type: originalType,
        durationMinutes: activity.durationMinutes,
        caloriesBurned: activity.caloriesBurned,
        date: activity.timestamp,
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

    // Health Connect
    try {
      final snapshot = await _fitService.getTodaySnapshot();
      _lastSnapshot = snapshot;
      print('[ActivityCubit] snapshot loaded: steps=${snapshot.steps}');
    } catch (e) {
      print('[ActivityCubit] Health Connect failed (non-fatal): $e');
    }

    // Backend activities
    try {
      final backendActivities = await _activityRepo.getActivities();

      _localActivities.clear();

      final restored = backendActivities.map((a) {
        final originalType = _originalTypes[a.id];
        return originalType != null ? a.copyWith(type: originalType) : a;
      }).toList();

      _localActivities.addAll(restored);
      await _saveCachedActivities();

      print('[ActivityCubit] backend activities loaded: ${restored.length}');
    } catch (e) {
      print('[ActivityCubit] backend activities failed: $e');

      if (_localActivities.isNotEmpty) {
        print('[ActivityCubit] using ${_localActivities.length} cached activities');
        _rebuildLoaded();
        return;
      }

      emit(TodayError('Failed to load activity data\n${e.toString()}'));
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
    final localOnly =
        _localActivities.where((a) => !_isHealthConnectId(a.id));

    final extraCalories =
        localOnly.fold<int>(0, (s, a) => s + a.caloriesBurned);
    final extraMinutes =
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

    _progressCubit?.updateLocalBurned(extraCalories);
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
}