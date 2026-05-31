import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/data/models/activity_model.dart';

class FitnessActivity {
  final String name;
  final int caloriesBurned;
  final int durationMinutes;

  FitnessActivity({
    required this.name,
    required this.caloriesBurned,
    required this.durationMinutes,
  });
}

class FitnessSnapshot {
  final int steps;
  final int caloriesBurned;
  final int workoutMinutes;
  final List<ActivityModel> activities;

  FitnessSnapshot({
    required this.steps,
    required this.caloriesBurned,
    required this.workoutMinutes,
    required this.activities,
  });
}

class GoogleFitService {
  final Health _health = Health();

  bool? _cachedPermission;
  bool _configured = false;

  // =====================================================
  // CONFIGURE
  // =====================================================

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  // =====================================================
  // PERMISSIONS
  // Checks steps preference FIRST before anything else
  // so that disabling HC is respected immediately
  // =====================================================

  Future<bool> requestPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check steps preference first before any cache check
      // If user disabled HC tracking return false immediately
      final stepsEnabled = prefs.getBool('hc_steps_enabled') ?? true;
      if (!stepsEnabled) {
        print('[Health] steps tracking disabled by user');
        _cachedPermission = false;
        return false;
      }

      // Check memory cache
      if (_cachedPermission == true) return true;

      // Check persisted permission
      final persistedGranted =
          prefs.getBool('hc_permission_granted') ?? false;
      if (persistedGranted) {
        _cachedPermission = true;
        return true;
      }

      await _ensureConfigured();

      final types = [
        HealthDataType.STEPS,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.WATER,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.WORKOUT,
      ];

      final permissions = [
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ_WRITE,
        HealthDataAccess.READ_WRITE,
        HealthDataAccess.READ,
      ];

      final hasPermissions =
          await _health.hasPermissions(types, permissions: permissions) ??
              false;

      if (hasPermissions) {
        _cachedPermission = true;
        await prefs.setBool('hc_permission_granted', true);
        print('[Health] permissions already granted');
        return true;
      }

      final granted = await _health.requestAuthorization(
          types, permissions: permissions);
      _cachedPermission = granted;
      await prefs.setBool('hc_permission_granted', granted);
      print('[Health] permission granted = $granted');
      return granted;
    } catch (e) {
      print('[Health] permission error: $e');
      return false;
    }
  }

  // =====================================================
  // TODAY SNAPSHOT
  // =====================================================

  Future<FitnessSnapshot> getTodaySnapshot() async {
    try {
      final granted = await requestPermissions();

      if (!granted) {
        return FitnessSnapshot(
            steps: 0, caloriesBurned: 0, workoutMinutes: 0, activities: []);
      }

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      int steps = 0;
      int calories = 0;
      int workoutMinutes = 0;
      final List<ActivityModel> activities = [];

      // Steps
      try {
        final totalSteps =
            await _health.getTotalStepsInInterval(start, now);
        steps = (totalSteps ?? 0).clamp(0, 999999);
      } catch (e) {
        print('[Health] steps error: $e');
      }

      // Calories
      try {
        final caloriesData = await _health.getHealthDataFromTypes(
          startTime: start,
          endTime: now,
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        );
        double total = 0;
        for (final point in caloriesData) {
          try {
            final value = point.value;
            if (value is NumericHealthValue) {
              total += value.numericValue.toDouble();
            }
          } catch (_) {}
        }
        calories = total.round().clamp(0, 99999);
      } catch (e) {
        print('[Health] calories error: $e');
      }

      // Workouts
      try {
        final workouts = await _health.getHealthDataFromTypes(
          startTime: start,
          endTime: now,
          types: [HealthDataType.WORKOUT],
        );

        final uniqueWorkouts = <String, HealthDataPoint>{};
        for (final workout in workouts) {
          final key =
              '${workout.dateFrom.millisecondsSinceEpoch}_${workout.dateTo.millisecondsSinceEpoch}';
          uniqueWorkouts[key] = workout;
        }

        for (final workout in uniqueWorkouts.values) {
          final duration = workout.dateTo.difference(workout.dateFrom);
          final mins = duration.inMinutes;
          if (mins <= 0 || mins > 600) continue;

          workoutMinutes += mins;

          int workoutCalories = 0;
          try {
            final value = workout.value;
            if (value is NumericHealthValue) {
              workoutCalories = value.numericValue.round();
            }
          } catch (_) {}

          String workoutType = 'Workout';
          try {
            workoutType = workout.value.toString();
          } catch (_) {}

          activities.add(ActivityModel(
            id: 'hc_${workout.dateFrom.millisecondsSinceEpoch}',
            type: _formatWorkoutName(workoutType),
            durationMinutes: mins,
            caloriesBurned: workoutCalories,
            timestamp: workout.dateFrom,
          ));
        }
      } catch (e) {
        print('[Health] workouts error: $e');
      }

      print('[Health] SUCCESS => steps=$steps calories=$calories '
          'workouts=$workoutMinutes activities=${activities.length}');

      return FitnessSnapshot(
        steps: steps,
        caloriesBurned: calories,
        workoutMinutes: workoutMinutes,
        activities: activities,
      );
    } catch (e) {
      print('[Health] snapshot fatal error: $e');
      return FitnessSnapshot(
          steps: 0, caloriesBurned: 0, workoutMinutes: 0, activities: []);
    }
  }

  // =====================================================
  // FORMAT WORKOUT NAME
  // =====================================================

  String _formatWorkoutName(String raw) {
    final cleaned = raw
        .replaceAll('_', ' ')
        .replaceAll('HealthWorkoutActivityType.', '')
        .toLowerCase();
    return cleaned
        .split(' ')
        .map((e) =>
            e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }

  // =====================================================
  // WRITE WATER
  // =====================================================

  Future<bool> writeWater(int ml) async {
    try {
      final granted = await requestPermissions();
      if (!granted) return false;
      if (ml <= 0) return false;

      final now = DateTime.now();
      final end = now.add(const Duration(seconds: 1));
      final liters = ml / 1000;

      final result = await _health.writeHealthData(
        value: liters,
        type: HealthDataType.WATER,
        startTime: now,
        endTime: end,
      );

      print('[Health] writeWater result = $result');
      return result;
    } catch (e) {
      print('[Health] writeWater error: $e');
      return false;
    }
  }

  // =====================================================
  // WRITE SLEEP
  // =====================================================

  Future<bool> writeSleep({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final granted = await requestPermissions();
      if (!granted) return false;
      if (!end.isAfter(start)) return false;

      final result = await _health.writeHealthData(
        value: 1,
        type: HealthDataType.SLEEP_ASLEEP,
        startTime: start,
        endTime: end,
      );

      print('[Health] writeSleep result = $result');
      return result;
    } catch (e) {
      print('[Health] writeSleep error: $e');
      return false;
    }
  }

  // =====================================================
  // CLEAR PERMISSION CACHE
  // Resets memory cache so next requestPermissions call
  // reads fresh values from SharedPreferences
  // =====================================================

  void clearPermissionCache() {
    _cachedPermission = null;
  }

  Future<void> clearPermissionCacheAndPersisted() async {
    _cachedPermission = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hc_permission_granted');
  }
}