import 'package:health/health.dart';
import 'package:vital_metrics/data/models/activity_model.dart';

class FitnessSnapshot {
  final int steps;
  final int caloriesBurned;
  final int workoutMinutes;
  final List<ActivityModel> activities;

  const FitnessSnapshot({
    required this.steps,
    required this.caloriesBurned,
    required this.workoutMinutes,
    required this.activities,
  });
}

abstract class GoogleFitService {
  Future<FitnessSnapshot> getTodaySnapshot();
  Future<void> writeWater(int amountMl);
  Future<void> writeSleep(int durationMinutes);
  factory GoogleFitService() => RealGoogleFitService();
}

class MockGoogleFitService implements GoogleFitService {
  @override
  Future<FitnessSnapshot> getTodaySnapshot() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const FitnessSnapshot(
      steps: 5420, caloriesBurned: 320, workoutMinutes: 45, activities: [],
    );
  }
  @override Future<void> writeWater(int amountMl) async {}
  @override Future<void> writeSleep(int durationMinutes) async {}
}

class RealGoogleFitService implements GoogleFitService {
  final Health _health = Health();

  static const _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  static const _writeTypes = [
    HealthDataType.WATER,
    HealthDataType.SLEEP_ASLEEP,
  ];

  static final _allTypes = [..._readTypes, ..._writeTypes];

  static final _permissions = [
    ..._readTypes.map((_) => HealthDataAccess.READ),
    ..._writeTypes.map((_) => HealthDataAccess.READ_WRITE),
  ];

  Future<bool> _requestPermissions() async {
    try {
      final sdkStatus = await _health.getHealthConnectSdkStatus();
      print('Health Connect SDK status: $sdkStatus');

      if (sdkStatus != HealthConnectSdkStatus.sdkAvailable) {
        print('Health Connect not available: $sdkStatus');
        return false;
      }

      await _health.configure();

      final alreadyGranted = await _health.hasPermissions(
        _allTypes,
        permissions: _permissions,
      );

      if (alreadyGranted == true) {
        print('Health Connect permissions already granted');
        return true;
      }

      final granted = await _health.requestAuthorization(
        _allTypes,
        permissions: _permissions,
      );

      print('Health Connect permissions granted: $granted');
      return granted;
    } catch (e) {
      print('Error requesting Health Connect permissions: $e');
      return false;
    }
  }

  @override
  Future<FitnessSnapshot> getTodaySnapshot() async {
    try {
      final granted = await _requestPermissions();
      if (!granted) {
        return const FitnessSnapshot(
          steps: 0, caloriesBurned: 0, workoutMinutes: 0, activities: [],
        );
      }

      final now      = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final data = await _health.getHealthDataFromTypes(
        types:     _readTypes,
        startTime: midnight,
        endTime:   now,
      );

      final cleaned = _health.removeDuplicates(data);

      int steps       = 0;
      int calories    = 0;
      int workoutMins = 0;
      final activities = <ActivityModel>[];

      for (final point in cleaned) {
        try {
          switch (point.type) {
            case HealthDataType.STEPS:
              steps += (point.value as NumericHealthValue).numericValue.toInt();

            case HealthDataType.ACTIVE_ENERGY_BURNED:
              calories += (point.value as NumericHealthValue).numericValue.toInt();

            case HealthDataType.WORKOUT:
              final mins = point.dateTo.difference(point.dateFrom).inMinutes;
              workoutMins += mins;

              String workoutType = 'Workout';
              if (point.value is WorkoutHealthValue) {
                workoutType = (point.value as WorkoutHealthValue).workoutActivityType.name;
              }

              int workoutCalories = 0;
              if (point.value is NumericHealthValue) {
                workoutCalories = (point.value as NumericHealthValue).numericValue.toInt();
              }

              activities.add(ActivityModel(
                id:              '${point.dateFrom.millisecondsSinceEpoch}',
                type:            _formatWorkoutType(workoutType),
                durationMinutes: mins,
                caloriesBurned:  workoutCalories,
                timestamp:       point.dateFrom,
              ));

            default:
              break;
          }
        } catch (e) {
          print('Error processing health point: $e');
          continue;
        }
      }

      // If Health Connect has no active energy burned data,
      // estimate calories from steps (avg 0.04 kcal per step)
      final estimatedCalories = calories > 0 ? calories : (steps * 0.04).round();

      return FitnessSnapshot(
        steps:          steps,
        caloriesBurned: estimatedCalories,
        workoutMinutes: workoutMins,
        activities:     activities,
      );
    } catch (e) {
      print('Error fetching health data: $e');
      return const FitnessSnapshot(
        steps: 0, caloriesBurned: 0, workoutMinutes: 0, activities: [],
      );
    }
  }

  @override
  Future<void> writeWater(int amountMl) async {
    try {
      final granted = await _requestPermissions();
      if (!granted) return;

      final now = DateTime.now();
      await _health.writeHealthData(
        value:     amountMl / 1000.0,
        type:      HealthDataType.WATER,
        startTime: now,
        endTime:   now,
        unit:      HealthDataUnit.LITER,
      );
      print('Water written: $amountMl ml');
    } catch (e) {
      print('Failed to write water: $e');
    }
  }

  @override
  Future<void> writeSleep(int durationMinutes) async {
    try {
      final granted = await _requestPermissions();
      if (!granted) return;

      final now        = DateTime.now();
      final sleepStart = now.subtract(Duration(minutes: durationMinutes));

      await _health.writeHealthData(
        value:     durationMinutes.toDouble(),
        type:      HealthDataType.SLEEP_ASLEEP,
        startTime: sleepStart,
        endTime:   now,
        unit:      HealthDataUnit.MINUTE,
      );
      print('Sleep written: $durationMinutes minutes');
    } catch (e) {
      print('Failed to write sleep: $e');
    }
  }

  String _formatWorkoutType(String type) {
    return type
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}